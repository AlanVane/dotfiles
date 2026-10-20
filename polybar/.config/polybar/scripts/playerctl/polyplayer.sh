#!/bin/sh

# Define your Icons
VLC_ICON="󰕼"
FIREFOX_ICON="󰈹" #Firefox Didn't seem to expose any info to playerctl, But here it is !
CHROME_ICON="󰊯" #Any Chromium based browser.
SPOTIFY_ICON="󰓇"
MUSIC_ICON="󰌳"

if [ "$(playerctl status 2> /dev/null)" == "Playing" ];
then
    PLAYER=$(echo $(playerctl metadata) |  awk '{print $1}')
    ARTIST=$(playerctl metadata artist 2> /dev/null)
    TITLE=$(media-title.sh)

    # If either artist or title length is > 15, Then cut and add ellipsis
    if [ "${#ARTIST}" -ge "16" ];
    then
        ARTIST=$(echo $(echo $ARTIST | cut -b 1-15)"...")
    fi

    if [ "${#TITLE}" -ge "16" ];
    then
        TITLE=$(echo $(echo $TITLE | cut -b 1-15)"...")
    fi

    case "$PLAYER" in
        "chromium") echo $CHROME_ICON$ARTIST - $TITLE
        ;;
        "vlc") echo $VLC_ICON$ARTIST - $TITLE
        ;;
        "spotify") echo $SPOTIFY_ICON$ARTIST - $TITLE
        ;;
        "firefox") echo $FIREFOX_ICON$ARTIST - $TITLE
        ;;
        "mpv") echo $MUSIC_ICON$ARTIST - $TITLE
        ;;
    esac

else
    echo "player is not running"
fi
