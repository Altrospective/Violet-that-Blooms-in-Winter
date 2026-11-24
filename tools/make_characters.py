from PIL import Image
from pixel_common import *

SKIN = (196, 146, 106); SKIN_SH = (166, 118, 86)
HAIR = (46, 36, 58); HAIR_HI = (84, 66, 104)
CLIP = (160, 120, 220)
SHIRT = (240, 240, 246); SHIRT_SH = (196, 200, 214)
SKIRT = (122, 126, 140); SKIRT_SH = (92, 96, 112)
SOCK = (232, 232, 240); SHOE = (52, 46, 62)
EYE = (34, 28, 46); MOUTH = (150, 92, 92); BLUSH = (214, 128, 118)

def pal(sil=False):
    if not sil:
        return dict(skin=SKIN, skin_sh=SKIN_SH, hair=HAIR, hair_hi=HAIR_HI, shirt=SHIRT, shirt_sh=SHIRT_SH,
                    skirt=SKIRT, skirt_sh=SKIRT_SH, sock=SOCK, shoe=SHOE)
    g = lambda v: (v, v, v + 10)
    return dict(skin=g(118), skin_sh=g(100), hair=g(60), hair_hi=g(78), shirt=g(150), shirt_sh=g(128),
                skirt=g(96), skirt_sh=g(80), sock=g(140), shoe=g(50))

def draw_front(img, frame, p, face, long_hair, clip):
    bob = -1 if frame else 0
    # long hair behind shoulders
    if long_hair:
        rect(img, 5, 3 + bob, 18, 21 + bob, p["hair"])
    else:
        rect(img, 5, 3 + bob, 18, 11 + bob, p["hair"])
    # head
    rect(img, 7, 6 + bob, 16, 14 + bob, p["skin"])
    # fringe and side hair
    rect(img, 6, 3 + bob, 17, 7 + bob, p["hair"])
    rect(img, 7, 8 + bob, 9, 8 + bob, p["hair"]); rect(img, 14, 8 + bob, 16, 8 + bob, p["hair"])
    rect(img, 5, 4 + bob, 6, 17 + bob if long_hair else 11 + bob, p["hair"])
    rect(img, 17, 4 + bob, 18, 17 + bob if long_hair else 11 + bob, p["hair"])
    hline(img, 8, 11, 4 + bob, p["hair_hi"])
    if face:
        rect(img, 9, 10 + bob, 9, 11 + bob, EYE); rect(img, 14, 10 + bob, 14, 11 + bob, EYE)
        px(img, 8, 12 + bob, BLUSH); px(img, 15, 12 + bob, BLUSH)
        hline(img, 11, 12, 13 + bob, MOUTH)
    if clip:
        rect(img, 15, 5 + bob, 15, 6 + bob, CLIP)
    # neck, torso, arms
    rect(img, 11, 15 + bob, 12, 15 + bob, p["skin_sh"])
    rect(img, 8, 15 + bob, 15, 21 + bob, p["shirt"])
    rect(img, 8, 20 + bob, 15, 21 + bob, p["shirt_sh"])
    px(img, 13, 18 + bob, p["shirt_sh"]); px(img, 14, 18 + bob, p["shirt_sh"])
    ly = 1 if frame == 1 else 0; ry = 1 if frame == 2 else 0
    rect(img, 6, 16 + bob, 7, 18 + bob, p["shirt"])
    rect(img, 16, 16 + bob, 17, 18 + bob, p["shirt"])
    rect(img, 6, 19 + bob + ly, 7, 21 + bob + ly, p["skin"])
    rect(img, 16, 19 + bob + ry, 17, 21 + bob + ry, p["skin"])
    # skirt
    hline(img, 8, 15, 22, p["skirt"]); hline(img, 7, 16, 23, p["skirt"])
    rect(img, 6, 24, 17, 26, p["skirt"])
    px(img, 10, 24, p["skirt_sh"]); px(img, 10, 25, p["skirt_sh"]); px(img, 14, 24, p["skirt_sh"]); px(img, 14, 25, p["skirt_sh"])
    hline(img, 6, 17, 26, p["skirt_sh"])
    # legs
    ll = 1 if frame == 1 else 0; rl = 1 if frame == 2 else 0
    rect(img, 9, 27, 10, 28 - ll, p["skin"]); rect(img, 13, 27, 14, 28 - rl, p["skin"])
    rect(img, 9, 29 - ll, 10, 29 - ll, p["sock"]); rect(img, 13, 29 - rl, 14, 29 - rl, p["sock"])
    rect(img, 8, 30 - ll, 10, 30 - ll, p["shoe"]); rect(img, 13, 30 - rl, 15, 30 - rl, p["shoe"])

