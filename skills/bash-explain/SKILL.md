---
name: bash-explain
description: Explain bash commands with safety analysis and best practices. Use when asked to explain bash command, what does this command do, is this safe to run, explain shell script, or breakdown command.
allowed-tools: []
---

# Bash Command Explanation Skill

Explains bash commands with detailed safety analysis and suggests improvements.

## When to Activate

This skill activates when the user requests:
- "explain this bash command: `rm -rf /tmp/*.log`"
- "what does `git log --oneline --graph` do?"
- "is this safe to run: `curl | bash`"
- "breakdown this shell script"
- "what are the flags in `ls -lah`"

## Required Workflow

### Step 1: Parse Command

Break down the command into components:
1. **Main command**: Base executable (e.g., `ls`, `git`, `docker`)
2. **Flags/options**: Short (`-a`) and long (`--all`) options
3. **Arguments**: Files, paths, values
4. **Pipes**: `|` chaining commands
5. **Redirects**: `>`, `>>`, `<`, `2>&1`
6. **Logic operators**: `&&`, `||`, `;`
7. **Subshells**: `$(...)`, `` `...` ``

### Step 2: Explain Each Part

For each component, provide:
- **What it does**: Plain English explanation
- **Common use cases**: When you'd use this
- **Variations**: Related flags or commands

### Step 3: Safety Assessment

Analyze command safety using references/bash-safety.md:

**Safety Levels**:
- 🔴 **DANGEROUS**: Could cause data loss, system damage, or security issues
  - Examples: `rm -rf /`, `chmod 777`, `curl | bash`, `:(){ :|:& };:`
  - Warning: "⚠️ This command can [specific risk]. Do NOT run unless you're certain."

- ⚠️ **CAUTION**: Requires privileges or has side effects
  - Examples: `sudo`, file modifications, system changes
  - Note: "This requires [permission/consideration]. Understand impact before running."

- ✅ **SAFE**: Read-only, no side effects
  - Examples: `ls`, `cat`, `grep`, `git log`
  - Info: "Safe to run. No system modifications."

### Step 4: Error Handling Analysis

Check if command has proper error handling:
- `set -e`: Exit on error
- `set -u`: Exit on undefined variable
- `set -o pipefail`: Pipe failures propagate
- Error checks: `if [ $? -ne 0 ]`

### Step 5: Suggest Improvements

Provide safer/better alternatives:
- **Quoting**: `"$var"` instead of `$var`
- **Safer flags**: `rm -i` (interactive) instead of `rm -f`
- **Error handling**: Add `|| exit 1` to critical commands
- **Readability**: Break long one-liners into multiple lines
- **Portability**: POSIX-compliant vs Bash-specific features

## Output Format

```markdown
## Command Breakdown

**Command**: `[original command]`

**Safety**: [🔴 DANGEROUS | ⚠️ CAUTION | ✅ SAFE]

---

### Components

1. **`command`** - [Explanation]
   - Does: [What it does]
   - Flags:
     - `-x`: [Flag explanation]
     - `--option`: [Long option explanation]

2. **`|`** - Pipe operator
   - Sends output of previous command as input to next

3. **`> file.txt`** - Redirect
   - Writes output to file (overwrites existing content)

---

### What This Does

[Plain English explanation of the entire command]

---

### Safety Analysis

[Safety level explanation with specific risks]

**Potential Issues**:
- [Risk 1]
- [Risk 2]

---

### Suggested Improvements

**Original**:
```bash
[original command]
```

**Safer Version**:
```bash
[improved command with comments]
```

**Changes**:
- [Improvement 1 explanation]
- [Improvement 2 explanation]

---

### Example Usage

```bash
# [Comment explaining context]
[example command]

# Expected output:
[sample output]
```
```

## Stop Rules

**STOP and warn user if**:
1. 🔴 Command is extremely dangerous (data destruction, fork bombs, etc.)
   - Show big warning: "⚠️ **STOP**: This command will [risk]. Do NOT run this."
   - Explain why it's dangerous before breaking down
   
2. ⚠️ Command uses `eval` or command injection patterns
   - Highlight security risk
   - Suggest safer alternatives

3. ❓ Command syntax is invalid or malformed
   - Point out syntax error
   - Suggest correction

## References

- `references/bash-safety.md` - Best practices and dangerous patterns
- [ShellCheck](https://www.shellcheck.net/) - Linting tool for shell scripts

## Success Criteria

✅ **Explanation is complete when**:
- All command components broken down
- Safety level clearly indicated
- Potential risks identified
- Improvements suggested (if applicable)
- Example usage provided
