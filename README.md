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

### 1. Manual Installation (Recommended for Pre-compiled Binaries)
Since this package uses a compiled Rust binary for performance, the easiest way to install it is to download a pre-compiled archive.

1.  Download the latest archive for your OS from the [Releases](https://github.com/wegrw-uk/espanso-uuid/releases) page (e.g., `espanso-uuid-windows-0.1.7.zip`).
2.  Open your Espanso matches directory. You can find this by running `espanso path` and looking for the "Matches" entry.
3.  Navigate to the `packages` subfolder (create it if it doesn't exist).
4.  Extract the downloaded archive into a folder named `espanso-uuid`.
    *   The path should look like `.../espanso/match/packages/espanso-uuid/package.yml`.
5.  Restart Espanso: `espanso restart`

### 2. From Source (via Git)
If you prefer to install via Git, you must compile the binary yourself.

1.  Install the source code:
    ```bash
    espanso install espanso-uuid --git https://github.com/wegrw-uk/espanso-uuid --external
    ```
2.  Navigate to the package folder (e.g., `%APPDATA%\espanso\match\packages\espanso-uuid` on Windows).
3.  Compile: `cargo build --release --manifest-path uuid_rs/Cargo.toml`
4.  Prepare the binary:
    *   **Windows:** `mkdir bin && copy uuid_rs\target\release\espanso-uuid-rs.exe bin\uuid-windows.exe`
    *   **macOS/Linux:** `mkdir -p bin && cp uuid_rs/target/release/espanso-uuid-rs bin/uuid-linux` (or `uuid-macos`)
5.  Restart Espanso: `espanso restart`

## Building and packaging

Use the release script from the repository root:

```bash
./scripts/build_espanso_package.sh
```

The script assembles output under `dist/espanso-uuid/0.1.0/` and can also create a compressed archive.
