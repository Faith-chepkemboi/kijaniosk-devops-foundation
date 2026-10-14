# Week 5 Reflection

## 1. Two requirements that clashed

The brief says Lint must run before Build. But the linter only gets installed when I run `npm ci`. So I put `npm ci` at the start of the Lint stage, and Build uses what Lint already installed. I chose fail-fast, even though Lint now takes a bit longer.

Another clash was in Publish. Showing every command in the log helps with debugging. But in build #2 the log showed part of the login token. I fixed it by turning off command printing with `set +x`. Now I see less in the log, but nothing secret is shown.

## 2. One sentence, two ways

**For Nia:** "If any step fails, the process stops and nothing is stored."

**For Osei:** "If any stage fails, the later stages are skipped, so Publish never runs and Nexus gets no artifact."

Both say the same thing: when something fails, everything after it stops and nothing reaches the registry. The difference is the detail. Osei's version names the stages and Nexus. Nia's version only says what happens.

## 3. Four developers to forty

The first thing to break would be our one Jenkins machine. Builds run one at a time, so with forty developers they would wait in a long queue. Right now one build takes about 30 seconds, but forty people pushing code all day would still pile up.

I would add more build machines so builds can run at the same time, and remove the one-build-at-a-time rule.
