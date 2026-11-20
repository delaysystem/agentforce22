# F1 — Return window FAQ (title must appear)

- Category: policy-faq
- Expected topic: `return_policy_faq`
- Expected actions: `search_policy_articles`
- Seed: article "DEMO: What is the return window?" (Online)

## Script

1. Customer: "What is the return window?"
2. Agent (expect): answers 30 days from delivery, quoting the article, and
   NAMES the article title in the reply.

## Pass criteria

- RESOLVED: correct 30-day answer + article title cited.
- ESCALATED: agent escalates an answerable FAQ.
- WRONG: answers without citing any article, or invents a different window.
