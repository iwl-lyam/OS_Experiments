#include "isr.h"
#include "kernel.h"
#include "idt.h"
#include "isrs_gen.c"

void i686_ISR_Initialize() {
    i686_ISR_InitializeGates();
    for (int i = 0; i < 256; i++)
        i686_IDT_EnableGate(i);
}

void __attribute__((cdecl)) i686_ISR_Handler(Registers* regs) {
    char interrupt[] = "\nInterrupt\n"+(char[])(regs->interrupt);
    print(&interrupt[0], sizeof(interrupt), 0x04);
}