import { execSync } from "child_process";
import { join } from "path";
import dotenv from "dotenv";
dotenv.config();
// Load environment variables from .env file

const GIT_COMMAND = process.env.GIT_COMMAND || "git diff --name-only";

const diffOutput = execSync(`${GIT_COMMAND}`, {
  encoding: "utf8"
})
  .toString()
  .trim();
const changedFiles = diffOutput ? diffOutput.split(/\r?\n/) : [];

console.log("Changed files:", changedFiles);

//to run command in the root of the repo
function run(cmd) {
  console.log(`\n> ${cmd}`);
  execSync(cmd, { stdio: "inherit" });
}

const lwcChanges = new Set();
const apexChanges = new Set();

// Identify changed LWC components and Apex classes
changedFiles.forEach((file) => {
  let match;
  if ((match = file.match(/^force-app\/main\/default\/lwc\/([^\/]+)\//))) {
    lwcChanges.add(match[1]);
  } else if (
    (match = file.match(/^force-app\/main\/default\/classes\/([^\.]+)\.cls/))
  ) {
    apexChanges.add(match[1]);
  }
});

if (!lwcChanges.size && !apexChanges.size) {
  console.log("No LWC or Apex changes detected; exiting.");
  process.exit(0);
}

lwcChanges.forEach((component) => {
  console.log(`Running tests for LWC component: ${component}`);
});

apexChanges.forEach((className) => {
  console.log(`Running tests for Apex class: ${className}`);
});

console.log("Running a Playwright test cases for changed files...");

const baseURL = process.env.BASE_URL;
if (!baseURL) {
  console.error("BASE_URL environment variable is not set.");
  process.exit(1);
}

// Run tests for LWC changes
lwcChanges.forEach((comp) => {
  const testDir = join("Playwright", "lwc", comp);
  run(`npx playwright test ${testDir}`);
});

// Run tests for Apex changes
apexChanges.forEach((cls) => {
  const testFile = join("Playwright", "apex", `${cls}.spec.ts`);
  run(`npx playwright test ${testFile}`);
});

console.log("\n✅ Test execution complete.");
