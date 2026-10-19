# Factory learnings

What apps taught the factory, and what the founder decided. Written by `/harvest`.

| Date | Source apps | Learning | Decision | Change |
|---|---|---|---|---|
| 2026-10-17 | founder | The new-app script is not how apps get started. The founder copies `template/` into a new repo and wants to start by just brainstorming. | adopted | Removed `scripts/new-app.sh`. Template ships `.factory` with the factory repo. Operator starts `/brainstorm` on the first message. Retro and harvest no longer need a local factory path. |
| 2026-10-17 | founder | New apps are made on GitHub with "Use this template", which copies the whole factory repo. | adopted | Added `scripts/make-app.sh`. The root `CLAUDE.md` tells Claude to run it on the first message in a copy, then start brainstorming. Self test covers it. |
| 2026-10-17 | founder | Signing the PRD with a typed `! ./scripts/signoff.sh` command is too much. A yes in chat is enough. | adopted | `/signoff` now asks Approve or Change in chat, then Claude runs `signoff.sh` to stamp it. The hash gate stays, so code is still locked until approval and after PRD changes. |
| 2026-10-17 | minespel | Claude running `signoff.sh` itself after a chat yes was blocked by the session safety check as approving its own work. | adopted | A new hook, `prd-approve.sh`, stamps the PRD when the founder picks Approve or types "approve". Claude no longer runs the stamp. Self test covers it. |
| 2026-10-19 | founder | Big builds take too long before the kids get something new. Ship workable features in small releases, in short loops after v1. | adopted | v1 is the smallest playable version. New `/release` skill runs one small release at a time (max 5 tasks): pick, approve in chat, build, check, ship, learn. Product, architect, qa, scribe, the PRD template, PLAN, STATUS, factory, build, qa and ship skills updated. |
| 2026-10-19 | founder | Agents should be checked by an independent agent, not by the one that did the work, and the checks must stay cheap. | adopted | New `verifier` agent (haiku, read only, Sonnet rerun only when unsure) and `scripts/verify.sh` (free checks for developer, qa and scribe work, protected by the gate hook). Build, qa and ship skills, developer and architect agents, CLAUDE.md and README updated. Self test covers it. |
