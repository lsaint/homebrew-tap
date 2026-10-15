"""Update one immutable PyPI source archive while preserving Formula structure."""

import hashlib
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path


def update_formula(content, version, url, checksum):
    if re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version) is None:
        raise ValueError("Invalid release version")
    parsed = urllib.parse.urlsplit(url)
    if (
        parsed.scheme != "https"
        or parsed.hostname != "files.pythonhosted.org"
        or parsed.query
        or parsed.fragment
        or parsed.username
        or parsed.password
        or not parsed.path.endswith(f"/aikito-{version}.tar.gz")
        or re.fullmatch(r"[0-9a-f]{64}", checksum) is None
    ):
        raise ValueError("Invalid release archive")
    url_pattern, sha_pattern = r'^  url "([^"\n]+)"$', r'^  sha256 "([0-9a-f]{64})"$'
    urls = re.findall(url_pattern, content, re.MULTILINE)
    shas = re.findall(sha_pattern, content, re.MULTILINE)
    if len(urls) != 1 or len(shas) != 1:
        raise ValueError("Ambiguous Formula archive")
    prior = re.search(r"/aikito-([0-9]+\.[0-9]+\.[0-9]+)\.tar\.gz$", urls[0])
    if prior is None:
        raise ValueError("Invalid prior archive")
    if tuple(map(int, version.split("."))) < tuple(map(int, prior[1].split("."))):
        raise ValueError("Release downgrade refused")
    if version == prior[1]:
        if urls[0] != url or shas[0] != checksum:
            raise ValueError("Published archive mutation refused")
        return content
    result = re.sub(
        url_pattern, lambda match: f'  url "{url}"', content, flags=re.MULTILINE
    )
    result = re.sub(
        sha_pattern, lambda match: f'  sha256 "{checksum}"', result, flags=re.MULTILINE
    )
    return re.sub(r"^  revision [0-9]+\n", "", result, flags=re.MULTILINE)


def fetch_json(version):
    for attempt in range(10):
        try:
            with urllib.request.urlopen(
                f"https://pypi.org/pypi/aikito/{version}/json", timeout=30
            ) as response:
                raw = response.read(4 * 1024 * 1024 + 1)
            if len(raw) > 4 * 1024 * 1024:
                raise ValueError("Metadata limit exceeded")
            return json.loads(raw)
        except (OSError, ValueError):
            if attempt == 9:
                raise
            time.sleep(10)


def main(version):
    version = version.removeprefix("v")
    if re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version) is None:
        raise ValueError("Invalid release version")
    metadata = fetch_json(version)
    candidates = [item for item in metadata["urls"] if item["packagetype"] == "sdist"]
    if len(candidates) != 1:
        raise ValueError("Exactly one source archive is required")
    artifact = candidates[0]
    path = Path("Formula/aikito.rb")
    before = path.read_text()
    after = update_formula(
        before, version, artifact["url"], artifact["digests"]["sha256"]
    )
    with urllib.request.urlopen(artifact["url"], timeout=60) as response:
        raw = response.read(64 * 1024 * 1024 + 1)
    if (
        len(raw) > 64 * 1024 * 1024
        or hashlib.sha256(raw).hexdigest() != artifact["digests"]["sha256"]
    ):
        raise ValueError("Archive checksum mismatch")
    path.write_text(after)
    print("[SUCCESS] Verified release archive and updated Formula")


if __name__ == "__main__":
    main(sys.argv[1])
