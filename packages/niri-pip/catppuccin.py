# recolours the settings page css in place: greys along the mocha greys, blues to mauve
import colorsys
import re
import sys

RGB = tuple[int, int, int]

GREYS = [
    "11111b", "181825", "1e1e2e", "313244", "45475a", "585b70",
    "6c7086", "7f849c", "9399b2", "a6adc8", "bac2de", "cdd6f4",
]
BASE = "1e1e2e"
MAUVE = "cba6f7"
GREEN = "a6e3a1"
RED = "f38ba8"
YELLOW = "f9e2af"
CRUST = "11111b"
TEXT = "cdd6f4"


def rgb(hexstr: str) -> RGB:
    return (int(hexstr[0:2], 16), int(hexstr[2:4], 16), int(hexstr[4:6], 16))


def lightness(c: RGB) -> float:
    return (max(c) + min(c)) / 510


def mix(a: RGB, b: RGB, t: float) -> RGB:
    return (
        round(a[0] + (b[0] - a[0]) * t),
        round(a[1] + (b[1] - a[1]) * t),
        round(a[2] + (b[2] - a[2]) * t),
    )


def grey(c: RGB) -> RGB:
    # between the two mocha greys around it, so the page keeps its layers
    ramp = [rgb(g) for g in GREYS]
    l = lightness(c)
    if l <= lightness(ramp[0]):
        return ramp[0]
    for lo, hi in zip(ramp, ramp[1:]):
        if l <= lightness(hi):
            return mix(lo, hi, (l - lightness(lo)) / (lightness(hi) - lightness(lo)))
    return ramp[-1]


def recolour(c: RGB) -> RGB:
    if (max(c) - min(c)) / 255 < 0.2:
        return grey(c)
    hue = colorsys.rgb_to_hls(c[0] / 255, c[1] / 255, c[2] / 255)[0] * 360
    if 190 <= hue < 260:
        # the source accent's lightness is full mauve, darker blues sink towards base
        return mix(rgb(BASE), rgb(MAUVE), min(1, lightness(c) / 0.68))
    if 90 <= hue < 170:
        return rgb(GREEN)
    if hue >= 330 or hue < 15:
        return rgb(RED)
    if 20 <= hue < 60:
        return rgb(YELLOW)
    return c


def hex_sub(m: re.Match[str]) -> str:
    h = m.group(1)
    if len(h) in (3, 4):
        h = "".join(ch * 2 for ch in h)
    r, g, b = recolour(rgb(h))
    return f"#{r:02x}{g:02x}{b:02x}{h[6:]}"


def rgba_sub(m: re.Match[str]) -> str:
    parts = [p.strip() for p in m.group(2).split(",")]
    r, g, b = recolour((int(parts[0]), int(parts[1]), int(parts[2])))
    return f"{m.group(1)}({', '.join([str(r), str(g), str(b), *parts[3:]])})"


def recolour_css(css: str) -> str:
    # light text on accent fills becomes dark, as catppuccin does
    css = css.replace("color: white", f"color: #{CRUST}")
    css = css.replace("background: white", f"background: #{TEXT}")
    css = re.sub(r"#([0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3,4})\b", hex_sub, css)
    return re.sub(r"\b(rgba?)\(\s*(\d+\s*,\s*\d+\s*,\s*\d+[^)]*)\)", rgba_sub, css)


path = sys.argv[1]
with open(path) as f:
    out = recolour_css(f.read())
with open(path, "w") as f:
    _ = f.write(out)
