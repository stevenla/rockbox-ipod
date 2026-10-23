# Building Rockbox with Docker

Build the image (compiles the ARM cross toolchain; takes a while the first time):

    docker compose build

To include other toolchains, change `TOOLCHAINS` in `docker-compose.yml`
(`a` arm, `m` m68k, `i` mips, `x` arm-linux, `y` mips-linux).

Build a target (output goes to `build-<target>-<type>/` in the repo):

    docker compose run --rm rockbox rbbuild ipodvideo          # rockbox.zip
    docker compose run --rm rockbox rbbuild ipod6g b           # bootloader
    docker compose run --rm rockbox rbbuild ipodvideo s all    # simulator

Or get a shell and run `tools/configure` / `make` yourself:

    docker compose run --rm rockbox
