rm -rf .build
mkdir .build

# assembly
gcc -g -c --include pong_asm/constants.S pong_asm/main.S -o .build/draft-main.o || exit 1

gcc `pkg-config --libs --cflags raylib` .build/draft-main.o pong_asm/sound_handler.c pong_asm/image_handler.c -o .build/bin || exit 1

# C
gcc -arch x86_64 -o .build/pong pong_c/pong.c `pkg-config --cflags --libs raylib` || exit 1

