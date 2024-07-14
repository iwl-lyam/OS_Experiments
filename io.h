#pragma once

static inline uint8_t inb(uint16_t port);
static inline void io_wait(void);
static inline void outb(uint16_t port, uint8_t val);