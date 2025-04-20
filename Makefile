# === Paths ===
BUILD_DIR = build
SRC_DIR = src
STARTUP = startup_stm32f446xx.s
LINKER = linker.ld

# === Tools ===
CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
CFLAGS = -mcpu=cortex-m4 -mthumb -Wall -O0 -g -ffreestanding -nostdlib \
		 -Icmsis_device_f4/Include \
		 -Icmsis_core/Core/Include \
		 -DSTM32F446xx
LDFLAGS = -T$(LINKER)

# === Files ===
C_SOURCES = $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SOURCES))
OBJ_FILES += $(BUILD_DIR)/startup.o
BIN = $(BUILD_DIR)/main.bin

# === Targets ===
all: $(BUILD_DIR)/main.elf $(BIN)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/startup.o: $(STARTUP) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/main.elf: $(OBJ_FILES)
	$(CC) $(CFLAGS) $(OBJ_FILES) -o $@ $(LDFLAGS)


$(BIN): $(BUILD_DIR)/main.elf
	$(OBJCOPY) -O binary $< $@


flash: all
	st-flash write $(BUILD_DIR)/main.bin 0x8000000

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean flash
