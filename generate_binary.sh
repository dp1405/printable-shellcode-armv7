#!/bin/bash

# Check if an input file was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <input_file.s>"
  exit 1
fi

input_file="$1"

# Check if the input file exists and has a .s extension
if [ ! -f "$input_file" ]; then
  echo "Error: File '$input_file' not found."
  exit 1
elif [[ "${input_file##*.}" != "s" ]]; then
  echo "Error: Input file must have a .s extension (e.g., myprogram.s)."
  exit 1
fi

# Extract the base name without the extension
base_name="${input_file%.s}"

echo "Processing $input_file..."

# 1. Assemble the .s file into an object file (.o)
echo "  Assembling to ${base_name}.o..."
if ! as "$input_file" -o "${base_name}.o"; then
  echo "Error: Assembly failed."
  exit 1
fi

# 2. Link the object file into an executable
echo "  Linking to ${base_name}..."
if ! ld "${base_name}.o" -o "$base_name"; then
  echo "Error: Linking failed."
  exit 1
fi

# 3. Extract the binary from the executable
echo "  Extracting binary to ${base_name}.bin..."
if ! objcopy -O binary "$base_name" "${base_name}.bin"; then
  echo "Error: Binary extraction failed."
  exit 1
fi

echo "Successfully processed '$input_file'."
echo "Generated files: ${base_name}.o, ${base_name}, ${base_name}.bin"