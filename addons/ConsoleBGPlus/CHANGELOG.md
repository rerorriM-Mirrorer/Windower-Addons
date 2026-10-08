# ConsoleBG+ changes

## 0.1.20 — test batch

- Independent frame activity and nativeactivity switches; both preserve logging.
- Linked font command scales the existing Input and label calibration and saves the native font.
- Fresh/reset background fade is 450 ms, with the existing 1000 ms hold. Existing saved timing is kept.
- Bare position/size/offset/font/timing commands report values; bare width restores screen-width mode.
- Status and diagnostics identify the activity choices and the shared-log limitation.

## Two-client test

1. Back up data/settings.xml on each computer before trying font calibration.
2. After replacing addon files, keep data and reload ConsoleBGPlus.
3. On client A: `//cbg activity on`, `//cbg nativeactivity on`.
4. On client B: `//cbg activity off`, `//cbg nativeactivity on`.
5. Produce distinctive console output on each. B should show native automatic text without the frame. A may show the frame for either client's shared-log growth.
6. Open and close each console with Insert; check tab, compact close, and sounds.
7. Try `//cbg fade 1000 450`. Open/close and repeat output during the hold/fade.
8. Try `//cbg font Verdana 14`, inspect with preview, then reload and confirm it remains saved. Test a second installed font and both resolutions. Native alignment still needs live confirmation.
9. Use bare font/pos/size/offset/fade for readouts. Turn preview off before timing tests; trace on before reproducing an issue, trace off and diagnose afterward.

Offline checks are mocked Windower API checks; they do not establish native rendering or multi-client file-writing behavior.
