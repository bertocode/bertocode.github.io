/** @typedef {{load: (Promise<unknown>); flags: (unknown)}} ElmPagesInit */

const isLightMode = () => {
  return (
    localStorage.theme === "light" ||
    (!("theme" in localStorage) &&
      window.matchMedia("(prefers-color-scheme: light)").matches)
  );
}

const toggleTheme = () => {
  if (isLightMode()) {
    localStorage.setItem("theme", "dark");
  } else {
    localStorage.setItem("theme", "light");
  }
  applyLightModeClass()
}

const applyLightModeClass = () => {
  if (isLightMode()) {
    document.documentElement.classList.add("light")
    document.documentElement.classList.remove("dark")
  } else {
    document.documentElement.classList.remove("light")
    document.documentElement.classList.add("dark")
  }
}

/** @type ElmPagesInit */
export default {
  load: async function (elmLoaded) {
    applyLightModeClass();
    const app = await elmLoaded;
    app.ports.toggleTheme.subscribe(() => toggleTheme());
  },
  flags: function () {
    return {
      theme: isLightMode(),
    };
  },
};