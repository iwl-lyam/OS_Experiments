#pragma once

void exception_handler();
void idt_set_descriptor(unsigned int vector, void* isr, unsigned int flags);
void idt_init();

