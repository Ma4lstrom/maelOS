ASM = nasm
ASMFLAGS = -f bin
IMG = ./bin/disk.img
BIN = ./bin/boot.bin
SRC = ./kernel/boot.asm

build: $(BIN)
	dd if=$(BIN) of=$(IMG) bs=512 count=1 conv=notrunc
	qemu-system-x86_64 --drive format=raw,file=$(IMG)

$(BIN): $(SRC)
	nasm $(ASMFLAGS) $(SRC) -o $(BIN)

clean:
	rm -f $(BIN) $(IMG)