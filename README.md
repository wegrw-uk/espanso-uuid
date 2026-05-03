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

### Pre-compiled Binaries (Recommended)
This is the easiest method. It downloads the pre-compiled binaries directly from the latest GitHub Release.

**Windows**
```bash
espanso install espanso-uuid --url https://github.com/wegrw-uk/espanso-uuid/releases/download/v0.1.6/espanso-uuid-windows-0.1.6.zip --external
```

**macOS**
```bash
espanso install espanso-uuid --url https://github.com/wegrw-uk/espanso-uuid/releases/download/v0.1.6/espanso-uuid-macos-0.1.6.tar.gz --external
```

**Linux**
```bash
espanso install espanso-uuid --url https://github.com/wegrw-uk/espanso-uuid/releases/download/v0.1.6/espanso-uuid-linux-0.1.6.tar.gz --external
```

### From Source (via Git)
If you install directly from the Git repository, you will only download the source code. You **must** compile the binary yourself using the Rust toolchain (`cargo`).

1. Install the source code via git:
   ```bash
   espanso install espanso-uuid --git https://github.com/wegrw-uk/espanso-uuid --external
   ```
2. Open your terminal and navigate to the newly cloned package folder (e.g., `%APPDATA%\espanso\match\packages\espanso-uuid` on Windows).
3. Compile the binary:
   ```bash
   cargo build --release --manifest-path uuid_rs/Cargo.toml
   ```
4. Create the `bin` directory and copy the compiled executable into it:
   * **Windows:** `mkdir bin && copy uuid_rs\target\release\espanso-uuid-rs.exe bin\uuid-windows.exe`
   * **macOS:** `mkdir -p bin && cp uuid_rs/target/release/espanso-uuid-rs bin/uuid-macos`
   * **Linux:** `mkdir -p bin && cp uuid_rs/target/release/espanso-uuid-rs bin/uuid-linux`
5. Restart espanso: `espanso restart`

## Building and packaging

Use the release script from the repository root:

```bash
./scripts/build_espanso_package.sh
```

The script assembles output under `dist/espanso-uuid/0.1.0/` and can also create a compressed archive.
