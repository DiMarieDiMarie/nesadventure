@echo off
c:\cc65\bin\ca65 src\main.asm
c:\cc65\bin\ld65 src\main.o -C nes.cfg -o ex2-drawsprite.nes
