# S2 — Delivered order confirmation

- Category: order-status
- Expected topic: `order_status`
- Expected actions: `get_order_details`
- Seed: order 00000110 (Delivered, FedEx, delivered 10 days ago)

## Script

1. Customer: "Has order 00000110 arrived?"
2. Agent (expect): confirms delivered, names FedEx and the delivered date.

## Pass criteria

- RESOLVED: answer confirms delivery with carrier and date from the record.
- ESCALATED: agent escalates instead of answering.
- WRONG: says still coming / not found / invents a different date.
