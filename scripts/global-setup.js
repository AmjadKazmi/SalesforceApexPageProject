// import { remove, copy } from "fs-extra";
// import { join } from "path";

// /**
//  * Playwright global setup:
//  * - Determines the real Chrome user profile directory
//  * - Clones it into a temporary folder to avoid locks on the live profile
//  */

// // Resolve the real Chrome profile based on OS
// function getRealProfilePath() {
//   const platform = process.platform;
//   if (platform === "darwin") {
//     // macOS
//     return join(
//       process.env.HOME,
//       "Library/Application Support/Google/Chrome/Default"
//     );
//   }
//   if (platform === "win32") {
//     // Windows
//     return join(
//       process.env.LOCALAPPDATA,
//       "Google",
//       "Chrome",
//       "User Data",
//       "Default"
//     );
//   }
//   // Linux fallback
//   return join(process.env.HOME, ".config/google-chrome/Default");
// }

// export default async () => {
//   const realProfile = getRealProfilePath();
//   const tempProfileRoot = join(__dirname, "..", "tmp-profile");

//   console.log(
//     `Cloning Chrome profile from ${realProfile} to ${tempProfileRoot}`
//   );
//   // Remove any existing temp profile
//   await remove(tempProfileRoot);
//   // Copy the entire profile folder
//   await copy(realProfile, tempProfileRoot);
// };
