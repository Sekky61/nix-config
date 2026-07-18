local function sh(command)
    hl.exec_cmd(command)
end

hl.on("hyprland.start", function()
    sh("ydotoold")
    sh("systemctl --user start hyprpolkitagent")
    sh("sh -lc 'command -v iio-hyprland >/dev/null 2>&1 && iio-hyprland eDP-1'")
    sh("wl-paste --type text --watch cliphist store")
    sh("wl-paste --type image --watch cliphist store")
    sh("hyprctl setcursor Bibata-Modern-Classic 24")
end)
