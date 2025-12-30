#!/bin/bash

# Upload Supply Chain Project to GitHub repository "supplychainproject"

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

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed.${NC}"
    exit 1
fi

# Check if this is a git repository
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Not a git repository. Initializing...${NC}"
    git init
    git branch -M main
fi

# Step 1: Remove existing remotes
echo -e "${BLUE}🔌 Disconnecting from existing repositories...${NC}"
EXISTING_REMOTES=$(git remote)
if [ -n "$EXISTING_REMOTES" ]; then
    for remote in $(git remote); do
        echo "   Removing remote: $remote"
        git remote remove "$remote"
    done
    echo -e "${GREEN}✅ Disconnected from existing remotes${NC}"
else
    echo -e "${GREEN}✅ No existing remotes found${NC}"
fi

# Step 2: Stage all changes
echo ""
echo -e "${BLUE}📦 Staging all files...${NC}"
git add -A

# Step 3: Commit if there are changes
CHANGES=$(git status --short)
if [ -n "$CHANGES" ]; then
    echo ""
    echo -e "${BLUE}💾 Committing changes...${NC}"
    git commit -m "Initial commit: Supply Chain Digital project

- Backend: Spring Boot application
- Frontend: Angular application
- Databricks: PySpark simulations
- Kafka: Event streaming
- Kubernetes: Deployment configurations
- Docker: Container setup" || {
        echo -e "${YELLOW}⚠️  No changes to commit${NC}"
    }
else
    echo -e "${GREEN}✅ No uncommitted changes${NC}"
fi

# Step 4: Create/connect to new GitHub repository
echo ""
echo -e "${BLUE}🔗 Connecting to GitHub repository...${NC}"
GITHUB_USER="rafi-khan-cmd"
REPO_NAME="supplychainproject"
GITHUB_REPO="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

echo "   Repository: $GITHUB_REPO"
echo ""

# Add the new remote
git remote add origin "$GITHUB_REPO" 2>/dev/null || git remote set-url origin "$GITHUB_REPO"
echo -e "${GREEN}✅ Connected to: $GITHUB_REPO${NC}"

# Step 5: Check if repository exists on GitHub
echo ""
echo -e "${BLUE}🔍 Checking if repository exists on GitHub...${NC}"
if git ls-remote --heads origin main &>/dev/null; then
    echo -e "${YELLOW}⚠️  Repository already exists on GitHub${NC}"
    echo ""
    read -p "Do you want to push to existing repository? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Cancelled.${NC}"
        exit 0
    fi
    echo ""
    echo -e "${BLUE}📥 Pulling latest changes...${NC}"
    git pull origin main --allow-unrelated-histories --no-edit 2>&1 || {
        echo -e "${YELLOW}⚠️  Pull failed. You may need to resolve conflicts manually.${NC}"
        echo "   Continuing with push..."
    }
else
    echo -e "${GREEN}✅ Repository doesn't exist yet (will be created on first push)${NC}"
    echo ""
    echo -e "${YELLOW}📝 Note: Create the repository on GitHub first:${NC}"
    echo "   1. Go to: https://github.com/new"
    echo "   2. Repository name: supplychainproject"
    echo "   3. Set it to Public or Private"
    echo "   4. DO NOT initialize with README, .gitignore, or license"
    echo "   5. Click 'Create repository'"
    echo ""
    read -p "Press Enter after creating the repository on GitHub..." 
fi

# Step 6: Push to GitHub
echo ""
echo -e "${BLUE}🚀 Pushing to GitHub...${NC}"
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

if git push -u origin "$CURRENT_BRANCH" 2>&1; then
    echo ""
    echo -e "${GREEN}✅ Successfully pushed to GitHub!${NC}"
    echo ""
    echo -e "${GREEN}🎉 Repository URL: https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
else
    echo ""
    echo -e "${RED}❌ Push failed.${NC}"
    echo ""
    echo -e "${YELLOW}Possible issues:${NC}"
    echo "   1. Repository doesn't exist on GitHub - create it first"
    echo "   2. Authentication required - run: git credential fill"
    echo "   3. Permission denied - check GitHub access"
    echo ""
    echo "To create the repository manually:"
    echo "   1. Go to: https://github.com/new"
    echo "   2. Name: supplychainproject"
    echo "   3. Don't initialize with any files"
    echo "   4. Then run this script again"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ All done!${NC}"

