#!/usr/bin/env python3
"""Genera un fondo de pantalla ASCII a partir de una imagen.

Separa la piel (tonos cálidos) del fondo de yeso por color y dibuja solo
la figura con caracteres claros sobre fondo oscuro.

Uso: ascii-wallpaper.py <imagen> <salida.png> [--size 1920x1080] [--fg #rrggbb] [--bg #rrggbb]
"""
import argparse

from PIL import Image, ImageDraw, ImageFilter, ImageFont

# De menos a más "tinta"
RAMP = " .:-=+*#%@"

FONT = "/usr/share/fonts/nerd-fonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Regular.ttf"


def hex_rgb(s):
    s = s.lstrip("#")
    return tuple(int(s[i:i + 2], 16) for i in (0, 2, 4))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("out")
    ap.add_argument("--size", default="1920x1080")
    ap.add_argument("--fg", default="#e5e9f0")
    ap.add_argument("--bg", default="#2e3440")
    ap.add_argument("--font-size", type=int, default=11)
    # Recorte del original (x0,y0,x1,y1) en fracciones: banda de las manos
    ap.add_argument("--crop", default="0,0.20,1,0.62")
    ap.add_argument("--center-y", type=float, default=0.5, help="centro vertical de la figura (0-1)")
    ap.add_argument("--threshold", type=int, default=16)
    ap.add_argument("--scale", type=float, default=0.86, help="ancho de la figura respecto a la pantalla")
    args = ap.parse_args()

    W, H = map(int, args.size.split("x"))
    font = ImageFont.truetype(FONT, args.font_size)
    cw = font.getbbox("M")[2]
    ch = int(args.font_size * 1.32)

    img = Image.open(args.src).convert("RGB")
    x0, y0, x1, y1 = (float(v) for v in args.crop.split(","))
    iw, ih = img.size
    img = img.crop((int(x0 * iw), int(y0 * ih), int(x1 * iw), int(y1 * ih)))

    cols = int(W * args.scale / cw)
    rows = int(cols * img.height / img.width * cw / ch)
    small = img.resize((cols, rows), Image.LANCZOS)

    # Máscara de piel en alta resolución: rojo mayor que azul (el yeso es casi gris),
    # suavizada y con los huecos de los reflejos rellenados
    big = img.copy()
    big.thumbnail((900, 900))
    br, _, bb = big.split()
    d = Image.eval(Image.merge("RGB", (br, bb, bb)).convert("L"), lambda v: v)
    diff = Image.new("L", big.size)
    bp, dp = big.load(), diff.load()
    for y in range(big.height):
        for x in range(big.width):
            R, G, B = bp[x, y]
            dp[x, y] = max(0, min(255, (R - B - args.threshold) * 8))
    diff = diff.filter(ImageFilter.GaussianBlur(2))
    diff = diff.point(lambda v: 255 if v > 90 else 0)
    diff = diff.filter(ImageFilter.MaxFilter(9)).filter(ImageFilter.MinFilter(9))
    mask = diff.resize((cols, rows), Image.BILINEAR)
    mp = mask.load()
    del d

    # Sombreado: zonas oscuras de la piel = más tinta
    lum = small.convert("L")
    lum = Image.eval(lum, lambda v: v).filter(ImageFilter.UnsharpMask(2, 160, 2))
    lp = lum.load()
    lo = min(lp[x, y] for y in range(rows) for x in range(cols) if mp[x, y] > 128) if any(
        mp[x, y] > 128 for y in range(rows) for x in range(cols)) else 0
    hi = 255

    canvas = Image.new("RGB", (W, H), hex_rgb(args.bg))
    draw = ImageDraw.Draw(canvas)
    ox = (W - cols * cw) // 2
    oy = int(H * args.center_y - rows * ch / 2)
    fg = hex_rgb(args.fg)
    n = len(RAMP) - 1
    for y in range(rows):
        line = []
        for x in range(cols):
            if mp[x, y] < 100:
                line.append(" ")
                continue
            t = 1 - (lp[x, y] - lo) / max(1, hi - lo)
            t = 0.12 + 0.88 * max(0.0, min(1.0, t))
            line.append(RAMP[int(t * n)])
        draw.text((ox, oy + y * ch), "".join(line), font=font, fill=fg)

    canvas.save(args.out, optimize=True)
    print(f"{args.out}: {W}x{H}, {cols}x{rows} caracteres")


if __name__ == "__main__":
    main()
