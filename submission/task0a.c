#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <math.h>
#include <byteswap.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <elf.h>
#include <ctype.h>
#include <fcntl.h>


void pprint(char * format, ...);

void closeFd();
void examineElfFile();
void quit();

int isElfFile(Elf32_Ehdr * isElf);
int readElfFile();
int setFileName();



int fd = -1;
void * map = NULL;

int main(int argc, char **argv) {   
    if(argc <= 1) {
        pprint("%s","Error: No File Name Entered!!!");
        return 1;
    }

    if(!readElfFile(argv[1]) || !isElfFile((Elf32_Ehdr*) map)) return 1;

    Elf32_Ehdr * elfHeader = (Elf32_Ehdr *) map;
    Elf32_Phdr * elfPHeader = (Elf32_Phdr *) (map + elfHeader->e_phoff);


    pprint("  %s      %s   %s   %s   %s     %s      %s     %s\n",
        "Type", "Offset", "VirtAddr", "PhysAddr", "FileSiz", "Memsiz", "Flg", "Align");
    int index;
    for(index = 0; index < elfHeader->e_phnum; ++index){
        pprint("%08x 0x%08x 0x%08x 0x%08x 0x%08x 0x%08x %08x 0x%08x\n",
            elfPHeader[index].p_type, 
            elfPHeader[index].p_offset, 
            elfPHeader[index].p_vaddr, 
            elfPHeader[index].p_paddr,
            elfPHeader[index].p_filesz,
            elfPHeader[index].p_memsz,
            elfPHeader[index].p_flags,
            elfPHeader[index].p_align);
    }
    return 0;
} 



int isElfFile(Elf32_Ehdr * toCheck){
    if(!toCheck) { pprint(">>Debug: %s.\n","Header Is Null"); return 0; }
    if(toCheck->e_ident[EI_MAG0] != ELFMAG0 || 
        toCheck->e_ident[EI_MAG1] != ELFMAG1 ||
        toCheck->e_ident[EI_MAG2] != ELFMAG2 ||
        toCheck->e_ident[EI_MAG3] != ELFMAG3){
        pprint(">>Debug: %s.\n","Magic Numbers Dont Represent An Elf File");
        return 0;
    }
    return 1;
}

void closeFd(){
        close(fd);
        fd = -1;    
}

int readElfFile(char * fileName){
    
    if (fd != -1){
        closeFd();
    }

    if ((fd = open(fileName,O_RDONLY)) == -1){
        pprint(">>Debug: %s %s.\n", "Failed Opening Given File:",fileName);
        return 0;
    }

    struct stat st;
    stat(fileName, &st);
    int size = st.st_size;
    if((map = mmap(0,size, PROT_READ,MAP_SHARED,fd,0)) == MAP_FAILED){
        pprint("%s\n","Error: Couldnt Map The File.");
        closeFd();
        return 0;
    }
    return 1;
}



void quit(){
        pprint("%s\n",">>Debug: quitting");
        if(fd != -1) closeFd();
        exit(0);
}
 
/* prints message to stdout */
void pprint(char * format, ...){
    va_list args;
    va_start(args,format);
    vfprintf(stdout, format, args);
    va_end(args);
}
