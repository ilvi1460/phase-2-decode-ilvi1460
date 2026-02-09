#!/bin/bash

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <parameter>"
    exit 1
fi

FILE_NAME="$1"

riscv32-unknown-elf-as -march=rv32im -o ${FILE_NAME}.o ${FILE_NAME}.S


riscv32-unknown-elf-ld -o ${FILE_NAME}.elf ${FILE_NAME}.o

riscv32-unknown-elf-objcopy -O binary ./${FILE_NAME}.elf temp${FILE_NAME}.bin

hexdump -v -e '1/4 "%08x\n"' temp${FILE_NAME}.bin

# rm temp${FILE_NAME}.bin


