# rockbox-ipod

A fork of [Rockbox](https://www.rockbox.org), the open-source firmware for
digital audio players, focused on iPod targets.

## Building

Builds run in Docker, so the only thing needed on the host is Docker.

1. Build the image. The first time, this compiles the ARM cross toolchain,
   which takes a while:

       docker compose build

2. Build a target. Output goes to `build-<target>-<type>/` in the repo:

       docker compose run --rm rockbox rbbuild ipodvideo          # rockbox.zip
       docker compose run --rm rockbox rbbuild ipod6g b           # bootloader
       docker compose run --rm rockbox rbbuild ipodvideo s all    # simulator

   Usage is `rbbuild <target> [type] [make goals...]`. Types are `n` normal
   (the default), `b` bootloader and `s` simulator. The make goals default to
   `zip`. Common iPod targets are `ipodvideo` (5G/5.5G), `ipod6g` (Classic),
   `ipodnano2g`, `ipodnano1g`, `ipodcolor`, `ipodmini2g` and `ipod4g`. See
   `tools/configure` for the full list.

3. Install the build by unzipping `rockbox.zip` to the root of the iPod
   (this creates `.rockbox/`).

For a shell inside the build environment (to run `tools/configure` and `make`
yourself), run `docker compose run --rm rockbox`. To add the toolchains for
non-ARM players, change `TOOLCHAINS` in `docker-compose.yml`. See
[`docker/README.md`](docker/README.md) for more.

For general Rockbox documentation, see [`docs/README`](docs/README) and
<https://www.rockbox.org/wiki/>.

## Changes from upstream

The fork is based on upstream commit `b883250b3a` ("test_boost decouple
calculations from screen refresh", 2026-10-23).

### iPod-style controls

The iPod keymap (`apps/keymaps/keymap-ipod.c`) works more like the original
iPod firmware:

| Button | Press | Hold |
| --- | --- | --- |
| Left (⏮) | Previous track, or restart the track if more than 3 s in | Rewind |
| Right (⏭) | Next track | Fast forward |
| Play/Pause | Main menu: play/pause. Lists and file browser: open Now Playing. Now Playing: play/pause | Stop playback |
| Menu | Back one level (from Now Playing: back to the screen it was opened from) | Go to the main menu |

- Left and right control playback on any screen: lists, menus, the file and
  database browsers, settings, Now Playing, and plugins that use the standard
  list keys. They no longer act as back/confirm in lists. Use Menu to go back
  and Select to confirm.
- Some screens still use left/right for their own purposes: the on-screen
  keyboard, the quick screen, the pitch screen, the FM radio, the recording
  screen, and the EQ, colour-picker and time/date setting screens.
- Seeking outside Now Playing has no progress bar. Only the fast-forward or
  rewind icon in the status bar shows it is happening. The jump is applied
  when you let go.
- Outside Now Playing, left/right always skip whole tracks: left restarts the
  current track if it has played for 3 seconds or more, and otherwise goes to
  the previous track. The "Skip Length" setting is ignored there. In Now
  Playing, left/right follow "Skip Length", whose default ("Skip Track") gives
  the same behaviour.
- Skip and seek are ignored in party mode or when nothing is playing.
  "Prevent Track Skipping" blocks the skips.
- In the main menu, Play/Pause toggles playback instead of opening Now
  Playing (it does nothing when no track is loaded). It still opens Now
  Playing from the file browser and other lists. Implemented with a separate
  `button_context_mainmenu` keymap that returns `ACTION_WPS_PLAY`, handled in
  `wps_handle_playback_action()` via `wps_do_action(WPS_PLAYPAUSE)`.
- Selecting the track that is already playing (or paused) opens Now Playing
  instead of restarting it, but only when it is selected from the same list
  it was started from: the same folder in the file browser, or the same
  album/artist/etc. listing in the database. A different list starts the track
  over as usual. The list is remembered as a key set with
  `playlist_set_source()` after `playlist_start()` in `ft_enter()`
  (`filetree.c`) and `tagtree_play_folder()` (`tagtree.c`), and cleared
  whenever the current playlist is replaced. `playlist_source_is_playing()`
  does the check. Limitations: the key for database listings is built from the
  menu entry and the selections leading to it, so it is lost if the database
  is reloaded; playlist files (.m3u) are not covered.
- The "Database" entry in the main menu and the settings menu is called
  "Music" (displayed and spoken). Only the `dest` and `voice` text of
  `LANG_TAGCACHE` in `apps/lang/english.lang` changed, so other languages
  still say "Database". Other messages that mention the database (e.g.
  "Database is not ready") are unchanged.
- Removed: holding Menu no longer opens the quick screen, and the "hold
  left/right to scroll lists" setting has no effect on iPods.
- Holding Menu while already on the main menu goes back to the previous
  screen (the existing Rockbox main-menu behaviour).

Implementation: `get_action()` (`apps/action.c`) passes skip/seek actions
returned outside the WPS context to the new `wps_handle_playback_action()`
(`apps/gui/wps.c`). That function reuses the WPS's own skip and seek code,
without redrawing the WPS. The WPS also now handles `ACTION_STD_CANCEL` by
returning to the previous screen. Other targets are unaffected, because no
other keymap returns these actions outside the WPS.

### Build environment

- **Docker build setup** (`Dockerfile`, `docker-compose.yml`, `.dockerignore`,
  `docker/`): a Debian 12 image that builds the ARM cross toolchain with
  `tools/rockboxdev.sh`, plus an `rbbuild` helper that configures and builds a
  target. It runs natively on Apple Silicon.

### Project files

- `AGENTS.md`: notes for coding agents. `CLAUDE.md` is a symlink to it.
- `README.md`: this file.
