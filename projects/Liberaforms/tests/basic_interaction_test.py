import os
import requests
from playwright.sync_api import sync_playwright, expect

BASE_URL = os.getenv("BASE_URL", "http://localhost")
ADMIN_EMAIL = "admin@example.org"
SUPER_PASSWD = "car-shop-in-the-mall"


def run_test():
    is_headful = os.getenv("HEADFUL") == "1"

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=not is_headful)
        context = browser.new_context(
            accept_downloads=True, record_video_dir="/tmp/videos/"
        )

        # Extended timeout for slow nixos test vms
        context.set_default_timeout(90 * 1000)

        #  1. Recovery & Registration
        print("Starting recovery and registration flow...")
        auth_page = context.new_page()
        auth_page.goto(f"{BASE_URL}/site/recover-password")

        auth_page.locator("input[name='email']").fill(ADMIN_EMAIL)
        auth_page.locator("button[type='submit']").click()
        auth_page.wait_for_url("**/user/new/*")

        auth_page.locator("input[name='username']").fill("superuser")
        # Grab both password inputs to cover the confirmation field
        auth_page.locator("input[type='password']").nth(0).fill(SUPER_PASSWD)
        auth_page.locator("input[type='password']").nth(1).fill(SUPER_PASSWD)
        auth_page.locator("button[type='submit']").click()

        auth_page.wait_for_url("**/user/superuser*")

        #  2. Create & Configure Form
        print("Creating and publishing form...")
        admin_page = context.new_page()
        admin_page.goto(f"{BASE_URL}/form/new/template/8")

        admin_page.locator("input#name").fill("sample")
        admin_page.locator("#commit_name").click()
        admin_page.locator("#submit_button").click()

        # Make the form public
        admin_page.locator("text=Options").click()
        admin_page.locator("#toggle_public_true").click()

        #  3. Fill the Form (New Tab)
        print("Filling out the published form...")
        form_page = context.new_page()
        form_page.goto(f"{BASE_URL}/sample")

        # Wait a bit; the 10s countdown sometimes prevents posting to answers
        form_page.wait_for_timeout(3000)

        # Click the first input strictly to ensure focus before tabbing
        form_page.locator("input").nth(1).fill("foo")
        form_page.locator("input").nth(2).fill("foo@bar.baz")
        form_page.locator("textarea").fill("foo")
        form_page.locator("button[name='submit']").click()

        expect(form_page.locator("#thankyou-page>.ds-marked-up")).to_have_text(
            "Thank you!", timeout=25000
        )
        form_page.close()

        #  4. Export and Verify CSV
        print("Exporting answers to CSV...")
        admin_page.bring_to_front()
        admin_page.locator("a", has_text="Answers").click()

        with admin_page.expect_download() as download_info:
            # Matches button containing "CSV" (handles the SVG icon implicitly)
            admin_page.locator("button", has_text="CSV").click()

        save_path = "/tmp/answers.csv"
        download_info.value.save_as(save_path)

        with open(save_path, "r") as f:
            csv_content = f.read()
            assert "foo" in csv_content, "Expected 'foo' to be in the exported CSV!"
            assert (
                "foo@bar.baz" in csv_content
            ), "Expected 'foo@bar.baz' to be in the exported CSV!"

        #  5. Test SMTP Configuration
        print("Testing SMTP configuration...")
        smtp_page = context.new_page()
        smtp_page.goto(f"{BASE_URL}/site/email/config")

        smtp_page.locator("input#email-recipient").fill("example@example.org")
        smtp_page.get_by_role("button", name="Send").click()

        try:
            smtp_page.locator(
                "#flash_container", has_text="SMTP config works!"
            ).wait_for(state="visible", timeout=10000)
        except Exception as e:
            print("FAILED: Did not see 'SMTP config works!' message.")
            raise e

        # wait a bit so mailpit has processed the mails
        smtp_page.wait_for_timeout(3000)
        smtp_page.close()

        #  6. Verify Mailpit Delivery
        print("Checking Mailpit API for delivered email...")

        response = requests.get("http://localhost:8025/api/v1/messages")
        response.raise_for_status()
        mail_data = response.json()

        assert (
            mail_data.get("total", 0) > 0
        ), "No emails found in Mailpit! Delivery failed."

        # Scan for the specific test email address
        found_email = any(
            to_addr.get("Address") == "example@example.org"
            for msg in mail_data.get("messages", [])
            for to_addr in msg.get("To", [])
        )

        assert (
            found_email
        ), "Test email to example@example.org was not found in Mailpit!"
        print("Test suite completed and passed successfully!")


if __name__ == "__main__":
    run_test()
