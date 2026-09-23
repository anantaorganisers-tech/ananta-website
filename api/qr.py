import base64
from html import escape
from http.server import BaseHTTPRequestHandler
from pathlib import Path
from urllib.parse import parse_qs, urlparse

import qrcode


QR_FOOTER_PATH = Path(__file__).resolve().parents[1] / "lib" / "assets" / "qr_footer.png"
MAROON = "#530B20"
CREAM = "#fff3de"
GOLD = "#c9a34a"
BLACK = "#000000"
WHITE = "#ffffff"
_QR_FOOTER_DATA_URI = None


def _qr_footer_data_uri():
    global _QR_FOOTER_DATA_URI
    if _QR_FOOTER_DATA_URI is None:
        encoded = base64.b64encode(QR_FOOTER_PATH.read_bytes()).decode("ascii")
        _QR_FOOTER_DATA_URI = f"data:image/png;base64,{encoded}"
    return _QR_FOOTER_DATA_URI


def _qr_matrix(pass_id):
    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=1,
        border=2,
    )
    qr.add_data(pass_id)
    qr.make(fit=True)
    return qr.get_matrix()


def _qr_rects(pass_id, x, y, size):
    matrix = _qr_matrix(pass_id)
    module_count = len(matrix)
    module_size = size / module_count
    rects = []

    for row_index, row in enumerate(matrix):
        for col_index, dark in enumerate(row):
            if not dark:
                continue
            rects.append(
                '<rect x="{:.3f}" y="{:.3f}" width="{:.3f}" height="{:.3f}" />'.format(
                    x + col_index * module_size,
                    y + row_index * module_size,
                    module_size + 0.04,
                    module_size + 0.04,
                )
            )

    return "\n".join(rects)


def _make_ticket_svg(pass_id):
    safe_pass_id = escape(pass_id)
    footer_src = _qr_footer_data_uri()
    qr_rects = _qr_rects(pass_id, 305, 448, 470)

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="1280" viewBox="0 0 1080 1280" role="img" aria-label="Rangaksh ticket {safe_pass_id}">
  <defs>
    <filter id="ticketShadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="18" stdDeviation="22" flood-color="#000000" flood-opacity="0.55"/>
    </filter>
    <style>
      .heading {{
        fill: {CREAM};
        font-family: Montserrat, Arial, sans-serif;
        font-size: 36px;
        font-weight: 600;
        letter-spacing: 7px;
      }}
      .pass {{
        fill: {CREAM};
        font-family: Montserrat, Arial, sans-serif;
        font-size: 60px;
        font-weight: 800;
      }}
      .brand {{
        fill: {CREAM};
        font-family: Montserrat, Arial, sans-serif;
        font-weight: 700;
      }}
    </style>
  </defs>

  <rect width="1080" height="1280" fill="transparent"/>
  <rect x="58" y="54" width="964" height="1144" rx="28" fill="{MAROON}" stroke="{GOLD}" stroke-width="3" filter="url(#ticketShadow)"/>

  <text x="540" y="150" text-anchor="middle" class="heading">YOUR RANGAKSH TICKET</text>
  <text x="540" y="252" text-anchor="middle" class="pass">{safe_pass_id}</text>

  <rect x="208" y="364" width="664" height="634" rx="28" fill="{MAROON}" stroke="{GOLD}" stroke-width="3"/>
  <rect x="236" y="386" width="608" height="590" rx="28" fill="{WHITE}"/>
  <g fill="{BLACK}">
    {qr_rects}
  </g>
  <image href="{footer_src}" x="340" y="1058" width="400" height="102" preserveAspectRatio="xMidYMid meet"/>
</svg>
"""


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

        ticket_svg = _make_ticket_svg(pass_id).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "image/svg+xml; charset=utf-8")
        self.send_header("Cache-Control", "public, max-age=31536000, immutable")
        self.end_headers()
        self.wfile.write(ticket_svg)
