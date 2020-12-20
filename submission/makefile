All:	infect

infect:	 task0b.o task1.o task2.o task3.o
	ld -m elf_i386 task0b.o -o task0b
	ld -m elf_i386 task1.o -o task1
	ld -m elf_i386 task2.o -o task2
	ld -m elf_i386 task3.o -o task3

task0b.o: task0b.s
	nasm -g -f elf task0b.s -o task0b.o

task1.o: task1.s
	nasm -g -f elf task1.s -o task1.o
	
task2.o: task2.s
	nasm -g -f elf task2.s -o task2.o
	
task3.o: task3.s
	nasm -g -f elf task3.s -o task3.o

clean:
	rm -f *.o task0b task1 task2 task3
