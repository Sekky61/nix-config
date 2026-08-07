hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.gesture({
    fingers = 4,
    direction = "up",
    action = function()
        hl.exec_cmd("xdg-open https://youtube.com/shorts")
    end,
})

hl.window_rule({
    name = "no-blur-all",
    match = { title = ".*" },
    no_blur = true,
})

for _, title in ipairs({
    "^(Open File)(.*)$",
    "^(Select a File)(.*)$",
    "^(Choose wallpaper)(.*)$",
    "^(Open Folder)(.*)$",
    "^(Save As)(.*)$",
    "^(Library)(.*)$",
}) do
    hl.window_rule({
        name = "float-dialog-" .. title,
        match = { title = title },
        float = true,
    })
end

for name, value in pairs({
    float = true,
    no_blur = true,
    no_initial_focus = true,
    opacity = 1.0,
    no_shadow = true,
    pin = true,
    size = "100% 100%",
}) do
    hl.window_rule({
        name = "gromit-" .. name,
        match = { title = "^(Gromit-mpx)$" },
        [name] = value,
    })
end

hl.layer_rule({
    name = "no-anim-waybar",
    match = { namespace = "waybar" },
    no_anim = true,
})
