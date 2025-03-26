#include <stdio.h>
#include <string.h>

#define myArray_size 29
#define value_size 57

// Values to camare against
const char res[] = {'\x40', '\x42', '\xb8', '\x4f', '\x92', '\xe5', '\x26', '\x33', '\xee', '\xa0', '\xc1', '\x97', '\xbc', '\x4f', '\x81', '\x43', '\x81', '\xe2', '\xdc', '\x2b', '\x92', '\xf9', '\x0f', '\x73', '\x96', '\x18', '\x2b', '\x33', '\xd0'};
// Sorted input 
char value[] = "33344445568EFLP___________aaadeeefhhiillmnnrsttttvwzzz{}";
char input[value_size];
char myArray[myArray_size];


void write_to(char base[], char c, size_t position) {
    size_t offset = position % 8;
    size_t first = position / 8 ;
    base[first] = base[first] ^ (c >> offset);
    if (offset == 0)
    {
        return ;
    }
    base[first+1] = base[first+1] ^ (c << (8 -offset));
}

/* 0 if correct, 1 otherwise */
int compare_contents(char input[], char value[], size_t val_size) {
    for (char* inp = input; *inp != '\0'; inp++)
    {
        for (size_t i = 0; i < val_size; i++)
        {
            if (value[i] == *inp)
            {
                value[i]='\0';
                break;
            }     
        }
    }
    
    char zeros[val_size];
    memset(zeros, 0, val_size);
    
    return memcmp(value, zeros, val_size);
}

int main(int argc, char const *argv[])
{
    
    printf("Your input: ");
    if (fgets(input, value_size, stdin)== NULL) {
        return 0;
    }
    input[value_size-1]='\0';    

    for (size_t i = 0; i < value_size; i++)
    {
        write_to(myArray, input[i], 4*i) ;
    }

    //if sorted(input) == value and myarray == value then "OK"
    if (! compare_contents(input, value, value_size) && ! memcmp(myArray, res, myArray_size))
    {
        printf("SUCCESS\n");
    } else {
        printf("FAIL\n");
    }
    
    return 0;
}
