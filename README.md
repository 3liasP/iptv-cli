# iptv
`iptv` is a CLI IPTV player for M3U playlists with fuzzy finding, right in your terminal.

![iptv](https://user-images.githubusercontent.com/4785263/228887981-3efb80a9-e40d-4076-b234-8fa737527018.gif)

The playlist will be updated once a day whenever you run `iptv`.

This repo is forked from [shahin8r/iptv](https://github.com/shahin8r/iptv)

## Additional features
- Handy progress bar when parsing large files
- Support for more varied formats of m3u files
- More coming soon...

## Dependencies
- [curl](https://github.com/curl/curl)
- [fzf](https://github.com/junegunn/fzf)
- [mpv](https://github.com/mpv-player/mpv)

All dependencies can be installed with your package manager.
For example,
```bash
sudo pacman -S curl fsf mpv
```

## Installation
```bash
cd iptv-cli
./install.sh
```

Run `iptv` with your playlist URL to load all the channels (only needed on first run).
You can use iptv-org's iptv repo's m3u list:
```bash
iptv https://iptv-org.github.io/iptv/index.m3u
```

## Usage
Run `iptv`.
