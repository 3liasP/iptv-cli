# iptv-cli
`iptv` is a CLI IPTV player for M3U playlists with fuzzy finding, right in your terminal.

![iptv](https://user-images.githubusercontent.com/4785263/228887981-3efb80a9-e40d-4076-b234-8fa737527018.gif)

The playlist will be updated once a day whenever you run `iptv`.

This repo is forked from [shahin8r/iptv](https://github.com/shahin8r/iptv).

## Additional features
- Handy progress bar when parsing large files
- Support for more varied formats of m3u files
- More coming soon...

## Dependencies
- [curl](https://github.com/curl/curl)
- [fzf](https://github.com/junegunn/fzf)
- [mpv](https://github.com/mpv-player/mpv)

All dependencies can be installed with your package manager.

For example with Arch Linux,
```bash
sudo pacman -S curl fsf mpv
```

## Installation
```bash
git clone https://github.com/3liasP/iptv-cli.git
cd iptv-cli
./install.sh
```

Run `iptv` with your playlist URL or filepath to load all the channels (only needed on first run).

For example, you can use m3u playlist provided in [this repo](https://github.com/iptv-org/iptv) by [iptv-org](https://github.com/iptv-org).
```bash
iptv -u "https://iptv-org.github.io/iptv/index.m3u"
```

Or alternatively using local file,
```bash
iptv -f ~/path/to/your/index.m3u
```

## Usage
Run `iptv`.

`iptv` will automatically update your remote playlist every 24 hours. Alternatively you can manually update by
```bash
iptv -r
```
