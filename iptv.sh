#!/bin/bash
command -v fzf >/dev/null 2>&1 || {
  echo >&2 "fzf required but not installed"
  exit 1
}
command -v mpv >/dev/null 2>&1 || {
  echo >&2 "mpv required but not installed"
  exit 1
}

m3u=$1

config_path="$HOME/.config/iptv/"
channels_file="$config_path/channels"
m3u_url_file="$config_path/m3u_url"
tmp_playlist="/tmp/iptvplaylist"
player_pid_file="/tmp/iptvplayerpid"

mkdir -p "$config_path"

usage() {
  cat <<EOF
usage: iptv [options...] <m3u>

    -h    Get help for commands
    -u    Remote URL for the M3U file
    -f    Local filepath for the M3U file
    -r    Reload the current channel list
EOF
}

save_channels() {
  if [ -f "$m3u_file" ]; then
    cat "$m3u_file" >$tmp_playlist
  else
    m3u_url=$(cat "$m3u_url_file")
    printf "\nLoading channels... "
    curl -s "$m3u_url" | grep EXTINF: -A 2 >$tmp_playlist
    printf "\nDone!\n"
  fi

  printf "Parsing channels... "
  channels=()
  url=""
  total_lines=$(wc -l <"$tmp_playlist")
  line_number=0

  while IFS= read -r line; do
    if [[ "$line" =~ tvg-name=\"([^\"]+)\" || "$line" =~ tvg-id=\"([^\"]+)\" ]]; then
      name="${BASH_REMATCH[1]}"
      url=""
    elif [[ "${line//$'\r'/}" =~ \#EXTINF:-1,(.*) ]]; then
      name="${BASH_REMATCH[1]}"
    elif [[ "$line" == http* ]]; then
      url="$line"
      channels+=("$name [CH:${#channels[@]}] url:$url")
    fi
    ((line_number++))
    printf "\rParsing channels... %d%%" $((line_number * 100 / total_lines))
  done <"$tmp_playlist"

  printf "\nDone!\n"

  printf "%s\n" "${channels[@]}" >$channels_file
}

while getopts ":f:u:hr" opt; do
  case ${opt} in
  f)
    m3u_file=$OPTARG
    if [ ! -f "$m3u_file" ]; then
      echo "File not found!"
      exit 1
    fi
    ;;
  u)
    m3u_url=$OPTARG
    ;;
  h)
    usage
    exit 0
    ;;
  r)
    save_channels
    exit 0
    ;;
  \?)
    echo "Invalid option: $OPTARG" 1>&2
    usage
    exit 1
    ;;
  :)
    echo "Invalid option: $OPTARG requires an argument" 1>&2
    usage
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "$m3u_file" ] && [ -z "$m3u_url" ] && [ ! -s "$channels_file" ]; then
  usage
  exit 1
fi

if [ ! -z "$m3u_file" ]; then
  cat "$m3u_file" >$m3u_url_file
  save_channels
  echo "Playlist saved from file. Now run iptv again without a M3U file."
  exit
fi

if [ ! -z "$m3u_url" ]; then
  echo "$m3u_url" >$m3u_url_file
  save_channels
  echo "Playlist saved from URL. Now run iptv again without a M3U URL."
  exit
fi

if [[ $(find "$channels_file" -mtime +7) ]]; then
  read -p "The channel list is older than a week. Do you want to refresh it now? (y/N): " refresh
  if [[ "$refresh" == "y" ]]; then
    save_channels
  fi
fi

selected=$(cat "$channels_file" | sed 's/ [^ ]*$//' | fzf)

if [ ! -n "$selected" ]; then
  exit 1
fi

selected_channel=$(echo "$selected" | sed 's/.*\(\[CH:[0-9]\+\]\).*/\1/')
selected_channel_line=$(cat "$channels_file" | grep -F "$selected_channel")
selected_channel_url=$(echo "$selected_channel_line" | grep -oE 'url:(.*)' | sed 's/url://' | tr -d '\r')
selected_channel_name=$(echo "$selected_channel_line" | sed 's/\(.*\) url:.*/\1/')

printf "Playing %s from %s" "$selected_channel_url" "$selected_channel_name"

if [ -f "$player_pid_file" ]; then
  player_pid=$(cat "$player_pid_file")

  if kill -0 "$player_pid" >/dev/null 2>&1; then
    kill "$player_pid"
  fi
fi

mpv "$selected_channel_url" >/dev/null 2>&1 &
echo $! >"$player_pid_file"
