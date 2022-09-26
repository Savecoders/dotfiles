#!/usr/bin/env bash

img="shot_$(date '+%m%d%H%M%S').png"

file="$HOME/Pictures/$img"

case $1 in
    "sel")
        slop=$(slop -b 2 -c '0.61,0.9,0.75,1' -p 22 -f "%g") || exit 1
        read -r G < <(echo $slop)
        import -window root -crop $G $file
        ;;

    "selnp")
        slop=$(slop -b 2 -c '0.61,0.9,0.75,1' -p -2 -f "%g") || exit 1
        read -r G < <(echo $slop)
        import -window root -crop $G $file
        ;;
    
    "selnpshad")
        slop=$(slop -b 2 -c '0.61,0.9,0.75,1' -p -3 -f "%g") || exit 1
        read -r G < <(echo $slop)
        import -window root -crop $G $file
        convert $file \( +clone -background black -shadow 75x10+0+0 \) +swap -bordercolor none -border 10 -background none -layers merge +repage $file
        ;;

    *)
        import -window root $file
        ;;
esac

xclip -selection clipboard -target image/png $file

#notify-send -i $file "Screenshot saved"
