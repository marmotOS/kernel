all: src/boot/boot_stage1.asm src/boot/boot_stage2.asm
	nasm -f bin -o b0.bin src/boot/boot_stage1.asm -Isrc/boot/
	nasm -f bin -o b1.bin src/boot/boot_stage2.asm -Isrc/boot/
	cat b0.bin b1.bin | dd status=noxfer conv=notrunc of=boot.flp


clean:
	rm -f b0.bin b1.bin boot.flp
