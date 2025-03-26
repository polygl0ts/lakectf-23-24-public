#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SCANF_SEQUENCE_SIZE 65
#define STDIN_BUFFER_SIZE 66
#define MAPPING 0x13371337000
#define EXE_PATH_LEN 8
#define FLAGS_LEN 8

#define XSTR(x) STR(x)
#define STR(x) #x

char* stdin_buffer; 
char exe_path[EXE_PATH_LEN] = "run";
char rw_flags[FLAGS_LEN] = "rw";
unsigned char tries = 1;

void setup_buffers() {
  stdin_buffer = (char*)mmap(MAPPING,STDIN_BUFFER_SIZE,PROT_READ | PROT_WRITE,MAP_PRIVATE | MAP_ANON | MAP_FIXED,-1,0);
  if(stdin_buffer == MAP_FAILED) {
    printf("mmap error. exiting.");
    exit(1);
  }
  setvbuf(stdin,stdin_buffer,_IOLBF,STDIN_BUFFER_SIZE);
  setbuf(stdout,NULL);
  setbuf(stderr,NULL);
}

int check_valid(size_t addr, char* filename, char* flags) {
  FILE* fp = fopen("/proc/self/maps","r");
  char* line = NULL;
  size_t size = 0;
  size_t start = 0;
  size_t end = 0;
  while (getline(&line,&size,fp) != -1) {
    if( strstr(line,flags) && strstr(line,filename)  ) {
      sscanf(line,"%zx-%zx",&start,&end);
      printf("Checking that %zx is in %zx - %zx...\n",addr,start,end);
      if((addr >= start) && (addr < end)) {
        return 1;
      }
    }
  }
  free(line);
  fclose(fp);
  return 0;
}

size_t get_number(char* var_name) {
  char buffer [SCANF_SEQUENCE_SIZE+1] = {0};
  char c;
  printf("%s> ",var_name);
  scanf("%" XSTR(SCANF_SEQUENCE_SIZE) "[01]",buffer);
  scanf("%1[\n]",&c);
  size_t res = strtoull(buffer,NULL,2);
#ifdef DEBUG_CHAL
  printf("%s = %zx\n",var_name,res);
#endif
  return res;
}

void beep_boop() {
  size_t dst = get_number("dst address");
  size_t idx = get_number("src idx");
  if (check_valid(dst,exe_path,rw_flags) && (idx < STDIN_BUFFER_SIZE)) {
    puts("ok !");
    char c = stdin_buffer[idx];
    *((char*)dst) = c;
  } else {
    printf("invalid : %zx, %zx.\n",dst,idx);
  }
}

void menu() {
  puts("0 - beep boop");
  puts("1 - exit");
}

int main() {
  puts("\n"
"███████╗ ██████╗ █████╗ ███╗   ██╗███████╗    ██████╗ ███████╗███████╗██████╗     ██████╗  ██████╗  ██████╗ ██████╗ \n"
"██╔════╝██╔════╝██╔══██╗████╗  ██║██╔════╝    ██╔══██╗██╔════╝██╔════╝██╔══██╗    ██╔══██╗██╔═══██╗██╔═══██╗██╔══██╗\n"
"███████╗██║     ███████║██╔██╗ ██║█████╗      ██████╔╝█████╗  █████╗  ██████╔╝    ██████╔╝██║   ██║██║   ██║██████╔╝\n"
"╚════██║██║     ██╔══██║██║╚██╗██║██╔══╝      ██╔══██╗██╔══╝  ██╔══╝  ██╔═══╝     ██╔══██╗██║   ██║██║   ██║██╔═══╝ \n"
"███████║╚██████╗██║  ██║██║ ╚████║██║         ██████╔╝███████╗███████╗██║         ██████╔╝╚██████╔╝╚██████╔╝██║     \n"
"╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝         ╚═════╝ ╚══════╝╚══════╝╚═╝         ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝     \n"
"");
#ifdef DEBUG_CHAL
  int fd = open("/proc/self/maps",O_RDONLY);
  char *buff = malloc(0x1000);
  read(fd,buff,0x1000);
  printf("%s\n",buff);
  free(buff);
#endif
  puts("BINARY GO BRRRRRRRRRRRRRRRRRR");
  setup_buffers();
  while(1) {
    menu();
    if(tries && !get_number("choice")) {
      beep_boop();
    } else {
      exit(0);
    }
    --tries;
  }
  return 0;
}
