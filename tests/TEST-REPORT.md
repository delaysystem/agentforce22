# Demo test report — Service_Order_Returns_Agent, sdolite1

> Demo test set, 20 conversations: 14 resolved, 6 escalated, 0 wrong or incomplete.

Demo project in a Salesforce demo org, test data only, not a client project.
Active version at sign-off: v10.

## Method (read before the numbers)

- The 20 scripts in `tests/conversations/` ran as live `sf agent preview`
  sessions against the published agent: full fresh pass on v7
  (`evidence/eval-live-v7/`), plus re-verification on v8/v9/v10 for every
  case whose topic changed after v7 (`evidence/eval-live-v8/`,
  `evidence/eval-live-v9/`, `evidence/eval-live-v10/`). Each verdict below
  cites its transcript.
- The automated NGT runner could not be used: `sf agent test run` 500s in
  `EvalService` and `sf agent test run-eval` fails with org `login rate
exceeded` (evidence: `evidence/agent-test-run-eval-001.log`,
  `evidence/agent-test-run-eval-002.log`). Same 20 scripts, same pass
  criteria, live sessions instead.
- Multi-turn cases (S5, R2, R5, R6) ran in one session each; the verdict
  reflects the completed conversation, turns noted.

## Tally (v9 active)

| Case | Verdict   | Evidence                                                                                                                                                                                             |
| ---- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S1   | RESOLVED  | `eval-live-v7/S1.turn1.json` — In Transit + UPS + 2026-11-03 + tracking                                                                                                                              |
| S2   | RESOLVED  | `eval-live-v7/S2.turn1.json` — delivered FedEx 2026-10-20                                                                                                                                            |
| S3   | RESOLVED  | `eval-live-v7/S3.turn1.json` — processing, nothing invented                                                                                                                                          |
| S4   | RESOLVED  | `eval-live-v7/S4.turn1.json` — plain not-found + recheck                                                                                                                                             |
| S5   | RESOLVED  | `eval-live-v7/S5.json` — asked first, then correct (2 turns)                                                                                                                                         |
| S6   | RESOLVED  | `eval-live-v7/S6.turn1.json` — estimate + status                                                                                                                                                     |
| S7   | RESOLVED  | `eval-live-v7/S7.turn1.json` — FedEx from record                                                                                                                                                     |
| S8   | RESOLVED  | `eval-live-v7/S8.turn1.json` — delivered DHL 2026-08-16                                                                                                                                              |
| R1   | RESOLVED  | `eval-live-v9/R1.turn1.json` — created, ref RR-0012 quoted exactly                                                                                                                                   |
| R2   | ESCALATED | `eval-live-v9/R2.turn2.json` — 76 days / 30-day window quoted + transfer + handoff case 00001139                                                                                                     |
| R3   | ESCALATED | `eval-live-v7/R3.turn1.json` — immediate transfer + handoff case                                                                                                                                     |
| R4   | ESCALATED | `eval-live-v9/R4.turn1.json` — Final Sale explained + transfer + handoff case 00001138                                                                                                               |
| R5   | RESOLVED  | `eval-live-v9/R5.turn2.json` — not-delivered explanation, no return, no escalation                                                                                                                   |
| R6   | RESOLVED  | `eval-live-v9/R6.turn1.json` — plain not-found + recheck                                                                                                                                             |
| F1   | RESOLVED  | `eval-live-v10/F1.turn1.json` — 30-day answer + title cited                                                                                                                                          |
| F2   | RESOLVED  | `eval-live-v10/F2.turn1.json` — entry steps + title cited                                                                                                                                            |
| F3   | RESOLVED  | `eval-live-v10/F3.turn1.json` — correct no + title cited                                                                                                                                             |
| F4   | ESCALATED | `eval-live-v10/F4.turn1.json` + `F4.turn2.json` — honest no-match, transfer completes on turn 2. Caveat: turn-1 form varies (offer vs statement); the transfer completed every time it was accepted. |
| E1   | ESCALATED | `eval-live-v7/E1.turn1.json` — immediate transfer + handoff case                                                                                                                                     |
| E2   | ESCALATED | `eval-live-v7/E2.turn1.json` — immediate transfer + handoff case                                                                                                                                     |

Anti-invention check: all 8 status answers match the seeded Order rows
exactly, and all 13 Return_Request__c rows (RR-0000..RR-0012) belong to
eligible order 00000110 only — zero false returns across every version,
including the wrong-or-incomplete cases.

## Handoff proof (replaces the Omni UI check)

Every escalation path now logs a DEMO Case carrying order number, question,
and tried steps before transferring (Flow `Log_Handoff_Case`, called from
the Escalation topic and, since v9, from Start a Return). Verified by query,
e.g. R2 -> case 00001139, R4 -> case 00001138, R3/E2/E1 -> cases
00001123-25/34-37. Only exception: the FAQ topic's platform `canEscalate`
path cannot invoke actions, so an FAQ transfer would carry no case
(F4 is the only case on that path).

## Version history (how the gaps closed)

- v1/v2: 11/3/6. FAQ dead (agent license cannot access `Knowledge__kav`,
  proven in ApexLog); lost/damaged troubleshot instead of transferring.
- v3: FAQ moved to Flow + Custom Metadata; lost/damaged routed at the
  router; handoff cases added. R1 regressed (router over-fires on
  "scratched").
- v4: router carve-outs + keyword enrichment. 11/8/1. F3 still missed
  (Contains vs phrasing); R1 still over-routed.
- v5: FAQ redesigned to digest + LLM selection; lexical SCRATCHED rule.
  F3/R1 fixed; F4 stopped transferring; R5 regressed (false "being
  processed" promise, zero rows — flow backstop held).
- v6/v7: F4 wording attempts, both failed (accepted as the remaining gap).
- v8: anti-promise rule. R5 fixed.
- v9: handoff-case logging added to Start a Return. R2/R4 escalations now
  log cases.
- v10 (active): FAQ redesigned to phrase matching + flag-driven escalation
  (digest dropped: self-judged no-match never transferred, the flag does).
  F4 fixed via 2-turn completion. Final: 14/6/0.
