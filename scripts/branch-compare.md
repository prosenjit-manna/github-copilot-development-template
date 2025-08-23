# Branch Comparison Scripts

This directory contains automated scripts to compare Git branches and extract changes as text files. These scripts are particularly useful for reviewing changes before merging development branches into production.

## Available Scripts

### 1. Shell Script (`branch-compare.sh`)
A comprehensive bash script that works on any Unix-like system.

#### Usage:
```bash
# Basic usage (compares dev with main)
./scripts/branch-compare.sh

# Specify custom branches
./scripts/branch-compare.sh dev main

# Specify custom output file
./scripts/branch-compare.sh dev main my-changes.txt

# Full syntax
./scripts/branch-compare.sh [source-branch] [target-branch] [output-file]
```

#### Examples:
```bash
# Compare dev branch with main branch
./scripts/branch-compare.sh dev main

# Compare feature branch with dev branch
./scripts/branch-compare.sh feature/new-feature dev

# Compare with custom output file
./scripts/branch-compare.sh dev main reports/pre-merge-review.txt
```

### 2. Quick Compare Script (`quick-compare.js`)
A lightweight Node.js script for quick console output and daily development checks.

#### Usage:
```bash
# Basic usage (compares dev with main)
node scripts/quick-compare.js

# Specify custom branches
node scripts/quick-compare.js feature/auth dev

# Use npm script from backend folder
cd backend && npm run compare:quick
```

## What the Scripts Generate

The shell script creates a comprehensive report including:

### 📊 Report Sections:

1. **Branch Status**: Latest commit information for both branches
2. **Commits to be Merged**: List of commits that will be merged
3. **Files Changed**: List of modified, added, and deleted files
4. **Change Statistics**: Summary of lines added/removed per file
5. **Detailed Changes**: Full diff showing actual code changes
6. **Merge Conflict Analysis**: Detection of potential merge conflicts
7. **Summary**: Quick overview of the changes

### 📁 Output Format:
- **File**: Text file with timestamp (e.g., `branch-changes-20250822-143022.txt`)
- **Location**: Current directory or specified path
- **Content**: Human-readable format suitable for code review

## Features

- ✅ **Comprehensive Analysis**: Complete overview of branch differences
- ✅ **Conflict Detection**: Identifies potential merge conflicts
- ✅ **File Filtering**: Excludes common files like `package-lock.json`, `node_modules`
- ✅ **Color Output**: Easy-to-read console output with colors
- ✅ **Error Handling**: Robust error checking and user-friendly messages
- ✅ **Flexible**: Works with any branch names and output locations

## Prerequisites

### For Shell Script:
- Git installed and configured
- Bash shell (available on macOS, Linux, WSL)

### For Quick Compare Script:
- Node.js installed (any recent version)
- Git installed and configured

## Common Use Cases

### 1. Pre-merge Review
```bash
# Before merging dev into main
./scripts/branch-compare.sh dev main pre-merge-review.txt
```

### 2. Feature Branch Review
```bash
# Review feature branch against dev
./scripts/branch-compare.sh feature/user-authentication dev
```

### 3. Release Preparation
```bash
# Compare release branch with main
./scripts/branch-compare.sh release/v2.1.0 main release-notes.txt
```

### 4. Hotfix Review
```bash
# Review hotfix against production
./scripts/branch-compare.sh hotfix/critical-bug prod
```

## Integration with CI/CD

You can integrate these scripts into your CI/CD pipeline:

```yaml
# Example GitHub Actions step
- name: Generate Branch Comparison
  run: |
    ./scripts/branch-compare.sh ${{ github.head_ref }} main comparison-report.txt
    
- name: Upload Report
  uses: actions/upload-artifact@v3
  with:
    name: branch-comparison
    path: comparison-report.txt
```

## Tips

1. **Review Before Merging**: Always run the comparison script before merging important branches
2. **Check for Conflicts**: Pay attention to the merge conflict analysis section
3. **Filter Output**: The scripts automatically exclude common files, but you can modify the exclusion list
4. **Archive Reports**: Keep comparison reports for important releases as documentation
5. **Team Reviews**: Share the generated reports with your team for collaborative code review

## Troubleshooting

### Common Issues:

1. **"Not in a git repository"**: Ensure you're running the script from within a Git repository
2. **"Branch does not exist"**: Check branch names with `git branch -a`
3. **Permission denied**: Make sure the shell script is executable (`chmod +x branch-compare.sh`)
4. **Network issues**: The script fetches latest changes; ensure you have network access

### Getting Help:

```bash
# Check available branches
git branch -a

# Check current branch
git branch --show-current

# Check git status
git status
```
