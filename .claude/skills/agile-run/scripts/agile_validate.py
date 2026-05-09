#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None

TYPE_TO_SCHEMA = {
    "agile": "agile.schema.json",
    "status": "status.schema.json",
    "feature": "feature.schema.json",
    "story": "story.schema.json",
    "traceability": "traceability.schema.json",
    "evidence": "evidence.schema.json",
    "release": "release.schema.json",
    "change-request": "change-request.schema.json",
}


def load_data(path: Path) -> Any:
    if path.suffix == ".json":
        return json.loads(path.read_text(encoding="utf-8"))
    if yaml is not None:
        return yaml.safe_load(path.read_text(encoding="utf-8"))

    ruby = (
        'require "yaml"; require "json"; require "date"; '
        "obj = YAML.load_file(ARGV[0]); "
        "puts JSON.generate(obj)"
    )
    result = subprocess.run(["ruby", "-e", ruby, str(path)], check=False, text=True, capture_output=True)
    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        raise RuntimeError("YAML parsing requires PyYAML or Ruby with YAML support")
    return json.loads(result.stdout)


def schema_for(schema_type: str | None = None, schema_path: str | None = None) -> Path:
    if schema_path:
        return Path(schema_path)
    if not schema_type:
        raise ValueError("schema type required")
    return Path(__file__).resolve().parent.parent / "schemas" / TYPE_TO_SCHEMA[schema_type]


def resolve_ref(root: dict[str, Any], ref: str) -> dict[str, Any]:
    node: Any = root
    for part in ref.removeprefix("#/").split("/"):
        node = node[part]
    return node


def type_matches(expected: str, value: Any) -> bool:
    if expected == "object":
        return isinstance(value, dict)
    if expected == "array":
        return isinstance(value, list)
    if expected == "string":
        return isinstance(value, str)
    if expected == "boolean":
        return isinstance(value, bool)
    if expected == "null":
        return value is None
    if expected == "number":
        return isinstance(value, (int, float)) and not isinstance(value, bool)
    if expected == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    return True


def check_schema(schema: dict[str, Any], value: Any, path: str, root: dict[str, Any]) -> list[str]:
    if "$ref" in schema:
        schema = resolve_ref(root, schema["$ref"])

    errors: list[str] = []
    expected_type = schema.get("type")
    if expected_type is not None:
        allowed = expected_type if isinstance(expected_type, list) else [expected_type]
        if not any(type_matches(item, value) for item in allowed):
            return [f"{path}: expected {expected_type}, got {type(value).__name__}"]

    if "const" in schema and value != schema["const"]:
        errors.append(f"{path}: expected const {schema['const']!r}")
    if "enum" in schema and value not in schema["enum"]:
        errors.append(f"{path}: expected one of {schema['enum']!r}")
    if "pattern" in schema and isinstance(value, str) and not re.match(schema["pattern"], value):
        errors.append(f"{path}: value {value!r} does not match {schema['pattern']}")
    if "minLength" in schema and isinstance(value, str) and len(value) < schema["minLength"]:
        errors.append(f"{path}: shorter than minLength {schema['minLength']}")

    if isinstance(value, dict):
        for key in schema.get("required", []):
            if key not in value:
                errors.append(f"{path}: missing required key {key}")
        for key, child_schema in schema.get("properties", {}).items():
            if key in value:
                errors.extend(check_schema(child_schema, value[key], f"{path}.{key}", root))

    if isinstance(value, list) and isinstance(schema.get("items"), dict):
        for index, item in enumerate(value):
            errors.extend(check_schema(schema["items"], item, f"{path}[{index}]", root))

    return errors


def validate_file(schema: Path, data_file: Path) -> list[str]:
    schema_data = json.loads(schema.read_text(encoding="utf-8"))
    data = load_data(data_file)
    return check_schema(schema_data, data, "<root>", schema_data)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--type", choices=TYPE_TO_SCHEMA)
    parser.add_argument("--schema")
    parser.add_argument("--file", required=True)
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    if not args.type and not args.schema:
        print("ERROR: provide --type or --schema", file=sys.stderr)
        return 2

    data_file = Path(args.file)
    schema = schema_for(args.type, args.schema)
    errors = validate_file(schema, data_file)
    if errors:
        print("Validation failed.", file=sys.stderr)
        print(errors[0], file=sys.stderr)
        return 1

    if not args.quiet:
        print("[agile-run] validation passed")
        print(f"File: {data_file.resolve()}")
        print(f"Schema: {schema.resolve()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
