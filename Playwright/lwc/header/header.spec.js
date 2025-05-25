import { test, expect } from "@playwright/test";
import dotenv from "dotenv";
dotenv.config();

test("header component renders correctly", async ({ page }) => {
  await page.goto("/lightning/n/RV_Maintenance");

  await page
    .locator("input[type='email'][id='username']")
    .fill(process.env.SF_USERNAME);
  await page
    .locator("input[type='password'][id='password']")
    .fill(process.env.SF_PASSWORD);
  await page.locator("input[type='submit'][id='Login']").click();

  try {
    await page.waitForLoadState("networkidle", { timeout: 10000 });
  } catch (error) {
    console.warn("waitForLoadState('networkidle') failed:", error);
  }

  // Handle "Remind Me Later"
  try {
    const remindMeLater = page.locator("text=Remind Me Later");
    if (await remindMeLater.isVisible({ timeout: 3000 })) {
      console.log("'Remind Me Later' is visible. Clicking it...");
      await remindMeLater.click();
    } else {
      console.log("'Remind Me Later' not visible. Skipping.");
    }
  } catch (e) {
    console.warn("'Remind Me Later' check failed. Skipping.");
  }

  await page.waitForURL("**/lightning/n/RV_Maintenance", { timeout: 10000 });

  const header = page.locator("h2 > span");
  await expect(header).toBeVisible({ timeout: 10000 });
  await expect(header).toHaveText("Maintenance Requests");
});
