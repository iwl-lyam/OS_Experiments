#include "idt.h"

void print_char(char c, int pos) {
	*(char*)(0xb8000+pos*2) = c;
}

void print(char* first, int len, int offset) {
	for (int i = 0; i<len; i++) {
		print_char(*(first+i), offset+i);
	}
}

extern int main() {
//	idt_init();
    char str[] = "Hello, world! -from protected mode";
    print(&str[0], sizeof(str), 0);
    return 0;
}

