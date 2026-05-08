#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, sys
from pathlib import Path
try:
    import yaml
    import jsonschema
    from jsonschema import Draft202012Validator, FormatChecker
except ImportError as e:
    print(f"ERROR: missing dependency: {e.name}. Install PyYAML and jsonschema.", file=sys.stderr); sys.exit(2)
TYPE_TO_SCHEMA={"agile":"agile.schema.json","status":"status.schema.json","feature":"feature.schema.json","story":"story.schema.json","traceability":"traceability.schema.json","release":"release.schema.json","evidence":"evidence.schema.json","change-request":"change-request.schema.json","decision-record":"decision-log.schema.json","recovery-record":"recovery-log.schema.json"}
def load(p):
    txt=Path(p).read_text(encoding='utf-8')
    return json.loads(txt) if str(p).endswith('.json') else yaml.safe_load(txt)
def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--type', choices=TYPE_TO_SCHEMA); ap.add_argument('--schema'); ap.add_argument('--file', required=True); ap.add_argument('--quiet', action='store_true'); a=ap.parse_args()
    schema=Path(a.schema) if a.schema else Path(__file__).resolve().parent.parent/'schemas'/TYPE_TO_SCHEMA[a.type]
    data=load(a.file); sch=json.loads(schema.read_text(encoding='utf-8'))
    errors=sorted(Draft202012Validator(sch, format_checker=FormatChecker()).iter_errors(data), key=lambda e:list(e.absolute_path))
    if errors:
        e=errors[0]; path='.'.join(map(str,e.absolute_path)) or '<root>'; print('Validation failed.', file=sys.stderr); print(f'Path: {path}', file=sys.stderr); print(f'Message: {e.message}', file=sys.stderr); return 1
    if not a.quiet: print('[agile-run] validation passed'); print(f'File: {Path(a.file).resolve()}'); print(f'Schema: {schema.resolve()}')
    return 0
if __name__=='__main__': sys.exit(main())
