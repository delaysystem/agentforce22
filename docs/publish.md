# Publishing the agent (user step)

The Agent Script bundle is authored, validated (`sf agent validate
authoring-bundle`, 0 errors), compiled successfully server-side, and deployed
to `sdolite1` as `AiAuthoringBundle` metadata. One step remains outside this
environment: publishing the bundle into an active agent.

## Why not from here

`sf agent publish authoring-bundle` fails in this sandbox at the Publish Agent
stage. Diagnosis (instrumented, reproducible):

- `POST https://api.salesforce.com/einstein/ai-agent/v1.1/authoring/agents`
  returns HTTP 404 with an empty body (compile via `.../authoring/scripts`
  succeeds, spec generation succeeds, old-flow preview succeeds).
- The CLI then falls back to `test.api.salesforce.com`, which is unreachable
  from this sandbox (TCP timeout on 443 and 80; `dev.api.salesforce.com`
  likewise). Production `api.salesforce.com` and the org instance respond
  normally, so this is specific to the v1.1 agents endpoint + pilot fallback
  hosts, not general connectivity.

The publish must therefore run where those endpoints are reachable, or via the
org UI (server-side). Either option below works.

## Option A (recommended): Agent Builder UI

1. Open `sdolite1`: `sf org open -o sdolite1`
2. Setup → Agentforce Agents (or Agent Builder) → find **Service Order
   Returns Agent** (API name `Service_Order_Returns_Agent`).
3. Review the three topics: Order Status, Start a Return, Return Policy FAQ.
4. Publish/Commit, then Activate the agent.
5. Tell the assistant it is published (paste the agent API name if it differs).

## Option B: CLI from your network

From any machine with this repo and `sdolite1` authenticated:

```sh
sf agent publish authoring-bundle --api-name Service_Order_Returns_Agent
sf agent activate --api-name Service_Order_Returns_Agent  # if a separate step is offered
```

If Option B also 404s, the org is not serving v1.1 agent creation and Option A
(UI, server-side) is the path; report the exact error back.

## After publish (assistant resumes here)

```sh
sf agent preview --api-name Service_Order_Returns_Agent --use-live-actions -d evidence/
sf agent test create --spec specs/Service_Order_Returns_Agent-ngtTestSpec.yaml --test-runner agentforce-studio
sf agent test run ...
```

First the topic/action DeveloperNames in the test-spec are verified against
the retrieved `GenAiPlugin`/`GenAiFunction` metadata, then preview
transcripts are captured and the 20-conversation test set runs for the honest
X/Y/Z report.
