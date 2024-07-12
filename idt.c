typedef struct {
	unsigned short    isr_low;      // The lower 16 bits of the ISR's address
	unsigned short    kernel_cs;    // The GDT segment selector that the CPU will load into CS before calling the ISR
	unsigned int     reserved;     // Set to zero
	unsigned int     attributes;   // Type and attributes; see the IDT page
	unsigned short    isr_high;     // The higher 16 bits of the ISR's address
} __attribute__((packed)) idt_entry_t;

typedef struct {
	unsigned short limit;
	unsigned long base;
}__attribute__((packed)) idtr_t;

__attribute__((aligned(0x10)))
static idt_entry_t idt[256];
static idtr_t idtr;

//__attribute__((noreturn))
//extern void exception_handler(void);
extern void exception_handler() {
    __asm__ volatile ("cli; hlt"); // Completely hangs the computer
}

void idt_set_descriptor(unsigned int vector, void* isr, unsigned int flags);
void idt_set_descriptor(unsigned int vector, void* isr, unsigned int flags) {
    idt_entry_t* descriptor = &idt[vector];

    descriptor->isr_low        = (unsigned long)isr & 0xFFFF;
    descriptor->kernel_cs      = 0x08; // this value can be whatever offset your kernel code selector is in your GDT
    descriptor->attributes     = flags;
    descriptor->isr_high       = (unsigned long)isr >> 16;
    descriptor->reserved       = 0;
}

static int vectors[256];

extern void* isr_stub_table[];

void idt_init(void);
void idt_init() {
    idtr.base = (unsigned long)&idt[0];
    idtr.limit = (unsigned short)(sizeof(idt_entry_t) * 256 - 1);

    for (unsigned int vector = 0; vector < 32; vector++) {
        idt_set_descriptor(vector, isr_stub_table[vector], 0x8E);
        vectors[vector] = 1;
    }

    __asm__ volatile ("lidt %0" : : "m"(idtr)); // load the new IDT
    __asm__ volatile ("sti"); // set the interrupt flag
}
