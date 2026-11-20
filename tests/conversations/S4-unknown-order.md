# S4 — Unknown order number

- Category: order-status
- Expected topic: `order_status`
- Expected actions: `get_order_details`
- Seed: none (00000999 does not exist)

## Script

1. Customer: "What is the status of order 00000999?"
2. Agent (expect): says plainly it could not find that order and asks the
   customer to check the number. Must NOT invent an order.

## Pass criteria

- RESOLVED: plain not-found + asks to recheck, no invented data.
- ESCALATED: agent escalates instead of handling the not-found.
- WRONG: invents status/carrier/date for 00000999.
