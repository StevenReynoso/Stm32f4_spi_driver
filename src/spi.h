
#ifndef SPI_H
#define SPI_H

#include <stdint.h>

void spi_init(void);
void spi_send(uint8_t data);
uint8_t spi_receive(void);

#endif // SPI_H