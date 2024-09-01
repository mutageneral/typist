#!/bin/sh

# use a POSIX shell shuf alternative if none on the system
command -v shuf > /dev/null 2> /dev/null || shuf() {
    awk '
        BEGIN {
            srand();
            OFMT = "%.17f"
        }
        {
            print rand(), $0
        }
    ' "$@" | 
    sort -k1,1n | 
    cut -d ' ' -f2- ;}

# first argument is the filename
filename="$1"
[ ! -f "$filename" ] && printf "%s\n" "You must provide a text file as argument." >&2 && exit 1

words=""
# read file line by line
while IFS= read -r line; do
    # split the line into words and set them as positional parameters
    # shellcheck disable=SC2086
    set -- $line
    for val; do
        # clean up each word: remove leading and trailing punctuation and quotes
        val=$(printf "%s" "$val" | sed -e 's/^[({'"'"'"]*//' -e 's/[.,!?;:)]}'"'"'"]*$//')
        words="$words
$val"   # one word per line in $words var
    done
done < "$filename"

line_length=0
{
    # loop over each shuffled words
    printf "%s\n" "$words" | shuf | while IFS= read -r word; do
        # update line length
        line_length=$((line_length + ${#word} + 1))
        # if line length exceeds 80 characters, make a new line
        if [ "$line_length" -gt 80 ]; then
            echo
            # update line length
            line_length=$(( ${#word} + 1 ))
        fi
        printf "%s " "$word"
    done
echo
} > "$filename"
