local function set_env(env)
    for name, value in pairs(env) do
        hl.env(name, value)
    end
end

set_env({
    QT_QPA_PLATFORM = "wayland",
    QT_QPA_PLATFORMTHEME = "qt5ct",
    QT_STYLE_OVERRIDE = "kvantum",
    GDK_SCALE = "1",
    XCURSOR_SIZE = "32",
})

hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 3,
        gaps_workspaces = 50,
        layout = "master",
        resize_on_border = true,
        border_size = 1,
    },
    master = {
        mfact = 0.7,
        new_status = "slave",
        -- Main window is on the left, but once there are 4+ slaves, it moves to center
        orientation = "center",
        slave_count_for_center_master = 4,
        center_master_fallback = "left",
    },
    dwindle = {
        preserve_split = true,
        smart_resizing = false,
    },
    input = {
        sensitivity = 0.2,
        kb_layout = "us,cz",
        kb_options = "grp:alt_shift_toggle,caps:super",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = false,
            clickfinger_behavior = true,
            scroll_factor = 0.5,
        },
        special_fallthrough = true,
    },
    decoration = {
        rounding = 5,
        blur = {
            enabled = true,
            xray = true,
            special = false,
            size = 5,
            passes = 4,
            brightness = 1,
            noise = 0.01,
            contrast = 1,
        },
        shadow = {
            enabled = true,
            offset = "0 2",
            range = 20,
            render_power = 2,
        },
        dim_inactive = true,
        dim_strength = 0.1,
        dim_special = 0,
    },
    animations = {
        enabled = true,
    },
    misc = {
        vrr = 1,
        key_press_enables_dpms = true,
        mouse_move_enables_dpms = true,
        focus_on_activate = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,
        enable_swallow = false,
        swallow_regex = "(foot|kitty|allacritty|Alacritty)",
        disable_hyprland_logo = true,
        on_focus_under_fullscreen = 2,
    },
    xwayland = {
        force_zero_scaling = true,
    },
    binds = {
        scroll_event_delay = 0,
    },
})

local curves = {
    md3_decel = { { 0.05, 0.7 }, { 0.1, 1 } },
    md3_accel = { { 0.3, 0 }, { 0.8, 0.15 } },
    overshot = { { 0.05, 0.9 }, { 0.1, 1.1 } },
    crazyshot = { { 0.1, 1.5 }, { 0.76, 0.92 } },
    hyprnostretch = { { 0.05, 0.9 }, { 0.1, 1.0 } },
    fluent_decel = { { 0.1, 1 }, { 0, 1 } },
    easeInOutCirc = { { 0.85, 0 }, { 0.15, 1 } },
    easeOutCirc = { { 0, 0.55 }, { 0.45, 1 } },
    easeOutExpo = { { 0.16, 1 }, { 0.3, 1 } },
}

for name, points in pairs(curves) do
    hl.curve(name, { type = "bezier", points = points })
end

for _, animation in ipairs({
    { leaf = "windows", enabled = true, speed = 3, bezier = "md3_decel", style = "popin 60%" },
    { leaf = "border", enabled = true, speed = 10, bezier = "default" },
    { leaf = "fade", enabled = true, speed = 2.5, bezier = "md3_decel" },
    { leaf = "workspaces", enabled = false, speed = 0, bezier = "default" },
}) do
    hl.animation(animation)
end
