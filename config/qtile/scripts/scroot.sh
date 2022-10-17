
img="shotArea$(date '+%m%d%H%M%S').png"

file="$HOME/Pictures/$img"

scrot -s $file 

xclip -selection clipboard -target image/png $file
