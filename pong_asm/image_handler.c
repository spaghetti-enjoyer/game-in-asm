#include <raylib.h>

Image image;
Texture2D texture;

void image_init()
{
    // image = LoadImage("images/thilo.png");
    image = LoadImage("images/alexandru.png");
    texture = LoadTextureFromImage(image);
}

void draw_image(int x, int y)
{
    DrawTexture(texture, x, y, WHITE);
}

void image_deinit()
{
    UnloadImage(image);
    UnloadTexture(texture);
}
