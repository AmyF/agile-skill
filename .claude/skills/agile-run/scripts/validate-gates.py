#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

from agile_validate import load_data, schema_for, validate_file


SCHEMA_TYPES = ["agile", "status", "feature", "story", "traceability", "evidence", "release", "change-request"]
BRANCH_PATTERN = re.compile(r"^(doc|impl|test|acceptance|release|hotfix|recovery|chore)/(FEA-[0-9]{4}-[0-9]{4}-[a-z0-9][a-z0-9-]*|US-[0-9]{3}-[a-z0-9][a-z0-9-]*|CR-[0-9]{4}-[0-9]{4}-[a-z0-9][a-z0-9-]*|REL-[0-9]{4}-[0-9]{4})/[a-z0-9][a-z0-9-]*$")
COMMIT_PATTERN = re.compile(r"^(docs|feat|fix|test|refactor|chore|release|hotfix|recovery)\((FEA-[0-9]{4}-[0-9]{4}-[a-z0-9][a-z0-9-]*|US-[0-9]{3}-[a-z0-9][a-z0-9-]*|CR-[0-9]{4}-[0-9]{4}-[a-z0-9][a-z0-9-]*|REL-[0-9]{4}-[0-9]{4})\): .+")
SHA_PATTERN = re.compile(r"^[0-9a-f]{7,40}$")


def validate_schema(schema_type: str, file_path: Path, failures: list[str]) -> None:
    errors = validate_file(schema_for(schema_type), file_path)
    if errors:
        failures.append(f"{file_path}: schema {schema_type} failed: {errors[0]}")


def has_placeholder(path: Path) -> bool:
    if not path.is_file():
        return False
    try:
        return "{{" in path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return False


def criterion_ids(criteria) -> set[str]:
    ids: set[str] = set()
    for index, item in enumerate(criteria or [], start=1):
        if isinstance(item, dict):
            value = item.get("id") or item.get("criterion_id")
            ids.add(str(value) if value else f"AC-{index:03d}")
        elif item:
            ids.add(str(item))
    return ids


def doc_ready(doc: dict) -> bool:
    return bool(doc.get("latest") or doc.get("versions"))


def waiver_ready(waiver: dict | None) -> bool:
    return (
        isinstance(waiver, dict)
        and waiver.get("status") == "waived"
        and bool(waiver.get("reason"))
        and bool(waiver.get("source"))
        and bool(waiver.get("downstream_risk"))
    )


def covers_all(criteria: set[str], coverage: set[str]) -> bool:
    return bool(criteria) and criteria.issubset(coverage)


def validate_feature(feature_path: Path, feature: dict, failures: list[str]) -> None:
    data = feature["feature"]
    criteria = criterion_ids(feature.get("acceptance_criteria"))
    if not criteria:
        failures.append(f"{feature_path}: feature acceptance_criteria must not be empty")

    ddd_policy = feature.get("ddd_policy", {})
    ddd_required = data.get("risk") == "high" or bool(ddd_policy.get("required"))
    ddd_doc = feature.get("documents", {}).get("ddd", {})
    if ddd_required and not doc_ready(ddd_doc) and not waiver_ready(ddd_policy.get("waiver")):
        failures.append(f"{feature_path}: high-risk or required DDD needs a DDD artifact or explicit waiver")


