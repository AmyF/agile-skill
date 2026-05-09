# Schema Usage

Schemas are minimal strict contracts for runtime YAML only. Markdown artifacts remain template-driven and flexible.

Use references and templates to author artifacts, generate runtime YAML, run validation scripts, fix errors, and validate again. Do not copy schemas or scripts into `.agile`. The validator avoids Python third-party requirements; PyYAML is optional and Ruby YAML is used as a fallback when available.
