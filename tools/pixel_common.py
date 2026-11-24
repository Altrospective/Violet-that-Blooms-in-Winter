"""Shared helpers for the pixel art generator. Run tools/generate_art.py to rebuild all art."""
from PIL import Image
import random

OUTLINE = (34, 28, 46, 255)

def rgba(c, a=255):
    return (c[0], c[1], c[2], a)

def px(img, x, y, color):
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color if len(color) == 4 else rgba(color))

def rect(img, x0, y0, x1, y1, color):
    """Inclusive rectangle."""
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px(img, x, y, color)

def hline(img, x0, x1, y, color):
    rect(img, x0, y, x1, y, color)

def vline(img, x, y0, y1, color):
    rect(img, x, y0, x, y1, color)

def outline(img, color=OUTLINE):
    """Add a 1px outline around every opaque pixel (4-neighbour)."""
    src = img.copy()
    for y in range(img.height):
        for x in range(img.width):
            if src.getpixel((x, y))[3] > 0:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < img.width and 0 <= ny < img.height and src.getpixel((nx, ny))[3] > 0:
                    img.putpixel((x, y), color)
                    break
    return img

def scaled(img, k):
    return img.resize((img.width * k, img.height * k), Image.NEAREST)

# Kawung (batik) tile, 8x8. X = motif.
KAWUNG = [
    "..XXXX..",
    ".X....X.",
    "X..XX..X",
    "X.X..X.X",
    "X.X..X.X",
    "X..XX..X",
    ".X....X.",
    "..XXXX..",
]

def kawung_fill(img, x0, y0, x1, y1, bg, fg):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            on = KAWUNG[(y - y0) % 8][(x - x0) % 8] == "X"
            px(img, x, y, fg if on else bg)

def dither_blend(c0, c1, t, x, y):
    """Ordered (Bayer 4x4) dither between two colors for pixel-art gradients."""
    bayer = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
    threshold = (bayer[y % 4][x % 4] + 0.5) / 16.0
    return c1 if t > threshold else c0
