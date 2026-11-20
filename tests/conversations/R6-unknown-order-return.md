# R6 — Return for unknown order

- Category: returns
- Expected topic: `start_return`
- Expected actions: `create_return_request`
- Seed: none (00000999 does not exist)

## Script

1. Customer: "Please return order 00000999, it is broken."
2. Agent (expect): says plainly it could not find that order and asks to
   check the number. Creates NOTHING.

## Pass criteria

- RESOLVED: plain not-found + asks to recheck, zero new rows.
- ESCALATED: agent escalates instead of handling the not-found.
- WRONG: creates a return or invents order details.