def validate_story(story_path: Path, story: dict, failures: list[str]) -> None:
    story_data = story["story"]
    story_dir = story_path.parent
    criteria = criterion_ids(story.get("acceptance_criteria"))
    if not criteria:
        failures.append(f"{story_path}: story acceptance_criteria must not be empty")

    docs = story.get("documents", {})
    if not doc_ready(docs.get("fid", {})):
        failures.append(f"{story_path}: FID document reference is required before gate pass")
    if not doc_ready(docs.get("tdd", {})):
        failures.append(f"{story_path}: TDD document reference is required before gate pass")

    ddd_policy = story.get("ddd_policy", {})
    ddd_required = story_data.get("risk") == "high" or bool(ddd_policy.get("required"))
    if ddd_required and not waiver_ready(ddd_policy.get("waiver")):
        failures.append(f"{story_path}: high-risk or required DDD needs explicit waiver or inherited approved DDD")

    trace_file = story_dir / story.get("traceability", {}).get("file", "traceability.yaml")
    if not trace_file.exists():
        failures.append(f"{story_path}: traceability file missing: {trace_file}")
        return
    trace = load_data(trace_file)
    links = trace.get("links", {})

    if not links.get("fid_refs"):
        failures.append(f"{trace_file}: fid_refs must not be empty")
    if not links.get("implementation_refs"):
        failures.append(f"{trace_file}: implementation_refs must not be empty")
    git_refs = links.get("git_refs", {})
    if not (git_refs.get("branches") or git_refs.get("commits") or git_refs.get("pull_requests")):
        failures.append(f"{trace_file}: at least one Git branch, commit, or PR ref is required")
    for branch in git_refs.get("branches") or []:
        if isinstance(branch, str) and not BRANCH_PATTERN.match(branch):
            failures.append(f"{trace_file}: invalid branch ref {branch!r}")
    for commit in git_refs.get("commits") or []:
        if isinstance(commit, str) and not (COMMIT_PATTERN.match(commit) or SHA_PATTERN.match(commit)):
            failures.append(f"{trace_file}: invalid commit ref {commit!r}")

    tdd_coverage: set[str] = set()
    for flow in links.get("tdd_flows") or []:
        tdd_coverage.update(map(str, flow.get("covers_acceptance_criteria") or []))
    if not covers_all(criteria, tdd_coverage):
        failures.append(f"{trace_file}: TDD flows must cover all story acceptance criteria")

    evidence_file = story_dir / story.get("evidence", {}).get("index", "evidence/evidence.yaml")
    if not evidence_file.exists():
        failures.append(f"{story_path}: evidence index missing: {evidence_file}")
        return
    evidence = load_data(evidence_file)
    evidence_items = evidence.get("evidence") or []
    if not evidence_items:
        failures.append(f"{evidence_file}: evidence must not be empty")

    evidence_coverage: set[str] = set()
    has_playtest = False
    for item in evidence_items:
        if item.get("status") in {"passed", "waived"}:
            evidence_coverage.update(map(str, item.get("covers_acceptance_criteria") or []))
        if item.get("type") == "playtest" and item.get("status") in {"passed", "waived"}:
            has_playtest = True
    if not covers_all(criteria, evidence_coverage):
        failures.append(f"{evidence_file}: passed or waived evidence must cover all story acceptance criteria")

    if story_data.get("profile") == "game":
        waived = any(w.get("gate_id") == "game_playtest_evidence" for w in evidence.get("waivers") or [])
        if not has_playtest and not waived:
            failures.append(f"{evidence_file}: game profile requires playtest evidence or a game_playtest_evidence waiver")


def validate_change_request(cr_path: Path, cr: dict, failures: list[str]) -> None:
    needs_approval = cr.get("change_classification") in {
        "approved_semantic_change",
        "release_freeze_change",
        "emergency_rollback_change",
    } or cr.get("decision") in {"approved", "revalidated", "closed"}
    if needs_approval and not cr.get("approvals"):
        failures.append(f"{cr_path}: semantic/release/emergency change requires an external approval record")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    agile = root / ".agile"
    failures: list[str] = []

    if not agile.is_dir():
        print(f"ERROR: .agile directory not found: {agile}", file=sys.stderr)
        return 2

    for path in agile.rglob("*"):
        if has_placeholder(path):
            failures.append(f"{path}: unresolved template placeholder")

    validate_schema("agile", agile / "agile.yaml", failures)
    validate_schema("status", agile / "status.yaml", failures)

    for feature_path in sorted(agile.glob("features/*/feature.yaml")):
        validate_schema("feature", feature_path, failures)
        feature = load_data(feature_path)
        validate_feature(feature_path, feature, failures)
        trace = feature_path.parent / feature.get("traceability", {}).get("file", "traceability.yaml")
        if trace.exists():
            validate_schema("traceability", trace, failures)
        else:
            failures.append(f"{feature_path}: feature traceability file missing")

    for story_path in sorted(agile.glob("features/*/stories/*/story.yaml")):
        validate_schema("story", story_path, failures)
        story = load_data(story_path)
        trace = story_path.parent / story.get("traceability", {}).get("file", "traceability.yaml")
        evidence = story_path.parent / story.get("evidence", {}).get("index", "evidence/evidence.yaml")
        if trace.exists():
            validate_schema("traceability", trace, failures)
        if evidence.exists():
            validate_schema("evidence", evidence, failures)
        validate_story(story_path, story, failures)

    for release_path in sorted(agile.glob("releases/*.yaml")):
        validate_schema("release", release_path, failures)

    for cr_path in sorted(agile.glob("changes/*.record.yaml")):
        validate_schema("change-request", cr_path, failures)
        validate_change_request(cr_path, load_data(cr_path), failures)

    if failures:
        print("Gate validation failed.", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    print("[agile-run] gate validation passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
