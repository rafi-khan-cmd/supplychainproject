#!/bin/bash

# Automated upload of Supply Chain Project to GitHub (non-interactive)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Uploading Supply Chain Project to GitHub${NC}"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed.${NC}"
    exit 1
fi

# Remove existing remotes
echo -e "${BLUE}🔌 Disconnecting from existing repositories...${NC}"
EXISTING_REMOTES=$(git remote 2>/dev/null || echo "")
if [ -n "$EXISTING_REMOTES" ]; then
    for remote in $(git remote); do
        echo "   Removing remote: $remote"
        git remote remove "$remote"
    done
fi

# Stage and commit
echo ""
echo -e "${BLUE}📦 Staging all files...${NC}"
git add -A

CHANGES=$(git status --short)
if [ -n "$CHANGES" ]; then
    echo -e "${BLUE}💾 Committing changes...${NC}"
    git commit -m "Update: Supply Chain Digital project

- Backend: Spring Boot application
- Frontend: Angular application  
- Databricks: PySpark simulations
- Kafka: Event streaming
- Kubernetes: Deployment configurations
- Docker: Container setup" || true
fi

# Connect to new repository
GITHUB_USER="rafi-khan-cmd"
REPO_NAME="supplychainproject"
GITHUB_REPO="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo ""
echo -e "${BLUE}🔗 Connecting to: $GITHUB_REPO${NC}"
git remote add origin "$GITHUB_REPO" 2>/dev/null || git remote set-url origin "$GITHUB_REPO"

# Push to GitHub
echo ""
echo -e "${BLUE}🚀 Pushing to GitHub...${NC}"
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

# Try to pull first if repo exists, then push
if git ls-remote --heads origin main &>/dev/null; then
    echo "   Repository exists, pulling latest..."
    git pull origin main --allow-unrelated-histories --no-edit 2>&1 || true
fi

if git push -u origin "$CURRENT_BRANCH" --force 2>&1; then
    echo ""
    echo -e "${GREEN}✅ Successfully pushed to GitHub!${NC}"
    echo ""
    echo -e "${GREEN}🎉 Repository: https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
else
    echo ""
    echo -e "${RED}❌ Push failed.${NC}"
    echo ""
    echo "Please create the repository on GitHub first:"
    echo "   1. Go to: https://github.com/new"
    echo "   2. Name: supplychainproject"
    echo "   3. Don't initialize with any files"
    echo "   4. Run this script again"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ All done!${NC}"

