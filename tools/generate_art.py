"""Rebuilds every generated pixel-art asset. Run from the project root:  python3 tools/generate_art.py
Requires Pillow. Edit the palettes and shapes in tools/make_*.py to restyle the art."""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from make_characters import silhouette
from make_world import *

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets")
def save(im, *parts):
    path = os.path.join(ROOT, *parts); os.makedirs(os.path.dirname(path), exist_ok=True); im.save(path); print("wrote", os.path.relpath(path))

save(silhouette(True), "sprites", "student_long.png")
save(silhouette(False), "sprites", "student_short.png")
save(violet_flower(), "sprites", "violet_flower.png")
save(bed(), "props", "bed.png")
save(sleeping_overlay(), "props", "bed_sleeping.png")
save(desk(), "props", "desk.png")
save(wardrobe(), "props", "wardrobe.png")
save(school_desk(), "props", "school_desk.png")
save(school_desk(64, 28, (170, 140, 104)), "props", "teacher_desk.png")
save(fan(0), "props", "fan_a.png")
save(fan(1), "props", "fan_b.png")
save(bedroom(), "backgrounds", "bedroom.png")
save(classroom(), "backgrounds", "classroom.png")
save(menu_dream(), "backgrounds", "menu_dream.png")
save(ui_frame(48, 16, (18, 15, 26, 238), (232, 226, 240, 255), (214, 170, 96, 255), 1), "ui", "frame_dark.png")
save(ui_frame(48, 16, (244, 236, 224, 238), (74, 58, 98, 255), (150, 84, 76, 255), 2), "ui", "frame_paper.png")
save(cursor(), "ui", "cursor_pencil.png")
