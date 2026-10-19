import sys

from fontTools.ttLib import TTFont

# powerline separators stay cell-aligned
POWERLINE = range(0xE0A0, 0xE0D8)


def is_icon(cp):
    return (0xE000 <= cp <= 0xF8FF or 0xF0000 <= cp <= 0xFFFFD) and cp not in POWERLINE


for path in sys.argv[1:]:
    font = TTFont(path)
    glyf, hmtx = font["glyf"], font["hmtx"]

    for name in {name for cp, name in font.getBestCmap().items() if is_icon(cp)}:
        glyph = glyf[name]
        if glyph.numberOfContours <= 0:
            continue
        glyph.recalcBounds(glyf)
        adv = hmtx[name][0]
        width = glyph.xMax - glyph.xMin

        # wide icons spill into the following space; centre them across both cells
        if width <= adv:
            continue
        glyph.coordinates.translate((round((2 * adv - width) / 2 - glyph.xMin), 0))
        glyph.recalcBounds(glyf)
        hmtx[name] = (adv, glyph.xMin)

    font.save(path)
