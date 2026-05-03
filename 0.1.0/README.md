# UUID for Espanso

This package provides triggers to generate UUIDv4 and RFC 9562 UUIDv7 values using a compiled Rust binary.

## Requirements

- Espanso installed.
- No external runtime (like Python or Node.js) is required.

## Usage

- Type `:uuid7` to generate a new UUIDv7.
- Type `:uuid4` to generate a new UUIDv4.

## How it works

The package uses a small Rust binary based on the `uuid` crate.
The package is split into OS-specific match files:

- Linux loads `bin/uuid-linux`
- macOS loads `bin/uuid-macos`
- Windows loads `bin/uuid-windows.exe`

Only the active OS variant is loaded through Espanso's `filter_os` field.

## Installation

If you are installing this manually:

1. Copy the `0.1.0` folder to your Espanso packages directory:
   - Linux: `~/.config/espanso/packages/espanso-uuid/0.1.0/`
   - macOS: `~/Library/Application Support/espanso/packages/espanso-uuid/0.1.0/`
   - Windows: `%AppData%/espanso/packages/espanso-uuid/0.1.0/`
2. Ensure the Linux/macOS binaries are executable (`chmod +x bin/uuid-linux bin/uuid-macos`).
3. Restart Espanso.

## Building and packaging

Use the release script from the repository root:

```bash
./scripts/build_espanso_package.sh
```

The script assembles output under `dist/espanso-uuid7/0.1.0/` and can also create a compressed archive.
