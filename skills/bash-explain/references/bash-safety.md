# Bash Safety Best Practices

## Essential Safety Flags

### The Holy Trinity: `set -euo pipefail`

```bash
#!/bin/bash
set -euo pipefail

# -e: Exit on any error (non-zero exit code)
# -u: Exit on undefined variable usage
# -o pipefail: Pipe failures cause script to exit
```

**Why this matters**:
- Without `-e`: Script continues after errors, causing cascading failures
- Without `-u`: Typos like `$USRE` instead of `$USER` silently expand to empty string
- Without `-o pipefail`: `failed_command | grep something` succeeds if grep succeeds

---

## Quoting Variables

### ❌ Dangerous (Word Splitting)
```bash
file="my document.txt"
rm $file  # Tries to delete "my" and "document.txt" separately!
```

### ✅ Safe (Quoted)
```bash
file="my document.txt"
rm "$file"  # Deletes "my document.txt" as intended
```

**Rule**: Always quote variables unless you explicitly want word splitting.

---

## Error Handling Patterns

### Check Command Success
```bash
if ! command_that_might_fail; then
    echo "Error: command failed" >&2
    exit 1
fi
```

### Capture Output with Error Handling
```bash
output=$(command) || {
    echo "Error: command failed" >&2
    exit 1
}
```

### Conditional Execution
```bash
# Run next command only if previous succeeds
command1 && command2

# Run next command only if previous fails
command1 || command2
```

---

## Safe File Operations

### Check File Existence Before Deleting
```bash
if [ -f "$file" ]; then
    rm "$file"
else
    echo "Warning: $file does not exist" >&2
fi
```

### Use Temporary Files Safely
```bash
# ❌ Dangerous (predictable name, race condition)
tempfile="/tmp/myapp.tmp"
echo "data" > "$tempfile"

# ✅ Safe (unique name, cleaned up)
tempfile=$(mktemp) || exit 1
trap 'rm -f "$tempfile"' EXIT
echo "data" > "$tempfile"
```

### Interactive Deletion
```bash
# Ask before each deletion
rm -i *.txt

# Verbose output
rm -v file.txt
```

---

## Dangerous Commands to Avoid

### 🔴 Never Run These

1. **`rm -rf /`** - Deletes entire filesystem
   - Even `rm -rf /*` is catastrophic
   - Always verify path before recursive delete

2. **`chmod 777 -R /`** - Makes everything world-writable
   - Severe security risk
   - Use specific permissions (644 for files, 755 for dirs)

3. **`curl http://example.com/script.sh | bash`** - Executes remote code blindly
   - Download first: `curl -O script.sh`
   - Inspect: `cat script.sh`
   - Then run: `bash script.sh`

4. **Fork Bomb: `:(){ :|:& };:`** - Spawns processes until system crashes
   - Uses function recursion to exhaust resources

5. **`dd if=/dev/random of=/dev/sda`** - Overwrites hard drive with random data
   - Irreversible data destruction

6. **`eval "$user_input"`** - Code injection vulnerability
   - Use proper argument parsing instead

---

## Input Validation

### Never Trust User Input
```bash
# ❌ Dangerous
read -p "Enter filename: " filename
rm "$filename"

# ✅ Safe
read -p "Enter filename: " filename
if [[ "$filename" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    rm "$filename"
else
    echo "Error: Invalid filename" >&2
    exit 1
fi
```

---

## Common Pitfalls

### 1. Unquoted Variables
```bash
# ❌ Breaks with spaces
for file in $files; do
    echo $file
done

# ✅ Proper quoting
for file in "$files"; do
    echo "$file"
done
```

### 2. Missing Error Checks
```bash
# ❌ Continues even if cd fails
cd /important/directory
rm -rf *

# ✅ Stops if cd fails
cd /important/directory || exit 1
rm -rf *
```

### 3. Assuming Commands Exist
```bash
# ❌ Fails silently if jq not installed
json=$(jq '.data' file.json)

# ✅ Check first
if ! command -v jq &> /dev/null; then
    echo "Error: jq not installed" >&2
    exit 1
fi
json=$(jq '.data' file.json)
```

### 4. Race Conditions
```bash
# ❌ File could be deleted between check and use
if [ -f "$file" ]; then
    cat "$file"  # Might fail!
fi

# ✅ Handle error
if [ -f "$file" ]; then
    cat "$file" 2>/dev/null || echo "File disappeared"
fi
```

---

## Resources

- **ShellCheck**: https://www.shellcheck.net/ - Static analysis for shell scripts
- **Google Shell Style Guide**: https://google.github.io/styleguide/shellguide.html
- **Bash Pitfalls**: https://mywiki.wooledge.org/BashPitfalls
- **Defensive Bash**: https://news.ycombinator.com/item?id=25175683

---

## Quick Reference

### Safe Script Template
```bash
#!/bin/bash
set -euo pipefail

# Script description
# Usage: ./script.sh <arg1> <arg2>

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <arg1> <arg2>" >&2
    exit 1
fi

# Variables
readonly ARG1="$1"
readonly ARG2="$2"

# Main logic with error handling
main() {
    local result
    result=$(command_that_might_fail) || {
        echo "Error: command failed" >&2
        return 1
    }
    
    echo "Success: $result"
}

# Cleanup trap
cleanup() {
    echo "Cleaning up..."
}
trap cleanup EXIT

# Run main function
main "$@"
```
