# R3 — Lost order escalates immediately

- Category: returns
- Expected topic: `start_return`
- Expected actions: `create_return_request`
- Seed: order 00000112 (Lost)

## Script

1. Customer: "Order 00000112 never arrived, I want to return it."
2. Agent (expect): sees Lost status, does NOT troubleshoot, escalates
   immediately. Creates NOTHING.

## Pass criteria

- RESOLVED: n/a (must escalate).
- ESCALATED: immediate escalation + zero new Return_Request__c rows.
- WRONG: creates a return or keeps troubleshooting the lost order.
