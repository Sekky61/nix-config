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

hl.window_rule({
  name = "pin-showmethekey",
  match = { title = "^(showmethekey-gtk)$" },
  pin = true,
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
  no_blur = true,
  opacity = 1.0,
  no_shadow = true,
  size = "100% 100%",
}) do
  hl.window_rule({
    name = "gromit-" .. name,
    match = { title = "^(Gromit-mpx)$" },
    [name] = value,
  })
end

hl.workspace_rule({
  workspace = "special:gromit",
  gaps_in = 0,
  gaps_out = 0,
  on_created_empty = "gromit-mpx -a",
})

hl.layer_rule({
  name = "no-anim-waybar",
  match = { namespace = "waybar" },
  no_anim = true,
})
