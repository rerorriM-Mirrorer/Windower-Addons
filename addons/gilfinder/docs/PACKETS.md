# Currency packet observations and reference definitions

This batch reads balances and requests the standard currency-menu snapshot.
No purchase, menu-choice, trade or NPC-interaction packets are sent.

| Scenario | Direction | ID | Fields/use | Evidence and confidence |
| --- | --- | --- | --- | --- |
| Currency menu snapshot request | Outgoing | 0x10F | Empty currency-menu request | Windower/Lua dev fields.outgoing[0x10F]; Ivaar Currencies pairs it with 0x113. Definition-backed, live capture pending. |
| Currency information reply | Incoming | 0x113 | Sparks of Eminence; Conquest Points (San d'Oria), (Bastok), (Windurst) | Windower packet definitions; no offsets recreated. Definition-backed, purchase refresh/latency needs live verification. |
| Passive Sparks update | Incoming | 0x110 | Sparks Total | Windower packet definitions; update timing needs live verification. |

References: addons/libs/packets/fields.lua in this source repository;
https://github.com/Windower/Lua/blob/dev/addons/libs/packets/fields.lua
and https://gist.github.com/Ivaar/a95d9e565bd9a0e2036179c0c8cdee58

Requests are necessary because not every currency balance is guaranteed to be
sent as a passive update. They occur after inventory ready, explicit query,
menu open/close and a 60-second fallback, capped at one request per two seconds.
Throttled explicit/menu requests are deferred to a later prerender. Replies
are parsed with Windower packets; blocked/injected incoming chunks are ignored.
The first sample establishes baseline without an earned/spent notification.
Unknown values remain unknown. Samples are session-only and cleared on zoning.

Repeated observations: none live in this environment. Automated synthetic
fixtures exercise zero, gains, losses, multiple nations, missing fields,
invalid negative values, failed parsing, throttling, deferred refresh and reset.
No synthetic test is evidence that the server sends a reply at a specific time.

Live recording needed: native currency menu initial reply; ordinary Sparks
gain; CP gain; CP/Sparks purchase through NPCmirror and manual menus; rapid
menu open/close; zoning while waiting; compare native menu amounts and tray.
Record whether 0x113/0x110 arrives and delay. No controlled captures claimed.
