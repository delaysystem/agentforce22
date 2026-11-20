# Demo artifacts checklist

## CLI-captured (assistant, post-publish)

- [x] Transcript 1: S1 order-status success — `evidence/eval-live/S1.turn1.json`
      (also `evidence/preview-S1-001.json`). In Transit + UPS + 2026-11-03 +
      tracking, matches seed.
- [x] Transcript 2: R1 return creation with reference number —
      `evidence/eval-live/R1.turn1.json` (ref RR-0003; live retests RR-0001,
      RR-0004 in `evidence/preview-R1-003.json`, `evidence/eval-live/R1.v2.json`).
- [x] `tests/TEST-REPORT.md`: filled after the 20 ran — final (v10):
      14 resolved, 6 escalated, 0 wrong or incomplete. Full fresh pass on
      v7 (`evidence/eval-live-v7/`) plus v8/v9/v10 spot re-verification of
      touched topics (`evidence/eval-live-v8/`, `evidence/eval-live-v9/`,
      `evidence/eval-live-v10/`).

## UI-captured (assistant via Patchright, sdolite1)

- [x] Builder screenshot: topic graph showing Order Status, Start a Return,
      Return Policy FAQ (plus Escalation/Off Topic/Ambiguous) —
      `evidence/builder-topics-001.png` (v1),
      `evidence/builder-v2-topics-002.png` (v2 Active).
- [x] Action I/O screenshots: `Get_Order_Details` inputs
      (`evidence/action-get-order-details-inputs-001.png`: Order Number,
      Account ID) and outputs
      (`evidence/action-get-order-details-outputs-001.png`: Found, Order
      Status, Shipment Status, Carrier, Delivery Estimate, Delivered Date,
      Result Message). Taken in Agent Builder's action view, not the Flow
      Builder canvas: the Setup app in this org renders empty / "Sorry to
      interrupt" (see `/tmp/sf-flow-retry.png`), so the canvas was
      unreachable. Same inputs/outputs, agent-facing surface.
- [x] Video, 68.6 s single take: `evidence/video-S5-status-001.webm`
      (1600x1000, 15 fps, Xvfb + xterm + ffmpeg x11grab). One order-status
      conversation start to close, live published agent, no cuts: S5 flow
      ("Where is my package?" -> number -> answer -> thanks). S1 script was
      used for the transcript artifacts; the video uses S5 because one
      question answered too fast to reach 60 s honestly. Method disclosed:
      terminal recording of `sf agent preview` (Builder Preview chat panel
      does not load in this org).

## Handoff (live-verified via Case records)

- Plan change: instead of an Omni-queue UI check (Setup UI unusable in this
  org), every escalation logs a DEMO handoff Case carrying order number,
  question, and tried steps (Flow `Log_Handoff_Case`). Verified by query,
  e.g. R2 -> case 00001139, R4 -> case 00001138, plus R3/E2/E1 cases
  00001123-25/34-37.
- Covered paths: Escalation topic (E1/R3/E2) and, since v9, in-topic
  Start a Return transfers (R2/R4). Only gap: the FAQ topic's platform
  `canEscalate` path cannot invoke actions (F4 is the only case there).
- Handoff context fields (`current_order_number`, `issue_summary`) are
  defined in the Agent Script and set before every escalation (validated
  bundle). Messaging context variables (ContactId/EndUserId/RoutableId)
  linked for web-chat/Omni routing.
- NOT live-verified: the Omni human queue receiving the transfer, and an
  embedded web-chat surface. Manual wiring steps are in
  `docs/channel-handoff.md`.

## Rules (from the brief)

- No published numbers before testing; report resolved, escalated, AND
  wrong/incomplete.
- Every artifact keeps the demo label: demo org, test data only.
