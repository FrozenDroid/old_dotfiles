#!/bin/bash
# Super ugly script and, although it works, will need adjustments if you want to use it.
# Dependencies: maim, jq, zenity
#
# First parameter is the path to a config file, which should look a bit like: 
#
# #!/bin/bash
# mastodon_token=""
# mastodon_api_url=""
#
# Make sure this file has execute permissions!

source $1

filename="$(uuidgen)-$(date +%d%m%Y_%H%M%S).jpg"
path=~/screenshots/$filename
maim --quality 10 -s $path

if [ $? -ne 0 ]; then
	exit 1
fi

choice=$(zenity --height=350 --text="Select a destination for the screenshot." \
	--list --radiolist --column "" --column "Destination"  TRUE "website" FALSE "toot")

echo $choice

if [ -z "$choice" ]; then
	exit 1
fi

if [ $choice == "toot" ]; then
	comment=$(zenity --title Toot --text="Enter a toot." --entry --entry-text="Enter your toot here...")
	if [ -z "$comment" ]; then
		exit 1
	fi
	image_upload_response=$(curl -F 'file=@'$path'' --header "Authorization: Bearer $mastodon_token" $mastodon_api_url/media)
	media_url=$(echo $image_upload_response | jq -r '.url')
	media_id=$(echo $image_upload_response | jq -r '.id')
	
	toot_upload=$(curl --data "{\"status\":\"$comment $media_url\", \"media_ids\":[$media_id]}" -H "Content-Type: application/json" -X POST --header "Authorization: Bearer $mastodon_token" $mastodon_api_url/statuses)
	toot_url=$(echo $toot_upload | jq -r '.uri')
	echo $toot_url | xclip -selection clipboard
	notify-send "Screenshot" "Uploaded to dev.glitch.social"
elif [ $choice == "website" ]; then
	scp $path vps:screenshots
	echo "https://screenshots.frozendroid.com/"$filename | xclip -selection clipboard
	notify-send "Screenshot" "Saved and uploaded"
fi
