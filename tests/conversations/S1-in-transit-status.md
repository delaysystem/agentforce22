# S1 — In-transit order status (primary demo + video candidate)

- Category: order-status
- Expected topic: `order_status`
- Expected actions: `get_order_details`
- Seed: order 00000109 (In Transit, UPS, delivery estimate set, tracking link set)

## Script

1. Customer: "Where is my order 00000109?"
2. Agent (expect): plain-language answer with In Transit status, UPS carrier,
   expected delivery date, and tracking link text. No invented details.

## Pass criteria

- RESOLVED: answer contains In Transit + UPS + a delivery date + tracking text.
- ESCALATED: agent escalates instead of answering (wrong path, counts as escalated).
- WRONG: any invented order data, or claims the order was not found.
