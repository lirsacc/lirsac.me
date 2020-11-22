// ----------------------------------------------------------------------------
// Dark/Light theme handling.
// ----------------------------------------------------------------------------

// WARN: This should be loaded before any content is rendered to avoid flashing
// of the theme., ideally at the top of the <body> tag.

let theme;

// Prefer user-stored preferences if possible.
try {
  theme = localStorage.getItem("theme");
} catch (e) {}

// Respect OS / Browser level preferences.
if (!theme) {
  try {
    if (window.matchMedia("prefer-color-scheme: dark").matches) {
      theme = "dark";
    } else if (window.matchMedia("prefer-color-scheme: light").matches) {
      theme = "light";
    } else {
      theme = "auto";
    }
  } catch (e) {
    theme = "auto";
  }
}

document.body.dataset.theme = theme;

// This can be run later.
function registerThemeSwitcher() {
  for (const el of document.querySelectorAll(".theme-switcher button")) {
    el.addEventListener("click", (evt) => {
      const nextTheme = evt.currentTarget.dataset.theme;
      document.body.dataset.theme = nextTheme || "auto";
      try {
        localStorage.setItem("theme", nextTheme);
      } catch (e) {}
    });
  }

  // Show the switcher now that it can work.
  for (const el of document.getElementsByClassName("theme-switcher")) {
    el.style.display = "initial";
  }
}

// ----------------------------------------------------------------------------
// Scroll detection
// ----------------------------------------------------------------------------

function registerScrollDetection() {
  const el = document.createElement("div");
  el.style.position = "absolute";
  el.style.width = "1px";
  el.style.height = "1px";
  el.style.top = "100px";
  el.style.left = "0";
  document.body.appendChild(el);
  if (
    "IntersectionObserver" in window &&
    "IntersectionObserverEntry" in window &&
    "intersectionRatio" in window.IntersectionObserverEntry.prototype
  ) {
    let observer = new IntersectionObserver((entries) => {
      if (entries[0].boundingClientRect.y < 0) {
        document.body.classList.add("has-scrolled");
      } else {
        document.body.classList.remove("has-scrolled");
      }
    });
    observer.observe(el);
  }
}

// ----------------------------------------------------------------------------
// Footnotes
// ----------------------------------------------------------------------------

// Zola doesn't generate backreferences on footnotes, which is an issue with
// pulldown-cmark (see: https://github.com/raphlinus/pulldown-cmark/issues/142).
// A static solution would be nicer though.

function generateFootnotsBackReferences() {
  for (const referenceElement of document.getElementsByClassName(
    "footnote-reference"
  )) {
    const targetId = referenceElement.firstChild
      .getAttribute("href")
      .replace(/^#/, "");

    const refId = `footnote-reference-${targetId}`;

    const targetEl = document.getElementById(targetId);

    if (!targetEl) {
      console.warn(`Cannot find footnote with id ${targetId}`);
      continue;
    }

    const labelEl = targetEl.firstChild;

    referenceElement.id = `${referenceElement.id} ${refId}`.replace(/^\s+/, "");

    const link = document.createElement("a");
    link.text = labelEl.innerText;
    link.href = `#${refId}`;
    link.classList = labelEl.classList;

    targetEl.replaceChild(link, labelEl);
  }
}

// ----------------------------------------------------------------------------
function init() {
  for (const fn of [
    registerThemeSwitcher,
    registerScrollDetection,
    generateFootnotsBackReferences,
  ]) {
    try {
      fn();
    } catch (e) {
      console.error(e);
    }
  }
}

if (document.readyState != "loading") {
  init();
} else {
  document.addEventListener("DOMContentLoaded", init);
}
