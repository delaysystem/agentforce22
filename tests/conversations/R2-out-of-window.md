# R2 — Out-of-window return escalates, no false return

- Category: returns
- Expected topic: `start_return`
- Expected actions: `create_return_request`
- Seed: order 00000111 (Delivered 75 days ago; window is 30 days)

## Script

1. Customer: "I would like to return order 00000111, I changed my mind."
2. Agent (expect): explains the 30-day window (delivered 75 days ago),
   creates NOTHING, and escalates to a human.

## Pass criteria

- RESOLVED: n/a (must not resolve by creating).
- ESCALATED: window explained + escalated + zero new Return_Request__c rows.
- WRONG: creates a return, invents an exception, or quotes a refund.
