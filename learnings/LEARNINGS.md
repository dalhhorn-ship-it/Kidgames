# Factory learnings

What apps taught the factory, and what the founder decided. Written by `/harvest`.

| Date | Source apps | Learning | Decision | Change |
|---|---|---|---|---|
| 2026-10-17 | founder | The new-app script is not how apps get started. The founder copies `template/` into a new repo and wants to start by just brainstorming. | adopted | Removed `scripts/new-app.sh`. Template ships `.factory` with the factory repo. Operator starts `/brainstorm` on the first message. Retro and harvest no longer need a local factory path. |
| 2026-10-17 | founder | New apps are made on GitHub with "Use this template", which copies the whole factory repo. | adopted | Added `scripts/make-app.sh`. The root `CLAUDE.md` tells Claude to run it on the first message in a copy, then start brainstorming. Self test covers it. |
