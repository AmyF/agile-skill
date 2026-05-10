#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None


ARRAY_KEYS = {
    "branch": "branches",
    "commit": "commits",
    "pull_request": "pull_requests",
    "issue": "issues",
}


def load_data(path: Path):
    if yaml is not None:
        return yaml.safe_load(path.read_text(encoding="utf-8"))
    ruby = 'require "yaml"; require "json"; require "date"; obj = YAML.load_file(ARGV[0]); puts JSON.generate(obj)'
    result = subprocess.run(["ruby", "-e", ruby, str(path)], check=False, text=True, capture_output=True)
    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        raise RuntimeError("YAML parsing requires PyYAML or Ruby with YAML support")
    return json.loads(result.stdout)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("traceability")
    parser.add_argument("ref_type", choices=["branch", "commit", "pull_request", "issue", "merge_commit", "merge_method"])
    parser.add_argument("value")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    path = Path(args.traceability)
    data = load_data(path)
    git_refs = data.setdefault("links", {}).setdefault("git_refs", {})

    if args.ref_type in ARRAY_KEYS:
        key = ARRAY_KEYS[args.ref_type]
        values = git_refs.setdefault(key, [])
        if args.value not in values:
            values.append(args.value)
    else:
        merge = git_refs.setdefault("merge", {})
        merge["commit" if args.ref_type == "merge_commit" else "method"] = args.value

    output = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
    if args.dry_run:
        print(output)
        return 0

    path.write_text(output, encoding="utf-8")
    print(f"[agile-git] recorded {args.ref_type}: {args.value}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
