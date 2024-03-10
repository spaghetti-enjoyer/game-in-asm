.data

score:         .asciz "00"                  # score string altered later
score_fmt:     .asciz "%d"                  # ugly but works

.text

greeting:       .asciz "Hello world!\n"
window_name:    .asciz "Pong" 

.global _main


draw_player:
    movq    $30, %rdi                       # x coordinate
    movq    $10, %rsi                       # y coordinate
    movq    $PADDLE_WIDTH, %rdx
    movq    $PADDLE_HEIGHT, %rcx
    movq    $WHITE, %r8
    call    _DrawRectangle 
    ret

_main:
    pushq   %rbp
    movq    %rsp, %rbp

    # need to reserve space for 9 vars (so 10 coz stack alignment)

    subq    $80, %rsp                       # 8 * 9 = 72 (+ 8) = 80 % 16 = 0
    movq    $PADDLE_DEFAULT_POS, -8(%rbp)   # playerY
    movq    $PADDLE_DEFAULT_POS, -16(%rbp)  # botY
    movq    $PADDLE_BASE_SPEED, -24(%rbp)   # paddleSpeed
    movq    $BALL_DEFAULT_X, -32(%rbp)      # ballX
    movq    $BALL_DEFAULT_Y, -40(%rbp)      # ballY
    movq    $BALL_BASE_SPEED_X, -48(%rbp)   # ballSpeedX
    movq    $BALL_BASE_SPEED_Y, -56(%rbp)   # ballSpeedY
    movq    $3, -64(%rbp)                   # scorePlayer
    movq    $2, -72(%rbp)                   # scoreComputer


    # game window init
    movq    $WINDOW_WIDTH, %rdi
    movq    $WINDOW_HEIGHT, %rsi
    leaq    window_name(%rip), %rdx
    call    _InitWindow

    movq    $FPS, %rdi
    call    _SetTargetFPS

main_loop:
    # should close but doesn't
    call    _WindowShouldClose
    cmpq    $1, %rax
    je      end

    # logic goes here... eventually

    # paddle logic

    # player

    # computer

    # ball logic

    # begin rendering
    call    _BeginDrawing

    # set backdrop
    movq    $BLACK, %rdi
    call    _ClearBackground

    # draw scores

    # player
    leaq    score(%rip), %rdi               # first need to convert score to string
    leaq    score_fmt(%rip), %rsi
    movq    -64(%rbp), %rdx
    call    _sprintf                        # sprintf(score, "%d", scorePlayer)

    leaq    score(%rip), %rdi               # DrawText only takes strings as the 1st arg
    movq    $WINDOW_WIDTH / 2 - 120, %rsi
    movq    $30, %rdx
    movq    $32, %rcx
    movq    $WHITE, %r8
    call    _DrawText                       # DrawText(score, WINDOW_WIDTH / 2 - 120, 30, 32, WHITE)

    # computer
    leaq    score(%rip), %rdi
    leaq    score_fmt(%rip), %rsi
    movq    -72(%rbp), %rdx
    call    _sprintf                        # sprintf(score, "%d", scoreComputer)

    leaq    score(%rip), %rdi
    movq    $WINDOW_WIDTH / 2 + 100, %rsi
    movq    $30, %rdx
    movq    $32, %rcx
    movq    $WHITE, %r8
    call    _DrawText                       # DrawText(score, WINDOW_WIDTH / 2 + 100, 30, 32, WHITE)

    # draw paddles and the ball

    # player
    movq    $PLAYER_OFFSET, %rdi
    movq    -8(%rbp), %rsi                  # notice the variable y coordinate
    movq    $PADDLE_WIDTH, %rdx
    movq    $PADDLE_HEIGHT, %rcx
    movq    $WHITE, %r8
    call    _DrawRectangle                  # DrawRectangle(PLAYER_OFFSET, playerY, PADDLE_WIDTH, PADDLE_HEIGHT, WHITE)

    # computer
    movq    $OPPONENT_OFFSET, %rdi
    movq    -16(%rbp), %rsi
    movq    $PADDLE_WIDTH, %rdx
    movq    $PADDLE_HEIGHT, %rcx
    movq    $WHITE, %r8
    call    _DrawRectangle                  # DrawRectangle(OPPONENT_OFFSET, botY, PADDLE_WIDTH, PADDLE_HEIGHT, WHITE)

    # draw the ball
    movq    -32(%rbp), %rdi
    movq    -40(%rbp), %rsi
    movq    $BALL_SIZE, %rdx
    movq    $BALL_SIZE, %rcx
    movq    $WHITE, %r8
    call    _DrawRectangle                  # DrawRectangle(ballX, ballY, BALL_SIZE, BALL_SIZE, WHITE)

    call    _EndDrawing
    jmp     main_loop

end:

    call    _CloseWindow

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rax
    ret