def draw_back(img, frame, p, long_hair, clip):
    bob = -1 if frame else 0
    rect(img, 6, 3 + bob, 17, 14 + bob, p["hair"])
    rect(img, 5, 4 + bob, 18, 12 + bob, p["hair"])
    if long_hair:
        rect(img, 6, 15 + bob, 17, 22 + bob, p["hair"])
        rect(img, 5, 12 + bob, 6, 18 + bob, p["hair"]); rect(img, 17, 12 + bob, 18, 18 + bob, p["hair"])
    vline(img, 10, 5 + bob, 12 + bob, p["hair_hi"]); vline(img, 11, 6 + bob, 10 + bob, p["hair_hi"])
    if clip:
        rect(img, 8, 5 + bob, 8, 6 + bob, CLIP)
    ly = 1 if frame == 1 else 0; ry = 1 if frame == 2 else 0
    rect(img, 6, 16 + bob, 7, 18 + bob, p["shirt"]); rect(img, 16, 16 + bob, 17, 18 + bob, p["shirt"])
    rect(img, 6, 19 + bob + ly, 7, 21 + bob + ly, p["skin"]); rect(img, 16, 19 + bob + ry, 17, 21 + bob + ry, p["skin"])
    if not long_hair:
        rect(img, 8, 15 + bob, 15, 21 + bob, p["shirt"]); rect(img, 8, 20 + bob, 15, 21 + bob, p["shirt_sh"])
    hline(img, 8, 15, 22, p["skirt"]); hline(img, 7, 16, 23, p["skirt"])
    rect(img, 6, 24, 17, 26, p["skirt"]); hline(img, 6, 17, 26, p["skirt_sh"])
    px(img, 10, 24, p["skirt_sh"]); px(img, 14, 24, p["skirt_sh"])
    ll = 1 if frame == 1 else 0; rl = 1 if frame == 2 else 0
    rect(img, 9, 27, 10, 28 - ll, p["skin"]); rect(img, 13, 27, 14, 28 - rl, p["skin"])
    rect(img, 9, 29 - ll, 10, 29 - ll, p["sock"]); rect(img, 13, 29 - rl, 14, 29 - rl, p["sock"])
    rect(img, 8, 30 - ll, 10, 30 - ll, p["shoe"]); rect(img, 13, 30 - rl, 15, 30 - rl, p["shoe"])

def draw_left(img, frame, p, face, long_hair, clip):
    bob = -1 if frame else 0
    if long_hair:
        rect(img, 11, 4 + bob, 17, 21 + bob, p["hair"])
    else:
        rect(img, 11, 4 + bob, 17, 11 + bob, p["hair"])
    rect(img, 7, 6 + bob, 14, 14 + bob, p["skin"])
    px(img, 6, 11 + bob, p["skin"])          # nose
    rect(img, 7, 3 + bob, 15, 7 + bob, p["hair"])
    rect(img, 10, 5 + bob, 16, 12 + bob, p["hair"])
    hline(img, 8, 12, 4 + bob, p["hair_hi"])
    if face:
        rect(img, 8, 10 + bob, 8, 11 + bob, EYE); px(img, 8, 13 + bob, BLUSH); px(img, 7, 14 + bob, MOUTH)
    if clip:
        rect(img, 10, 5 + bob, 10, 6 + bob, CLIP)
    rect(img, 9, 15 + bob, 14, 21 + bob, p["shirt"]); rect(img, 9, 20 + bob, 14, 21 + bob, p["shirt_sh"])
    swing = {0: 0, 1: -1, 2: 1}[frame]
    rect(img, 10 + swing, 16 + bob, 12 + swing, 18 + bob, p["shirt"])
    rect(img, 10 + swing, 19 + bob, 12 + swing, 21 + bob, p["skin"])
    rect(img, 8, 22, 15, 23, p["skirt"]); rect(img, 7, 24, 16, 26, p["skirt"]); hline(img, 7, 16, 26, p["skirt_sh"])
    px(img, 11, 24, p["skirt_sh"]); px(img, 13, 24, p["skirt_sh"])
    f = {0: (10, 13), 1: (8, 13), 2: (11, 14)}[frame]   # (front leg x, back leg x)
    for x, back in ((f[1], True), (f[0], False)):
        rect(img, x, 27, x + 1, 28, p["skin"]); rect(img, x, 29, x + 1, 29, p["sock"])
        rect(img, x - (0 if back else 1), 30, x + 1, 30, p["shoe"])

def make_frame(direction, frame, sil=False, long_hair=True, face=True, clip=True):
    img = Image.new("RGBA", (24, 32), (0, 0, 0, 0))
    p = pal(sil)
    if direction == "down":
        draw_front(img, frame, p, face and not sil, long_hair, clip and not sil)
    elif direction == "up":
        draw_back(img, frame, p, long_hair, clip and not sil)
    else:
        draw_left(img, frame, p, face and not sil, long_hair, clip and not sil)
        if direction == "right":
            img = img.transpose(Image.FLIP_LEFT_RIGHT)
    return outline(img)

def violet_sheet():
    sheet = Image.new("RGBA", (24 * 3, 32 * 4), (0, 0, 0, 0))
    for row, d in enumerate(["down", "up", "left", "right"]):
        for col in range(3):
            sheet.paste(make_frame(d, col), (col * 24, row * 32))
    return sheet

def silhouette(long_hair=True):
    return make_frame("down", 0, sil=True, long_hair=long_hair)
