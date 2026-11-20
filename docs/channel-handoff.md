# Web chat channel + human handoff (manual UI steps)

Channel work is UI-only in `sdolite1`; nothing here is CLI-deployable, so this
doc is the click-path. Status: NOT-RUN (needs the published agent + UI access).

## 1. Human queue

1. Setup → Queues → New: e.g. `Service_Agent_Escalations`.
2. Supported objects: Messaging Session (and Case as backup).
3. Add the demo service users as members.
4. Note the queue DeveloperName for the routing step.

## 2. Omni-Channel routing

1. Setup → Omni-Channel → Routing Configurations → New (Most Available or
   similar), capacity 1, tied to the queue above.
2. Presence Statuses: ensure an Available-for-Messaging status exists.

## 3. Messaging channel

1. Setup → Messaging Settings → New Channel → Enhanced WhatsApp/Messaging for
   Web (per what the demo org offers) or Embedded Service Chat for web chat.
2. Enable Agentforce/agent handoff on the channel where offered.
3. Create a Messaging Component / Chat Button + Deployment pointing at the
   queue; embed on the demo site page.

## 4. Agent handoff wiring

1. In Agent Builder for Service Order Returns Agent, set the escalation
   action target to the Omni-Channel flow/queue from step 2.
2. Handoff context (already in the Agent Script): before every
   `@utils.escalate`, the agent saves `current_order_number` and
   `issue_summary` (question + what was tried). Verify in Agent Builder that
   these variables are passed to the handoff / pre-chat transcript.
3. Fallback the brief requires: if escalation fails, the agent offers to log
   a support Case instead (in the escalation topic instructions).

## 5. Verify (manual)

1. Start a web-chat session as the demo customer.
2. Run E1 (angry / manager request): a human must receive the chat with the
   order number (when known), the question, and the tried-steps summary.
3. Run R2 (out-of-window): same handoff check with the window explanation in
   the transcript.
4. Record pass/fail in `tests/TEST-REPORT.md` alongside the 20.
