ASM = nasm
ASMFLAGS = -f bin
IMG = ./bin/os.img
BIN = ./bin/boot.bin
SRC = ./kernel/boot.asm
QEMU_PATH = "C:\Program Files\qemu\qemu-system-x86_64.exe"
OBJS = bin/kernel.o bin/print.o
LINKER= ./kernel/linker.ld
KERNEL_BIN= ./bin/kernel.bin

# MACOS
build_mac: $(KERNEL_BIN)
	nasm -f bin ./kernel/boot.asm -o ./bin/boot.bin
	nasm -f bin ./kernel/stage2.asm -o ./bin/stage2.bin
	dd if=/dev/zero of=./bin/os.img bs=512 count=2880
	dd if=./bin/boot.bin of=./bin/os.img bs=512 count=1 conv=notrunc
	dd if=./bin/stage2.bin of=./bin/os.img bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=./bin/os.img bs=512 seek=2 conv=notrunc
	qemu-system-x86_64 -drive file=./bin/os.img,if=floppy,format=raw,index=0

build:
	nasm -f bin ./kernel/boot.asm -o ./bin/boot.bin
	nasm -f bin ./kernel/stage2.asm -o ./bin/stage2.bin
	dd if=./bin/boot.bin of=./bin/os.img bs=512 count=1 conv=notrunc
	dd if=./bin/stage2.bin of=./bin/os.img bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=./bin/os.img bs=512 seek=2 conv=notrunc
	qemu-system-x86_64 --drive format=raw,file=$(IMG)

clean:
	rm -f ./bin/*

$(KERNEL_BIN): $(OBJS) $(LINKER)
	x86_64-elf-ld -m elf_i386 -T $(LINKER) --oformat binary $(OBJS) -o $(KERNEL_BIN)

bin/kernel.o: kernel/kernel.asm
	nasm -f elf32 kernel/kernel.asm -o bin/kernel.o

bin/print.o: kernel/print.asm
	nasm -f elf32 kernel/print.asm -o bin/print.o

run-wind:
	$(QEMU_PATH) --drive format=raw,file=$(IMG)