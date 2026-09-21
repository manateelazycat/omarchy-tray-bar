# Omarchy Tray Bar

An Omarchy bar plugin that displays all non-hidden system tray icons directly,
without an expander arrow or hover-to-expand interaction.

## Features

- Tray icons are expanded by default and remain visible.
- No expander arrow or reserved arrow spacing.
- No hover-to-collapse behavior.
- Empty drawer space disappears when there are no drawer items.
- Supports both horizontal and vertical Omarchy bars.
- Replaces the built-in `omarchy.tray` widget automatically when enabled.

## Install

```bash
omarchy plugin add https://github.com/manateelazycat/omarchy-tray-bar.git --enable --yes
```

No manual edits to `~/.config/omarchy/shell.json` or the plugin source are
required.

## Update

```bash
omarchy plugin update io.github.manateelazycat.tray-bar --yes
```

## Remove

```bash
omarchy plugin remove io.github.manateelazycat.tray-bar --yes
```

Removing the plugin restores Omarchy's built-in system tray.

## Development

```bash
omarchy plugin validate .
npm test
```

## Credits

Based on the system tray from [Omarchy](https://github.com/omacom/omarchy),
whose original MIT license is preserved in
[licenses/OMARCHY-LICENSE](licenses/OMARCHY-LICENSE). See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

GNU General Public License v3.0 only. See [LICENSE](LICENSE).
