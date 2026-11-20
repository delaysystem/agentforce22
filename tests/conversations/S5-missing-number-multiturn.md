# S5 — Missing order number, multi-turn (tests clarification)

- Category: order-status
- Expected topic: `order_status`
- Expected actions: `get_order_details`
- Seed: order 00000109 (In Transit, UPS)

## Script

1. Customer: "Where is my package?"
2. Agent (expect): asks for the order number (no guessing).
3. Customer: "It is 00000109."
4. Agent (expect): In Transit + UPS + delivery estimate + tracking text.

## Pass criteria

- RESOLVED: asks first, then answers correctly from the record.
- ESCALATED: agent escalates instead of asking/answering.
- WRONG: answers without an order number, or invents order data.
