#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error.
# The return value of a pipeline is the status of the last command to exit with a non-zero status.
set -eo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging helpers
print_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# Check dependencies
check_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install it first."
        exit 1
    fi

    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed or not available as 'docker compose'."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    
    print_success "All dependencies met."
}

# Main execution
main() {
    check_dependencies

    # Ensure workspace directory exists
    if [ ! -d "workspace" ]; then
        print_info "Creating workspace directory..."
        mkdir -p workspace
    fi

    print_info "Building the FreeBuff sandbox environment..."
    docker compose build

    # Instructions for the user
    echo -e "\n${YELLOW}****************************************************************"
    echo -e "   🚀 FREEBUFF SANDBOX IS READY"
    echo -e "****************************************************************${NC}"
    echo -e "${GREEN}1.${NC} Inside the container, run: ${BLUE}freebuff${NC}"
    echo -e "${GREEN}2.${NC} IMPORTANT: Changes are ISOLATED. To extract them ${RED}BEFORE${NC} exiting:"
    echo -e "   Open a new terminal and run:"
    echo -e "   ${BLUE}docker cp freebuff-sandbox:/workspace ./review-output${NC}"
    echo -e "${YELLOW}****************************************************************${NC}\n"

    print_info "Starting interactive session. Type 'exit' to stop.\n"
    docker compose run --rm freebuff
}

main
