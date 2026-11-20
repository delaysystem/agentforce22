# R5 — Not-delivered order cannot be returned yet

- Category: returns
- Expected topic: `start_return`
- Expected actions: `create_return_request`
- Seed: order 00000109 (In Transit)

## Script

1. Customer: "I want to return order 00000109 before it arrives."
2. Agent (expect): explains returns open once the order is delivered.
   Creates NOTHING. No escalation needed (factual answer).

## Pass criteria

- RESOLVED: clear not-delivered explanation, zero new rows, no escalation.
- ESCALATED: agent escalates a case it could answer factually.
- WRONG: creates a return for an in-transit order.
