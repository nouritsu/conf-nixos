import os
import sqlite3
import sys

db_path = os.path.expanduser("~/.config/BraveSoftware/Brave-Browser/Default/Web Data")

if not os.path.isfile(db_path):
    print("brave: Web Data not found, skipping")
    sys.exit(0)

for pid in os.listdir("/proc"):
    if pid.isdigit():
        try:
            comm = open(f"/proc/{pid}/comm").read().strip()
            if comm == "brave":
                print("brave: browser is running, skipping (db locked)")
                sys.exit(0)
        except OSError:
            pass

engines = [
    (
        "Wikipedia",
        "@wiki",
        "https://en.wikipedia.org/w/index.php?title=Special:Search&search={searchTerms}",
    ),
    ("YouTube", "@yt", "https://www.youtube.com/results?search_query={searchTerms}"),
    (
        "YouTube Long",
        "@youtube",
        "https://www.youtube.com/results?search_query={searchTerms}",
    ),
    (
        "NixOS Options",
        "@no",
        "https://search.nixos.org/options?channel=unstable&query={searchTerms}",
    ),
    (
        "Nix Packages",
        "@np",
        "https://search.nixos.org/packages?channel=unstable&query={searchTerms}",
    ),
    (
        "Home Manager Options",
        "@hm",
        "https://home-manager-options.extranix.com/?query={searchTerms}&release=master",
    ),
]

conn = sqlite3.connect(db_path)
c = conn.cursor()
c.execute("DELETE FROM keywords WHERE created_by_policy = 1")
for name, keyword, url in engines:
    c.execute(
        """
        INSERT INTO keywords
        (short_name, keyword, favicon_url, url, safe_for_autoreplace,
        input_encodings, created_by_policy, is_active, alternate_urls)
        VALUES (?, ?, '', ?, 0, 'UTF-8', 1, 1, '[]')
        """,
        (name, keyword, url),
    )
conn.commit()
conn.close()
print(f"brave: patched {len(engines)} site search engines")
