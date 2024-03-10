#include <raylib.h>
#include <stdio.h>
#include <stdlib.h>

#define WINDOW_HEIGHT 600
#define WINDOW_WIDTH 960
#define PADDLE_WIDTH 10
#define PADDLE_HEIGHT 100
#define BALL_SIZE 10
#define FPS 60
#define PADDLE_OFFSET 30
#define BALL_BASE_SPEED_X 5
#define BALL_BASE_SPEED_Y 2
#define PADDLE_BASE_SPEED 5

int main()
{
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Pong");
    SetTargetFPS(FPS);

    int playerY = WINDOW_HEIGHT / 2 - PADDLE_HEIGHT / 2;
    int botY = WINDOW_HEIGHT / 2 - PADDLE_HEIGHT / 2;
    int ballX = WINDOW_WIDTH / 2 - BALL_SIZE / 2;
    int ballY = WINDOW_HEIGHT / 2 - BALL_SIZE / 2;
    int paddleSpeed = PADDLE_BASE_SPEED;
    int ballSpeedX = BALL_BASE_SPEED_X;
    int ballSpeedY = BALL_BASE_SPEED_Y;

    int scorePlayer = 0;
    int scoreBot = 0;

    while (!WindowShouldClose())
    {

        // paddle mechanics

        // player

        if (IsKeyDown(KEY_DOWN))
        {
            playerY += paddleSpeed;
        }
        if (playerY > WINDOW_HEIGHT - PADDLE_HEIGHT)
        {
            playerY = WINDOW_HEIGHT - PADDLE_HEIGHT;
        }
        if (IsKeyDown(KEY_UP))
        {
            playerY -= paddleSpeed;
        }
        if (playerY < 0)
        {
            playerY = 0;
        }

        // computer

        if (ballY > botY + PADDLE_HEIGHT / 2)
        {
            botY += paddleSpeed;
        }
        if (botY > WINDOW_HEIGHT - PADDLE_HEIGHT)
        {
            botY = WINDOW_HEIGHT - PADDLE_HEIGHT;
        }
        if (ballY < botY + PADDLE_HEIGHT / 2)
        {
            botY -= paddleSpeed;
        }
        if (botY < 0)
        {
            botY = 0;
        }

        // ball mechanics

        ballX += ballSpeedX;
        ballY += ballSpeedY;

        // player side

        if (ballX < PADDLE_OFFSET + PADDLE_WIDTH && ballY > playerY && ballY < playerY + PADDLE_HEIGHT)
        {
            ballX = PADDLE_OFFSET + PADDLE_WIDTH;
            ballSpeedX *= -1;
        }
        if (ballX < 0)
        {
            scoreBot++;
            ballX = WINDOW_WIDTH / 2 - BALL_SIZE / 2;
            ballY = WINDOW_HEIGHT / 2 - BALL_SIZE / 2;
            ballSpeedX = 5;
            ballSpeedY = 2;
        }

        // computer side 

        if (ballX > WINDOW_WIDTH - PADDLE_OFFSET - PADDLE_WIDTH && ballY > botY && ballY < botY + PADDLE_HEIGHT)
        {
            ballX = WINDOW_WIDTH - PADDLE_OFFSET - PADDLE_WIDTH;
            ballSpeedX *= -1;
        }
        if (ballX > WINDOW_WIDTH - BALL_SIZE)
        {
            scorePlayer++;
            ballX = WINDOW_WIDTH / 2 - BALL_SIZE / 2;
            ballY = WINDOW_HEIGHT / 2 - BALL_SIZE / 2;
            ballSpeedX = BALL_BASE_SPEED_X;
            ballSpeedY = BALL_BASE_SPEED_Y;
        }

        if (ballY < 0)
        {
            ballSpeedY *= -1;
            ballY = 0;
            // printf("ball y inverted: %i, speed: %i\n", ballY, ballSpeedY);
        }
        if (ballY > WINDOW_HEIGHT - BALL_SIZE)
        {
            ballSpeedY++;
            ballSpeedX++;
            ballSpeedY *= -1;
            ballY = WINDOW_HEIGHT - BALL_SIZE - 1;
        }
        // printf("ball y: %i\n", ballY);

        BeginDrawing();
        // background and score
        ClearBackground(BLACK);

        char *scoreString = malloc(2 * sizeof(char));
        sprintf(scoreString, "%i", scorePlayer);
        DrawText(scoreString, WINDOW_WIDTH / 2 - 120, 30, 32, WHITE);
        sprintf(scoreString, "%i", scoreBot);
        DrawText(scoreString, WINDOW_WIDTH / 2 + 100, 30, 32, WHITE);
        free(scoreString);
        // paddles
        DrawRectangle(PADDLE_OFFSET, playerY, PADDLE_WIDTH, PADDLE_HEIGHT, WHITE);
        DrawRectangle(WINDOW_WIDTH - PADDLE_WIDTH - PADDLE_OFFSET, botY, PADDLE_WIDTH, PADDLE_HEIGHT, WHITE);
        // ball
        DrawRectangle(ballX, ballY, BALL_SIZE, BALL_SIZE, WHITE);
        EndDrawing();
    }
    CloseWindow();
    return 0;
}