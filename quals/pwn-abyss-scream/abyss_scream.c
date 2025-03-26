#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

void save_msg(int score) {
    char message[256];
    char *name = calloc(8, sizeof(char));
    printf("You can now scream a longer message but before you do so, we'll take your name: ");
    fflush(stdout);
    gets(name);
    
    printf("Saved score of %d for %s. Date and Time: ", score, name);
    fflush(stdout);
    system("date");

    printf("Now please add a message: ");
    fflush(stdout);
    gets(message);

    puts("Your message:");

    printf(message);
    
    puts("");

    fflush(stdout);

    return;
}

int main() {   
    char input;
    int score = 0;

    printf("Scream into the abyss and see how long it takes for you to get a response ;)");

    while(1){

        printf("Current iteration: %d\n", score);
    
        // reads and stores input
        printf("Enter input: ");
        fflush(stdout);
        input = getchar();
        getchar();
        if (input == 'x') {
           save_msg(score); 
           score = 0;     
        } else {
            score += 1;
        }
    }
    
    
    return 0;
}

__attribute_used__ void nothing_to_see_here() {
    asm ("pop %rdi");
    asm ("ret");


}
