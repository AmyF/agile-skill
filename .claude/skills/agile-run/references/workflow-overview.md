# Workflow Overview

`.agile` is the source of truth for app/game delivery. The normal flow is:

Intake -> Feature PRD -> Story + Acceptance Criteria -> DDD if required -> FID -> TDD/BDD -> Implementation -> Acceptance Evidence -> Git Gate -> Release.

Acceptance Criteria are created before FID and TDD. BDD belongs to TDD. DDD is risk-based, not universal. Mid-workflow semantic changes must be classified before applying.

Use the `app` profile for application behavior, platform, data, privacy, accessibility, and integration work. Use the `game` profile for gameplay loops, controls, feel, rules, assets, playtest evidence, and performance budgets.
