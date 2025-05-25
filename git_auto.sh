#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display error messages
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        error_exit "Not in a Git repository!"
    fi
}

# Check remote existence
check_remote() {
    if ! git remote get-url origin > /dev/null 2>&1; then
        error_exit "Remote 'origin' does not exist!"
    fi
}

# Check for changes
check_changes() {
    if [ -z "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}No changes to commit.${NC}"
        exit 0
    fi
}

# Get current branch name
get_branch() {
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    branch=$(git rev-parse --abbrev-ref HEAD) || \
    error_exit "Cannot get current branch!"
    echo "$branch"
}

# Parse arguments
COMMIT_MSG="nambah, bos!"
DRY_RUN=false

while getopts ":m:dh" opt; do
    case $opt in
        m) COMMIT_MSG="$OPTARG" ;;
        d) DRY_RUN=true ;;
        h) 
            echo "Usage: $0 [-m commit_message] [-d] [-h]"
            echo "  -m  Custom commit message"
            echo "  -d  Dry run (show what would be done)"
            echo "  -h  Show this help"
            exit 0
            ;;
        \?) error_exit "Invalid option: -$OPTARG" ;;
        :) error_exit "Option -$OPTARG requires an argument." ;;
    esac
done

# Main execution
set -e # Exit immediately if any command fails

check_git_repo
check_remote
check_changes

BRANCH=$(get_branch)

echo -e "${GREEN}Working on branch: ${YELLOW}$BRANCH${NC}"

if $DRY_RUN; then
    echo -e "${YELLOW}--- DRY RUN ---${NC}"
    echo "git add ."
    echo "git commit -m \"$COMMIT_MSG\""
    echo "git push origin $BRANCH"
    exit 0
fi

# Perform actual operations
echo -e "${GREEN}Staging all changes...${NC}"
git add .

echo -e "${GREEN}Committing changes...${NC}"
git commit -m "$COMMIT_MSG"

echo -e "${GREEN}Pushing to origin/$BRANCH...${NC}"
git push origin "$BRANCH"

echo -e "${GREEN}✅ Successfully pushed changes!${NC}"
