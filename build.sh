git pull

echo "preprocessing"
./helpers/generate_isrs.sh isrs_gen.c isrs_gen.inc
echo "assembling bootloader"
nasm "boot.asm" -f elf -g -F dwarf -o "boot.elf"
echo "assembling support files"
nasm "kernel_entry.asm" -f elf -g -F dwarf -o "kernel_entry.o"
nasm "idt.asm" -f elf -g -F dwarf -o "idt_asm.o"
nasm "isr.asm" -f elf -g -F dwarf -o "isr_asm.o"
echo "kernel compile"
i686-elf-gcc -ffreestanding -m32 -c -g "kernel.c" -o "kernel.o"
i686-elf-gcc -ffreestanding -m32 -c -g "idt.c" -o "idt.o"
i686-elf-gcc -ffreestanding -m32 -c -g "isr.c" -o "isr.o"
i686-elf-gcc -ffreestanding -m32 -c -g "pic.c" -o "pic.o"
i686-elf-gcc -ffreestanding -m32 -c -g "io.c" -o "io.o"
#echo "zeroes assembly"
#nasm "zeroes.asm" -f elf -g -F dwarf -o "zeroes.bin"
echo "kernel link"
i686-elf-ld -o "full_kernel.o" -Ttext 0x1000 "kernel_entry.o"  "idt.o" "pic.o" "io.o" "isr.o" "isr_asm.o" "idt_asm.o" "kernel.o" --oformat elf
i686-elf-ld -o "OS.o" "boot.o" "full_kernel.o"
#cat "boot.bin" "full_kernel.bin" "zeroes.bin"  > "OS.bin"
