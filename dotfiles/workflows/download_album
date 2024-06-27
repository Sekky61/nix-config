#/bin/bash

# TODO create folder first

# Download an album from youtube playlist using yt-dlp
# arg 1: youtube playlist url
# arg 2: album name

# check arg count
if [ $# -ne 2 ]; then
    echo "Usage: $0 <youtube playlist url> <album name>"
    exit 1
fi

yt-dlp -x --audio-format mp3 $1

# remove id TODO leaves a space
rename 's/\[.*\]//' *\ \[*\].mp3 *.mp3

# add album name
id3v2 -A $2 *.mp3
