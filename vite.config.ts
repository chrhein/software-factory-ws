import { defineConfig } from "vite";
import { execSync } from "node:child_process";
import { octane } from "octane/compiler/vite";
import tailwindcss from "@tailwindcss/vite";

// The "Meld inn en feil" (report a bug) button needs to know which GitHub repo the app belongs to.
// The browser cannot read git, so we look up the remote when Vite starts.
function githubRepo(): string {
  try {
    const url = execSync("git remote get-url origin", { encoding: "utf8" }).trim();
    return url.match(/github\.com[:/](.+?\/.+?)(?:\.git)?$/)?.[1] ?? "";
  } catch {
    return "";
  }
}

export default defineConfig({
  plugins: [octane(), tailwindcss()],
  define: { "import.meta.env.VITE_GITHUB_REPO": JSON.stringify(githubRepo()) },
  build: { target: "esnext" },
});
