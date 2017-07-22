all: MarmotOS.pdf kernel

kernel: src/boot/boot_stage1.asm src/boot/boot_stage2.asm
	nasm -f bin -o b0.bin src/boot/boot_stage1.asm -Isrc/boot/
	nasm -f bin -o b1.bin src/boot/boot_stage2.asm -Isrc/boot/
	cat b0.bin b1.bin | dd status=noxfer conv=notrunc of=boot.flp

MarmotOS.pdf: doc/MarmotOS.tex
	cd doc && latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make MarmotOS.tex

clean:
	rm -f b0.bin b1.bin boot.flp
	rm -f doc/MarmotOS.aux
	rm -f doc/MarmotOS.fdb*
	rm -f doc/MarmotOS.fls
	rm -f doc/MarmotOS.pdf
	rm -f doc/MarmotOS.toc
	rm -f doc/MarmotOS.log 
