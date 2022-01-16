#!/usr/bin/env bash

ACPIDUMP="acpidump"
DECOMPILED_PREFIX="decompiled"
ORIGINAL_TABLE="dsdt.dat"
DECOMPILED_TABLE="$DECOMPILED_PREFIX.dsl"
FIXED_DECOMPILED_TABLE="fixed.dsl"
RECOMPILED_PREFIX="recompiled"
RECOMPILED_TABLE="$RECOMPILED_PREFIX.aml"
FINAL_IMAGE="acpi_override.img"

# Help
if [ "$1" == '--help' ] || [ "$1" == '-h' ]; then
	echo "-c        - Clean all junk files after image generation"
	echo "-h --help - Show help"
	exit 0
fi

# Move to script's directory
cd "$(dirname "$0")"

echo "INFO: Root access is needed in order to dump DSDT table."
echo "READ the script's source!"
sudo acpidump > "$ACPIDUMP" || { echo "Could not dump DSDT table" ;  exit 1; }
acpixtract "$ACPIDUMP" || { echo "Could extract DSDT table" ;  exit 1; }

echo "Decompiling $ORIGINAL_TABLE into $DECOMPILED_TABLE:"
iasl -p "$DECOMPILED_PREFIX" -d "$ORIGINAL_TABLE" || { echo "Could decompile DSDT table" ;  exit 2; }

printf "\n\n"

# We have to increment revision number by one.
# Otherwise, the kernel won't inject the new DSDT table.
# source: https://delta-xi.net/blog/#056

# Find revision
# See page 4 for more info: https://acpica.org/sites/acpica/files/asl_tutorial_v20190625.pdf
REVISION=$(cat "$DECOMPILED_TABLE" | sed -rn 's/(DefinitionBlock \(.*,.*,*0x)(.*)(\))/\2/p')
if [ $? -eq 0 ]; then
    echo "Old revision: 0x$REVISION"
else
    echo "Error finding revision."
    exit 3
fi

# Increment revision
NEW_REVISION=$(echo "obase=ibase=16;$REVISION+1" | bc | awk '{ printf "%08d\n", $0 }')
if [ $? -eq 0 ]; then
    echo "New revision: 0x$NEW_REVISION"
else
    echo "Error incrementing revision."
    exit 4
fi

# Replace revision
FIXED_REVISION_SOURCE=$(sed -r "s/(DefinitionBlock \(.*,.*,*0x)(.*)(\))/\1$NEW_REVISION\3/g" $DECOMPILED_TABLE)
# TODO: Add proper replacement check (this just uses return code)
if [ $? -eq 0 ]; then
    echo "Successfully replaced revision."
else
    echo "Error replacing revision."
    exit 5
fi

# Fix table itself
echo "$FIXED_REVISION_SOURCE" | sed -r 's/Name \(H8DR, 0x00\)/Name \(H8DR, One\)/' > "$FIXED_DECOMPILED_TABLE"
# TODO: Add proper replacement check (this just uses return code)
if [ $? -eq 0 ]; then
    echo "Successfully replaced problematic part of the table."
else
    echo "Error replacing problematic part."
    exit 6
fi

echo "Recompiling table:"
iasl -ve -p "$RECOMPILED_PREFIX" "$FIXED_DECOMPILED_TABLE"

echo "Creating $FINAL_IMAGE"
mkdir -p kernel/firmware/acpi
cp "$RECOMPILED_TABLE" kernel/firmware/acpi/dsdt.aml
find kernel | cpio -H newc --create > "$FINAL_IMAGE" || { echo "Could create $FINAL_IMAGE" ;  exit 7; }

#Cleanup
if [[ "$*" = *c* ]]; then
    printf '\n\nDoing user requested cleanup\n'
    rm "$ORIGINAL_TABLE"
    rm "$DECOMPILED_TABLE"
    rm "$FIXED_DECOMPILED_TABLE"
    rm "$RECOMPILED_TABLE"
    rm "$RECOMPILED_PREFIX.hex"
    rm *.dat
    rm acpidump
    rm -rf kernel
else
    echo 'Keeping files'
fi

printf "\n\n------------------COMPLETED---------------------\n\n"

echo "Now you can copy $FINAL_IMAGE into /boot and add it to your bootloader."
echo "Check README.md for further info on how to do it"

