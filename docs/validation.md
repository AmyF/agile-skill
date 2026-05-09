# Validation

Schemas are minimal strict contracts for runtime YAML. Markdown artifacts are template-driven.

AI reads references and templates, generates runtime files, runs schema and gate scripts, fixes errors, and reports success only after validation passes. Dependencies: Python 3. PyYAML is optional; when absent, the validator falls back to Ruby YAML if available.
