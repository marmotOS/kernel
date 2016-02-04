# MarmotOS Kernel

[![License](https://img.shields.io/badge/license-XFree86-blue.svg)](LICENSE)
![Architecture](https://img.shields.io/badge/arch-x86--64-blue.svg)

Please read the LICENSE file for license information. 

Documentation is in /doc
source is in /src

Assembly code is written NASM format and should be assembled with NASM.


Make all will compile into a floppy image, boot.flp. This can be loaded with QEMU:

qemu-system-x86_64 -fda boot.flp
