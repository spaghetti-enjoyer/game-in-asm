#include <raylib.h>

struct Sound sounds[2];

void sound_init()
{
    InitAudioDevice();
    sounds[0] = LoadSound("./sounds/ping.wav");
    sounds[1] = LoadSound("./sounds/pong.wav");
}

void play_sound(int index)
{
    PlaySound(sounds[index]);
}
