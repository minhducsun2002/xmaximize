#!/usr/bin/env bash

FULLSCREEN_COMMAND="echo 1"
DESKTOP_COMMAND="echo 2"


# script under here

NOW=""
function on_fullscreen {
    if [[ "$NOW" != "fullscreen" ]]; then
        NOW="fullscreen";
        $FULLSCREEN_COMMAND;
    fi
}

function on_desktop {
    if [[ "$NOW" != "desktop" ]]; then
        NOW="desktop";
        $DESKTOP_COMMAND;
    fi
}

function detect_maximized {
    # list windows
    local COUNT=$(
        xprop -root | grep ^_NET_CLIENT_LIST | tr ' ' '\n' | grep 0x | tr -d ',' \
        | xargs -L1 xprop -id \
        | grep "_NET_WM_STATE(ATOM)" | grep "_NET_WM_STATE_MAXIMIZED" \
        | wc -l
    )

    echo $COUNT;
}

function handle {
    local LINE="$1"
    if [[ "$1" == _NET_ACTIVE_WINDOW* ]]; then
        if [[ "$(detect_maximized)" == "0" ]]; then
            on_desktop;
        else
            on_fullscreen;
        fi
        return 0;
    fi
    if [[ "$1" == _NET_SHOWING_DESKTOP* ]]; then
        if [[ "$3" == "1" ]]; then
            on_desktop;
        else
            on_fullscreen;
        fi
        return 0
    fi

}


DIR=$(dirname $0)
xprop -spy -root | while IFS= read -r LINE; do
    if grep -e ^_NET_ACTIVE_WINDOW -e ^_NET_SHOWING_DESKTOP -q; then
        handle $LINE;
    fi
done