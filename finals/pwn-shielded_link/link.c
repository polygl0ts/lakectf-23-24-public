#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define text_size 0x80

struct item{
	long price;
	char description[1];
};
typedef struct item item_t;

struct link{
        item_t* shield;
	char bio[text_size];
};
typedef struct link link_t;


size_t get_number() {
  size_t n = 0;
  scanf("%zu%*c",&n);
  return n;
}

void menu(){
    puts("Link, cosa vuoi fare?");
    puts("1. Aggiungi un nuovo scudo");
    puts("2. Cambia scudo");
    puts("3. Scarta scudo");
    puts("4. Stampare scudo");
    puts("5. Cambia la tua biografia");
    puts(">");
}

void setup(){ 
  setbuf(stdin,NULL);
  setbuf(stdout,NULL);
  setbuf(stderr,NULL);

}

int main(){
	setup();
	link_t* Link = malloc(sizeof(link_t));
	memset(Link, 0, sizeof(link_t));
	printf("malloco: %p\n", &malloc);
	puts("Prendi questo scudo e sii al sicuro, collegamento!\n");
	while(1){
		menu();
		size_t option = get_number();
		switch(option) {
			case 1: {
				puts("taglia: >");
				size_t size = get_number();
				if(size < 0 || size > 0x100){
					puts("NONONONONONONO");
					break;
				}
				item_t* new_item = malloc(sizeof(item_t)+size);
				new_item->price = 10;
				puts("Nuova descrizione dello scudo >");
				read(0, new_item->description, size);
				Link->shield = new_item;
				break;
				}
			case 2: {
				puts("Di quale scudo? >");
				read(0, &Link->shield, 8);
				break;
				}
			case 3: {
				free(Link->shield);
				break;
				}
			case 4: {
				printf("Prezzo: %lu\n", Link->shield->price);
				printf("Descrizione: %s\n", Link->shield->description);
				break;
				}
			case 5: {
				puts("Nuova biografia >");
				read(0, Link->bio, text_size);
				break;
				}
			default: {
				puts("Opzione sconosciuta!");
				return 0;
				 }
		}
	}
}
