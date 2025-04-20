#include "stm32f4xx.h"
#include "stm32f446xx.h"

/*
    **************** HOW FAST THE LIGHT BLINKS **********************

    The delay function uses a simple while loop:
        → Each loop iteration takes approximately 4 CPU cycles

    delay(1,000,000):
        → 1,000,000 × 4 cycles = 4,000,000 cycles

    If the MCU clock is 84 MHz (84,000,000 cycles/sec):
        → 1 cycle ≈ 11.9 ns
        → 4,000,000 × 11.9 ns ≈ 0.0476 seconds per delay call

    Since the LED toggles ON → OFF → ON, one full blink cycle is:
        → 2 × delay = 2 × 0.0476 ≈ 0.0952 seconds (≈ 95.2 ms blink period)
*/

void delay(volatile uint32_t time){
    while(time--);
}

void gpio_led_init(void) {
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;               // Enable clock for GPIOA (AHB1 bus),            RCC_AHB1ENR offset: 0x30

    GPIOA->MODER &= ~(0x3 << (5 * 2));                 // Clear MODER[11:10] for PA5 (2 bits per pin)   Moder offset :      0x00
    GPIOA->MODER |=  (0x1 << (5 * 2));                 // Set PA5 to General Purpose Output mode (01)

    GPIOA->OTYPER &= ~(1 << 5);                        // Set output type to push-pull (default),       OTYPER offset:      0x04

    GPIOA->PUPDR &= ~(0x3 << (5 * 2));                 // Disable pull-up/pull-down for PA5,            PUPDR offset :      0x0C
}

int main(void) {
    gpio_led_init();

    while (1) {
        GPIOA->ODR ^= (1 << 5);                        // Toggle PA5 using XOR,                         ODR offset: 0x14
        delay(1000000);                                // Crude software delay (~95 ms blink period)
    }
}
