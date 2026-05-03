import os
import subprocess
import sys


def main():
    if len(sys.argv) < 2:
        print("Error: Missing UUID version argument", file=sys.stderr)
        return
    mode = sys.argv[1]

    # Get the absolute path to the package directory
    base_dir = os.path.dirname(os.path.abspath(__file__))

    # Route to the correct binary based on the OS
    if sys.platform.startswith("win"):
        binary = "uuid-windows.exe"
    elif sys.platform.startswith("darwin"):
        binary = "uuid-macos"
    else:
        binary = "uuid-linux"

    bin_path = os.path.join(base_dir, "bin", binary)

    # Check if the binary exists before attempting to execute
    if not os.path.exists(bin_path):
        print(f"Error: Binary not found at '{bin_path}'", file=sys.stderr)
        return

    # Ensure the binary has executable permissions (helpful for Unix)
    if not sys.platform.startswith("win"):
        os.chmod(bin_path, 0o755)

    try:
        result = subprocess.run(
            [bin_path, mode], capture_output=True, text=True, check=True
        )
        # Print the exact output without a trailing newline
        print(result.stdout, end="")
    except subprocess.CalledProcessError as e:
        print(
            f"Error executing binary '{bin_path}' with mode '{mode}' (code {e.returncode}): {e.stderr}",
            file=sys.stderr,
        )
    except Exception as e:
        print(f"Failed to execute UUID binary '{bin_path}': {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
