# R1 — Eligible return, reference number (transcript candidate)

- Category: returns
- Expected topic: `start_return`
- Expected actions: `create_return_request`
- Seed: order 00000110 (Delivered 10 days ago, Solar family = returnable)

## Script

1. Customer: "I want to return the solar panel from order 00000110, it arrived scratched."
2. Agent (expect): creates the return via the action and gives the exact
   reference number (RO-xxxx) from the action output.

## Pass criteria

- RESOLVED: return created (verify Return_Request__c row exists) + reference number
  quoted exactly; no invented number.
- ESCALATED: agent escalates an eligible return.
- WRONG: no record created, invented reference, or wrong window math.
