"""Read-only browser smoke test. Requires: pip install playwright.

Serve build/web at localhost:8080, then run python tool/smoke_web.py.
Optional AUDY_SMOKE_EMAIL / AUDY_SMOKE_PASSWORD enable account checks.
Uses installed Chrome/Edge. Does not save configs or change cloud progress.
"""
import os
from playwright.sync_api import sync_playwright


def enable_accessibility(page):
    page.wait_for_function("document.querySelector('flt-semantics-placeholder') || document.querySelector('flt-semantics [role]')", timeout=45000)
    placeholder = page.locator("flt-semantics-placeholder")
    if placeholder.count():
        placeholder.evaluate("e => e.click()")


def type_field(page, label, value):
    # Flutter's text-input connection is established by focus. Use normal key
    # events rather than assigning an accessibility input's DOM value.
    field = page.get_by_label(label, exact=True)
    field.click()
    page.wait_for_timeout(150)
    field.press_sequentially(value, delay=25)
    page.keyboard.press("Tab")


def run(channel):
    base = os.getenv("AUDY_SMOKE_URL", "http://127.0.0.1:8080")
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(channel=channel, headless=True)
        context = browser.new_context(viewport={"width": 1280, "height": 900})
        page = context.new_page()
        errors = []
        page.on("pageerror", lambda error: errors.append(str(error)))
        # Prevent writes to real child data while exercising the compiled UI.
        def guard(route):
            request = route.request
            read_rpc = request.url.split("?")[0].endswith("/rpc/caretaker_roster")
            if request.method not in ("GET", "HEAD", "OPTIONS") and not read_rpc:
                route.abort()
            else:
                route.continue_()
        context.route("**/rest/v1/**", guard)
        page.goto(base, wait_until="domcontentloaded")
        enable_accessibility(page)
        page.get_by_label("Email", exact=True).wait_for()
        assert "Caretaker Home" not in page.locator("body").inner_text()
        assert "Debug" not in page.locator("body").inner_text()
        for path, mime in [("sqlite3.wasm", "application/wasm"), ("drift_worker.js", "javascript")]:
            response = context.request.get(f"{base}/{path}")
            assert response.ok and mime in response.headers.get("content-type", ""), path
        email = os.getenv("AUDY_SMOKE_EMAIL")
        password = os.getenv("AUDY_SMOKE_PASSWORD")
        if email and password:
            type_field(page, "Email", email)
            type_field(page, "Password", password)
            page.get_by_role("button", name="Sign In", exact=True).last.click()
            page.get_by_text("Caretaker Home", exact=True).wait_for(timeout=45000)
            assert "Browser storage is unavailable" not in page.locator("body").inner_text()
            for title in ["Study Plan · TBD", "Manual (Guide) · TBD", "Customization", "Assignments & Rewards · TBD"]:
                assert page.get_by_text(title, exact=True).count(), title
            page.get_by_text("Customization", exact=True).click()
            for title in ["Social Chat", "FlashCard", "MiniPuzzle", "Emotion", "Fruit Catch"]:
                page.get_by_text(title, exact=False).wait_for()
            page.get_by_text("FlashCard", exact=False).click()
            page.get_by_text("Add Custom Flashcard Card", exact=True).wait_for()
            # Refresh an argument-dependent screen safely back to signed-in home.
            page.reload(wait_until="domcontentloaded")
            enable_accessibility(page)
            page.get_by_text("Caretaker Home", exact=True).wait_for(timeout=45000)
            page.get_by_text("Child Progress", exact=False).click()
            page.get_by_text("Level, Points & History", exact=True).wait_for()
            page.get_by_text("Profile", exact=False).click()
            page.get_by_text("Settings", exact=True).click()
            page.get_by_text("App Settings", exact=True).wait_for()
            page.go_back()
            page.get_by_text("Log out", exact=True).click()
            page.get_by_label("Email", exact=True).wait_for(timeout=10000)
            assert "Caretaker Home" not in page.locator("body").inner_text()
        assert not errors, errors
        browser.close()
        print(f"{channel}: public startup, database assets, no JS exceptions" +
              (", caretaker navigation/refresh/logout passed" if email and password else " (account checks skipped)"))


if __name__ == "__main__":
    for browser_channel in ["chrome", "msedge"]:
        run(browser_channel)
