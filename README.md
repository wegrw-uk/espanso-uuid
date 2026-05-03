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

Espanso external packages can be installed directly from a URL.

### Windows
```bash
espanso install espanso-uuid --url https://github.com/wegrw-uk/espanso-uuid/releases/download/v0.1.5/espanso-uuid-windows-0.1.3.zip --external
```

### macOS
```bash
espanso install espanso-uuid --url https://github.com/wegrw-uk/espanso-uuid/releases/download/v0.1.5/espanso-uuid-macos-0.1.3.tar.gz --external
```

### Linux
```bash
espanso install espanso-uuid --url https://github.com/wegrw-uk/espanso-uuid/releases/download/v0.1.5/espanso-uuid-linux-0.1.3.tar.gz --external
```

## Building and packaging

Use the release script from the repository root:

```bash
./scripts/build_espanso_package.sh
```

The script assembles output under `dist/espanso-uuid/0.1.0/` and can also create a compressed archive.
