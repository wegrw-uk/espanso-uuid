#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRATE_DIR="$REPO_ROOT/uuid_rs"
PACKAGE_NAME="espanso-uuid"

# Use root files as source
if [[ ! -f "$REPO_ROOT/_manifest.yml" ]]; then
  echo "error: expected package manifest at $REPO_ROOT/_manifest.yml" >&2
  exit 1
fi

VERSION="$(awk '/^version:/ { print $2; exit }' "$REPO_ROOT/_manifest.yml")"
if [[ -z "$VERSION" ]]; then
  echo "error: unable to parse package version from _manifest.yml" >&2
  exit 1
fi

OUT_ROOT="$REPO_ROOT/dist/$PACKAGE_NAME"
# Hub versioned directory
HUB_OUT_DIR="$OUT_ROOT/$VERSION"
# Local/External distribution (flat)
FLAT_OUT_DIR="$OUT_ROOT/latest"

BUILD_HOST=true
ATTEMPT_CROSS=true
ALLOW_PARTIAL=false
CREATE_ARCHIVE=true
SKIP_BUILD=false

usage() {
  cat <<'EOF'
Usage: ./scripts/build_espanso_package.sh [options]

Options:
  --host-only         Build only the current host target
  --allow-partial     Do not fail if one or more platform binaries are missing
  --no-archive        Skip creating archives
  --skip-build        Skip compilation and only package existing binaries
  -h, --help          Show this help

Output:
  dist/espanso-uuid/<version>/ (Hub format)
  dist/espanso-uuid/latest/    (External format)
  dist/espanso-uuid/*.tar.gz
  dist/espanso-uuid/*.zip
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host-only) ATTEMPT_CROSS=false; shift ;;
    --allow-partial) ALLOW_PARTIAL=true; shift ;;
    --no-archive) CREATE_ARCHIVE=false; shift ;;
    --skip-build) SKIP_BUILD=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option $1" >&2; usage >&2; exit 1 ;;
  esac
done

build_target() {
  local target="$1"
  local source_bin="$2"
  local dest_name="$3"
  local built_path="$CRATE_DIR/target/$target/release/$source_bin"

  if [[ "$SKIP_BUILD" == false ]]; then
    echo "==> Building target: $target"
    if ! cargo build --release --target "$target" --manifest-path "$CRATE_DIR/Cargo.toml"; then
      echo "warn: failed to build target $target" >&2
      return 1
    fi
  else
    echo "==> Skipping build for target: $target"
  fi

  if [[ ! -f "$built_path" ]]; then
    echo "error: binary not found at $built_path" >&2
    return 1
  fi

  # Copy to both output formats
  cp "$built_path" "$HUB_OUT_DIR/bin/$dest_name"
  cp "$built_path" "$FLAT_OUT_DIR/bin/$dest_name"

  if [[ "$dest_name" != *.exe ]]; then
    chmod +x "$HUB_OUT_DIR/bin/$dest_name" "$FLAT_OUT_DIR/bin/$dest_name"
  fi
  echo "ok: wrote $dest_name"
  return 0
}

echo "==> Preparing output directories"
rm -rf "$OUT_ROOT"
mkdir -p "$HUB_OUT_DIR/bin" "$FLAT_OUT_DIR/bin"

# 1. Prepare FLAT (External) package - keep paths as they are in root
cp "$REPO_ROOT/_manifest.yml" "$REPO_ROOT/package.yml" "$REPO_ROOT/README.md" "$FLAT_OUT_DIR/"

# 2. Prepare HUB package - inject version into paths
for f in _manifest.yml package.yml README.md; do
  sed "s/packages\/$PACKAGE_NAME\/bin/packages\/$PACKAGE_NAME\/$VERSION\/bin/g" "$REPO_ROOT/$f" > "$HUB_OUT_DIR/$f"
done

HOST_TARGET="$(rustc -vV | awk '/^host:/ {print $2}')"
LINUX_OK=false; MACOS_OK=false; WINDOWS_OK=false

if [[ "$BUILD_HOST" == true ]]; then
  case "$HOST_TARGET" in
    *-linux-*) build_target "$HOST_TARGET" "espanso-uuid-rs" "uuid-linux" && LINUX_OK=true || true ;;
    *-apple-darwin) build_target "$HOST_TARGET" "espanso-uuid-rs" "uuid-macos" && MACOS_OK=true || true ;;
    *-windows-*) build_target "$HOST_TARGET" "espanso-uuid-rs.exe" "uuid-windows.exe" && WINDOWS_OK=true || true ;;
  esac
fi

if [[ "$ATTEMPT_CROSS" == true ]]; then
  [[ "$LINUX_OK" == false ]] && build_target "x86_64-unknown-linux-gnu" "espanso-uuid-rs" "uuid-linux" && LINUX_OK=true || true
  [[ "$MACOS_OK" == false ]] && build_target "x86_64-apple-darwin" "espanso-uuid-rs" "uuid-macos" && MACOS_OK=true || true
  [[ "$WINDOWS_OK" == false ]] && build_target "x86_64-pc-windows-gnu" "espanso-uuid-rs.exe" "uuid-windows.exe" && WINDOWS_OK=true || true
fi

if [[ "$ALLOW_PARTIAL" == false && ("$LINUX_OK" != true || "$MACOS_OK" != true || "$WINDOWS_OK" != true) ]]; then
  echo "error: missing one or more platform binaries" >&2
  exit 1
fi

if [[ "$CREATE_ARCHIVE" == true ]]; then
  # Universal Hub Archive (includes versioned folder)
  (cd "$OUT_ROOT" && tar -czf "${PACKAGE_NAME}-hub-${VERSION}.tar.gz" "$VERSION")

  # Flat Archive (External/Direct install)
  (cd "$FLAT_OUT_DIR" && tar -czf "$OUT_ROOT/${PACKAGE_NAME}-${VERSION}.tar.gz" .)
  if command -v zip >/dev/null 2>&1; then
    (cd "$FLAT_OUT_DIR" && zip -rq "$OUT_ROOT/${PACKAGE_NAME}-${VERSION}.zip" .)
  fi
  # Platform-specific archives (Exclusive package.yml per OS)
  for plat in linux macos windows; do
    PLAT_DIR="$OUT_ROOT/tmp-$plat"
    mkdir -p "$PLAT_DIR/bin"
    cp "$FLAT_OUT_DIR/_manifest.yml" "$FLAT_OUT_DIR/README.md" "$PLAT_DIR/"
    
    # Determine the correct CONFIG variable and path based on OS
    config_var="\$CONFIG"
    if [[ "$plat" == "windows" ]]; then
      config_var="%CONFIG%"
    fi
    binary_path="${config_var}/match/packages/${PACKAGE_NAME}/bin/uuid-$plat$([[ "$plat" == "windows" ]] && echo ".exe")"

    # Generate an OS-specific package.yml that targets the exact binary with an absolute path
    cat <<EOF > "$PLAT_DIR/package.yml"
matches:
  - trigger: ":uuid7"
    replace: "{{output}}"
    vars:
      - name: output
        type: script
        params:
          args:
            - "$binary_path"
            - "7"

  - trigger: ":uuid4"
    replace: "{{output}}"
    vars:
      - name: output
        type: script
        params:
          args:
            - "$binary_path"
            - "4"
EOF

    if [[ "$plat" == "windows" ]]; then
      cp "$FLAT_OUT_DIR/bin/uuid-windows.exe" "$PLAT_DIR/bin/"
      (cd "$PLAT_DIR" && zip -rq "$OUT_ROOT/${PACKAGE_NAME}-${plat}-${VERSION}.zip" .)
    else
      cp "$FLAT_OUT_DIR/bin/uuid-${plat}" "$PLAT_DIR/bin/"
      tar -C "$PLAT_DIR" -czf "$OUT_ROOT/${PACKAGE_NAME}-${plat}-${VERSION}.tar.gz" "."
    fi
    rm -rf "$PLAT_DIR"
  done
fi

echo "==> Done. Version: $VERSION"
echo "Archives in $OUT_ROOT"
