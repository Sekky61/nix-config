local function sh(command)
    hl.exec_cmd(command)
end

local function run_if(command)
    sh("sh -lc 'command -v " .. command .. " >/dev/null 2>&1 && " .. command .. "'")
end

hl.on("hyprland.start", function()
    sh("ydotoold")
    sh("systemctl --user start hyprpolkitagent")
    sh("sh -lc 'command -v iio-hyprland >/dev/null 2>&1 && iio-hyprland eDP-1'")
    sh("wl-paste --type text --watch cliphist store")
    sh("wl-paste --type image --watch cliphist store")
    sh("hyprctl setcursor Bibata-Modern-Classic 24")
    sh("handy --start-hidden")
    run_if("ags run")
end)
