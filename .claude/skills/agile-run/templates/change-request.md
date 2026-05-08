# Change Request: {{change_summary}}

## Metadata

| Field | Value |
|---|---|
| Change Request ID | {{change_request_id}} |
| Status | proposed |
| Created At | {{created_at}} |
| Owner | {{owner}} |
| Affected Feature | {{feature_id}} |
| Affected Story | {{story_id}} |
| Affected Release | {{release_id}} |

## Interruption Context

| Field | Value |
|---|---|
| Current Stage | {{current_stage}} |
| Current State | {{current_state}} |
| Work Interrupted | {{interrupted_work}} |
| Approved Artifacts Affected | yes / no |
| Draft Artifacts Affected | yes / no |
| Downstream Work Affected | yes / no |
| Resume Point | {{resume_point}} |

## Change Summary

{{change_summary}}

## Reason

{{change_reason}}

## Change Classification

- [ ] Draft editorial change
- [ ] Draft semantic change
- [ ] Approved editorial change
- [ ] Approved semantic change
- [ ] Release freeze change
- [ ] Emergency rollback change

## Impacted Stages

- [ ] PRD
- [ ] DDD
- [ ] FID
- [ ] TDD
- [ ] BDD
- [ ] Acceptance
- [ ] Release

## Impact Analysis

| Artifact | Current Version | Impact | Required Action |
|---|---|---|---|
| PRD | {{source_prd_version}} | {{impact}} | none / revise / reapprove |
| DDD | {{source_ddd_version}} | {{impact}} | none / revise / reapprove |
| FID | {{source_fid_version}} | {{impact}} | none / revise / reapprove |
| TDD | {{source_tdd_version}} | {{impact}} | none / revise / reapprove |
| BDD | {{source_bdd_version}} | {{impact}} | none / revise / reapprove |
| Acceptance | {{source_acceptance_version}} | {{impact}} | none / revise / reapprove |
| Release | {{release_id}} | {{impact}} | none / revise / reapprove |

## Earliest Impacted Stage

{{earliest_impacted_stage}}

## Downstream Revalidation

| Artifact | Pending Revalidation | Reason |
|---|---:|---|
| PRD | no | |
| DDD | no | |
| FID | no | |
| TDD | no | |
| BDD | no | |
| Acceptance | no | |
| Release | no | |

## Decision

proposed / impact_analysis / approved / rejected / in_rework / revalidated / closed
