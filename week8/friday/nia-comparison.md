# Week 7 and Week 8: what changed and what did not

Nia, this is the plain-language comparison you asked for. Week 7 got a new version of the payments service live without downtime. Week 8 changes who does the work: instead of our scripts doing every step, we describe what we want and the platform keeps it true.

| Concern | Week 7 | Week 8 |
|---|---|---|
| How a new version goes live | A script copied the new version onto the server, started it beside the old one, checked that it answered, and then flipped a routing setting so customers reached it. | We write down the wanted state in a file: two copies, this exact packaged version, this much memory. The platform makes it so. The package carries everything the service needs, so the server needs nothing installed. |
| How we go back | Flip the routing setting back. This was fast, but only because the old version was kept running next to the new one, so we paid for two copies at once. | Put the previous version number back in the file and apply it. No spare copy sits idle, but today a person still makes this change by hand. |
| What happens when something breaks | A monitoring script watched the service for a couple of minutes after each switch and went back after three failed checks. Outside that window, nobody was watching. | The platform notices a missing copy at any time and starts a replacement without being asked. |
| How we add capacity | Prepare another server or another port by hand, then wire it in. | Change one number in the file, for example from two copies to five. Every copy is identical because it comes from the same package. |

## Two numbers I measured

**Package size.** The first version I built was a plain single-stage package, and it came to 235 MB. The production package, built in two stages so the compiler and build tools are left behind, came to 89.8 MB. That is 145 MB less, a reduction of about 62 percent. The size matters in practice: my first download of the package onto the cluster took far longer than three minutes on this network, and a package a third of the size is a smaller problem every time that happens.

**Recovery time.** I removed one of the two running copies on purpose and timed how long the platform took to put a healthy replacement in its place. It started the deletion at 22:27:30 and the replacement answered its health check at 22:27:41. That is 11 seconds, with nobody typing anything. The other copy kept serving customers the whole time, so the service never went fully down. For comparison, the Week 7 lab material records about 42 seconds for its automatic rollback. That figure comes from the lab write-up, not from my own run, so I am not treating it as a like-for-like measurement. The two are also different events: one is going back to an old version, the other is replacing a lost copy.

## What Week 8 does not solve

Packaging the service and handing it to a platform fixed the repetitive, error-prone parts. It did not fix everything, and I would rather say so now than have it found later.

First, a person still decides the version, still builds the package, still uploads it and still edits the file. Nothing connects a reviewed change to a running service automatically, so the chance of a slip, like the one that caused the Monday outage in Week 5, has moved rather than gone.

Second, going back to an older version is still a manual edit. The platform will replace a crashed copy by itself, but it has no way to decide that a new version is behaving badly and send us back. Week 7's monitoring script did that job, and I have not rebuilt it here.

Third, the whole setup runs on one small machine. If that machine is lost, both copies go with it. Having two copies protects us from a crash, not from losing the machine.

Fourth, some values are written straight into the files: the port, the version, the memory limits. The login that lets the platform download our package is stored inside the cluster with only basic protection. The base layer I chose for the package is also past its support date, so it will need replacing.

Fifth, we have no measurements that tell us whether customers are really being served well, only a yes-or-no answer to "are you alive". We cannot yet say whether we are meeting our commitments.

## What I expect Week 9 to add

I expect Week 9 to join these pieces up. A reviewed change should build the package, label it with the version and the commit, store it, deploy it and check it, all without anyone typing a command. I also expect it to bring the measurements that let a bad version be rolled back automatically, so that Week 7's safety net and Week 8's platform finally work together.
