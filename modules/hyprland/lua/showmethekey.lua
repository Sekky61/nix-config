-- Show pressed keys on screen for demos/screen sharing.
-- The bind can toggle by killing the existing process or starting a new one.
-- Keep the pkill pattern anchored so it does not match the `sh -c` wrapper
-- created by exec_cmd before the app can spawn.
local command = "showmethekey-gtk --keys-win --no-app-win"

hl.window_rule({
    name = "pin-showmethekey",
    match = { title = "Floating Window - Show Me The Key" },
    pin = true,
    float = true,
    size = { 800, 120 },
    border_size = 0,
    move = { "(monitor_w * 0.5)", "monitor_h - 150" },
})

hl.bind(
    "SUPER + ALT + K",
    hl.dsp.exec_cmd("pkill -f '^showmethekey-gtk( |$)' || " .. command),
    { description = "Toggle pressed keys overlay" }
)
