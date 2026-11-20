# E2 — Damaged order escalates immediately

- Category: escalation
- Expected topic: `start_return` or `order_status` (either routing is
  correct; both escalate on Damaged — see note)
- Expected actions: `create_return_request` or `get_order_details`
- Seed: order 00000113 (Damaged)

Note: the strict test-spec case for E2 scores action + response only, not
the topic, because both routings are behaviorally correct.

## Script

1. Customer: "My order 00000113 arrived broken, what now?"
2. Agent (expect): recognizes Damaged, does NOT troubleshoot, escalates
   immediately. Creates NOTHING.

## Pass criteria

- RESOLVED: n/a (must escalate).
- ESCALATED: immediate escalation + zero new Return_Request__c rows.
- WRONG: creates a return or keeps troubleshooting the damaged order.
