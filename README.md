# UUID for Espanso

This package provides triggers to generate UUIDv4 and RFC 9562 UUIDv7 values using a compiled Rust binary.

## Requirements

- Espanso installed.
- Zero external dependencies (no Python, Node.js, or Rust toolchain required).

## Usage

- Type `:uuid7` to generate a new UUIDv7.
- Type `:uuid4` to generate a new UUIDv4.

## How it works

The package uses a small Rust binary based on the `uuid` crate.
The package uses Espanso's `filter_os` feature to automatically load the correct binary for your system:

- Linux: `bin/uuid-linux`
- macOS: `bin/uuid-macos`
- Windows: `bin/uuid-windows.exe`

## Installation

### 1. Espanso Hub (Coming Soon / Universal)
Once accepted into the official Espanso Hub, this package will be installable via a single command across all operating systems.

```bash
espanso install espanso-uuid
```

### 2. Pre-compiled Binaries
For users who want to install immediately, you can download the OS-specific pre-compiled archives. These archives are designed to be extracted directly into your Espanso packages folder.

1. Download the latest archive for your OS from the [Releases](https://github.com/wegrw-uk/espanso-uuid/releases) page:
   * **Windows:** `espanso-uuid-windows-0.1.17.zip`
   * **macOS:** `espanso-uuid-macos-0.1.17.tar.gz`
   * **Linux:** `espanso-uuid-linux-0.1.17.tar.gz`
2. Open your Espanso matches directory by running `espanso path` and looking for the "Matches" entry.
3. Navigate into the `packages` subfolder.
4. Extract the downloaded archive into a folder exactly named `espanso-uuid`.
5. Restart Espanso: `espanso restart`

### 3. From Source / Git (Easiest)
This package includes pre-compiled binaries for Linux, macOS, and Windows directly in the repository. This means you can install it via Git and it will work immediately without needing to compile anything or install the Rust toolchain.

```bash
espanso install espanso-uuid --git https://github.com/wegrw-uk/espanso-uuid --external
```

After installation, simply restart Espanso: `espanso restart`

## Building and packaging

The build and packaging process is fully automated via GitHub Actions. On every push to `main`, the binaries are recompiled and committed to the `bin/` directory.

To manually trigger a build (requires Rust):

```bash
cargo build --release --manifest-path uuid_rs/Cargo.toml
```
