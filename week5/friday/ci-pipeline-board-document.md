# How Our Code Becomes an Approved Version

## From a saved change to a stored version

Every time a developer saves a change to our project, the system starts checking it on its own. It looks at how the code is written first, because that is the quickest check and catches careless mistakes in seconds. Then it builds the package, and tests it and runs a safety check on its ingredients at the same time. In my runs the whole thing took about half a minute. If every step passes, the package is stored in our registry with a version label made of the product version plus a short code that points to the exact change behind it. If any step fails, the process stops there and nothing is stored.

## Why the version label matters

For a payments platform, we must always be able to answer one question: exactly which code is running? Because each label ends with a code tied to one specific change, we can trace any stored package back to who made it, when, and why. The registry is also set to refuse a second package with the same label, so nobody can quietly replace a version that was already approved.

## The steps and what each one confirms

| Step | What it confirms |
|---|---|
| Check the writing | The code follows our style rules and has no typos that would break it |
| Build the package | The code can be assembled into a complete, working package |
| Run the tests | The code does what we expect it to do |
| Safety check | The parts we ship to customers contain no known serious weaknesses |
| Keep a copy | A fingerprinted copy is saved, so we can prove which build produced it |
| Store in the registry | The package is filed under its own unique version label |

## What Happens When Something Goes Wrong

To be sure the system really stops bad changes, I broke each main step on purpose, one at a time, and watched what happened. After each test I fixed the problem and confirmed everything returned to normal.

- **A typo in the code:** it was caught at the very first step, within seconds. Nothing else ran, so no time was spent building something already faulty.
- **A broken build:** the writing check passed but the build failed. Testing and storing were skipped, because testing a package that does not exist tells us nothing.
- **A failing test:** the tests failed, but the safety check still ran to the end. The developer sees every problem at once instead of fixing one and discovering another. Saving and storing were skipped.
- **A failure keeping the copy:** the tests and safety check passed, but the copy could not be saved, so storing was skipped. Nothing reaches the registry without a record.
- **A wrong login for the registry:** everything passed and a copy was kept, but the final step was refused. The registry received nothing, so it never holds a half-finished version.

In every case the working area was cleaned up afterwards, and the log recorded that the result had changed from passing to failing, so the problem is easy to spot. What nobody gets is a package that skipped a check.

## What this does not do yet

This system stops at storing a package. It does not put that package into use; deployment is a separate step still to be built. The safety check covers only what we ship to customers, not the tools developers use, where dozens of known weaknesses are reported. The registry account the system uses has broader rights than it needs and should be narrowed. Every run creates a new version, even when the code is identical, so there is no separate "approved for release" stage yet. Alerts appear in the log but are not yet sent to the team by email or chat. Finally, our tests are three simple checks; they do not yet cover real payment scenarios or heavy load. Passwords are changed by hand in two places, and we saw one run fail when they did not match.
