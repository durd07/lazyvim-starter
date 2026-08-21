// terminal-browser --preload script: vim-style scrolling for the preview pane.
// terminal-browser has no extension support and no built-in scroll keys, so page
// keybindings live here. Runs in an isolated world, so it cannot collide with the
// page's own scripts. Note that terminal-browser registers preloads per Electron
// session, so this applies to every page in the same terminal-browser process.

const LINE = 80;
const PENDING_G_MS = 500;

let pendingG = false;

window.addEventListener(
  "keydown",
  (e) => {
    const target = e.target;
    if (target && (target.isContentEditable || /^(input|textarea|select)$/i.test(target.tagName || ""))) {
      return;
    }
    // leave modified keys to the browser itself
    if (e.ctrlKey || e.metaKey || e.altKey) {
      return;
    }

    const el = document.scrollingElement || document.documentElement;
    const page = window.innerHeight;

    switch (e.key) {
      case "j":
        el.scrollBy({ top: LINE });
        break;
      case "k":
        el.scrollBy({ top: -LINE });
        break;
      case "d":
        el.scrollBy({ top: page / 2 });
        break;
      case "u":
        el.scrollBy({ top: -page / 2 });
        break;
      case "f":
        el.scrollBy({ top: page });
        break;
      case "b":
        el.scrollBy({ top: -page });
        break;
      case "G":
        el.scrollTo({ top: el.scrollHeight });
        break;
      case "g":
        if (pendingG) {
          el.scrollTo({ top: 0 });
          pendingG = false;
        } else {
          pendingG = true;
          setTimeout(() => (pendingG = false), PENDING_G_MS);
        }
        e.preventDefault();
        return;
      default:
        return;
    }

    pendingG = false;
    e.preventDefault();
  },
  true,
);
