#!/bin/bash
filename="$(uuidgen)-$(date +%d%m%Y_%H%M%S).jpg"
path=~/screenshots/$filename
maim --quality 10 -s $path
scp $path vps:screenshots
echo "https://screenshots.frozendroid.com/"$filename | xclip -selection clipboard
notify-send "Screenshot" "Saved and uploaded"