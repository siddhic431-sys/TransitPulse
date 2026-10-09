
import json
import os
from datetime import datetime, timezone
from pathlib import Path

import requests
from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(PROJECT_ROOT / ".env")

API_KEY = os.getenv("CTA_API_KEY")
OUTPUT_DIR = PROJECT_ROOT / "data" / "raw" / "realtime"


def save_snapshot(feed_name, feed_url):
    if not API_KEY:
        print("CTA_API_KEY is not configured yet.")
        return

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # The endpoint must be supplied from CTA's official documentation.
    response = requests.get(
        feed_url,
        params={"key": API_KEY},
        timeout=30,
    )
    response.raise_for_status()

    timestamp = datetime.now(timezone.utc)
    filename = f"{feed_name}_{timestamp:%Y%m%dT%H%M%SZ}.json"
    output_path = OUTPUT_DIR / filename

    # Save JSON responses directly; decode protobuf feeds separately.
    data = response.json()
    output_path.write_text(
        json.dumps(data, indent=2),
        encoding="utf-8",
    )

    print(f"Saved snapshot: {output_path}")


if __name__ == "__main__":
    print("TransitPulse collector prepared.")
    print("Waiting for CTA API key and verified feed URL.")
