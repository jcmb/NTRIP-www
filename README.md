# NTRIP-www

Web-based NTRIP diagnostic tools for testing caster connectivity, browsing sourcetables, verifying mountpoint data flow, testing VRS connections, and generating KML accuracy rings.

Designed for **Linux** with Apache CGI. Intended as an internal/support utility on a trusted network.

## Features

| Page | Purpose |
|------|---------|
| `ntripdump.html` | Fetch and display an NTRIP sourcetable (sortable) |
| `ntrip_mount.html` | Test a fixed-base mountpoint (no position required) |
| `vrs_mount.html` | Test a VRS/network mountpoint with lat/long and optional RTCM3 decode |
| `ntrip_rings.html` | Download KML accuracy rings derived from a sourcetable |

Mountpoints in the sourcetable link directly to the mount-test CGIs. VRS entries include lat/long from the table row.

## Requirements

### Runtime (Linux)

- Apache with CGI enabled
- `perl`
- `python3`
- `curl`

### From this repo

- HTML forms in the repo root
- CGI scripts in `cgi-bin/`

### From the IBSS repo (`cgi-bin/`)

Required for KML accuracy rings (`ntrip_rings.html`):

- `IBSS_kml_horz_circle`
- `IBSS_kml_vert_circle`

Clone IBSS alongside NTRIP-www (e.g. `../IBSS/cgi-bin`) or pass `--ibss-cgi-dir` to the installer.

### Server assets (not in either repo)

- Trimble CSS: `/var/www/html/css/tcui-styles.css`, `theme.blue.css`
- Trimble logo: `/var/www/html/images/trimble-logo.jpg` (and `.png` if used)
- jQuery Tablesorter (optional, not committed here): copy `jquery.tablesorter.min.js` and `jquery.tablesorter.widgets.min.js` into the NTRIP-www repo root before install, or place them directly in `/var/www/html/NTRIP/`
- RTCM3 decoder (optional): `RTCM3/RTCM3_Decode.py` under the CGI directory for the “Decode Stream as RTCM3” option on VRS mount tests

## Installation

```bash
git clone <NTRIP-www-repo>
git clone <IBSS-repo> ../IBSS    # sibling checkout recommended

cd NTRIP-www
sudo ./install.sh
```

Custom paths:

```bash
sudo ./install.sh \
  --web-dir /var/www/html/NTRIP \
  --cgi-dir /usr/lib/cgi-bin/NTRIP \
  --ibss-cgi-dir /path/to/IBSS/cgi-bin
```

The installer:

1. Copies HTML to `/var/www/html/NTRIP`
2. Copies CGI scripts to `/usr/lib/cgi-bin/NTRIP` (mode 755)
3. Installs `IBSS_kml_*` binaries from the IBSS repo
4. Patches deployed `vrs_mount.html` and `ntrip_rings.html` form actions to `/cgi-bin/NTRIP/…`
5. Sets ownership to `apache` or `www-data` when present

### Apache configuration

Ensure CGI is enabled and `/cgi-bin/` is mapped to `/usr/lib/cgi-bin/` (default on RHEL/CentOS). Example:

```apache
ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
<Directory "/usr/lib/cgi-bin">
    AllowOverride None
    Options +ExecCGI
    Require all granted
</Directory>
```

After install, these URLs should work:

- `http://<host>/NTRIP/ntripdump.html`
- `http://<host>/NTRIP/ntrip_mount.html`
- `http://<host>/NTRIP/vrs_mount.html`
- `http://<host>/NTRIP/ntrip_rings.html`

CGI endpoints live under `/cgi-bin/NTRIP/` (e.g. `/cgi-bin/NTRIP/ntripdump.sh`).

## Repository layout

```
NTRIP-www/
├── install.sh              # Linux installer
├── ntripdump.html          # Sourcetable browser form
├── ntrip_mount.html        # Base mount test form
├── vrs_mount.html          # VRS mount test form
├── ntrip_rings.html        # KML rings form
└── cgi-bin/
    ├── NtripClient.py      # NTRIP client (Python 3)
    ├── ntripdump.sh        # Sourcetable CGI
    ├── ntripdump.pl        # Sourcetable HTML formatter
    ├── ntrip_mount.sh      # Base mount test CGI
    ├── ibss_mount.pl       # IBSS-specific status parser
    ├── ntrip_mount.pl      # Generic NTRIP status parser
    ├── vrs_mount.sh        # VRS mount test CGI
    ├── ntrip_circles       # KML rings CGI
    ├── ntripibss_horz_circle.pl
    └── ntripibss_vert_circle.pl
```

## How it works

```
Browser form  →  Bash CGI  →  curl / NtripClient.py  →  NTRIP caster
                    ↓
              Perl formatter  →  HTML or KML response
```

- **Sourcetable**: `curl --http0.9` handles legacy casters; supports NTRIP v1/v2.
- **Base mount**: `NtripClient.py` connects for 10 seconds, captures headers and stream bytes.
- **VRS mount**: same client with `--GGA` and user-supplied lat/long; 20 seconds when RTCM3 decode is requested.
- **KML rings**: downloads sourcetable, Perl filters base stations, IBSS KML binaries generate placemarks.

Temporary files use `/tmp/` with `$$` suffixes and are removed after use.

## Known limitations

- **Credentials in GET requests** — usernames and passwords appear in URLs, server logs, and browser history. Use only on trusted networks.
- **RTCM3 on base mount** — checkbox present in `ntrip_mount.html`; backend wiring in `ntrip_mount.sh` is not yet implemented (see TODO in HTML).
- **Linux only** — uses `stat -c %s` and expects standard Apache layout on RHEL-style systems.
- **No input sanitization** — query parameters are passed to shell commands; do not expose publicly.

## Development

Clone both repos side by side:

```
GitHub/
├── NTRIP-www/
└── IBSS/
```

Run CGI scripts locally only with care; they expect Apache `QUERY_STRING` and write to `/tmp/`.

### Optional: Tablesorter

`ntripdump.sh` loads Tablesorter from `/NTRIP/jquery.tablesorter*.js`. These files are listed in `.gitignore` and must be supplied at install time.

## Related repositories

| Repo | Provides |
|------|----------|
| **NTRIP-www** (this repo) | HTML forms, NTRIP test CGIs, sourcetable display |
| **IBSS** | `IBSS_kml_horz_circle`, `IBSS_kml_vert_circle` for accuracy rings |
