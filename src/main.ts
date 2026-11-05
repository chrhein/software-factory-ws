import { createRoot } from "octane";
import posthog from "posthog-js";
import { App } from "./App.tsrx";

const key = import.meta.env.VITE_POSTHOG_KEY;
if (key) {
  posthog.init(key, {
    api_host: import.meta.env.VITE_POSTHOG_HOST ?? "https://eu.i.posthog.com",
    capture_exceptions: true,
  });
}

createRoot(document.getElementById("root")!).render(App);
