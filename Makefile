ASM = nasm
ASMFLAGS = -f bin
IMG = ./bin/os.img
BIN = ./bin/boot.bin
SRC = ./kernel/boot.asm
QEMU_PATH = "C:\Program Files\qemu\qemu-system-x86_64.exe"
# MACOS
# build: $(BIN)
# 	dd if=$(BIN) of=$(IMG) bs=512 count=1 conv=notrunc
# 	qemu-system-x86_64 --drive format=raw,file=$(IMG)

build:
	nasm -f bin ./kernel/boot.asm -o ./bin/boot.bin
	nasm -f bin ./kernel/stage2.asm -o ./bin/stage2.bin
	dd if=./bin/boot.bin of=./bin/os.img bs=512 count=1
	dd if=./bin/stage2.bin of=./bin/os.img bs=512 seek=1
	qemu-system-x86_64 --drive format=raw,file=$(IMG)

clean:
	rm -f $(BIN) $(IMG)

run-wind:
	$(QEMU_PATH) --drive format=raw,file=$(IMG)