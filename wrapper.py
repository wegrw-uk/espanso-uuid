import sys
import subprocess
import os

def main():
    # Default to v7 if no argument is passed
    mode = sys.argv[1] if len(sys.argv) > 1 else "7"
    
    # Get the absolute path to the package directory
    base_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Route to the correct binary based on the OS
    if sys.platform.startswith('win'):
        binary = "uuid-windows.exe"
    elif sys.platform.startswith('darwin'):
        binary = "uuid-macos"
    else:
        binary = "uuid-linux"
        
    bin_path = os.path.join(base_dir, "bin", binary)
    
    # Ensure the binary has executable permissions (helpful for Unix)
    if not sys.platform.startswith('win') and os.path.exists(bin_path):
        os.chmod(bin_path, 0o755)
    
    try:
        result = subprocess.run([bin_path, mode], capture_output=True, text=True, check=True)
        # Print the exact output without a trailing newline
        print(result.stdout, end="")
    except Exception as e:
        print(f"Error executing binary: {e}", end="")

if __name__ == "__main__":
    main()
