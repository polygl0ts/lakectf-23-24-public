#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define MAX_READ 16

struct {
  char* content;
  size_t size;
} feedback;

void menu() {
  puts("1 - read from file");
  puts("2 - read from memory");
  puts("3 - send feedback");
  printf("> ");
  int option = 0;
  scanf("%d%*c",&option);
  if (option == 1) {
    char filename[MAX_READ] = {};
    printf("filename > ");
    int nb_read = read(stdin->_fileno,filename,MAX_READ);
    if(nb_read>0){
      filename[nb_read-1] = '\0';
    } else {
      filename[0] = '\0';
    }

    FILE* f = fopen(filename,"r");
    if(!f) {
      printf("cannot fopen %s\n",filename);
      exit(1);
    }

    char buff[MAX_READ];
    if(!fgets(buff,MAX_READ,f)) {
      printf("cannot fgets %s\n",filename);
      exit(1);
    }
    if(fclose(f)) {
      printf("cannot fclose %s\n",filename);
      exit(1);
    }
    printf("%s\n",buff);

  } else if(option == 2) {
    size_t addr = 0;
    printf("address > ");
    scanf("%zx",&addr);
    puts((char*)addr);
  } else if(option == 3) {
    size_t size = 0;
    if(feedback.content) {
      puts("sorry, but that's enough criticism for today !");
    } else {
      puts("please share your thoughts with us");
      printf("> ");
      getline(&(feedback.content),&(feedback.size),stdin);
      puts("thank you !");
    
    }
  } else {
    puts("invalid choice");
    exit(1);
  }
}

int main() {
 setbuf(stdin,NULL);
 setbuf(stdout,NULL);
 setbuf(stderr,NULL);

  FILE* flag = fopen("flaaaaaaaaaaaaag","r");
  if(!flag) {
    puts("cannot fopen the flaaaaaaaaaaaaag");
    exit(1);
  }
  char c;
  if(fread(&c,1,1,flag) < 1) {
    puts("cannot fread the flaaaaaaaaaaaaag");
    exit(1);
  }
  if(fclose(flag)) {
    puts("cannot fclose the flaaaaaaaaaaaaag");
    exit(1);
  }

  printf("At polygl0ts we are very cool, so you get the first flaaaaaaaaaaaaag character for free : %c\n",c);
  puts("Figure out the rest yourself !");

  int actions = 4;
  while(actions > 0) {
    printf("You have %d action(s) left\n",actions);
    menu(c);
    --actions;
  }
  if(feedback.content) {
    free(feedback.content);
  }
  puts("no actions left :(");
  exit(0);
}
