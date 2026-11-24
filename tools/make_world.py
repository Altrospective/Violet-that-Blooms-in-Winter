import random, math
from PIL import Image
from pixel_common import *
from make_characters import silhouette

WOOD = (118, 88, 68); WOOD_DK = (86, 62, 50); WOOD_LT = (150, 116, 88)
INDIGO = (52, 60, 104); CREAM = (222, 210, 176)
WALL = (150, 164, 168); WALL_DK = (132, 146, 152)

def new(w, h, c=(0, 0, 0, 0)):
    return Image.new("RGBA", (w, h), c)

# ---------------------------------------------------------------- props
def bed():
    im = new(64, 40)
    rect(im, 2, 0, 61, 8, WOOD)                    # headboard
    hline(im, 2, 61, 1, WOOD_LT)
    rect(im, 3, 8, 60, 35, (214, 208, 214))        # mattress
    rect(im, 6, 10, 24, 18, (238, 238, 244)); hline(im, 6, 24, 18, (200, 200, 214))   # pillow
    kawung_fill(im, 4, 26, 59, 35, INDIGO, CREAM)  # blanket pushed down
    hline(im, 4, 59, 25, CREAM)
    rect(im, 2, 35, 61, 39, WOOD); hline(im, 2, 61, 36, WOOD_LT)
    rect(im, 2, 38, 5, 39, WOOD_DK); rect(im, 58, 38, 61, 39, WOOD_DK)
    return outline(im)

def sleeping_overlay():
    im = new(64, 40)
    kawung_fill(im, 4, 19, 59, 35, INDIGO, CREAM)  # blanket pulled up
    hline(im, 4, 59, 19, CREAM)
    rect(im, 9, 9, 25, 18, (46, 36, 58))           # hair spread on the pillow
    rect(im, 12, 11, 19, 17, (196, 146, 106))      # face
    hline(im, 13, 14, 14, (34, 28, 46)); hline(im, 17, 18, 14, (34, 28, 46))  # closed eyes
    rect(im, 20, 14, 30, 22, (46, 36, 58))         # hair down onto the blanket
    px(im, 21, 10, (160, 120, 220)); px(im, 21, 11, (160, 120, 220))          # hair clip
    return outline(im)

def desk():
    im = new(56, 40)
    rect(im, 1, 8, 54, 24, WOOD_LT); hline(im, 1, 54, 8, (170, 136, 106))
    rect(im, 1, 25, 54, 30, WOOD); hline(im, 1, 54, 25, WOOD_DK)
    rect(im, 20, 26, 36, 30, WOOD_DK); hline(im, 26, 30, 28, (210, 180, 100))
    rect(im, 3, 31, 6, 39, WOOD_DK); rect(im, 49, 31, 52, 39, WOOD_DK)
    rect(im, 8, 11, 22, 19, (110, 86, 150)); rect(im, 8, 11, 9, 19, (84, 64, 120)); hline(im, 8, 22, 19, (84, 64, 120))  # sketchbook
    hline(im, 12, 19, 14, (160, 140, 200))
    rect(im, 29, 14, 33, 18, (232, 228, 214)); px(im, 34, 15, (232, 228, 214)); px(im, 34, 16, (232, 228, 214))    # mug
    rect(im, 42, 18, 48, 20, (110, 114, 126)); vline(im, 44, 8, 18, (150, 154, 166)); hline(im, 40, 46, 8, (150, 154, 166))  # lamp
    return outline(im)

def wardrobe():
    im = new(40, 64)
    rect(im, 2, 4, 37, 61, WOOD); rect(im, 1, 2, 38, 5, WOOD_LT); hline(im, 1, 38, 5, WOOD_DK)
    for x0 in (5, 22):
        rect(im, x0, 9, x0 + 12, 56, WOOD_DK); rect(im, x0 + 1, 10, x0 + 11, 55, (104, 76, 60))
    vline(im, 19, 6, 58, WOOD_DK); vline(im, 20, 6, 58, WOOD_DK)
    rect(im, 16, 32, 17, 36, (210, 180, 100)); rect(im, 22, 32, 23, 36, (210, 180, 100))
    rect(im, 3, 62, 7, 63, WOOD_DK); rect(im, 32, 62, 36, 63, WOOD_DK)
    return outline(im)

