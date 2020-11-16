#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "data.h"
#include "helper.h"

void refresh_screen() {
    CLR_SCREEN;
    CRS_POS_SOF;
}

void print_text() {
    unsigned int i;
    for (i = 0; i < tt.length; i++) {
        if (tt.buffer[i] == '\n') {
            printf("\u23CE\n");
        } else {
            printf("%c", tt.buffer[i]);
        }
    }
    CRS_POS_SOF;
}

void print_from_buffer() {
    write(STDOUT_FILENO, &tt.buffer[tt.pos], 1);
}

void print_to_next_line() {
    write(STDOUT_FILENO, "\u23CE\n", strlen("\u23CE\n"));
}

void del() {
    CRS_POS_B;
    tt.pos--;
    print_from_buffer();
    CRS_POS_B;
}

void del_to_prev_line() {
    int i = 2;
    CRS_POS_UP;
    while (tt.buffer[tt.pos - i] != '\n' && tt.pos - i != 0) {
        CRS_POS_F;
        i++;
    }
    if (tt.pos - i == 0) {
        CRS_POS_F;
    }
    tt.pos--;
    PRINT_TO_SCREEN("\u23CE");
    CRS_POS_B;
}

