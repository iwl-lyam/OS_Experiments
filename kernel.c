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
    char str[] = "Hello world!";
    print(&str[0], 12, 0);
	idt_init();
    str = " Interrupts enabled now, hopefully!"
      print(str,sizeof(str),13);
    return 0;
}