def school_desk(w=36, h=20, top=(190, 160, 120)):
    im = new(w, h)
    rect(im, 0, 0, w - 1, h // 2 - 1, top); hline(im, 0, w - 1, 0, (214, 186, 146))
    rect(im, 0, h // 2, w - 1, h // 2 + 3, (150, 120, 92))
    rect(im, 2, h // 2 + 4, 4, h - 1, (120, 124, 136)); rect(im, w - 5, h // 2 + 4, w - 3, h - 1, (120, 124, 136))
    return outline(im)

def fan(frame):
    im = new(32, 16)
    vline(im, 15, 0, 5, (150, 154, 166)); vline(im, 16, 0, 5, (150, 154, 166))
    rect(im, 13, 6, 18, 9, (96, 100, 112))
    blade = (190, 170, 140)
    if frame == 0:
        rect(im, 1, 8, 12, 10, blade); rect(im, 19, 8, 30, 10, blade)
    else:
        rect(im, 5, 7, 12, 9, blade); rect(im, 19, 7, 26, 9, blade)
        hline(im, 2, 4, 9, (190, 170, 140, 110)); hline(im, 27, 29, 9, (190, 170, 140, 110))
    return outline(im)

def violet_flower():
    im = new(16, 24)
    vline(im, 8, 10, 23, (96, 150, 100)); vline(im, 9, 12, 23, (96, 150, 100))
    rect(im, 10, 15, 13, 16, (96, 150, 100)); rect(im, 3, 18, 7, 19, (96, 150, 100))
    for i in range(5):
        a = math.tau * i / 5 - math.pi / 2
        cx, cy = 8 + round(3 * math.cos(a)), 6 + round(3 * math.sin(a))
        rect(im, cx - 1, cy - 1, cx + 1, cy + 1, (150, 98, 218))
    rect(im, 7, 5, 8, 6, (250, 216, 104))
    return outline(im, (60, 40, 96, 255))

# ---------------------------------------------------------------- backgrounds
def tile_floor(im, y0, y1, c1, c2, grout, seed):
    rnd = random.Random(seed)
    for ty in range(y0, y1, 16):
        for tx in range(0, im.width, 16):
            base = c1 if rnd.random() < 0.5 else c2
            for y in range(ty, min(ty + 16, y1)):
                for x in range(tx, min(tx + 16, im.width)):
                    c = grout if (x == tx or y == ty) else base
                    if c is base and rnd.random() < 0.04:
                        c = (base[0] - 6, base[1] - 6, base[2] - 6)
                    px(im, x, y, c)

def louvre_window(im, x0, y0, x1, y1, frame_c=(230, 230, 226)):
    rect(im, x0, y0, x1, y1, frame_c)
    gx0, gy0, gx1, gy1 = x0 + 5, y0 + 5, x1 - 5, y1 - 5
    for y in range(gy0, gy1 + 1):
        t = (y - gy0) / max(1, gy1 - gy0)
        sky = (int(176 + 24 * t), int(184 + 22 * t), int(198 + 16 * t))
        for x in range(gx0, gx1 + 1):
            phase = (y - gy0) % 6
            if phase <= 2:
                c = (210, 214, 214)
            elif phase == 3:
                c = (158, 166, 176)
            else:
                c = sky
            px(im, x, y, c)
    cx = (gx0 + gx1) // 2
    rect(im, cx - 1, gy0, cx + 1, gy1, frame_c)                 # centre bar
    hline(im, gx0, gx1, gy0 + 1, (96, 102, 112)); hline(im, gx0, gx1, gy0 + 2, (96, 102, 112))   # rain gutter lip
    for gx in range(gx0 + 6, gx1, 14):
        px(im, gx, gy0 + 3, (96, 102, 112))                       # drip points
    rect(im, x0 - 3, y1 + 1, x1 + 3, y1 + 4, (214, 214, 210)); hline(im, x0 - 3, x1 + 3, y1 + 5, (120, 124, 128))  # sill

def clock(im, cx, cy):
    for y in range(-10, 11):
        for x in range(-10, 11):
            d = math.hypot(x, y)
            if d <= 10:
                px(im, cx + x, cy + y, (60, 56, 66) if d > 8.5 else (240, 240, 236))
    for a in range(12):
        ang = math.tau * a / 12
        px(im, cx + round(7 * math.sin(ang)), cy - round(7 * math.cos(ang)), (60, 56, 66))
    for k in range(7):
        px(im, cx, cy - k, (60, 56, 66))
    for k in range(5):
        px(im, cx - k, cy + round(k * 0.6), (60, 56, 66))

def bedroom():
    im = new(640, 360, rgba((0, 0, 0)))
    rnd = random.Random(7)
    for y in range(110):
        for x in range(640):
            c = WALL
            if y < 6:
                c = WALL_DK
            elif rnd.random() < 0.05:
                c = (WALL[0] - 5, WALL[1] - 5, WALL[2] - 5)
            px(im, x, y, c)
    rect(im, 0, 102, 639, 108, (214, 214, 210)); hline(im, 0, 639, 109, (120, 124, 126))
    tile_floor(im, 110, 360, (186, 182, 174), (178, 174, 166), (150, 146, 140), 3)
    for y in range(110, 128):                         # wall shadow on the floor
        for x in range(640):
            if dither_blend(0, 1, (128 - y) / 18, x, y):
                c = im.getpixel((x, y)); px(im, x, y, (c[0] - 14, c[1] - 14, c[2] - 12))
    louvre_window(im, 274, 20, 366, 92)
    # door
    rect(im, 434, 38, 482, 109, WOOD_DK); rect(im, 437, 41, 479, 109, WOOD)
    for (a, b, c, d) in ((441, 46, 457, 70), (461, 46, 475, 70), (441, 76, 457, 104), (461, 76, 475, 104)):
        rect(im, a, b, c, d, (104, 76, 60)); rect(im, a + 1, b + 1, c - 1, d - 1, (138, 106, 82))
    rect(im, 473, 78, 475, 80, (210, 180, 100))
    clock(im, 150, 48)
    # class schedule pinned to the wall
    rect(im, 522, 32, 556, 76, (236, 232, 220)); rect(im, 522, 32, 556, 36, (190, 80, 80))
    for ly in range(40, 74, 4):
        hline(im, 525, 553 - (ly % 8), ly, (150, 146, 140))
    px(im, 522, 32, (60, 56, 66)); px(im, 556, 32, (60, 56, 66))
    # woven mat (tikar)
    mx0, my0, mx1, my1 = 268, 232, 392, 292
    for y in range(my0, my1 + 1):
        for x in range(mx0, mx1 + 1):
            c = (200, 160, 96) if ((x // 2) + (y // 2)) % 2 else (176, 134, 76)
            edge = min(x - mx0, mx1 - x, y - my0, my1 - y)
            if edge < 5:
                c = (140, 76, 68)
            elif edge == 6:
                c = (222, 210, 176)
            px(im, x, y, c)
    for y in range(my0 + 2, my1, 4):
        px(im, mx0 - 1, y, (176, 134, 76)); px(im, mx1 + 1, y, (176, 134, 76))
    return im

def classroom():
    im = new(640, 360, rgba((0, 0, 0)))
    rect(im, 0, 0, 639, 70, (214, 216, 210))
    rect(im, 0, 71, 639, 119, (118, 148, 146)); hline(im, 0, 639, 71, (86, 112, 112)); hline(im, 0, 639, 72, (86, 112, 112))
    rect(im, 0, 114, 639, 119, (84, 106, 106))
    tile_floor(im, 120, 360, (194, 196, 192), (186, 188, 184), (156, 158, 154), 11)
    louvre_window(im, 36, 22, 124, 90); louvre_window(im, 516, 22, 604, 90)
    # blackboard
    rect(im, 234, 14, 406, 66, WOOD); rect(im, 238, 18, 402, 60, (52, 82, 70)); rect(im, 234, 62, 406, 66, WOOD_DK)
    rnd = random.Random(5)
    for y in range(24, 56, 8):
        x = 246
        while x < 380:
            n = rnd.randint(6, 22); hline(im, x, x + n, y, (206, 210, 202)); x += n + rnd.randint(4, 8)
    # flag (red and white)
    vline(im, 212, 8, 62, (120, 124, 136)); vline(im, 213, 8, 62, (120, 124, 136))
    rect(im, 214, 10, 232, 16, (196, 60, 64)); rect(im, 214, 17, 232, 23, (240, 240, 240))
    clock(im, 440, 40)
    return im

def menu_dream():
    W, H, HZ = 640, 360, 200
    im = new(W, H, rgba((0, 0, 0)))
    sky = [(176, 160, 224), (200, 172, 228), (224, 184, 232), (244, 204, 232), (254, 226, 234), (255, 238, 238)]
    for y in range(HZ):
        t = y / HZ * (len(sky) - 1); i = min(int(t), len(sky) - 2); f = t - i
        for x in range(W):
            px(im, x, y, dither_blend(sky[i], sky[i + 1], f, x, y))
    rnd = random.Random(21)
    for (cx, cy, w) in ((70, 62, 90), (300, 40, 70), (520, 90, 100), (200, 120, 60)):
        for k in range(5):
            ox, oy = rnd.randint(-w // 3, w // 3), rnd.randint(-4, 4)
            rect(im, cx + ox - w // 4, cy + oy, cx + ox + w // 4, cy + oy + 5, (255, 246, 248))
    for layer, col, pts in ((0, (206, 188, 232), [(0, 186), (80, 170), (170, 188), (280, 176), (380, 190), (480, 172), (560, 186), (640, 176)]),
                            (1, (190, 170, 220), [(0, 200), (0, 190), (120, 180), (230, 194), (340, 184), (450, 196), (560, 182), (640, 192), (640, 200)])):
        for x in range(W):
            seg = max(i for i in range(len(pts) - 1) if pts[i][0] <= x) if x < pts[-1][0] else len(pts) - 2
            (x0, y0), (x1, y1) = pts[seg], pts[seg + 1]
            top = y0 + (y1 - y0) * (x - x0) / max(1, x1 - x0)
            for y in range(int(top), HZ):
                px(im, x, y, col)
    lake = [(226, 238, 250), (196, 216, 240), (170, 196, 226)]
    for y in range(HZ, H):
        t = (y - HZ) / (H - HZ) * (len(lake) - 1); i = min(int(t), len(lake) - 2); f = t - i
        for x in range(W):
            px(im, x, y, dither_blend(lake[i], lake[i + 1], f, x, y))
    # a faint batik (kawung) pattern frozen under the ice
    for y in range(226, H):
        for x in range(W):
            if KAWUNG[(y // 3) % 8][(x // 3) % 8] == "X":
                c = im.getpixel((x, y)); px(im, x, y, (min(255, c[0] + 12), min(255, c[1] + 10), min(255, c[2] + 6)))
    for _ in range(140):                               # ice sheen dashes
        x, y = rnd.randint(0, W - 12), rnd.randint(HZ + 4, H - 2)
        hline(im, x, x + rnd.randint(3, 10), y, (246, 250, 255))
    cracks = [[(60, 320), (100, 300), (130, 308), (180, 284)], [(420, 340), (470, 316), (520, 324), (580, 296)], [(300, 352), (320, 322), (310, 298)]]
    for poly in cracks:
        for (a, b) in zip(poly, poly[1:]):
            n = max(abs(b[0] - a[0]), abs(b[1] - a[1]))
            for s in range(n + 1):
                px(im, round(a[0] + (b[0] - a[0]) * s / n), round(a[1] + (b[1] - a[1]) * s / n), (120, 146, 186))
    for (x, y) in ((120, 336), (250, 314), (380, 338), (520, 310), (90, 292)):   # withered violets under the ice
        c = (96, 78, 134)
        rect(im, x - 1, y - 1, x + 1, y + 1, c); vline(im, x, y - 6, y - 2, c)
    for _ in range(60):
        px(im, rnd.randint(0, W - 1), rnd.randint(HZ + 2, H - 1), (255, 255, 255))
    return im

# ---------------------------------------------------------------- UI
def ui_frame(size, margin, fill, line, ornament, seed):
    rnd = random.Random(seed)
    im = new(size, size)
    inner = size - 2 * margin
    # periodic wobble for the repeating edge slice
    j = [0]
    for _ in range(inner - 2):
        j.append(max(-1, min(1, j[-1] + rnd.choice((-1, 0, 0, 1)))))
    j.append(0)
    def off(i): return j[i]
    def graphite(x, y, base):
        r = rnd.random()
        return base if r > 0.18 else (base[0] - 28, base[1] - 28, base[2] - 24, 255)
    rect(im, 4, 4, size - 5, size - 5, fill)
    for x in range(4, size - 4):
        i = min(max(x - margin, 0), inner - 1)
        d = off(i) if margin <= x < size - margin else 0
        for yy in (4 + d, size - 5 + d):
            px(im, x, yy, graphite(x, yy, line))
        if (x % 3) != 1:
            for yy in (7 + d, size - 8 + d):
                px(im, x, yy, (line[0], line[1], line[2], 150))
    for y in range(4, size - 4):
        i = min(max(y - margin, 0), inner - 1)
        d = off(i) if margin <= y < size - margin else 0
        for xx in (4 + d, size - 5 + d):
            px(im, xx, y, graphite(xx, y, line))
        if (y % 3) != 1:
            for xx in (7 + d, size - 8 + d):
                px(im, xx, y, (line[0], line[1], line[2], 150))
    # batik corner ornaments
    for (cx, cy) in ((3, 3), (size - 13, 3), (3, size - 13), (size - 13, size - 13)):
        rect(im, cx, cy, cx + 9, cy + 9, fill)
        for y in range(8):
            for x in range(8):
                if KAWUNG[y][x] == "X":
                    px(im, cx + 1 + x, cy + 1 + y, ornament)
    return im

def cursor():
    im = new(12, 12)
    c = (74, 58, 98, 255)
    hline(im, 1, 8, 5, c); hline(im, 1, 8, 6, c)
    for k in range(4):
        vline(im, 7 + k, 3 + k, 8 - k, c)
    return im
