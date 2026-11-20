# S6 — Delivery estimate question

- Category: order-status
- Expected topic: `order_status`
- Expected actions: `get_order_details`
- Seed: order 00000109 (In Transit, delivery estimate set)

## Script

1. Customer: "When will order 00000109 arrive?"
2. Agent (expect): gives the expected delivery date from the record plus
   current In Transit status.

## Pass criteria

- RESOLVED: estimate matches the record; status included.
- ESCALATED: agent escalates instead of answering.
- WRONG: invents a date or says the order was not found.
