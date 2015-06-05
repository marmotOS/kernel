all: src/bootloader.asm src/stage2.asm
	nasm -f bin -o b0.bin src/bootloader.asm
	nasm -f bin -o b1.bin src/stage2.asm
	cat b0.bin b1.bin | dd status=noxfer conv=notrunc of=boot.flp


clean:
	rm -f b0.bin b1.bin boot.flp
