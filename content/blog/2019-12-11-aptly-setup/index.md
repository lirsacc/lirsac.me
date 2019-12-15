+++
title = "Hosting and distributing Debian packages with aptly and S3"
slug = "hosting-and-distributing-debian-packages-with-aptly-and-s3"
date = 2019-12-11
template = "post.html"
+++

<aside>

This article was originally published on [Threads' engineering blog](https://thread.engineering/2019-12-11-aptly-setup/).

</aside>

This article describes Thread’s current setup for hosting and distributing Debian packages. We’ll first explain why we ended up with this setup and provide steps necessary to replicate it as well as a high level cost overview.

### Context & Goals

We currently distribute most of our Python applications to production as Debian packages. This is native to our distribution of choice (Debian), and offers clear advantages such as dependency resolution between packages and integration with `systemd`.

We previously used a hosted service called Aptnik to distribute private packages. This worked well for some years, unfortunately it was discontinued earlier this year, leading us to evaluate alternatives.

Our application delivery process is rather simple [^1]:

1. On successful CI build, we upload the package(s) to the apt repository.
2. We release by ssh-ing into production machines and installing the latest version.

As such the requirements were mainly:

1. Provide a simple & safe mechanism for uploading new package versions.
2. Securely & reliably serve the packages to our infrastructure (bare metal and cloud VMs).

Our first approach was to look at other fully managed products such as [PackageCloud](https://packagecloud.io/) or [Cloudsmith](https://cloudsmith.io/) to minimise the required engineering effort and operational overhead. 
Our trial of PackageCloud indicated that their upload API was eventually consistent (leading to unreliable releases) and that this would be too costly [^2] for our use case. We decided to look at hosting our packages on our own infrastructure and settled on using [Aptly](https://www.aptly.info/) (an open source application built to maintain local apt repositories) and serving packages through Amazon S3.

### The setup

We'll detail here how we are running the aptly service and how we interact with it from our machines.

You'll need a valid [aptly configuration file](https://www.aptly.info/doc/configuration/) and GPG key as well as an [Ansible ](https://www.ansible.com/) controlled machine to run the aptly API and an [S3 bucket](https://aws.amazon.com/s3/).

#### Running Aptly

As for most of our infrastructure, everything is setup through Ansible and configured to run through `systemd`:

<details class="expandable-code">

<summary>Ansible role</summary>

```yaml
---
# Group and user to run under
- name: Ensure "aptly" group exists
  group:
    name: aptly
    state: present

- name: Add "aptly" user
  user:
    name: aptly
    group: aptly

- name: Import aptly repository key
  apt_key:
    id=ED75B5A4483DA07C
    keyserver=hkp://p80.pool.sks-keyservers.net:80
    state=present

- name: Add aptly repository
  apt_repository:
    repo="deb http://repo.aptly.info/ squeeze main"

- name: Install required packages
  apt:
    pkg={{ item }}
    update_cache=yes
  with_items:
    # See: https://www.aptly.info/doc/feature/pgp-providers/
    - gnupg1
    - gpgv1
    - aptly

- name: /var/lib/aptly
  file:
    path=/var/lib/aptly
    state=directory
    group=aptly
    owner=aptly

- name: Copy public key
  copy:
    src: ../files/key.pub
    dest: /var/lib/aptly/key.pub
    group: aptly
    owner: aptly

- name: Copy secret key
  copy:
    src: ../files/key.sec
    dest: /var/lib/aptly/key.sec
    group: aptly
    owner: aptly

# This needs to use gpg1 so the correct keyring is used and aptly can pick up
# on the keys later on.
- name: Import public key to gpg
  command: gpg1 --import /var/lib/aptly/key.pub
  become: yes
  become_user: aptly

- name: Import secret key to gpg
  command: gpg1 --import /var/lib/aptly/key.sec
  become: yes
  become_user: aptly
  # Ignore 'already in secret keyring' error
  ignore_errors: yes

- name: /etc/aptly.conf
  template:
    src=aptly.conf
    dest=/etc/aptly.conf
    mode=644
    group=aptly
    owner=aptly

- name: aptly.service
  template:
    src=aptly.service
    dest=/etc/systemd/system/aptly.service
    mode=644
  notify:
    restart aptly

- name: cleanup.sh
  template:
    src=cleanup.sh
    dest=/var/lib/aptly/cleanup.sh
    mode=755

- name: aptly-cleanup.service
  template:
    src={{ item }}
    dest=/etc/systemd/system/{{ item }}
    mode=644
  with_items:
    - aptly-cleanup.service
    - aptly-cleanup.timer

- name: certbot for ${YOUR_APRLY_DOMAIN} certificate
  include_role:
    name: geerlingguy-certbot
  vars:
    certbot_create_standalone_stop_services:
    - nginx
    certbot_auto_renew_options: --quiet --no-self-upgrade --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"
    certbot_certs:
    - domains:
      - ${YOUR_APRLY_DOMAIN}

- name: /etc/nginx/aptly.htpasswd
  copy:
    src=../files/aptly.htpasswd
    dest=/etc/nginx/aptly.htpasswd
    mode=644

- name: /etc/nginx/sites-enabled/aptly
  template:
    src=nginx.conf
    dest=/etc/nginx/sites-enabled/aptly
    mode=644
  notify:
    restart nginx

- name: running
  service:
    name=aptly
    state=started
    enabled=yes

- name: enable cleanup timer
  service:
    name: aptly-cleanup.timer
    state: started
    enabled: yes
```

</details>

<details class="expandable-code">

<summary>aptly.service unit file</summary>

```
[Unit]
Description=Aptly API
ConditionPathExists=/etc/aptly.conf

[Service]
Type=simple
WorkingDirectory=/var/lib/aptly
ExecStart=/usr/bin/aptly api serve -listen "localhost:{{ aptly_api_port }}" -no-lock
Restart=always
SyslogIdentifier=aptly
User=aptly

[Install]
WantedBy=multi-user.target
```

</details>

All the steps should be fairly self explanatory and reproducible outside of Ansible; but we'll expand on the details of the more custom parts of the setup.

- The aptly API is exposed behind an nginx proxy and secured through HTTPS (using Let's Encrypt) and basic authentication. This provides some level of security when accessing it from our CI provider which is where packages are uploaded from:

  <details class="expandable-code">

  <summary>/etc/nginx/sites-enabled/aptly</summary>

  ```nginx
  server {
    server_name     ${YOUR_APTLY_DOMAIN}

    listen          80;

    return          301 https://$server_name$request_uri;
  }

  server {
    listen          443 ssl;
    server_name     ${YOUR_APTLY_DOMAIN}

    # HTTPS certificates
    ssl_certificate     /etc/letsencrypt/live/${YOUR_APTLY_DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${YOUR_APTLY_DOMAIN}/privkey.pem;

    # We upload debs through this server hence the large size limit.
    client_max_body_size      500M;

    # Expose public key for clients
    location /gpgkey {
      alias /var/lib/aptly/key.pub;
    }

    location / {

      auth_basic              "Restricted";
      auth_basic_user_file    /etc/nginx/aptly.htpasswd;

      proxy_redirect          off;

      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto $scheme;

      proxy_pass              http://localhost:{{ aptly_api_port }}/;
      proxy_read_timeout      300;

      proxy_redirect          default;
    }
  }
  ```

  </details>

- As we release quite often, we setup the following script to routinely drop old versions of our packages and keep storage needs under control. This gives us enough versions to promote older packages for short term rollbacks. For longer term rollbacks we can rebuild from scratch or recover older packages from backups.

  <details class="expandable-code">

  <summary>cleanup.sh</summary>

  ```bash
  #!/usr/bin/env bash

  # Cleanup task to ensure the repository does not grow too much.
  # This uses the CLI and not the API and is meant to run on the machine
  # hosting the aptly db.

  set -eu -o pipefail

  REPO="${APTLY_REPO_NAME}"
  MAX_VERSIONS=20
  ENDPOINT="s3:${S3_BUCKET}:${PATH_PREFIX}/"

  deleted=false

  # Extract unique package ids currently known in the repo, these include the
  # version number and architecture hence the sed + filter to list all unique
  # packages by name.
  packages=$(aptly repo search ${REPO} | sed -E 's/_[0-9]+_all//' | uniq)

  for package in ${packages}; do
    echo "Processing ${package}"

    versions=$(aptly repo search ${REPO} "${package}" | sed -E 's/[^0-9]//g')
    version_count=$(echo "${versions}" | wc -w)

    echo "- ${version_count} versions found"

    if [ "$version_count" -le "$MAX_VERSIONS" ]; then
      echo "- Not cleaning up ${package}"
    else
      echo "- Cleaning up $() ${package}"

      # There must be a better way to do this...
      highmark=$(for x in $versions; do echo "$x"; done | sort -V -r | tail -n +"${MAX_VERSIONS}" | head -1)

      # See https://www.aptly.info/doc/feature/query/ for details on how the query works.
      aptly repo remove ${REPO} "${package} (<< ${highmark})"

      deleted=true
    fi
  done

  if [ "$deleted" = true ] ; then
    # Removed dangling references
    aptly db cleanup
    # Assuming the repo had been published already, this will just update the remote
    aptly publish update any "${ENDPOINT}"
  fi
  ```

  </details>

  <details class="expandable-code">

  <summary>aptly-cleanup.service</summary>

  ```
  [Unit]
  Description=Cleanup old versions from Aptly repo
  ConditionPathExists=/var/lib/aptly/cleanup.sh

  [Service]
  Type=oneshot
  WorkingDirectory=/var/lib/aptly
  ExecStart=/var/lib/aptly/cleanup.sh
  SyslogIdentifier=aptly
  User=aptly

  [Install]
  WantedBy=multi-user.target
  ```

  </details>

  <details class="expandable-code">
  <summary>aptly-cleanup.timer</summary>

  ```
  [Unit]
  Description=Cleanup old versions from Aptly repo

  [Timer]
  OnCalendar=daily
  Persistent=true

  [Install]
  WantedBy=timers.target
  ```

  </details>

- Omitted from the Ansible role are monitoring & backup configurations used for added reliability.

#### Uploading packages

Now that we have a running aptly API, we start uploading packages. We use the following script after building debs and storing all the packages in a single directory.

<details class="expandable-code">

<summary>upload-debs.sh</summary>

```bash
#!/usr/bin/env bash

set -xeu

APTLY_URL="https://${BASIC_AUTH}@${YOUR_APTLY_DOMAIN}"
APTLY_STAGE_DIRECTORY="${STAGE_DIRECTORY}"
APTLY_CURL_FLAGS="--include --fail"

for f in *deb; do
    # Upload the file to staging area of aptly. This does not publish the package.
    curl ${APTLY_CURL_FLAGS} --form "file=@${f}" --request POST "${APTLY_URL}/api/files/${APTLY_STAGE_DIRECTORY}"
done

# Tell aptly to include all the staged files from the stage directory
# into the repo. This will include any file put there so make sure no
# other process stages files there to avoid conflicts with other CI processes.
curl ${APTLY_CURL_FLAGS} --request POST "${APTLY_URL}/api/repos/${APTLY_REPO}/file/${APTLY_STAGE_DIRECTORY}"

# Tell aptly to publish the repo to S3. This will lock so only one CI process owns the operation.
curl ${APTLY_CURL_FLAGS} --request PUT "${APTLY_URL}/api/publish/s3:${S3_BUCKET}:${PATH_PREFIX}/" \
     --header 'Content-Type: application/json' \
     --data '{}'
```

</details>

The only tricky part is using a separate stage directory for each set of related packages. This is necessary to avoid race conditions when multiple CI processes upload simultaneously.

This is more than one step, but it is reliable and ensures that releasing dependent packages is done in a single, consistent, operation, that is once the above script exits successfully, we know that all the new versions will be available to our machines. 

This was important as some hosted solutions would not provide a consistent upload endpoint and instead released on a timer leading to inconsistent and delayed releases. In practice this showed up as not all the uploaded packages being available when we updated running machines which lead to incompatible versions and missed releases.

#### Downloading packages

Aptly itself is used to manage the repository (hierarchy, manifests, signing, etc.) and doesn't serve packages by default. We've chosen to expose our repository through S3 and download packages directly from there to benefit from AWS access control and reliability. On machines, we use [apt-transport-s3](https://github.com/MayaraCloud/apt-transport-s3).

The only thing required to get this to work was adding the following rules to our production machines Ansible role:

<details class="expandable-code">

<summary>Package downloader Ansible role</summary>

```yaml
- name: Thread Aptly GPG key
    get_url:
        url: https://${YOUR_APTLY_DOMAIN}/gpgkey
        dest: /etc/apt/trusted.gpg.d/thread.aptly.gpg.asc
        mode: '0644'
        
- name: apt-transport-s3
    action: apt
      pkg={{ item }}
      update_cache=yes
      default_release={{ debian_release }}
      cache_valid_time=43200
    with_items:
      - apt-transport-s3
      
- name: sources.list
    template:
      src=sources.list
      dest=/etc/apt/sources.list
      mode=0644
    notify:
      update APT cache

  - name: /etc/apt/s3auth.conf
    template:
        src=s3auth.conf
        dest=/etc/apt/s3auth.conf
        mode=0644
```

</details>

Where `s3auth.conf` contains your S3 credentials and `sources.list` contains the following line: `deb s3://${BUCKET_NAME}.s3.amazonaws.com/${PATH_PREFIX}/ any main`.

### Final cost estimate

As mentioned above, one of the main reasons to go with a self managed solution was to keep costs under control. So how are we doing now?

Our current costs can be broken into:

Hosting cost:

- We are hosting aptly on one of our existing VMs alongside other workloads which doesn't incur any extra cost for us. 
- Looking at resource usage, we could easily run this on a `t3.small` EC2 instance for less than $17 a month.

Storage cost:

- Our current aptly directory is around 15GB.
- Our VM similarly doesn't incur extra cost as we had enough free disk space to spare.
- This comes out at less than $1 in monthly S3 cost.
- If we were to host aptly on an EC2 instance, this would also come out at less than $1 per month for the required EBS volume.

Bandwidth cost:

- On average, we incur $4.5 per day for egress bandwidth from our bucket.
- This comes out as ~$140 per month which is around 1.5TB of egress. 

This cost is entirely incurred due to downloading packages onto our bare metal machines, which are not running in AWS. Our EC2 instances are within the same region as the S3 bucket, incurring no bandwidth cost. 

If we wanted to optimise our costs further, we could explore publishing the aptly repository to locations closer to our bare metal machine [^3]. That being said, while hosting on S3 does incur some cost, there are other non trivial benefits. The main one for us being reliability: our application delivery is split from our main infrastructure and should not be a blocker in a recovery scenario.

---

This setup has required little to no maintenance past the initial implementation and has proven easy to use for the engineering team. It provides significantly cheaper bandwidth than what similar plans on hosted services would offer, as well as stronger consistency guarantees. We've now been running it for almost 5 months and overall this has been well worth the extra effort.

---

[^1]: There are other considerations which add complexity when releasing software, but these are fairly orthogonal to the problem at hand.

[^2]: The main cost driver being bandwidth charges: our software packages can get quite large — in the order of 200-300MB — and with our current release frequency — around 10-15/day — this would have forced us into tiers above $700 per month (the highest advertised tier for PackageCloud).

[^3]: Aptly supports [publishing to the filesystem](https://www.aptly.info/doc/feature/filesystem/) at which point we can serve the repository through nginx alongside the API.
