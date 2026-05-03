# Espanso UUID Generator

A fast, native UUID generator for [Espanso](https://espanso.org/), written in Rust. Supports both UUIDv4 and RFC 9562 UUIDv7.

## Features

- **Fast & Native**: Uses a compiled Rust binary for minimal overhead.
- **Zero Dependencies**: No need for Python, Node.js, or other runtimes.
- **Multi-platform**: Supports Linux, macOS, and Windows.
- **Modern UUIDs**: Generates standard UUIDv4 and the new time-ordered UUIDv7.

## Triggers

- `:uuid7` -> Generates a UUIDv7 (e.g., `018f3d6c-3b3d-7a3d-8a3d-3b3d3b3d3b3d`)
- `:uuid4` -> Generates a UUIDv4 (e.g., `f47ac10b-58cc-4372-a567-0e02b2c3d479`)

## Installation

### Via Espanso (Recommended)

Once published to the Espanso Hub, you can install it using:

```bash
espanso install espanso-uuid
```

### Manual Installation

1. Download the latest release for your platform from the [Releases](https://github.com/wegrw-uk/espanso-uuid/releases) page.
2. Extract the contents to your Espanso packages directory:
   - **Linux**: `~/.config/espanso/packages/espanso-uuid/`
   - **macOS**: `~/Library/Application Support/espanso/packages/espanso-uuid/`
   - **Windows**: `%AppData%/espanso/packages/espanso-uuid/`
3. Restart Espanso.

## Development

### Structure

- `uuid_rs/`: The Rust source code for the generator binary.
- `0.1.0/`: The Espanso package configuration and match files for version 0.1.0.
- `scripts/`: Helper scripts for building and packaging.

### Building from Source

You need [Rust](https://rustup.rs/) installed.

```bash
# Build the binary
cargo build --release --manifest-path uuid_rs/Cargo.toml

# Package for all platforms (requires cross-compilers)
./scripts/build_espanso_package.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
