#!/bin/bash
# Install NTRIP-www for Apache on Linux.
#
#   www  -> /var/www/html/NTRIP
#   cgi  -> /usr/lib/cgi-bin/NTRIP
#
# Requires root. Expects perl, python3, and curl on the target host.
# Optional (not in this repo): IBSS_kml_* binaries, RTCM3/RTCM3_Decode.py,
# jquery.tablesorter*.js (copy beside this script before install if needed),
# and Trimble CSS/images under /var/www/html/css and /var/www/html/images.

set -euo pipefail

WEB_DIR="/var/www/html/NTRIP"
CGI_DIR="/usr/lib/cgi-bin/NTRIP"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WEB_OWNER="${WEB_OWNER:-apache:apache}"
CGI_OWNER="${CGI_OWNER:-apache:apache}"

usage() {
    cat <<EOF
Usage: sudo $0 [--web-dir DIR] [--cgi-dir DIR]

Install NTRIP HTML and CGI scripts.

  --web-dir DIR   Web root (default: $WEB_DIR)
  --cgi-dir DIR   CGI directory (default: $CGI_DIR)
  -h, --help      Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --web-dir)
            WEB_DIR="$2"
            shift 2
            ;;
        --cgi-dir)
            CGI_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ "$(id -u)" -ne 0 ]]; then
    echo "This installer must be run as root (e.g. sudo $0)." >&2
    exit 1
fi

missing=()
for cmd in perl python3 curl install; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing+=("$cmd")
    fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Missing required commands: ${missing[*]}" >&2
    exit 1
fi

echo "Installing NTRIP-www"
echo "  from: $SCRIPT_DIR"
echo "  www:  $WEB_DIR"
echo "  cgi:  $CGI_DIR"

mkdir -p "$WEB_DIR" "$CGI_DIR"

html_files=(ntripdump.html ntrip_mount.html ntrip_rings.html vrs_mount.html)
for html in "${html_files[@]}"; do
    src="$SCRIPT_DIR/$html"
    if [[ ! -f "$src" ]]; then
        echo "Missing required file: $src" >&2
        exit 1
    fi
    install -m 644 "$src" "$WEB_DIR/$html"
done

for js in jquery.tablesorter.min.js jquery.tablesorter.widgets.min.js; do
    src="$SCRIPT_DIR/$js"
    if [[ -f "$src" ]]; then
        install -m 644 "$src" "$WEB_DIR/$js"
        echo "  installed $js"
    else
        echo "  note: $js not found (optional; place copy in repo root before install)"
    fi
done

# Patch deployed HTML so form actions match /cgi-bin/NTRIP/ layout.
sed -i \
    -e 's|action="/cgi-bin/vrs_mount.sh"|action="/cgi-bin/NTRIP/vrs_mount.sh"|' \
    -e 's|action="cgi-bin/IBSS/ntrip_circles"|action="/cgi-bin/NTRIP/ntrip_circles"|' \
    "$WEB_DIR/vrs_mount.html" \
    "$WEB_DIR/ntrip_rings.html"

if [[ ! -d "$SCRIPT_DIR/cgi-bin" ]]; then
    echo "Missing directory: $SCRIPT_DIR/cgi-bin" >&2
    exit 1
fi

for src in "$SCRIPT_DIR/cgi-bin"/*; do
    base="$(basename "$src")"
    case "$base" in
        .DS_Store) continue ;;
    esac
    case "$base" in
        *.sh|*.pl|*.py|ntrip_circles)
            install -m 755 "$src" "$CGI_DIR/$base"
            ;;
        *)
            install -m 644 "$src" "$CGI_DIR/$base"
            ;;
    esac
done

if id apache >/dev/null 2>&1; then
    chown -R "$WEB_OWNER" "$WEB_DIR"
    chown -R "$CGI_OWNER" "$CGI_DIR"
elif id www-data >/dev/null 2>&1; then
    WEB_OWNER="www-data:www-data"
    CGI_OWNER="www-data:www-data"
    chown -R "$WEB_OWNER" "$WEB_DIR"
    chown -R "$CGI_OWNER" "$CGI_DIR"
fi

echo
echo "Install complete."
echo
echo "Pages:"
echo "  http://<host>/NTRIP/ntripdump.html"
echo "  http://<host>/NTRIP/ntrip_mount.html"
echo "  http://<host>/NTRIP/vrs_mount.html"
echo "  http://<host>/NTRIP/ntrip_rings.html"
echo
echo "Ensure Apache serves CGI from /cgi-bin/ (ScriptAlias) and allows"
echo "ExecCGI in /usr/lib/cgi-bin/NTRIP."
echo
echo "Manual steps still required on the server:"
echo "  - Trimble CSS/images under /var/www/html/css and /var/www/html/images"
echo "  - IBSS_kml_horz_circle, IBSS_kml_vert_circle in $CGI_DIR (for KML rings)"
echo "  - RTCM3/RTCM3_Decode.py under $CGI_DIR (for RTCM3 decode option)"

optional_missing=()
for bin in IBSS_kml_horz_circle IBSS_kml_vert_circle; do
    if [[ ! -x "$CGI_DIR/$bin" ]]; then
        optional_missing+=("$bin")
    fi
done
if [[ ! -x "$CGI_DIR/RTCM3/RTCM3_Decode.py" ]]; then
    optional_missing+=("RTCM3/RTCM3_Decode.py")
fi
if [[ ${#optional_missing[@]} -gt 0 ]]; then
    echo
    echo "Optional components not present after install:"
    for item in "${optional_missing[@]}"; do
        echo "  - $item"
    done
fi
