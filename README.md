# ShineOS live-build

This is an independent live-build configuration for an amd64 Debian 13
(Trixie) GNOME live system with the Debian Installer's live installation mode.
It keeps the captured desktop assets inside this tree; it does not read from a
developer home directory when building.

## Build profile

- GNOME desktop and the requested GNOME utilities
- Extension Manager, GNOME Extensions, KDE Connect, and Waydroid
- Dark GNOME color scheme by default, Adwaita GNOME Shell, MacTahoe-Dark for
  legacy GTK apps, and the captured Starcons icon theme
- Instrument Sans and JetBrains Mono (SIL OFL 1.1; see CREDITS.txt)
- Wallpaper (see CREDITS.txt) and ShineOS boot artwork (Plymouth theme)
- Fastfetch with the active ShineOS config and logo for new users
- The `teamstarlightos/asciify` CLI installed system-wide with its MIT license
- Captured extension source archive; the chroot hook detects the GNOME Shell
  version in the image, installs extensions whose metadata lists that version,
  and removes unsupported extensions from the enabled list

Waydroid is installed from the official Trixie backports archive; other
packages remain on Debian 13 stable unless a dependency requires a backport.
Its Android system image is fetched by Waydroid during setup rather than
bundled in this ISO.

## Lower-memory build

The SquashFS root uses gzip level 1, and the build wrapper pins live-build to
one allowed CPU. This lowers peak memory use and keeps the installed desktop
content the same; the image is larger than with high-ratio compression.

From this directory, use the standard live-build steps:

```sh
sudo lb clean
sudo ./auto/config
sudo taskset -c 0 lb build
```

`auto/config` restores the Trixie installer, backports access, and low-memory
settings after a clean. The ISO is written in the project directory. The optional
`build-iso.sh` helper makes an isolated build and writes to `output/`.

## Asset provenance and limits

Assets were copied from the active ShineOS desktop: the `MacTahoe-Dark` GTK
theme, `Starcons` icons, active wallpaper, GNOME Shell extension directories,
installed user fonts (open-licensed only, see CREDITS.txt), and the
existing Shine hexagon logo. No home directory, browser data, or application
profiles are copied.

`config/extension-settings.ini` is the sanitized project-local import of the
provided extension settings. Personal home paths, device pairings, and
settings for unavailable or incompatible extensions are omitted. Only enabled
extensions with available source that declares compatibility with Trixie's
GNOME Shell are enabled. Weather Or Not, Screenshot Window Sizer, and GSConnect
are excluded from this ISO at the developer's request.

The font and icon/theme source directories did not expose license files in
the inspected locations. Review their redistribution terms before publishing
an ISO. Keep each upstream author's licensing notices with any assets for
which they are present.

## History

ShineOS was originally based on Origin UI 26 Sedona Beta 2 by The Ester Project, and early versions also used Ubuntu code by Canonical. It is now an independent Debian-based distribution. See CREDITS.txt.
