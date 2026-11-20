# S8 — Old delivered order status

- Category: order-status
- Expected topic: `order_status`
- Expected actions: `get_order_details`
- Seed: order 00000111 (Delivered 75 days ago, DHL)

## Script

1. Customer: "Is order 00000111 still on its way?"
2. Agent (expect): says it was delivered (with date), via DHL. Plain language.

## Pass criteria

- RESOLVED: delivered state + date + carrier from the record.
- ESCALATED: agent escalates instead of answering.
- WRONG: says in transit / not found / invents details.
