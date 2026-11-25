"""Extract Violet's game-ready sprite frames from the supplied reference sheet.

Run from the project root:
    python tools/import_violet_reference.py "path/to/Pasted Image.png"
Requires Pillow.
"""
import argparse
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
FRAME_SIZE = (24, 32)
SHEET_SIZE = (4 * FRAME_SIZE[0], 4 * FRAME_SIZE[1])


def _cell_boxes(x_edges: tuple[int, ...], y0: int, y1: int) -> list[tuple[int, int, int, int]]:
    return [
        (x_edges[index] + 3, y0 + 3, x_edges[index + 1] - 3, y1 - 3)
        for index in range(len(x_edges) - 1)
    ]


def _extract_frame(source: Image.Image, box: tuple[int, int, int, int], size: tuple[int, int]) -> Image.Image:
    frame = source.crop(box).convert("RGBA")
    pixels = frame.load()
    for y in range(frame.height):
        for x in range(frame.width):
            red, green, blue, _alpha = pixels[x, y]
            if min(red, green, blue) >= 246 and max(red, green, blue) - min(red, green, blue) <= 14:
                pixels[x, y] = (0, 0, 0, 0)

    bounds = frame.getbbox()
    if bounds is None:
        raise ValueError(f"No character pixels found in source crop {box}")
    character = frame.crop(bounds)
    scale = min((size[0] - 2) / character.width, size[1] / character.height)
    resized = character.resize(
        (max(1, round(character.width * scale)), max(1, round(character.height * scale))),
        Image.Resampling.NEAREST,
    )
    output = Image.new("RGBA", size, (0, 0, 0, 0))
    output.alpha_composite(resized, ((size[0] - resized.width) // 2, size[1] - resized.height))
    return output


def _save_sheet(source: Image.Image, rows: list[list[tuple[int, int, int, int]]], path: Path) -> None:
    sheet = Image.new("RGBA", SHEET_SIZE, (0, 0, 0, 0))
    for row_index, row in enumerate(rows):
        for column_index, box in enumerate(row):
            frame = _extract_frame(source, box, FRAME_SIZE)
            sheet.alpha_composite(frame, (column_index * FRAME_SIZE[0], row_index * FRAME_SIZE[1]))
    path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(path)


def main() -> None:
    parser = argparse.ArgumentParser(description="Import Violet's sprite frames from the reference sheet.")
    parser.add_argument("source", type=Path, help="Path to the supplied Violet sprite-sheet image")
    args = parser.parse_args()

    source = Image.open(args.source).convert("RGB")
    if source.size != (1024, 765):
        raise ValueError(f"Expected a 1024x765 reference sheet, got {source.width}x{source.height}")

    left_columns = (17, 139, 262, 384, 505)
    uniform = _cell_boxes(left_columns, 95, 245)
    walk_left = _cell_boxes(left_columns, 271, 416)
    walk_right = _cell_boxes(left_columns, 443, 574)
    walk_up = _cell_boxes(left_columns, 599, 755)

    sprite_dir = ROOT / "assets" / "sprites"
    _save_sheet(source, [uniform, walk_up, walk_left, walk_right], sprite_dir / "violet_sheet.png")

    sketching = (765, 603, 882, 752)
    _extract_frame(source, sketching, (48, 40)).save(sprite_dir / "violet_sketching.png")
    print("Imported Violet's walk atlas and sketching pose.")


if __name__ == "__main__":
    main()
