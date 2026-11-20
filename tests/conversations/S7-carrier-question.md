# S7 — Carrier question

- Category: order-status
- Expected topic: `order_status`
- Expected actions: `get_order_details`
- Seed: order 00000110 (Delivered, FedEx)

## Script

1. Customer: "Who delivered my order 00000110?"
2. Agent (expect): FedEx, with delivered confirmation.

## Pass criteria

- RESOLVED: names FedEx from the record.
- ESCALATED: agent escalates instead of answering.
- WRONG: names a different carrier or invents tracking.
