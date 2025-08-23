#!/bin/bash

# Branch Comparison Script
# Usage: ./branch-compare.sh [source-branch] [target-branch] [output-file]
# Example: ./branch-compare.sh dev main changes.txt

set -e

# Default values
SOURCE_BRANCH=${1:-"dev"}
TARGET_BRANCH=${2:-"main"}
OUTPUT_FILE=${3:-"branch-changes-$(date +%Y%m%d-%H%M%S).txt"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Branch Comparison Tool${NC}"
echo -e "${BLUE}=========================${NC}"
echo "Source Branch: ${GREEN}${SOURCE_BRANCH}${NC}"
echo "Target Branch: ${GREEN}${TARGET_BRANCH}${NC}"
echo "Output File: ${GREEN}${OUTPUT_FILE}${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check if branches exist
if ! git show-ref --verify --quiet refs/heads/${SOURCE_BRANCH} && ! git show-ref --verify --quiet refs/remotes/origin/${SOURCE_BRANCH}; then
    echo -e "${RED}Error: Branch '${SOURCE_BRANCH}' does not exist${NC}"
    exit 1
fi

if ! git show-ref --verify --quiet refs/heads/${TARGET_BRANCH} && ! git show-ref --verify --quiet refs/remotes/origin/${TARGET_BRANCH}; then
    echo -e "${RED}Error: Branch '${TARGET_BRANCH}' does not exist${NC}"
    exit 1
fi

# Fetch latest changes
echo -e "${YELLOW}📡 Fetching latest changes...${NC}"
git fetch origin

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Start writing to output file
cat > "$OUTPUT_FILE" << EOF
Branch Comparison Report
========================
Generated on: $(date)
Repository: $(basename "$(git rev-parse --show-toplevel)")
Source Branch: ${SOURCE_BRANCH}
Target Branch: ${TARGET_BRANCH}

EOF

echo -e "${YELLOW}📊 Generating comparison report...${NC}"

# 1. Branch status and commit information
echo "=== BRANCH STATUS ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "Latest commit on ${SOURCE_BRANCH}:" >> "$OUTPUT_FILE"
git log -1 --pretty=format:"Commit: %H%nAuthor: %an <%ae>%nDate: %ad%nMessage: %s%n" --date=format:'%Y-%m-%d %H:%M:%S' ${SOURCE_BRANCH} >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "Latest commit on ${TARGET_BRANCH}:" >> "$OUTPUT_FILE"
git log -1 --pretty=format:"Commit: %H%nAuthor: %an <%ae>%nDate: %ad%nMessage: %s%n" --date=format:'%Y-%m-%d %H:%M:%S' ${TARGET_BRANCH} >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 2. Commits that are in source but not in target
echo "=== COMMITS TO BE MERGED (${SOURCE_BRANCH} -> ${TARGET_BRANCH}) ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

COMMITS_AHEAD=$(git rev-list --count ${TARGET_BRANCH}..${SOURCE_BRANCH})
echo "Number of commits ahead: ${COMMITS_AHEAD}" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ "$COMMITS_AHEAD" -gt 0 ]; then
    git log --pretty=format:"[%h] %s (%an, %ad)" --date=short ${TARGET_BRANCH}..${SOURCE_BRANCH} >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
else
    echo "No new commits to merge." >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

# 3. Files changed
echo "=== FILES CHANGED ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

git diff --name-status ${TARGET_BRANCH}..${SOURCE_BRANCH} >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 4. Statistics
echo "=== CHANGE STATISTICS ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
git diff --stat ${TARGET_BRANCH}..${SOURCE_BRANCH} >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 5. Detailed diff for code review
echo "=== DETAILED CHANGES ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Note: Below are the actual code changes. Review carefully before merging." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Get diff excluding certain files/directories
git diff ${TARGET_BRANCH}..${SOURCE_BRANCH} \
    -- . \
    ':(exclude)package-lock.json' \
    ':(exclude)yarn.lock' \
    ':(exclude)*.log' \
    ':(exclude)node_modules' \
    ':(exclude).env*' \
    >> "$OUTPUT_FILE"

# 6. Potential conflicts
echo "" >> "$OUTPUT_FILE"
echo "=== MERGE CONFLICT ANALYSIS ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Check for potential merge conflicts
if git merge-tree $(git merge-base ${TARGET_BRANCH} ${SOURCE_BRANCH}) ${TARGET_BRANCH} ${SOURCE_BRANCH} | grep -q "^<<<<<<< "; then
    echo "⚠️  POTENTIAL MERGE CONFLICTS DETECTED!" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Files that may have conflicts:" >> "$OUTPUT_FILE"
    git merge-tree $(git merge-base ${TARGET_BRANCH} ${SOURCE_BRANCH}) ${TARGET_BRANCH} ${SOURCE_BRANCH} | grep -E "^<<<<<<< |^>>>>>>> " | sort | uniq >> "$OUTPUT_FILE"
else
    echo "✅ No merge conflicts detected." >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"

# 7. Summary
echo "=== SUMMARY ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "• Commits to merge: ${COMMITS_AHEAD}" >> "$OUTPUT_FILE"
echo "• Files changed: $(git diff --name-only ${TARGET_BRANCH}..${SOURCE_BRANCH} | wc -l | tr -d ' ')" >> "$OUTPUT_FILE"
echo "• Lines added: $(git diff --numstat ${TARGET_BRANCH}..${SOURCE_BRANCH} | awk '{added+=$1} END {print added+0}')" >> "$OUTPUT_FILE"
echo "• Lines removed: $(git diff --numstat ${TARGET_BRANCH}..${SOURCE_BRANCH} | awk '{removed+=$2} END {print removed+0}')" >> "$OUTPUT_FILE"

# Display summary to console
echo -e "${GREEN}✅ Comparison complete!${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "• Commits to merge: ${COMMITS_AHEAD}"
echo "• Files changed: $(git diff --name-only ${TARGET_BRANCH}..${SOURCE_BRANCH} | wc -l | tr -d ' ')"
echo "• Lines added: $(git diff --numstat ${TARGET_BRANCH}..${SOURCE_BRANCH} | awk '{added+=$1} END {print added+0}')"
echo "• Lines removed: $(git diff --numstat ${TARGET_BRANCH}..${SOURCE_BRANCH} | awk '{removed+=$2} END {print removed+0}')"
echo ""
echo -e "${YELLOW}📄 Report saved to: ${OUTPUT_FILE}${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review the generated report"
echo "2. Check for any merge conflicts"
echo "3. Test the changes in a staging environment"
echo "4. If everything looks good, merge with:"
echo "   ${GREEN}git checkout ${TARGET_BRANCH} && git merge ${SOURCE_BRANCH}${NC}"
