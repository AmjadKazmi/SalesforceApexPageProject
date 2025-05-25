import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "Playwright",
  reporter: "html",
  use: {
    headless: false, // you can watch it run
    baseURL: process.env.BASE_URL
  },
  projects: [{ name: "chromium" }]
});

// /** to use same installed browser available in system */
// import { defineConfig, FullConfig } from "@playwright/test";
// export default defineConfig({
//   globalSetup: require.resolve("./scripts/global-setup.js"),
//   testDir: "Playwright",
//   timeout: 60_000,
//   use: {
//     headless: false,
//     channel: "chrome",
//     launchOptions: {
//       // Use the cloned profile prepared in globalSetup
//       userDataDir: "tmp-profile"
//     },
//     baseURL: process.env.BASE_URL
//     // Do not use storageState since full userDataDir is used
//   },
//   projects: [
//     {
//       name: "chrome-with-cloned-profile",
//       use: {
//         // Inherit use context from above
//       }
//     }
//   ]
// });
