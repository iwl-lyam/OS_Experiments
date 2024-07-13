git pull

echo "preprocessing"
./helpers/generate_isrs.sh isrs_gen.c isrs_gen.inc
echo "assembling bootloader"
nasm "boot.asm" -f bin -o "boot.bin"
echo "assembling support files"
nasm "kernel_entry.asm" -f elf -o "kernel_entry.o"
nasm "idt.asm" -f elf -o "idt_asm.o"
nasm "isr.asm" -f elf -o "isr_asm.o"
echo "kernel compile"
i686-elf-gcc -ffreestanding -m32 -c "kernel.c" -o "kernel.o"
i686-elf-gcc -ffreestanding -m32 -c "idt.c" -o "idt.o"
i686-elf-gcc -ffreestanding -m32 -c "isr.c" -o "isr.o"
echo "zeroes assembly"
nasm "zeroes.asm" -f bin -o "zeroes.bin"
echo "kernel link"
i686-elf-ld -o "full_kernel.bin" -Ttext 0x1000 "kernel_entry.o" "idt.o" "isr.o" "isr_asm.o" "idt_asm.o" "kernel.o" --oformat binary
cat "boot.bin" "full_kernel.bin" "zeroes.bin"  > "OS.bin"
