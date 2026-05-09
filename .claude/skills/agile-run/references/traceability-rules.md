# Traceability Rules

Traceability is a machine-readable gate, not a manual matrix.

Required story chain: requirement or PRD -> Story Acceptance Criteria -> FID -> TDD flow -> optional BDD scenario -> implementation ref -> evidence -> Git ref. Release traceability adds release refs after story acceptance.

Every Acceptance Criterion must be covered by at least one TDD flow and one passing or waived evidence item. Game stories must include playtest evidence unless waived. High-risk stories must include DDD or an explicit waiver.
