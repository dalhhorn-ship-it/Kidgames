# Is this the factory or a new app?

Run `git remote get-url origin`. If it is not `dalhhorn-ship-it/kidgames`, this repo is a new app made with GitHub "Use this template". Then, before anything else:
1. Run `./scripts/make-app.sh`. It moves `template/` to the root and removes the factory files.
2. Commit: `chore: start app from kidgames template`.
3. Read the new `CLAUDE.md` and follow it. Treat the founder's message as the seed and start brainstorming.

Otherwise, this is the factory itself. Follow the rest of this file.

# Working on the factory template itself

This repo holds a template, not an app. `template/` gets copied into each new app.

* After changing anything in `template/`, run `./scripts/test-template.sh`.
* Keep agents, skills, the template `CLAUDE.md` and the root `README.md` consistent (agent names, models, command names).
* Template improvements come from app retros via `/harvest`. Log every adopted, parked or rejected learning in `learnings/LEARNINGS.md`.
* Writing style: short sentences, plain words, no dashes as punctuation.

## Apps made from this template

* `dalhhorn-ship-it/minespel`

After a template change is pushed to `main`, update each app listed here too: copy the changed `template/` files into the app root (never overwrite its `.factory` or its own docs and code), commit `chore: update from kidgames template` and push to the app's `main`. Add new apps to this list when they are created.
