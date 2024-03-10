rm -rf pong
gcc -arch x86_64 -o pong pong.c `pkg-config --cflags --libs raylib`