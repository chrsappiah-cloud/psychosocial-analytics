#!/usr/bin/env python3
"""Fill App Store Connect form (metadata, screenshots, review info) and submit version 1.0."""
from __future__ import annotations

import json
import mimetypes
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

import jwt

ROOT = Path(__file__).resolve().parents[1]
RESPONSE = json.loads((ROOT / "Distribution/AppStoreConnect/submission-response.json").read_text())
SCREENSHOTS = ROOT / "Distribution/screenshots/appstore-ready"
RAW_SCREENSHOTS = ROOT / "Distribution/screenshots"

ISSUER_ID = "70c46c69-5d6d-438d-b300-31df2b93163a"
KEY_ID = "4B8M4ZHLMF"
KEY_PATH = Path.home() / ".appstoreconnect/private_keys/AuthKey_4B8M4ZHLMF.p8"

APP_ID = "6768490648"
VERSION_ID = "f1cefa6e-6302-428d-bbc6-5142c346f2ba"
VERSION_LOC_ID = "1b67e276-aaf9-4218-8788-62ba4da64841"
APP_INFO_ID = "4b93905f-a698-42fc-8d68-572560a9cdda"
APP_INFO_LOC_ID = None  # resolved at runtime

# App Store Connect allows max 10 screenshots per display size.
# Order matches Distribution/AppStoreConnect/FORM_RESPONSES.md (slots 1–10).
SCREENSHOT_ORDER = [
    "01-login.png",
    "02-home.png",
    "03-upload.png",
    "04-upload-newclient.png",
    "05-assess.png",
    "06-clients.png",
    "07-insights.png",
    "08-reports.png",
    "09-settings.png",
    "10-admin-overview.png",
]

DISPLAY_TYPE = "APP_IPHONE_67"
# 13-inch iPad in App Store Connect (not legacy APP_IPAD_PRO_129 / 2048×2732).
IPAD_DISPLAY_TYPE = "APP_IPAD_PRO_3GEN_129"
IPAD_SCREENSHOTS = ROOT / "Distribution/screenshots/ipad/appstore-ready"
IPAD_SCREENSHOT_ORDER = [
    "01-home.png",
    "02-upload.png",
    "03-clients.png",
    "04-admin.png",
]
LOCALE = "en-AU"


class ASCClient:
    def __init__(self) -> None:
        self._token = ""
        self._token_exp = 0

    def token(self) -> str:
        if time.time() < self._token_exp - 60:
            return self._token
        private_key = KEY_PATH.read_text()
        now = int(time.time())
        self._token = jwt.encode(
            {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
            private_key,
            algorithm="ES256",
            headers={"kid": KEY_ID},
        )
        self._token_exp = now + 1200
        return self._token

    def request(self, method: str, url: str, body: dict | None = None) -> dict:
        data = None
        headers = {"Authorization": f"Bearer {self.token()}"}
        if body is not None:
            data = json.dumps(body).encode()
            headers["Content-Type"] = "application/json"
        req = urllib.request.Request(url, data=data, method=method, headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                raw = resp.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as err:
            detail = err.read().decode()
            raise RuntimeError(f"{method} {url} -> {err.code}: {detail}") from err

    def get(self, url: str) -> dict:
        return self.request("GET", url)

    def patch(self, url: str, body: dict) -> dict:
        return self.request("PATCH", url, body)

    def post(self, url: str, body: dict) -> dict:
        return self.request("POST", url, body)

    def delete(self, url: str) -> dict:
        return self.request("DELETE", url)


def resolve_app_info_loc(client: ASCClient) -> str:
    locs = client.get(f"https://api.appstoreconnect.apple.com/v1/appInfos/{APP_INFO_ID}/appInfoLocalizations")
    for loc in locs["data"]:
        if loc["attributes"].get("locale") == LOCALE:
            return loc["id"]
    raise RuntimeError(f"No app info localization for {LOCALE}")


def update_metadata(client: ASCClient) -> None:
    global APP_INFO_LOC_ID
    APP_INFO_LOC_ID = resolve_app_info_loc(client)
    fields = RESPONSE["submissionFields"]

    version_attrs = {
        "description": fields["appInfo"]["description"],
        "keywords": fields["appInfo"]["keywords"],
        "marketingUrl": fields["urls"]["marketingURL"],
        "promotionalText": fields["appInfo"]["promotionalText"],
        "supportUrl": fields["urls"]["supportURL"],
    }
    try:
        client.patch(
            f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{VERSION_LOC_ID}",
            {
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "id": VERSION_LOC_ID,
                    "attributes": {**version_attrs, "whatsNew": fields["versionInfo"]["whatsNew"]},
                }
            },
        )
    except RuntimeError as err:
        if "whatsNew" in str(err):
            client.patch(
                f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{VERSION_LOC_ID}",
                {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "id": VERSION_LOC_ID,
                        "attributes": version_attrs,
                    }
                },
            )
            print("✓ Version localization updated (whatsNew skipped — set manually if required)")
        else:
            raise
    else:
        print("✓ Version localization metadata updated")

    client.patch(
        f"https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{APP_INFO_LOC_ID}",
        {
            "data": {
                "type": "appInfoLocalizations",
                "id": APP_INFO_LOC_ID,
                "attributes": {"subtitle": fields["appInfo"]["subtitle"]},
            }
        },
    )
    print("✓ App info subtitle updated")

    client.patch(
        f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{VERSION_ID}",
        {
            "data": {
                "type": "appStoreVersions",
                "id": VERSION_ID,
                "attributes": {"copyright": fields["versionInfo"]["copyright"]},
            }
        },
    )
    print("✓ Copyright set")


