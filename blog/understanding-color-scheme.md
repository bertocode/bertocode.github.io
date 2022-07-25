---
title: Understanding dark mode and prefers-color-scheme
tags: [dark-mode,javascript,colours]
date: 22-06-2022
---


When I started with the development of this web, I wanted to be able to toggle between dark and light theme. I was not very sure how it "really" worked, so decided to write the post to show the results of my findings.

First thing I understood is that if you set up in the css a media query using, the `prefers-color-scheme` you can get the information from the user.
This is if they prefer dark or light themes.

I know that as a user you can set up some kind of preference from options of the browser, also to enforce it between the different browsers using the code inspector or developer tools.

So I asked myself, I can change this property using javascript, so I can directly read `prefers-color-scheme` and that's it.

It seems that not directly.
There is not such a thing, my best guess, it is that for security reasons you would be updating attributes that would be read-only.

But there are some important things that can be spoken about:
- There is the possibility of using a meta tag color "theme-color" that allows in a limited amount of browsers to interact with the browser color, but it seems limited to PWA in chrome an iOS, Mac-Safari browsers [Can I use - Meta theme color](https://caniuse.com/meta-theme-color)

- It's common that developers in case of the `prefer-color-scheme` is not supported nor set, they will default to the light theme.

- It is also common, that after using  `prefers-color-scheme` query, there is some workaround using classes and/or css variables.

Let's see some examples:

- You can create [CSS custom properties/CSS variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties) on the root element, setting the font-color and body color based on the class set to the html Element.

```css
:root,
:root.dark {
  --bg-color: #28003a;
  --font-color: #fff;
}

  

:root.light {
  --bg-color: #debaff;
  --font-color: #000;
}

  

body {
  background-color: var(--bg-color);
  color : var(--font-color);
}
```

```js
document.querySelector('button').addEventListener('click',
  () => document.documentElement.classList.toggle('light')
);
```

 [Example to toggle theme with variables](https://codi.link/PCFET0NUWVBFIGh0bWw+DQo8aHRtbCBsYW5nPSJlbiI+DQo8aGVhZD4NCiAgPG1ldGEgY2hhcnNldD0iVVRGLTgiPg0KICA8bWV0YSBodHRwLWVxdWl2PSJYLVVBLUNvbXBhdGlibGUiIGNvbnRlbnQ9IklFPWVkZ2UiPg0KICA8bWV0YSBuYW1lPSJ2aWV3cG9ydCIgY29udGVudD0id2lkdGg9ZGV2aWNlLXdpZHRoLCBpbml0aWFsLXNjYWxlPTEuMCI+DQogIDx0aXRsZT5Eb2N1bWVudDwvdGl0bGU+DQo8L2hlYWQ+DQo8Ym9keT4NCiAgPGgxPlRoaXMgaXMgYSBkYXJrLWxpZ2h0IGV4YW1wbGU8L2gxPg0KICA8YnV0dG9uPkNoYW5nZSB0aGVtZTwvYnV0dG9uPg0KPC9ib2R5Pg0KPC9odG1sPg==|OnJvb3QsDQo6cm9vdC5kYXJrIHsNCiAgLS1iZy1jb2xvcjogIzI4MDAzYTsNCiAgLS1mb250LWNvbG9yOiAjZmZmOw0KfQ0KDQo6cm9vdC5saWdodCB7DQogIC0tYmctY29sb3I6ICNkZWJhZmY7DQogIC0tZm9udC1jb2xvcjogIzAwMDsNCn0NCg0KYm9keSB7DQogIGJhY2tncm91bmQtY29sb3I6IHZhcigtLWJnLWNvbG9yKTsNCiAgY29sb3IgOiB2YXIoLS1mb250LWNvbG9yKTsNCn0=|ZG9jdW1lbnQucXVlcnlTZWxlY3RvcignYnV0dG9uJykuYWRkRXZlbnRMaXN0ZW5lcignY2xpY2snLA0KICAoKSA9PiBkb2N1bWVudC5kb2N1bWVudEVsZW1lbnQuY2xhc3NMaXN0LnRvZ2dsZSgnbGlnaHQnKQ0KKTs=)

- To the previous example, you can also add the media query, to always default to the user choice. We can add after the `root.light selector`:

```css
@media (prefers-color-scheme:light){
  :root {
    --bg-color: #debaff;
    --font-color: #000;
  }
}
```
[Example to toggle theme with default for light theme](https://codi.link/PCFET0NUWVBFIGh0bWw+DQo8aHRtbCBsYW5nPSJlbiI+DQo8aGVhZD4NCiAgPG1ldGEgY2hhcnNldD0iVVRGLTgiPg0KICA8bWV0YSBodHRwLWVxdWl2PSJYLVVBLUNvbXBhdGlibGUiIGNvbnRlbnQ9IklFPWVkZ2UiPg0KICA8bWV0YSBuYW1lPSJ2aWV3cG9ydCIgY29udGVudD0id2lkdGg9ZGV2aWNlLXdpZHRoLCBpbml0aWFsLXNjYWxlPTEuMCI+DQogIDx0aXRsZT5Eb2N1bWVudDwvdGl0bGU+DQo8L2hlYWQ+DQo8Ym9keT4NCiAgPGgxPlRoaXMgaXMgYSBkYXJrLWxpZ2h0IGV4YW1wbGU8L2gxPg0KICA8YnV0dG9uPkNoYW5nZSB0aGVtZTwvYnV0dG9uPg0KPC9ib2R5Pg0KPC9odG1sPg==|OnJvb3QsDQo6cm9vdC5kYXJrIHsNCiAgLS1iZy1jb2xvcjogIzI4MDAzYTsNCiAgLS1mb250LWNvbG9yOiAjZmZmOw0KfQ0KDQo6cm9vdC5saWdodCB7DQogIC0tYmctY29sb3I6ICNkZWJhZmY7DQogIC0tZm9udC1jb2xvcjogIzAwMDsNCn0NCg0KQG1lZGlhIChwcmVmZXJzLWNvbG9yLXNjaGVtZTpsaWdodCl7DQogIDpyb290IHsNCiAgICAtLWJnLWNvbG9yOiAjZGViYWZmOw0KICAgIC0tZm9udC1jb2xvcjogIzAwMDsNCiAgfQ0KfQ0KDQpib2R5IHsNCiAgYmFja2dyb3VuZC1jb2xvcjogdmFyKC0tYmctY29sb3IpOw0KICBjb2xvciA6IHZhcigtLWZvbnQtY29sb3IpOw0KfQ==|ZG9jdW1lbnQucXVlcnlTZWxlY3RvcignYnV0dG9uJykuYWRkRXZlbnRMaXN0ZW5lcignY2xpY2snLA0KICAoKSA9PiBkb2N1bWVudC5kb2N1bWVudEVsZW1lbnQuY2xhc3NMaXN0LnRvZ2dsZSgnbGlnaHQnKQ0KKTs=)

- We can expand this decision by saving the user decision, once they have made the choice. We can use the LocalStorage API to achieve this. The css remains the same and now
```js
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

  

// Button to change current theme
document.querySelector('button').addEventListener('click',
  () => toggleTheme()
)
```

[Example where toggle theme is stored in LocalStorage](https://codi.link/PCFET0NUWVBFIGh0bWw+DQo8aHRtbCBsYW5nPSJlbiI+DQo8aGVhZD4NCiAgPG1ldGEgY2hhcnNldD0iVVRGLTgiPg0KICA8bWV0YSBodHRwLWVxdWl2PSJYLVVBLUNvbXBhdGlibGUiIGNvbnRlbnQ9IklFPWVkZ2UiPg0KICA8bWV0YSBuYW1lPSJ2aWV3cG9ydCIgY29udGVudD0id2lkdGg9ZGV2aWNlLXdpZHRoLCBpbml0aWFsLXNjYWxlPTEuMCI+DQogIDx0aXRsZT5FeGFtcGxlIGZvciBjb2xvciB0aGVtZTwvdGl0bGU+DQo8L2hlYWQ+DQo8Ym9keT4NCiAgPGgxPlRoaXMgaXMgYSBkYXJrLWxpZ2h0IGV4YW1wbGU8L2gxPg0KICA8YnV0dG9uPkNoYW5nZSB0aGVtZTwvYnV0dG9uPg0KPC9ib2R5Pg0KPC9odG1sPg0K|OnJvb3QsDQo6cm9vdC5kYXJrIHsNCiAgLS1iZy1jb2xvcjogIzI4MDAzYTsNCiAgLS1mb250LWNvbG9yOiAjZmZmOw0KfQ0KDQo6cm9vdC5saWdodCB7DQogIC0tYmctY29sb3I6ICNkZWJhZmY7DQogIC0tZm9udC1jb2xvcjogIzAwMDsNCn0NCg0KQG1lZGlhIChwcmVmZXJzLWNvbG9yLXNjaGVtZTpsaWdodCl7DQogIDpyb290IHsNCiAgICAtLWJnLWNvbG9yOiAjZGViYWZmOw0KICAgIC0tZm9udC1jb2xvcjogIzAwMDsNCiB9DQp9DQoNCmJvZHkgew0KICBiYWNrZ3JvdW5kLWNvbG9yOiB2YXIoLS1iZy1jb2xvcik7DQogIGNvbG9yIDogdmFyKC0tZm9udC1jb2xvcik7DQp9|Y29uc3QgaXNMaWdodE1vZGUgPSAoKSA9PiB7DQogIHJldHVybiAoDQogICAgbG9jYWxTdG9yYWdlLnRoZW1lID09PSAibGlnaHQiIHx8DQogICAgKCEoInRoZW1lIiBpbiBsb2NhbFN0b3JhZ2UpICYmDQogICAgICB3aW5kb3cubWF0Y2hNZWRpYSgiKHByZWZlcnMtY29sb3Itc2NoZW1lOiBsaWdodCkiKS5tYXRjaGVzKQ0KICApOw0KfQ0KDQpjb25zdCB0b2dnbGVUaGVtZSA9ICgpID0+IHsNCiAgaWYgKGlzTGlnaHRNb2RlKCkpIHsNCiAgICBsb2NhbFN0b3JhZ2Uuc2V0SXRlbSgidGhlbWUiLCAiZGFyayIpOw0KICB9IGVsc2Ugew0KICAgIGxvY2FsU3RvcmFnZS5zZXRJdGVtKCJ0aGVtZSIsICJsaWdodCIpOw0KICB9DQogIGFwcGx5TGlnaHRNb2RlQ2xhc3MoKQ0KfQ0KDQpjb25zdCBhcHBseUxpZ2h0TW9kZUNsYXNzID0gKCkgPT4gew0KICBpZiAoaXNMaWdodE1vZGUoKSkgew0KICAgIGRvY3VtZW50LmRvY3VtZW50RWxlbWVudC5jbGFzc0xpc3QuYWRkKCJsaWdodCIpDQogICAgZG9jdW1lbnQuZG9jdW1lbnRFbGVtZW50LmNsYXNzTGlzdC5yZW1vdmUoImRhcmsiKQ0KICB9IGVsc2Ugew0KICAgIGRvY3VtZW50LmRvY3VtZW50RWxlbWVudC5jbGFzc0xpc3QucmVtb3ZlKCJsaWdodCIpDQogICAgZG9jdW1lbnQuZG9jdW1lbnRFbGVtZW50LmNsYXNzTGlzdC5hZGQoImRhcmsiKQ0KICB9DQp9DQoNCmFwcGx5TGlnaHRNb2RlQ2xhc3MoKQ0KDQovLyBCdXR0b24gdG8gY2hhbmdlIGN1cnJlbnQgdGhlbWUNCmRvY3VtZW50LnF1ZXJ5U2VsZWN0b3IoJ2J1dHRvbicpLmFkZEV2ZW50TGlzdGVuZXIoJ2NsaWNrJywNCiAgKCkgPT4gdG9nZ2xlVGhlbWUoKQ0KKQ==)

Interesting link: https://webdesign.tutsplus.com/tutorials/color-schemes-with-css-variables-and-javascript--cms-36989