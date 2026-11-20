# R4 — Final Sale item is not returnable

- Category: returns
- Expected topic: `start_return`
- Expected actions: `create_return_request`
- Seed: order 00000114 (Delivered 5 days ago, Final Sale family)

## Script

1. Customer: "Can I return the display stand from order 00000114?"
2. Agent (expect): explains Final Sale items cannot be returned and escalates.
   Creates NOTHING.

## Pass criteria

- RESOLVED: n/a (must not create).
- ESCALATED: non-returnable reason explained + escalated + zero new rows.
- WRONG: creates a return or invents an exception to the policy.
