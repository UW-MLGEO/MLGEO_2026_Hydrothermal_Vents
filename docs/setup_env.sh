#!/bin/bash

# ============================================================
# Environment Setup Script for ML Methane Seeps Project
# ============================================================

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message "$BLUE" "============================================================"
print_message "$BLUE" "ML Methane Seeps Environment Setup"
print_message "$BLUE" "============================================================"
echo ""

# Check if conda is available
if command -v conda &> /dev/null; then
    print_message "$GREEN" "✓ Conda detected"
    USE_CONDA=true
else
    print_message "$YELLOW" "⚠ Conda not detected, will use pip/venv"
    USE_CONDA=false
fi

# Function to setup with Conda
setup_conda() {
    print_message "$BLUE" "\nSetting up Conda environment..."
    
    # Check if environment already exists
    if conda env list | grep -q "mlgeo-methane-seeps"; then
        print_message "$YELLOW" "Environment 'mlgeo-methane-seeps' already exists."
        read -p "Do you want to remove and recreate it? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_message "$YELLOW" "Removing existing environment..."
            conda env remove -n mlgeo-methane-seeps -y
        else
            print_message "$YELLOW" "Updating existing environment..."
            conda env update -f environment.yml
            print_message "$GREEN" "✓ Environment updated"
            return
        fi
    fi
    
    # Create environment from yml file
    print_message "$BLUE" "Creating conda environment from environment.yml..."
    conda env create -f environment.yml
    
    print_message "$GREEN" "✓ Conda environment created successfully!"
    print_message "$YELLOW" "\nTo activate the environment, run:"
    print_message "$YELLOW" "    conda activate mlgeo-methane-seeps"
}

# Function to setup with pip/venv
setup_venv() {
    print_message "$BLUE" "\nSetting up Python virtual environment..."
    
    # Check Python version
    python_version=$(python3 --version 2>&1 | awk '{print $2}')
    print_message "$GREEN" "✓ Python version: $python_version"
    
    # Create virtual environment
    if [ -d "venv" ]; then
        print_message "$YELLOW" "Virtual environment already exists."
        read -p "Do you want to remove and recreate it? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_message "$YELLOW" "Removing existing virtual environment..."
            rm -rf venv
        else
            print_message "$YELLOW" "Using existing virtual environment..."
            source venv/bin/activate
            pip install --upgrade pip
            pip install -r requirements.txt
            print_message "$GREEN" "✓ Packages updated"
            return
        fi
    fi
    
    print_message "$BLUE" "Creating virtual environment..."
    python3 -m venv venv
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    print_message "$BLUE" "Upgrading pip..."
    pip install --upgrade pip
    
    # Install requirements
    print_message "$BLUE" "Installing packages from requirements.txt..."
    pip install -r requirements.txt
    
    print_message "$GREEN" "✓ Virtual environment created successfully!"
    print_message "$YELLOW" "\nTo activate the environment, run:"
    print_message "$YELLOW" "    source venv/bin/activate"
}

# Main setup logic
print_message "$BLUE" "Select installation method:"
echo "  1) Conda (recommended if available)"
echo "  2) pip + venv"
echo "  3) Auto-detect"
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        if [ "$USE_CONDA" = true ]; then
            setup_conda
        else
            print_message "$RED" "✗ Conda is not available on this system"
            print_message "$YELLOW" "Installing with pip/venv instead..."
            setup_venv
        fi
        ;;
    2)
        setup_venv
        ;;
    3|*)
        if [ "$USE_CONDA" = true ]; then
            print_message "$GREEN" "Auto-detected: Using Conda"
            setup_conda
        else
            print_message "$GREEN" "Auto-detected: Using pip/venv"
            setup_venv
        fi
        ;;
esac

# Verify installation
echo ""
print_message "$BLUE" "============================================================"
print_message "$BLUE" "Verifying Installation"
print_message "$BLUE" "============================================================"

if [ "$USE_CONDA" = true ] && conda env list | grep -q "mlgeo-methane-seeps"; then
    print_message "$GREEN" "✓ Conda environment created"
    print_message "$BLUE" "\nActivating environment to verify packages..."
    
    # Activate and check key packages
    eval "$(conda shell.bash hook)"
    conda activate mlgeo-methane-seeps
    
    python -c "
import sys
packages = ['numpy', 'pandas', 'scipy', 'obspy', 'netCDF4', 'sklearn', 'torch', 'matplotlib']
missing = []
for pkg in packages:
    try:
        __import__(pkg)
        print(f'✓ {pkg}')
    except ImportError:
        missing.append(pkg)
        print(f'✗ {pkg} - MISSING')

if missing:
    print(f'\n⚠ Warning: {len(missing)} package(s) could not be imported')
    sys.exit(1)
else:
    print('\n✓ All key packages verified!')
"
elif [ -d "venv" ]; then
    print_message "$GREEN" "✓ Virtual environment created"
    print_message "$BLUE" "\nActivating environment to verify packages..."
    
    source venv/bin/activate
    
    python -c "
import sys
packages = ['numpy', 'pandas', 'scipy', 'obspy', 'netCDF4', 'sklearn', 'torch', 'matplotlib']
missing = []
for pkg in packages:
    try:
        __import__(pkg)
        print(f'✓ {pkg}')
    except ImportError:
        missing.append(pkg)
        print(f'✗ {pkg} - MISSING')

if missing:
    print(f'\n⚠ Warning: {len(missing)} package(s) could not be imported')
    sys.exit(1)
else:
    print('\n✓ All key packages verified!')
"
fi

echo ""
print_message "$BLUE" "============================================================"
print_message "$GREEN" "Setup Complete!"
print_message "$BLUE" "============================================================"
echo ""

if [ "$USE_CONDA" = true ] && conda env list | grep -q "mlgeo-methane-seeps"; then
    print_message "$YELLOW" "Next steps:"
    print_message "$YELLOW" "  1. Activate environment: conda activate mlgeo-methane-seeps"
    print_message "$YELLOW" "  2. Start Jupyter: jupyter notebook"
    print_message "$YELLOW" "  3. Open: shr_seismicity_relevant_dates.ipynb"
elif [ -d "venv" ]; then
    print_message "$YELLOW" "Next steps:"
    print_message "$YELLOW" "  1. Activate environment: source venv/bin/activate"
    print_message "$YELLOW" "  2. Start Jupyter: jupyter notebook"
    print_message "$YELLOW" "  3. Open: shr_seismicity_relevant_dates.ipynb"
fi

echo ""
print_message "$BLUE" "For more information, see:"
print_message "$BLUE" "  README.md in MLGEO_2026_Hydrothermal_Vents/docs/"
echo ""
