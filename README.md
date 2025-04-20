# STM32F4 SPI Driver and LED Blinking Project

This project demonstrates low-level embedded development on the STM32F446RE microcontroller using a custom SPI driver and GPIO-based LED toggling. The implementation is bare-metal, without using STM32 HAL only CMSIS.

## Features

- Direct register access for GPIO and SPI configuration
- Bare-metal system initialization with a custom startup file
- Custom linker script defining memory layout
- Manual vector table definition and interrupt setup
- GDB-compatible build for step-by-step debugging
- Flashable binary via ST-Link

## Project Overview

This project initializes GPIO pin PA5 to toggle an onboard LED and sets up SPI1 on PA5 (SCK), PA6 (MISO), and PA7 (MOSI) using direct register manipulation. It is designed to teach low-level embedded systems concepts through minimal external dependencies.

## Requirements

- STM32F446RE Nucleo board
- arm-none-eabi-gcc toolchain
- make (GNU Make)
- stlink tools (`st-flash`, `st-util`)
- GDB for debugging (optional)

## Build and Flash

To build the project:

```bash
make
```

To flash the built binary onto the STM32 board:

```bash
make flash
```

## Debugging

To debug using GDB:

1. Start ST-Link server:

    ```bash
    st-util
    ```

2. In another terminal:

    ```bash
    arm-none-eabi-gdb build/main.elf
    ```

3. Within GDB:

    ```
    target extended-remote :4242
    monitor reset halt
    break main
    continue
    ```

## Learning Objectives

This project is intended to provide a foundational understanding of:

- ARM Cortex-M boot process and memory layout
- Linker scripts and startup code in embedded systems
- Bit-level peripheral configuration
- Building and debugging bare-metal firmware
