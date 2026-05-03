#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRATE_DIR="$REPO_ROOT/uuid_rs"
PACKAGE_NAME="espanso-uuid"
DEFAULT_VERSION_DIR="$REPO_ROOT/0.1.0"

if [[ ! -f "$DEFAULT_VERSION_DIR/_manifest.yml" ]]; then
  echo "error: expected package template at $DEFAULT_VERSION_DIR" >&2
  exit 1
fi

VERSION="$(awk '/^version:/ { print $2; exit }' "$DEFAULT_VERSION_DIR/_manifest.yml")"
if [[ -z "$VERSION" ]]; then
  echo "error: unable to parse package version from _manifest.yml" >&2
  exit 1
fi

PACKAGE_TEMPLATE_DIR="$REPO_ROOT/$VERSION"
if [[ ! -d "$PACKAGE_TEMPLATE_DIR" ]]; then
  echo "error: expected versioned package directory $PACKAGE_TEMPLATE_DIR" >&2
  exit 1
fi

OUT_ROOT="$REPO_ROOT/dist/$PACKAGE_NAME"
OUT_DIR="$OUT_ROOT/$VERSION"
ARCHIVE_PATH="$OUT_ROOT/${PACKAGE_NAME}-${VERSION}.tar.gz"

BUILD_HOST=true
ATTEMPT_CROSS=true
ALLOW_PARTIAL=false

usage() {
  cat <<'EOF'
Usage: ./scripts/build_espanso_package.sh [options]

Options:
  --host-only         Build only the current host target and package it
  --allow-partial     Do not fail if one or more platform binaries are missing
  --no-archive        Skip creating the final tar.gz archive
  -h, --help          Show this help

Output:
  dist/espanso-uuid7/<version>/
  dist/espanso-uuid/espanso-uuid-<version>.tar.gz
EOF
}

CREATE_ARCHIVE=true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host-only)
      ATTEMPT_CROSS=false
      shift
      ;;
    --allow-partial)
      ALLOW_PARTIAL=true
      shift
      ;;
    --no-archive)
      CREATE_ARCHIVE=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

build_target() {
  local target="$1"
  local source_bin="$2"
  local dest_name="$3"

  echo "==> Building target: $target"
  if cargo build --release --target "$target" --manifest-path "$CRATE_DIR/Cargo.toml"; then
    local built_path="$CRATE_DIR/target/$target/release/$source_bin"
    if [[ ! -f "$built_path" ]]; then
      echo "error: build succeeded but binary not found at $built_path" >&2
      return 1
    fi
    cp "$built_path" "$OUT_DIR/bin/$dest_name"
    if [[ "$dest_name" != *.exe ]]; then
      chmod +x "$OUT_DIR/bin/$dest_name"
    fi
    echo "ok: wrote $OUT_DIR/bin/$dest_name"
    return 0
  fi

  echo "warn: failed to build target $target" >&2
  return 1
}

echo "==> Preparing output directory: $OUT_DIR"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR/bin"

cp "$PACKAGE_TEMPLATE_DIR/_manifest.yml" "$OUT_DIR/_manifest.yml"
cp "$PACKAGE_TEMPLATE_DIR/package.yml" "$OUT_DIR/package.yml"
cp "$PACKAGE_TEMPLATE_DIR/README.md" "$OUT_DIR/README.md"
cp "$PACKAGE_TEMPLATE_DIR/_linux.yml" "$OUT_DIR/_linux.yml"
cp "$PACKAGE_TEMPLATE_DIR/_macos.yml" "$OUT_DIR/_macos.yml"
cp "$PACKAGE_TEMPLATE_DIR/_windows.yml" "$OUT_DIR/_windows.yml"

HOST_TARGET="$(rustc -vV | awk '/^host:/ {print $2; exit}')"
HOST_OK=false
LINUX_OK=false
MACOS_OK=false
WINDOWS_OK=false

if [[ "$BUILD_HOST" == true ]]; then
  case "$HOST_TARGET" in
    *-linux-*)
      build_target "$HOST_TARGET" "espanso-uuid-rs" "uuid-linux" && HOST_OK=true && LINUX_OK=true || true
      ;;
    *-apple-darwin)
      build_target "$HOST_TARGET" "espanso-uuid-rs" "uuid-macos" && HOST_OK=true && MACOS_OK=true || true
      ;;
    *-windows-*)
      build_target "$HOST_TARGET" "espanso-uuid-rs.exe" "uuid-windows.exe" && HOST_OK=true && WINDOWS_OK=true || true
      ;;
    *)
      echo "warn: unsupported host target for naming map: $HOST_TARGET" >&2
      ;;
  esac
fi

if [[ "$ATTEMPT_CROSS" == true ]]; then
  if [[ "$LINUX_OK" == false ]]; then
    build_target "x86_64-unknown-linux-gnu" "espanso-uuid-rs" "uuid-linux" && LINUX_OK=true || true
  fi

  if [[ "$MACOS_OK" == false ]]; then
    build_target "x86_64-apple-darwin" "espanso-uuid-rs" "uuid-macos" && MACOS_OK=true || true
  fi

  if [[ "$WINDOWS_OK" == false ]]; then
    build_target "x86_64-pc-windows-gnu" "espanso-uuid-rs.exe" "uuid-windows.exe" && WINDOWS_OK=true || true
  fi
fi

echo
printf 'Built binaries:\n'
[[ "$LINUX_OK" == true ]] && echo "  - linux:   yes" || echo "  - linux:   no"
[[ "$MACOS_OK" == true ]] && echo "  - macos:   yes" || echo "  - macos:   no"
[[ "$WINDOWS_OK" == true ]] && echo "  - windows: yes" || echo "  - windows: no"

if [[ "$ALLOW_PARTIAL" == false ]]; then
  if [[ "$LINUX_OK" != true || "$MACOS_OK" != true || "$WINDOWS_OK" != true ]]; then
    echo "error: missing one or more platform binaries; rerun with --allow-partial to package anyway" >&2
    exit 1
  fi
fi

if [[ "$CREATE_ARCHIVE" == true ]]; then
  mkdir -p "$OUT_ROOT"
  tar -C "$OUT_ROOT" -czf "$ARCHIVE_PATH" "$VERSION"
  echo "==> Wrote archive: $ARCHIVE_PATH"
fi

echo "==> Done. Package directory: $OUT_DIR"
