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

### 1. Espanso Hub (Coming Soon / Universal)
Once accepted into the official Espanso Hub, this package will be installable via a single command across all operating systems. It uses a lightweight Python wrapper to automatically route to the correct, high-performance Rust binary for your system.

```bash
espanso install espanso-uuid
```

### 2. Pre-compiled Binaries (Strict Zero-Dependency)
For users who want to install immediately or prefer a strict zero-dependency approach (bypassing the Python router entirely), you can download the OS-specific pre-compiled archives. These archives use absolute paths to directly invoke the native Rust binary.

1. Download the latest archive for your OS from the [Releases](https://github.com/wegrw-uk/espanso-uuid/releases) page:
   * **Windows:** `espanso-uuid-windows-0.1.14.zip`
   * **macOS:** `espanso-uuid-macos-0.1.14.tar.gz`
   * **Linux:** `espanso-uuid-linux-0.1.14.tar.gz`
2. Open your Espanso matches directory by running `espanso path` and looking for the "Matches" entry.
3. Navigate into the `packages` subfolder.
4. Extract the downloaded archive into a folder exactly named `espanso-uuid`.
5. Restart Espanso: `espanso restart`

### 3. From Source (via Git)
If you prefer to install via Git, you must compile the Rust binary yourself.

1. Install the source repository:
   ```bash
   espanso install espanso-uuid --git https://github.com/wegrw-uk/espanso-uuid --external
   ```
2. Open your terminal and navigate to the newly cloned package folder (e.g., `%APPDATA%\espanso\match\packages\espanso-uuid` on Windows).
3. Compile the binary: `cargo build --release --manifest-path uuid_rs/Cargo.toml`
4. Prepare the binary (the root package uses the Python router for local testing, so you must create the expected `bin/` structure):
   * **Windows:** `mkdir bin && copy uuid_rs\target\release\espanso-uuid-rs.exe bin\uuid-windows.exe`
   * **macOS/Linux:** `mkdir -p bin && cp uuid_rs/target/release/espanso-uuid-rs bin/uuid-linux` (or `uuid-macos`)
5. Restart Espanso: `espanso restart`

## Building and packaging

Use the release script from the repository root:

```bash
./scripts/build_espanso_package.sh
```

The script assembles output under `dist/espanso-uuid/0.1.0/` and can also create a compressed archive.
