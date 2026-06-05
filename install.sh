#!/usr/bin/env bash

# configuration
PNAME="tbs5930"
KERNEL_VERSION=$(uname -r)
KERNEL_DEV="/usr"
KERNEL_DIR="${KERNEL_DEV}/lib/modules/${KERNEL_VERSION}/build"

# make arguments
#MAKE_ARGS="CONFIG_MEDIA_SUPPORT=m CONFIG_DVB_CORE=m CONFIG_DVB_NET=y CONFIG_DVB_USB_TBS5930=m CONFIG_DVB_M88RS6060=m KCFLAGS='-Wall -Wextra -Werror'"
MAKE_ARGS="CONFIG_MEDIA_SUPPORT=m CONFIG_DVB_CORE=m CONFIG_DVB_NET=y CONFIG_DVB_USB_TBS5930=m CONFIG_DVB_M88RS6060=m"

# directories
SRC_DIR="./drivers/media"
BUILD_DIR=$(pwd)
OUTPUT_DIR="$(pwd)/output"

# check dependencies
if ! command -v make &> /dev/null; then
    echo "Error: make is required"
    exit 1
fi

if ! command -v depmod &> /dev/null; then
    echo "Warning: depmod not found, module dependencies may not be updated"
fi

# check kernel directory
if [ ! -d "$KERNEL_DIR" ]; then
    echo "Error: Kernel build directory not found at $KERNEL_DIR"
    echo "Make sure kernel headers are installed"
    exit 1
fi

# check kernel headers source
if [ ! -d "$SRC_DIR" ]; then
    echo "Error: Source directory $SRC_DIR not found"
    exit 1
fi

# Build phase
echo "Building modules..."
make -C "$KERNEL_DIR" M="${BUILD_DIR}/drivers/media" $MAKE_ARGS modules
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Install phase
echo "Installing modules..."

# create output dir
mkdir -p "$OUTPUT_DIR"

make -C "$KERNEL_DIR" M="${BUILD_DIR}/drivers/media" $MAKE_ARGS \
    INSTALL_MOD_PATH="$OUTPUT_DIR" modules_install

if [ $? -ne 0 ]; then
    echo "Install failed!"
    exit 1
fi

echo "Build and installation completed successfully!"
echo "Modules installed to: $OUTPUT_DIR"

# instructions
echo ""
echo "To install system-wide, run:"
echo "  sudo cp -r $OUTPUT_DIR/lib/modules/* /lib/modules/"
echo "  sudo depmod -a"