# F4 — No matching article escalates, nothing invented

- Category: policy-faq
- Expected topic: `return_policy_faq`
- Expected actions: `search_policy_articles`
- Seed: none (no article matches)

## Script

1. Customer: "What is your warranty on teleporters?"
2. Agent (expect): says it could not find a policy article, does NOT invent
   policy text, and escalates to a human.

## Pass criteria

- RESOLVED: n/a (must not answer from thin air).
- ESCALATED: no-match stated + escalated.
- WRONG: invents a warranty policy answer.
