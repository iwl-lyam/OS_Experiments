#include "idt.h"

void print_char(char c, int pos, int colour) {
	*(char*)(0xb8000+pos*2) = c;
    *(char*)(0xb8001+pos*2) = colour;
}

void print(char* first, int len, int offset, int colour) {
	for (int i = 0; i<len; i++) {
		print_char(*(first+i), offset+i, colour);
	}
}

extern int main() {
//	idt_init();
    char str[] = "Hello, world!";
    print(&str[0], sizeof(str), 0, 0x0f);
    char str2[] = " -from protected mode";
    print(%str2[0], sizeof(str2), len(str), 0x04);
    return 0;
}

