/*
    Summary:
        - Enabling clocks for GPIOA and SPI1 peripherals
        - Configuring PA5, PA6, PA7 for Alternate Function mode (AF5 for SPI1)
            - 00 -> Input
            - 01 -> General Output
            - 10 -> Alternate Function
            - 11 -> Analog
        - Configuring SPI1:
            - Master mode
            - Baud rate = f_PCLK / 8 (BR_1)
            - Software slave management enabled (SSM)
            - Internal slave select set (SSI)
        - Handling SPI transmission and reception:
            - Waits for TXE (transmit buffer empty)
            - Waits for BSY (SPI not busy)
            - Receives by sending dummy byte and checking RXNE
*/



#include "spi.h"
#include "stm32f4xx.h"
#include <stm32f446xx.h>

void spi_init(void) {
    
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;           // GPIOA for SPI1 pins (PA5: SCK, PA6: MISO, PA7: MOSI)
    RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;            // SPI1 is on the APB2 peripheral bus

    GPIOA->MODER &= ~(0x3F << (5 * 2));            // Clear MODER bits for pins 5, 6, 7 (2 bits each) , our moder has offset of 0x00
    GPIOA->MODER |=  (0x2 << (5 * 2))              // Set PA5 to AF mode (10)
                  |  (0x2 << (6 * 2))              // Set PA6 to AF mode
                  |  (0x2 << (7 * 2));             // Set PA7 to AF mode

    GPIOA->AFR[0] |= (0x5 << (5 * 4))              // Set AF5 for PA5
                   | (0x5 << (6 * 4))              // Set AF5 for PA6
                   | (0x5 << (7 * 4));             // Set AF5 for PA7

    SPI1->CR1  = SPI_CR1_MSTR                      // Master mode
               | SPI_CR1_BR_1                      // Baud rate = f_PCLK / 8 (slow start for stability)
               | SPI_CR1_SSM                       // Software slave management enabled
               | SPI_CR1_SSI;                      // Internal slave select set (prevents MODF)

    SPI1->CR1 |= SPI_CR1_SPE;                      // Enable SPI1 peripheral
}

void spi_send(uint8_t data) {
    while (!(SPI1->SR & SPI_SR_TXE));              // Wait until TX buffer is empty
    SPI1->DR = data;                               // Write data to SPI data register (starts transmission)
    while (!(SPI1->SR & SPI_SR_TXE));              // Wait until transmit complete
    while (SPI1->SR & SPI_SR_BSY);                 // Wait until SPI is no longer busy
}

uint8_t spi_receive(void) {
    spi_send(0xFF);                                // Send dummy byte to generate SPI clock
    while (!(SPI1->SR & SPI_SR_RXNE));             // Wait until RX buffer is full (data received)
    return SPI1->DR;                               // Return received byte from data register
}
