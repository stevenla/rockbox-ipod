# AGENTS.md

Project-specific notes for coding agents working in this repo. `CLAUDE.md` is a
symlink to this file. Keep it short and current: add things that aren't obvious
from the code, and remove anything that becomes wrong.

## What this repo is

A personal fork of [Rockbox](https://www.rockbox.org) (upstream:
`git://git.rockbox.org/rockbox`), focused on iPod targets.

## Recording changes (required)

Every change made in this fork must be summarized in the "Changes from
upstream" section of `README.md`, in the same commit as the change. This
applies to code, keymaps, build and tooling changes alike. For each change,
describe:

- what changed, from the user's point of view (for UI or behaviour changes),
- any limitations or behaviour that was removed,
- the files and functions involved, briefly.

Update or remove an entry when a later change supersedes it. Keep the build
instructions at the top of `README.md` up to date as well.

## Building

Use the Docker setup rather than installing a toolchain on the host (macOS):

    docker compose build                                   # once; builds the ARM toolchain
    docker compose run --rm rockbox rbbuild ipodvideo      # -> build-ipodvideo-n/rockbox.zip
    docker compose run --rm rockbox rbbuild ipod6g b       # bootloader
    docker compose run --rm rockbox rbbuild ipodvideo s all  # simulator

- Default target: build `ipod4g` (iPod 4th gen, monochrome) unless told
  otherwise: `docker compose run --rm rockbox rbbuild ipod4g`.
- `rbbuild <target> [type] [make goals...]` is `docker/rbbuild.sh`. Types:
  `n` normal, `b` bootloader, `s` simulator.
- The build directories `build-*/` are git-ignored.
- The image includes only the ARM toolchain (`TOOLCHAINS: "a"` in
  `docker-compose.yml`). Add letters there for other architectures.
- Common iPod configure targets: `ipodvideo` (5G/5.5G), `ipod6g` (Classic),
  `ipodnano2g`, `ipodcolor`, `ipodmini2g`, `ipod4g`. See `tools/configure`.

## Conventions

- Follow upstream style: C, 4-space indent, and a GPL header on new source files.
  See `docs/CONTRIBUTING`.
- Keep fork changes in small, separate commits so they can be rebased on
  upstream or submitted upstream.

## Notes / learnings

- Keymaps: `apps/keymaps/keymap-ipod.c` is shared by every iPod model. A
  prerequisite button must match the previous button exactly, so
  `BUTTON_MENU|BUTTON_REPEAT` with prerequisite `BUTTON_MENU` fires only once
  per hold.
- Skip and play actions (`ACTION_WPS_SKIP*`, `ACTION_WPS_PLAY`) returned by a keymap in any context other than
  `CONTEXT_WPS` are handled inside `get_action()` by
  `wps_handle_playback_action()`, and become `ACTION_NONE` for the caller.

<!-- Add project-specific findings here as they come up. -->
