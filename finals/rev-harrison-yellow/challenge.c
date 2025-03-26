#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define FLAG_SIZE 37

unsigned char enc_flag[FLAG_SIZE + 1] = {0x64, 0xe7, 0xf9, 0xcc, 0x42, 0x92, 0x36, 0x35, 0x4a, 0x5c, 0x70, 0x32, 0xa4, 0xb8, 0xab, 0xea, 0x2c, 0xc2, 0xe4, 0x74, 0xda, 0xfb, 0x2e, 0xde, 0x87, 0x56, 0xc8, 0x18, 0x41, 0x51, 0xc3, 0x6a, 0x48, 0xfa, 0x9, 0x9f, 0x24};


void obfuscate(unsigned char *data) {
    for (int i = 0; i < FLAG_SIZE; i++) {
        data[i] = (data[i] + i * 42) ^ (i + 3);
        data[i] = (data[i] << 4) | (data[i] >> 4);
    }
}

void deobfuscate(unsigned char *data) {
    for (int i = 0; i < FLAG_SIZE; i++) {
        data[i] = (data[i] >> 4) | (data[i] << 4);
        data[i] = (data[i] ^ (i + 3)) - i * 42;
    }
}


unsigned int deflipper(unsigned int input) {

}

//void main2() {
    //char* real_flag = "EPFL{On3_Of_My_F1ng3r5_1s_M1ss1ng!!!}";
    //char flag[FLAG_SIZE+1];
    //strcpy(flag, real_flag);
    //obfuscate((unsigned char*)flag);
    //for (int i = 0; i < FLAG_SIZE; i++) {
        //printf("0x%hhx, ", flag[i]);
    //}
    //deobfuscate((unsigned char*)flag);
    //printf("%s\n", flag);
//}


int check_flag(unsigned char *input) {

    obfuscate((unsigned char*)input);

    return memcmp(enc_flag, input, FLAG_SIZE) == 0;
}

int main() {
    char input[FLAG_SIZE + 1];

    printf("Enter the flag:\n");
    fgets(input, sizeof(input), stdin);
    input[strcspn(input, "\n")] = 0; // Remove newline char

    if (check_flag((unsigned char*) input)) {
        printf("Congratulations! You found the flag!\n");
    } else {
        printf("Sorry, that's not the correct flag. Try again.\n");
    }
}
