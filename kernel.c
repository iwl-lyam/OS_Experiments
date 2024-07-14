#include "idt.h"
#include "kernel.h"
#include "isr.h"
#include "pic.h"

int cursor_x = 0;
int cursor_y = 0;

void print_char(char c, int colour) {
	*(char*)(0xb8000+cursor_x*2+2*cursor_y*LINECHARS) = c;
    *(char*)(0xb8001+cursor_x*2+2*cursor_y*LINECHARS) = colour;

    cursor_x += 1;
    if (cursor_x >= LINECHARS) {
        cursor_y += 1;
        cursor_x = 0;
    }
}

void print(char* first, int len, int colour) {
	for (int i = 0; i<len; i++) {
        if (*(first+i) == 0xA) {
            cursor_y += 1;
            cursor_x = 0;
            i++;
        } else if (*(first+i) == 0x0) {
            continue;
        }
		print_char(*(first+i), colour);
	}
}

extern int main() {
    PIC_remap(32, 40);
    pic_disable();
	i686_IDT_Initialise();
    char str[] = "Hello, world!";
    print(&str[0], sizeof(str), 0x0f);
    i686_ISR_Initialize();
    char str2[] = " -from protected mode (VGA framebuffer)\n";
    print(&str2[0], sizeof(str2), 0x04);
    __asm("int $0x4");
    char str3[] = "test string 3";
    print(&str3[0], sizeof(str3), 0x0f);
    return 0;
}

