// Dark/Light theme handling.

// WARN: This should be loaded before any content is rendered to avoid flashing
// of the theme., ideally at the top of the <body> tag.

var theme;

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

function registerThemeSwitcher() {
  for (var el of document.querySelectorAll(".theme-switcher button")) {
    el.addEventListener("click", (evt) => {
      var nextTheme = evt.currentTarget.dataset.theme;
      document.body.dataset.theme = nextTheme || "auto";
      try {
        localStorage.setItem("theme", nextTheme);
      } catch (e) {}
    });
  }

  for (var el of document.getElementsByClassName("theme-switcher")) {
    el.style.display = "initial";
  }
}

if (document.readyState != "loading") {
  registerThemeSwitcher();
} else {
  document.addEventListener("DOMContentLoaded", registerThemeSwitcher);
}
