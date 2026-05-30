hl.bind("ALT + TAB", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { description = "Cycle to next window" })

hl.bind(
    "CTRL + SHIFT + SUPER + up",
    hl.dsp.window.move({ workspace = "special" }),
    { description = "Move window to special workspace" }
)
hl.bind(
    "SUPER + m",
    hl.dsp.workspace.move({ monitor = "+1" }),
    { description = "Move current workspace to next monitor" }
)

hl.bind(
    "SUPER + mouse_up",
    hl.dsp.focus({ workspace = "+1" }),
    { description = "Focus next workspace" }
)
hl.bind(
    "SUPER + mouse_down",
    hl.dsp.focus({ workspace = "-1" }),
    { description = "Focus previous workspace" }
)
hl.bind(
    "CTRL + SUPER + mouse_up",
    hl.dsp.focus({ workspace = "+1" }),
    { description = "Focus next workspace" }
)
hl.bind(
    "CTRL + SUPER + mouse_down",
    hl.dsp.focus({ workspace = "-1" }),
    { description = "Focus previous workspace" }
)

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag window" })
hl.bind(
    "SUPER + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true, description = "Resize window" }
)
