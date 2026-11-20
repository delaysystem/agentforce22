# Service Agent — Order Status and Returns (Service Cloud)

**Demo project in a Salesforce demo org, test data only, not a client project.**

Upwork title: Service Agent, Order Status and Returns, for Service Cloud.

Service teams answer the same three questions all day: where is my order, can
I return it, and what is the return window. This demo builds one Agentforce
Service Agent with three topics that reads live order data instead of guessing:

- **Order Status** — order number (asked or from the customer record) → status,
  carrier, expected delivery, in plain language.
- **Start a Return** — eligibility by order date + product type, return-window
  explanation, return request record + reference number.
- **Return Policy FAQ** — published policy entries only, entry title in
  every answer. (v1–v2 used Knowledge articles via Apex; the Einstein Agent
  license cannot access `Knowledge__kav`, so v3+ answers from Custom Metadata
  via Flow — same grounded-with-citation outcome.)

## Status

Live in `sdolite1`: Agent Script bundle validated (0 errors), published via
the v68 `AiAgentDefinition` + `AiAgentDefinitionVersion` metadata path (the
CLI `agent publish` endpoint 404s; see [docs/publish.md](docs/publish.md)),
v10 Active. The 20-conversation test set ran against the live agent: 14
resolved, 6 escalated, 0 wrong or incomplete — see
[tests/TEST-REPORT.md](tests/TEST-REPORT.md). Artifacts (transcripts,
screenshots, 68 s video) in [docs/artifacts.md](docs/artifacts.md).

## Layout

- `force-app/main/default/` — deployable metadata:
  - `objects/` — 6 Order demo fields; `Return_Request__c` (returns; the
    agent license cannot see standard `ReturnOrder`); `Return_Policy__mdt`
    (policy entries; the agent license cannot see `Knowledge__kav`).
  - `customMetadata/` — 3 published policy entries (window, start-a-return,
    Final Sale).
  - `flows/` — `Get_Order_Details`, `Create_Return_Request`,
    `Search_Policy_Content`, `Log_Handoff_Case` (autolaunched, active,
    agent-bound).
  - `classes/` — `SearchPolicyArticles` + test (SOSL FAQ search; superseded
    for the live agent in v3 by the Flow above — kept, deployed, and green
    as evidence; Apex stays out of the demo per the brief).
  - `permissionsets/` — `Service_Order_Returns_Agent` (read Orders/Cases/
    Knowledge, create returns + handoff cases, run flows).
  - `aiAuthoringBundles/Service_Order_Returns_Agent/` — the Agent Script
    source of truth (3 brief topics + escalation/off-topic/ambiguous).
  - `aiAgents/`, `aiAgentDefinitionVersions/` — v68 publish path (`#1`–`#10`;
    `#10` Active).
- `config/agent/demo-config.json` — single config source (30-day window,
  Final Sale exclusion, escalation triggers, target org).
- `scripts/apex/` — `seed_demo_data.apex` (idempotent demo seed),
  `debug_flows.apex` (maintained action-level harness, 19 checks green).
- `tests/conversations/` — the 20 scripted conversations (8/6/4/2).
- `tests/TEST-REPORT.md` — tally sheet; numbers filled only after testing.
- `specs/` — NGT test-spec YAML (topic/action names verified post-publish).
- `evidence/` — append-only run evidence (seed, debug, SOSL probes).
- `docs/` — publish (user step), channel/handoff, artifacts checklist.

## Demo constants

Single source: `config/agent/demo-config.json`. Return window 30 days from
delivery; `Final Sale` product family excluded; escalate on angry customer,
manager request, or lost/damaged order. Guardrails: never change payment,
address, or account ownership; never quote a refund not read from a record.

## Working with this project

```sh
sf config set target-org sdolite1
sf project deploy start
sf apex run --file scripts/apex/seed_demo_data.apex   # aborts if seeded
sf apex run --file scripts/apex/debug_flows.apex       # action harness
sf apex run test --class-names SearchPolicyArticlesTest
sf agent validate authoring-bundle --api-name Service_Order_Returns_Agent
# publish: v68 metadata path, see docs/publish.md, then:
sf agent activate -n Service_Order_Returns_Agent --version 10
sf agent preview start -n Service_Order_Returns_Agent
```

Target org alias: `sdolite1`. Source API version: 68.0.

## Known residues (demo org, all inert and documented)

- `Search_Return_Policy_Articles` flow remains in the org, unbound:
  superseded first by Apex SOSL, then by the metadata flow; org-side delete
  is blocked by the platform (`insufficient access rights on
cross-reference id`, tried active and obsolete). Removed from this repo;
  documented here instead of hidden.
- Test `Return_Request__c` rows (RR-0000…) plus early standard `ReturnOrder`
  rows (RO-0002…), created by the debug harness and live tests; DEMO data.
- Test handoff `Case` rows (00001120…) from the harness and escalation tests.
- DEMO `Knowledge__kav` articles remain published but unused by the agent
  since v3 (license block, proven in logs); the metadata search replaced them.

## License

Business Source License 1.1 — see [LICENSE](LICENSE). Non-production use is
granted; the file states the Change Date and Change License.
