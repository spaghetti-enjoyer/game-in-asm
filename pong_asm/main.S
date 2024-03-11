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
    # actually only needed 8 ;-;

    subq    $80, %rsp                       # 8 * 9 = 72 (+ 8) = 80 % 16 = 0
    movq    $PADDLE_DEFAULT_POS, -8(%rbp)   # playerY
    movq    $PADDLE_DEFAULT_POS, -16(%rbp)  # computerY
    # movq  $1234, -24(%rbp)                # oopsie
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
    cmpb    $0, %al                         # compare the first byte for boolean values
    jne     end

    # logic goes here... eventually

paddle_logic:

    # player

check_player_down:

    movq    $KEY_DOWN, %rdi                 # if arrow down is pressed
    call    _IsKeyDown
    cmpb    $0, %al                         # again just the 1st byte
    je      check_player_up

    addq    $PLAYER_SPEED, -8(%rbp)         # move paddle downwards

    cmpq    $PADDLE_MAX_Y, -8(%rbp)         # if (playerY < PADDLE_MAX_Y)
    jl      check_player_up                 # skip next section
                                            # check if paddle fully inside the screen
    movq    $PADDLE_MAX_Y, -8(%rbp)         # playerY = PADDLE_MAX_Y

check_player_up:

    movq    $KEY_UP, %rdi                   # check if up arrow is pressed      
    call    _IsKeyDown
    cmpb    $0, %al
    je      check_computer_down

    subq    $PLAYER_SPEED, -8(%rbp)         # move paddle up

    cmpq    $PADDLE_MIN_Y, -8(%rbp)         # check if paddle fully inside the screen
    jg      check_computer_down

    movq    $PADDLE_MIN_Y, -8(%rbp)         # playerY = PADDLE_MIN_Y

    # computer

check_computer_down:

    movq    -16(%rbp), %rax                 # only on registers :)))
    addq    $PADDLE_HALF, %rax              # so that the middle of the paddle locks onto the ball
    cmpq    -40(%rbp), %rax                 # if (computerY_mid > ballY)
    jg      check_computer_up               # skip

    addq    $OPPONENT_SPEED, -16(%rbp)      # move computer down

    cmpq    $PADDLE_MAX_Y, -16(%rbp)        # if (paddleY < PADDLE_MAX_Y)
    jl      check_computer_up               # skip

    movq    $PADDLE_MAX_Y, -16(%rbp)        # computerY = PADDLE_MAX_Y

check_computer_up:

    movq    -16(%rbp), %rax                 # same as above
    addq    $PADDLE_HALF, %rax              
    cmpq    -40(%rbp), %rax                 # if (computerY_mid < ballY)
    jl      ball_logic                      # skip

    subq    $OPPONENT_SPEED, -16(%rbp)      # move computer up

    cmpq    $PADDLE_MIN_Y, -16(%rbp)        # if (computerY > PADDLE_MIN_Y)
    jg      ball_logic                      # skip

    movq    $PADDLE_MIN_Y, -16(%rbp)        # computerY = PADDLE_MIN_Y

ball_logic:

    movq    -48(%rbp), %rax                 # ballX += ballSpeedX
    addq    %rax, -32(%rbp)                 # at least 1 operand has to be a register
    movq    -56(%rbp), %rax
    addq    %rax, -40(%rbp)                 # ballY += ballSpeedY

    # ball touching different surfaces

player_hitting_ball:



player_missing:                             # computer scores

    cmpq    $BALL_MIN_X, -32(%rbp)          # if (ballX > BALL_MIN_x)
    jg      computer_hitting_ball           # skip

    movq    $BALL_MIN_X, -32(%rbp)          # ballX = BALL_MIN_X

    movq    $-1, %rax                       # ballSpeedX *= -1
    imulq   -48(%rbp), %rax                 # only works on registers :))))
    movq    %rax, -48(%rbp)

    addq    $1, -72(%rbp)                   # update computer score

computer_hitting_ball:


computer_missing:                           # player scores

    cmpq    $BALL_MAX_X, -32(%rbp)          # if (ballX < BALL_MAX_X)
    jl      ball_touching_top_wall          # skip 

    movq    $BALL_MAX_X, -32(%rbp)          # ballX = BALL_MAX_X, so that it doesnt get stuck on the edge

    movq    $-1, %rax                       # ballSpeedX *= -1
    imulq   -48(%rbp), %rax                 # only works on registers :))))
    movq    %rax, -48(%rbp)

    addq    $1, -64(%rbp)                   # update player score

ball_touching_top_wall:

    cmpq    $BALL_MIN_Y, -40(%rbp)          # if (ballY > BALL_MIN_Y)
    jg      ball_touching_bottom_wall       # skip

    movq    $BALL_MIN_Y, -40(%rbp)          # ballY = BALL_MIN_Y

    movq    $-1, %rax                       # ballSpeedY *= -1
    imulq  -56(%rbp), %rax                  # again, only on registers :)))
    movq    %rax, -56(%rbp)

ball_touching_bottom_wall:

    cmpq    $BALL_MAX_Y, -40(%rbp)          # if (ballY < BALL_MAX_Y)
    jl      rendering                       # skip

    movq    $BALL_MAX_Y, -40(%rbp)          # ballY = BALL_MAX_Y

    movq    $-1, %rax                       # ballSpeedY *= -1
    imulq   -56(%rbp), %rax                 # again, only on registers :)))
    movq    %rax, -56(%rbp)

rendering:

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