def ensure_review_detail(client: ASCClient) -> None:
    review = RESPONSE["submissionFields"]["appReviewInfo"]
    attrs = {
        "contactEmail": review["contactEmail"],
        "contactFirstName": "Christopher",
        "contactLastName": "Appiah-Thompson",
        "contactPhone": "+61400000000",
        "notes": review["notes"],
        "demoAccountName": review["demoAccountName"],
        "demoAccountPassword": review["demoAccountPassword"],
        "demoAccountRequired": True,
    }
    rel = {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": VERSION_ID}}}

    existing = client.get(
        f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{VERSION_ID}/appStoreReviewDetail"
    )
    if existing.get("data"):
        detail_id = existing["data"]["id"]
        client.patch(
            f"https://api.appstoreconnect.apple.com/v1/appStoreReviewDetails/{detail_id}",
            {"data": {"type": "appStoreReviewDetails", "id": detail_id, "attributes": attrs}},
        )
        print("✓ App review detail updated")
        return

    client.post(
        "https://api.appstoreconnect.apple.com/v1/appStoreReviewDetails",
        {"data": {"type": "appStoreReviewDetails", "attributes": attrs, "relationships": rel}},
    )
    print("✓ App review detail created")


def upload_binary(path: Path, operations: list) -> None:
    for op in operations:
        method = op.get("method", "PUT")
        url = op["url"]
        headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        with path.open("rb") as fh:
            data = fh.read()
        req = urllib.request.Request(url, data=data, method=method, headers=headers)
        with urllib.request.urlopen(req, timeout=300) as resp:
            if resp.status >= 400:
                raise RuntimeError(f"Upload failed {resp.status}")


def fix_submission_requirements(client: ASCClient) -> None:
    """Resolve App Store Connect blockers: category, content rights, privacy URL, age rating."""
    global APP_INFO_LOC_ID
    APP_INFO_LOC_ID = resolve_app_info_loc(client)
    fields = RESPONSE["submissionFields"]

    client.patch(
        f"https://api.appstoreconnect.apple.com/v1/appInfoLocalizations/{APP_INFO_LOC_ID}",
        {
            "data": {
                "type": "appInfoLocalizations",
                "id": APP_INFO_LOC_ID,
                "attributes": {"privacyPolicyUrl": fields["urls"]["privacyPolicyURL"]},
            }
        },
    )
    print("✓ Privacy Policy URL set on app info")

    client.patch(
        f"https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}",
        {
            "data": {
                "type": "apps",
                "id": APP_ID,
                "attributes": {"contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"},
            }
        },
    )
    print("✓ Content Rights: does not use third-party content")

    client.patch(
        f"https://api.appstoreconnect.apple.com/v1/appInfos/{APP_INFO_ID}",
        {
            "data": {
                "type": "appInfos",
                "id": APP_INFO_ID,
                "relationships": {
                    "primaryCategory": {"data": {"type": "appCategories", "id": "MEDICAL"}},
                    "secondaryCategory": {"data": {"type": "appCategories", "id": "EDUCATION"}},
                },
            }
        },
    )
    print("✓ Primary category: Medical, Secondary: Education")

    age_attrs = {
        "alcoholTobaccoOrDrugUseOrReferences": "NONE",
        "contests": "NONE",
        "gambling": False,
        "gamblingSimulated": "NONE",
        "violenceCartoonOrFantasy": "NONE",
        "violenceRealistic": "NONE",
        "violenceRealisticProlongedGraphicOrSadistic": "NONE",
        "profanityOrCrudeHumor": "NONE",
        "matureOrSuggestiveThemes": "NONE",
        "horrorOrFearThemes": "NONE",
        "sexualContentOrNudity": "NONE",
        "sexualContentGraphicAndNudity": "NONE",
        "medicalOrTreatmentInformation": "INFREQUENT",
        "healthOrWellnessTopics": True,
        "unrestrictedWebAccess": False,
        "lootBox": False,
        "userGeneratedContent": False,
        "messagingAndChat": False,
        "advertising": False,
        "gunsOrOtherWeapons": "NONE",
        "parentalControls": False,
        "ageAssurance": False,
    }
    client.patch(
        f"https://api.appstoreconnect.apple.com/v1/ageRatingDeclarations/{APP_INFO_ID}",
        {"data": {"type": "ageRatingDeclarations", "id": APP_INFO_ID, "attributes": age_attrs}},
    )
    print("✓ Age rating questionnaire completed")


def upload_screenshot_set(
    client: ASCClient,
    display_type: str,
    screenshot_dir: Path,
    order: list[str],
    label: str,
) -> None:
    # ASC filter[screenshotDisplayType] is unreliable; match display type in code.
    sets = client.get(
        f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{VERSION_LOC_ID}/appScreenshotSets"
        "?limit=50"
    )
    matching = [
        s
        for s in sets.get("data", [])
        if s.get("attributes", {}).get("screenshotDisplayType") == display_type
    ]
    if matching:
        for s in matching:
            shots = client.get(
                f"https://api.appstoreconnect.apple.com/v1/appScreenshotSets/{s['id']}/appScreenshots"
            )
            for shot in shots.get("data", []):
                client.delete(f"https://api.appstoreconnect.apple.com/v1/appScreenshots/{shot['id']}")
            client.delete(f"https://api.appstoreconnect.apple.com/v1/appScreenshotSets/{s['id']}")
        print(f"✓ Cleared existing {label} screenshot set")

    created = client.post(
        "https://api.appstoreconnect.apple.com/v1/appScreenshotSets",
        {
            "data": {
                "type": "appScreenshotSets",
                "attributes": {"screenshotDisplayType": display_type},
                "relationships": {
                    "appStoreVersionLocalization": {
                        "data": {"type": "appStoreVersionLocalizations", "id": VERSION_LOC_ID}
                    }
                },
            }
        },
    )
    set_id = created["data"]["id"]
    print(f"✓ Created {label} screenshot set {set_id}")

    for index, name in enumerate(order):
        path = screenshot_dir / name
        if not path.exists():
            print(f"  skip missing {name}")
            continue
        size = path.stat().st_size
        reserved = client.post(
            "https://api.appstoreconnect.apple.com/v1/appScreenshots",
            {
                "data": {
                    "type": "appScreenshots",
                    "attributes": {"fileName": name, "fileSize": size},
                    "relationships": {
                        "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}
                    },
                }
            },
        )
        shot_id = reserved["data"]["id"]
        ops = reserved["data"]["attributes"].get("uploadOperations", [])
        upload_binary(path, ops)
        client.patch(
            f"https://api.appstoreconnect.apple.com/v1/appScreenshots/{shot_id}",
            {
                "data": {
                    "type": "appScreenshots",
                    "id": shot_id,
                    "attributes": {"uploaded": True},
                }
            },
        )
        for _ in range(30):
            status = client.get(f"https://api.appstoreconnect.apple.com/v1/appScreenshots/{shot_id}")
            state = (status["data"]["attributes"].get("assetDeliveryState") or {}).get("state")
            if state in ("COMPLETE", "READY_FOR_SALE"):
                print(f"  ✓ {name} (#{index + 1}) — {state}")
                break
            if state == "FAILED":
                errors = (status["data"]["attributes"].get("assetDeliveryState") or {}).get("errors", [])
                raise RuntimeError(f"{name} failed: {errors}")
            time.sleep(2)
        else:
            print(f"  ⚠ {name} still processing")


def ensure_screenshot_dimensions() -> None:
    """Resize raw captures to 1290×2796 for App Store Connect."""
    import subprocess

    script = ROOT / "scripts/resize-screenshots-for-appstore.sh"
    subprocess.run(["bash", str(script)], check=True)


def upload_screenshots(client: ASCClient) -> None:
    ensure_screenshot_dimensions()
    upload_screenshot_set(client, DISPLAY_TYPE, SCREENSHOTS, SCREENSHOT_ORDER, 'iPhone 6.7"')


def upload_ipad_screenshots(client: ASCClient) -> None:
    import subprocess

    ipad_dir = IPAD_SCREENSHOTS
    if not all((ipad_dir / n).exists() for n in IPAD_SCREENSHOT_ORDER):
        cap = ROOT / "scripts/capture-ipad-screenshots.sh"
        subprocess.run(["bash", str(cap)], check=True)
    else:
        subprocess.run(["bash", str(ROOT / "scripts/resize-ipad-screenshots.sh")], check=True)
    upload_screenshot_set(client, IPAD_DISPLAY_TYPE, ipad_dir, IPAD_SCREENSHOT_ORDER, 'iPad 13"')


def verify_pricing(client: ASCClient) -> None:
    """Confirm app price schedule exists (Free tier for base territory)."""
    sched = client.get(f"https://api.appstoreconnect.apple.com/v1/appPriceSchedules/{APP_ID}?include=manualPrices,baseTerritory")
    base = (sched.get("data", {}).get("relationships", {}).get("baseTerritory", {}).get("data") or {}).get("id")
    manual = (sched.get("data", {}).get("relationships", {}).get("manualPrices", {}).get("data") or [])
    auto = client.get(f"https://api.appstoreconnect.apple.com/v1/appPriceSchedules/{APP_ID}/automaticPrices")
    auto_total = (auto.get("meta", {}).get("paging") or {}).get("total", 0)
    if manual:
        print(f"✓ Price schedule: base={base}, manual={len(manual)}, automatic={auto_total}")
    else:
        print("⚠ No manual price on schedule — set Free in App Store Connect → Pricing and Availability")


def submit_for_review(client: ASCClient) -> None:
    try:
        client.post(
            "https://api.appstoreconnect.apple.com/v1/appStoreVersionSubmissions",
            {
                "data": {
                    "type": "appStoreVersionSubmissions",
                    "relationships": {
                        "appStoreVersion": {
                            "data": {"type": "appStoreVersions", "id": VERSION_ID}
                        }
                    },
                }
            },
        )
        print("✓ Submitted for App Review")
    except RuntimeError as err:
        print(f"⚠ Submit blocked: {err}")
        print("  Attach a non-expired build in App Store Connect, then re-run with --submit-only")


def main() -> int:
    args = sys.argv[1:]
    submit_only = "--submit-only" in args
    screenshots_only = "--screenshots-only" in args
    ipad_only = "--ipad-screenshots-only" in args
    fix_only = "--fix-requirements" in args
    all_screenshots = "--all-screenshots" in args
    client = ASCClient()

    if fix_only:
        fix_submission_requirements(client)
        verify_pricing(client)
    elif all_screenshots:
        upload_screenshots(client)
        upload_ipad_screenshots(client)
    elif ipad_only:
        upload_ipad_screenshots(client)
    elif screenshots_only:
        upload_screenshots(client)
    elif not submit_only:
        fix_submission_requirements(client)
        update_metadata(client)
        ensure_review_detail(client)
        upload_screenshots(client)
        upload_ipad_screenshots(client)
        verify_pricing(client)

    if "--submit-only" in args or "--submit" in args:
        submit_for_review(client)

    print("\nDone. Check: https://appstoreconnect.apple.com/apps/6768490648/distribution/ios/version/inflight")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
