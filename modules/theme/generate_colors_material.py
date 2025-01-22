#!/usr/bin/env python3
from material_color_utilities_python import *
from pathlib import Path
from PIL import Image
import sys
import subprocess
import os

# Configuration for wallpaper sources
WALLPAPER_SOURCES = {
    'hyprpaper': "hyprctl hyprpaper listloaded",
    'swww': "swww query | awk -F 'image: ' '{print $2}'",
    'ags': "ags run-js 'wallpaper.get(0)'",
}

DEFAULT_WALLPAPER_SOURCE = 'hyprpaper'
RESIZE_WIDTH = 64  # Base width for image processing

def darken(hex_color: str, factor: float = 0.7) -> str:
    """Darken a hex color by a given factor."""
    if not (hex_color.startswith('#') and len(hex_color) in (4, 7)):
        raise ValueError("Invalid hex color format")
        
    hex_color = hex_color.lstrip('#')
    rgb = tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
    darkened_rgb = tuple(int(max(0, val * factor)) for val in rgb)
    return "#{:02X}{:02X}{:02X}".format(*darkened_rgb)

def get_wallpaper_path(source: str) -> str:
    """Get wallpaper path from specified source."""
    if source not in WALLPAPER_SOURCES:
        raise ValueError(f"Unknown wallpaper source: {source}")
        
    try:
        cmd_output = subprocess.check_output(WALLPAPER_SOURCES[source], shell=True)
        return cmd_output.decode("utf-8").strip()
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Failed to get wallpaper from {source}: {e}")

def process_image(path: str) -> Image:
    """Load and resize image for processing."""
    img = Image.open(path)
    wpercent = (RESIZE_WIDTH / float(img.size[0]))
    hsize = int((float(img.size[1]) * float(wpercent)))
    return img.resize((RESIZE_WIDTH, hsize), Image.Resampling.LANCZOS)

def generate_theme(source_type: str, source_value: str, dark_mode: bool = True) -> dict:
    """Generate color theme from either image path or color."""
    if source_type == 'image':
        img = process_image(source_value)
        theme = themeFromImage(img)
    elif source_type == 'color':
        theme = themeFromSourceColor(argbFromHex(source_value))
    else:
        raise ValueError("Invalid source type")

    scheme = theme.get('schemes').get('dark' if dark_mode else 'light')
    
    # Generate color dictionary
    colors = {
        'darkmode': dark_mode,
        'primary': hexFromArgb(scheme.get_primary()),
        'onPrimary': hexFromArgb(scheme.get_onPrimary()),
        'primaryContainer': hexFromArgb(scheme.get_primaryContainer()),
        'onPrimaryContainer': hexFromArgb(scheme.get_onPrimaryContainer()),
        'secondary': hexFromArgb(scheme.get_secondary()),
        'onSecondary': hexFromArgb(scheme.get_onSecondary()),
        'secondaryContainer': hexFromArgb(scheme.get_secondaryContainer()),
        'onSecondaryContainer': hexFromArgb(scheme.get_onSecondaryContainer()),
        'tertiary': hexFromArgb(scheme.get_tertiary()),
        'onTertiary': hexFromArgb(scheme.get_onTertiary()),
        'tertiaryContainer': hexFromArgb(scheme.get_tertiaryContainer()),
        'onTertiaryContainer': hexFromArgb(scheme.get_onTertiaryContainer()),
        'error': hexFromArgb(scheme.get_error()),
        'onError': hexFromArgb(scheme.get_onError()),
        'errorContainer': hexFromArgb(scheme.get_errorContainer()),
        'onErrorContainer': hexFromArgb(scheme.get_onErrorContainer()),
        'background': hexFromArgb(scheme.get_background()),
        'onBackground': hexFromArgb(scheme.get_onBackground()),
        'surface': hexFromArgb(scheme.get_surface()),
        'onSurface': hexFromArgb(scheme.get_onSurface()),
        'surfaceVariant': hexFromArgb(scheme.get_surfaceVariant()),
        'onSurfaceVariant': hexFromArgb(scheme.get_onSurfaceVariant()),
        'outline': hexFromArgb(scheme.get_outline()),
        'shadow': hexFromArgb(scheme.get_shadow()),
        'inverseSurface': hexFromArgb(scheme.get_inverseSurface()),
        'inverseOnSurface': hexFromArgb(scheme.get_inverseOnSurface()),
        'inversePrimary': hexFromArgb(scheme.get_inversePrimary()),
    }
    
    # Apply dark mode adjustments
    if dark_mode:
        colors['background'] = darken(colors['background'], 0.6)
        colors['colorbarbg'] = colors['background']
    
    return colors

def print_scss_variables(colors: dict) -> None:
    """Print color theme as SCSS variables."""
    print(f"$darkmode: {str(colors['darkmode']).lower()};")
    for key, value in colors.items():
        if key != 'darkmode':
            print(f"${key}: {value};")

def main():
    dark_mode = "-l" not in sys.argv
    
    try:
        if "--path" in sys.argv:
            path_index = sys.argv.index("--path")
            colors = generate_theme('image', sys.argv[path_index + 1], dark_mode)
        elif "--color" in sys.argv:
            color_index = sys.argv.index("--color")
            colors = generate_theme('color', sys.argv[color_index + 1], dark_mode)
        else:
            wallpaper_path = get_wallpaper_path(DEFAULT_WALLPAPER_SOURCE)
            colors = generate_theme('image', wallpaper_path, dark_mode)
        
        # Output SCSS to stdout
        print(f"$darkmode: {str(colors['darkmode']).lower()};")
        for key, value in colors.items():
            if key != 'darkmode':
                print(f"${key}: {value};")
        
        # Output JSON to fd 3
        with os.fdopen(3, 'w') as fdfile:
            print(json.dumps(colors, indent=2), file=fdfile)
            
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
