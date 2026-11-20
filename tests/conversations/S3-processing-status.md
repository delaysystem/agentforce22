# S3 — Processing order, not shipped yet

- Category: order-status
- Expected topic: `order_status`
- Expected actions: `get_order_details`
- Seed: order 00000115 (Processing, no carrier)

## Script

1. Customer: "Can you track order 00000115 for me?"
2. Agent (expect): says the order is processing / not shipped yet, no carrier
   or tracking yet. Must NOT invent carrier or tracking.

## Pass criteria

- RESOLVED: processing state stated, no invented carrier/tracking.
- ESCALATED: agent escalates instead of answering.
- WRONG: invents a carrier, tracking link, or delivery date.
