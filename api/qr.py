from http.server import BaseHTTPRequestHandler
from io import BytesIO
from pathlib import Path
from urllib.parse import parse_qs, urlparse

import qrcode
from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT_DIR = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT_DIR / "lib" / "assets"

MAROON = "#5b0620"
CREAM = "#fff3de"
GOLD = "#c9a34a"
BLACK = "#000000"
WHITE = "#ffffff"


def _load_font(size, bold=False):
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
        if bold
        else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation2/LiberationSans-Bold.ttf"
        if bold
        else "/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            continue
    return ImageFont.load_default()


def _fit_font(draw, text, max_width, start_size, min_size, bold=False):
    size = start_size
    while size >= min_size:
        font = _load_font(size, bold=bold)
        if draw.textbbox((0, 0), text, font=font)[2] <= max_width:
            return font
        size -= 2
    return _load_font(min_size, bold=bold)


def _center_text(draw, xy, text, font, fill, spacing=0):
    x, y = xy
    if spacing <= 0:
        bbox = draw.textbbox((0, 0), text, font=font)
        draw.text((x - (bbox[2] - bbox[0]) / 2, y), text, font=font, fill=fill)
        return

    widths = [draw.textlength(char, font=font) for char in text]
    total_width = sum(widths) + spacing * (len(text) - 1)
    cursor = x - total_width / 2
    for char, width in zip(text, widths):
        draw.text((cursor, y), char, font=font, fill=fill)
        cursor += width + spacing


def _rounded_rectangle(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def _make_qr(pass_id):
    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=14,
        border=2,
    )
    qr.add_data(pass_id)
    qr.make(fit=True)
    return qr.make_image(fill_color=BLACK, back_color=WHITE).convert("RGB")


def _paste_contained(base, image_path, box):
    try:
        image = Image.open(image_path).convert("RGBA")
    except OSError:
        return

    left, top, right, bottom = box
    max_width = right - left
    max_height = bottom - top
    scale = min(max_width / image.width, max_height / image.height)
    size = (max(1, int(image.width * scale)), max(1, int(image.height * scale)))
    image = image.resize(size, Image.Resampling.LANCZOS)
    x = left + (max_width - size[0]) // 2
    y = top + (max_height - size[1]) // 2
    base.alpha_composite(image, (x, y))


def _make_ticket(pass_id):
    canvas_width = 1080
    canvas_height = 1280
    image = Image.new("RGBA", (canvas_width, canvas_height), (0, 0, 0, 0))

    shadow = Image.new("RGBA", (canvas_width, canvas_height), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    _rounded_rectangle(
        shadow_draw,
        (72, 68, 1008, 1208),
        30,
        fill=(0, 0, 0, 190),
    )
    image.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(28)), (0, 0))

    draw = ImageDraw.Draw(image)
    card_box = (58, 54, 1022, 1198)
    _rounded_rectangle(draw, card_box, 28, fill=MAROON, outline=GOLD, width=3)

    heading_font = _load_font(29, bold=True)
    _center_text(
        draw,
        (canvas_width / 2, 138),
        "YOUR RANGAKSH TICKET",
        heading_font,
        CREAM,
        spacing=7,
    )

    pass_font = _fit_font(draw, pass_id, 760, 78, 42, bold=True)
    _center_text(draw, (canvas_width / 2, 215), pass_id, pass_font, CREAM)

    qr_outer = (208, 364, 872, 998)
    _rounded_rectangle(draw, qr_outer, 28, fill=MAROON, outline=GOLD, width=3)

    qr_panel = (236, 386, 844, 976)
    _rounded_rectangle(draw, qr_panel, 28, fill=WHITE)

    qr_image = _make_qr(pass_id)
    qr_image = qr_image.resize((470, 470), Image.Resampling.NEAREST).convert("RGBA")
    image.alpha_composite(qr_image, (305, 448))

    _paste_contained(image, ASSET_DIR / "ananta_logo.png", (332, 1062, 420, 1148))
    _paste_contained(image, ASSET_DIR / "appbar_rangaksh.png", (420, 1044, 748, 1164))

    return image.convert("RGB")


class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        query = parse_qs(urlparse(self.path).query)
        pass_id = query.get("id", [""])[0].strip()

        if not pass_id:
            self.send_response(400)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"Missing ticket pass ID.")
            return

        image = _make_ticket(pass_id)
        buffer = BytesIO()
        image.save(buffer, format="PNG")

        self.send_response(200)
        self.send_header("Content-Type", "image/png")
        self.send_header("Cache-Control", "public, max-age=31536000, immutable")
        self.end_headers()
        self.wfile.write(buffer.getvalue())
