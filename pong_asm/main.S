.data

score:         .asciz "00"                  # score string altered later
score_fmt:     .asciz "%d"                  # ugly but works

.text

window_name:                .asciz "Pong" 
menu_title:                 .asciz "pong"
singleplayer_prompt:        .asciz "[S] 1 player"
multiplayer_prompt:         .asciz "[M] 2 players"
back_to_menu_prompt:        .asciz "[Q] Go back to menu"
difficulty_selector_prompt: .asciz "[1 - 5] Choose difficulty"

.global _main

_main:
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $80, %rsp                       # need to reserve space for 10 variables

    # game window and sound init
    movq    $WINDOW_WIDTH, %rdi
    movq    $WINDOW_HEIGHT, %rsi
    leaq    window_name(%rip), %rdx
    call    _InitWindow

    movq    $FPS, %rdi
    call    _SetTargetFPS

    call    _sound_init

back_to_menu:
    movq    $PADDLE_DEFAULT_POS, -8(%rbp)   # playerY
    movq    $PADDLE_DEFAULT_POS, -16(%rbp)  # opponentY
    movq    $PADDLE_BASE_SPEED, -24(%rbp)   # difficulty = player speed + diff parameter
    movq    $BALL_DEFAULT_X, -32(%rbp)      # ballX
    movq    $BALL_DEFAULT_Y, -40(%rbp)      # ballY
    movq    $BALL_BASE_SPEED_X, -48(%rbp)   # ballSpeedX
    movq    $BALL_BASE_SPEED_Y, -56(%rbp)   # ballSpeedY
    movq    $0, -64(%rbp)                   # scorePlayer
    movq    $0, -72(%rbp)                   # scoreOpponent
    movq    $0, -80(%rbp)                   # game mode (signle/multi)

menu_loop:
    
    call    _WindowShouldClose
    cmpb    $0, %al                         # compare the first byte for boolean values
    jne     end

    movq    $KEY_S, %rdi                    # check for single player
    call    _IsKeyDown
    cmpb    $0, %al
    jne     singleplayer_init

    movq    $KEY_M, %rdi                    # check for two players
    call    _IsKeyDown
    cmpb    $0, %al
    jne     multiplayer_init

    # render some menus
    call    _BeginDrawing

    movq    $BLACK, %rdi
    call    _ClearBackground                # set backdrop

    leaq    menu_title(%rip), %rdi          # DrawText only takes strings as the 1st arg
    movq    $WINDOW_WIDTH / 2 - 110, %rsi
    movq    $OFFSET * 2, %rdx
    movq    $FONT_SIZE * 3, %rcx
    movq    $WHITE, %r8
    call    _DrawText                       # game title pong

    leaq    singleplayer_prompt(%rip), %rdi 
    movq    $OFFSET, %rsi
    movq    $WINDOW_HEIGHT - OFFSET * 2 - FONT_SIZE * 2, %rdx
    movq    $FONT_SIZE, %rcx
    movq    $WHITE, %r8
    call    _DrawText                       # 1 player button

    leaq    multiplayer_prompt(%rip), %rdi 
    movq    $OFFSET, %rsi
    movq    $WINDOW_HEIGHT - OFFSET * 2, %rdx
    movq    $FONT_SIZE, %rcx
    movq    $WHITE, %r8
    call    _DrawText                       # 2 players button

    call    _EndDrawing
    jmp     menu_loop

singleplayer_init:
    movq    $SINGLEPLAYER, -80(%rbp)        # set the value to later render computer controlled paddle only

    movq    $PONG, %rdi                     # menu selection sound
    call    _play_sound
    
choose_difficulty_loop:
    call    _WindowShouldClose              # exit the game
    cmpb    $0, %al                         # compare the first byte for boolean values
    jne     end

    movq    $KEY_1, %rdi                    # easy
    call    _IsKeyDown
    cmpb    $0, %al
    jne     difficulty_1

    movq    $KEY_2, %rdi                    # mid
    call    _IsKeyDown
    cmpb    $0, %al
    jne     difficulty_2

    movq    $KEY_3, %rdi                    # hard
    call    _IsKeyDown
    cmpb    $0, %al
    jne     difficulty_3

    movq    $KEY_4, %rdi                    # very hard
    call    _IsKeyDown
    cmpb    $0, %al
    jne     difficulty_4

    movq    $KEY_5, %rdi                    # impossible
    call    _IsKeyDown
    cmpb    $0, %al
    jne     difficulty_5

    movq    $KEY_Q, %rdi                    # go back to menu
    call    _IsKeyDown
    cmpb    $0, %al
    jne     back_to_menu

    # render difficulty selector
    call    _BeginDrawing

    movq    $BLACK, %rdi
    call    _ClearBackground                # set backdrop

    leaq    back_to_menu_prompt(%rip), %rdi 
    movq    $OFFSET, %rsi
    movq    $OFFSET, %rdx
    movq    $FONT_SIZE / 2, %rcx
    movq    $WHITE, %r8
    call    _DrawText                       # back to menu button

    leaq    difficulty_selector_prompt(%rip), %rdi 
    movq    $OFFSET, %rsi
    movq    $WINDOW_HEIGHT - OFFSET - FONT_SIZE, %rdx
    movq    $FONT_SIZE, %rcx
    movq    $WHITE, %r8
    call    _DrawText                       # select difficulty button

    call    _EndDrawing
    jmp     choose_difficulty_loop

difficulty_1:
    addq    $1, -24(%rbp)

    movq    $PONG, %rdi                     # menu sound
    call    _play_sound

    jmp     main_loop

difficulty_2:
    addq    $2, -24(%rbp)

    movq    $PONG, %rdi
    call    _play_sound

    jmp     main_loop

difficulty_3:
    addq    $3, -24(%rbp)

    movq    $PONG, %rdi
    call    _play_sound

    jmp     main_loop

difficulty_4:
    addq    $4, -24(%rbp)

    movq    $PONG, %rdi
    call    _play_sound

    jmp     main_loop

difficulty_5:
    addq    $5, -24(%rbp)

    movq    $PONG, %rdi
    call    _play_sound

    jmp     main_loop

multiplayer_init:
    movq    $MULTIPLAYER, -80(%rbp)         # set the value to later render player controlled paddle only

    movq    $PONG, %rdi                     # menu selection sound
    call    _play_sound

    jmp     main_loop

main_loop:
    
    call    _WindowShouldClose              # exit the game
    cmpb    $0, %al                         # compare the first byte for boolean values
    jne     end

    movq    $KEY_Q, %rdi                    # go back to menu
    call    _IsKeyDown
    cmpb    $0, %al
    jne     back_to_menu

    # logic goes here... eventually

paddle_logic:

player_logic:

check_player_down:

    movq    $KEY_S, %rdi                    # if S key is pressed
    call    _IsKeyDown
    cmpb    $0, %al                         # again just the 1st byte
    je      check_player_up

    addq    $PLAYER_SPEED, -8(%rbp)         # move paddle downwards

    cmpq    $PADDLE_MAX_Y, -8(%rbp)         # if (playerY < PADDLE_MAX_Y)
    jl      check_player_up                 # skip next section
                                            # check if paddle fully inside the screen
    movq    $PADDLE_MAX_Y, -8(%rbp)         # playerY = PADDLE_MAX_Y

check_player_up:

    movq    $KEY_W, %rdi                    # check if W key is pressed      
    call    _IsKeyDown
    cmpb    $0, %al
    je      opponent_logic

    subq    $PLAYER_SPEED, -8(%rbp)         # move paddle up

    cmpq    $PADDLE_MIN_Y, -8(%rbp)         # check if paddle fully inside the screen
    jg      opponent_logic

    movq    $PADDLE_MIN_Y, -8(%rbp)         # playerY = PADDLE_MIN_Y

opponent_logic:

    cmpq    $1, -80(%rbp)                   # check gamemode
    je      singleplayer
    jmp     multiplayer

singleplayer:
check_computer_down:

    movq    -16(%rbp), %rax                 # only on registers :)))
    addq    $PADDLE_HALF, %rax              # so that the middle of the paddle locks onto the ball
    cmpq    -40(%rbp), %rax                 # if (computerY_mid > ballY)
    jg      check_computer_up               # skip

    movq    -16(%rbp), %rax                 # computerY
    addq    -24(%rbp), %rax                 # move computer down
    movq    %rax, -16(%rbp)

    cmpq    $PADDLE_MAX_Y, -16(%rbp)        # if (computerY < PADDLE_MAX_Y)
    jl      check_computer_up               # skip

    movq    $PADDLE_MAX_Y, -16(%rbp)        # computerY = PADDLE_MAX_Y

check_computer_up:

    movq    -16(%rbp), %rax                 # same as above
    addq    $PADDLE_HALF, %rax              
    cmpq    -40(%rbp), %rax                 # if (computerY_mid < ballY)
    jl      ball_logic                      # skip

    movq    -16(%rbp), %rax                 # computerY
    subq    -24(%rbp), %rax                 # move computer up
    movq    %rax, -16(%rbp)

    cmpq    $PADDLE_MIN_Y, -16(%rbp)        # if (computerY > PADDLE_MIN_Y)
    jg      ball_logic                      # skip

    movq    $PADDLE_MIN_Y, -16(%rbp)        # computerY = PADDLE_MIN_Y

multiplayer:
check_player2_down:

    movq    $KEY_DOWN, %rdi                 # if arrow down is pressed
    call    _IsKeyDown
    cmpb    $0, %al                         # again just the 1st byte
    je      check_player2_up

    addq    $PLAYER_SPEED, -16(%rbp)        # move opponent down

    cmpq    $PADDLE_MAX_Y, -16(%rbp)        # if (opponentY < PADDLE_MAX_Y)
    jl      check_player2_up                # skip

    movq    $PADDLE_MAX_Y, -16(%rbp)        # opponentY = PADDLE_MAX_Y

check_player2_up:

    movq    $KEY_UP, %rdi                   # if arrow up is pressed
    call    _IsKeyDown
    cmpb    $0, %al                         
    je      ball_logic

    subq    $PLAYER_SPEED, -16(%rbp)        # move opponent up

    cmpq    $PADDLE_MIN_Y, -16(%rbp)        # if (opponentY > PADDLE_MIN_Y)
    jg      ball_logic                      # skip

    movq    $PADDLE_MIN_Y, -16(%rbp)        # opponentY = PADDLE_MIN_Y

ball_logic:

    movq    -48(%rbp), %rax                 # ballX += ballSpeedX
    addq    %rax, -32(%rbp)                 # at least 1 operand has to be a register
    movq    -56(%rbp), %rax
    addq    %rax, -40(%rbp)                 # ballY += ballSpeedY

    # ball touching different surfaces

player_hitting_ball:

    movq    $PLAYER_RIGHT_EDGE, %rax
    cmpq    -32(%rbp), %rax                 # if right edge < ballX
    jl      player_missing                  # skip

    movq    $PLAYER_LEFT_EDGE, %rax
    cmpq    -32(%rbp), %rax                 # if left edge > ballX
    jg      player_missing                  # skip

    movq    -8(%rbp), %rax
    subq    $BALL_SIZE, %rax                # adjust for ball size, so that it doesnt clip through the top edge
    cmpq    -40(%rbp), %rax                 # if top edge > ballY
    jg      player_missing                  # skip

    movq    -8(%rbp), %rax
    addq    $PADDLE_HEIGHT, %rax
    cmpq    -40(%rbp), %rax                 # if bottom edge < ballY
    jl      player_missing                  # skip

    movq    $PLAYER_RIGHT_EDGE, -32(%rbp)   # so that it doesnt clip on the edge

    movq    $-1, %rax                       # ballSpeedX *= -1
    imulq   -48(%rbp), %rax                 # only works on registers :))))
    movq    %rax, -48(%rbp)

    movq    $PING, %rdi                     # play paddle hit sound
    call    _play_sound

    # increasing ball speed

    incq    -48(%rbp)                       # ballSpeedX++

    cmpq    $BALL_MAX_SPEED_X, -48(%rbp)    # if (ballSpeedX < max ball speed x)
    jl      player_missing                  # skip

    movq    $BALL_MAX_SPEED_X, -48(%rbp)    # ballSpeedX = max ball speed x

player_missing:                             # computer scores

    cmpq    $BALL_MIN_X, -32(%rbp)          # if (ballX > BALL_MIN_x)
    jg      opponent_hitting_ball           # skip

    movq    $BALL_DEFAULT_X, -32(%rbp)      # ballX = default x pos
    movq    $BALL_BASE_SPEED_X, -48(%rbp)   # ballSpeedX = base x speed
    movq    $BALL_BASE_SPEED_Y, -56(%rbp)   # ballSpeedY = base y speed

    addq    $1, -72(%rbp)                   # update computer score

    movq    $PONG, %rdi                     # goal sound
    call    _play_sound

opponent_hitting_ball:

    movq    $OPPONENT_LEFT_EDGE, %rax
    cmpq    -32(%rbp), %rax                 # if left edge > ballX
    jg      opponent_missing                # skip

    movq    $OPPONENT_RIGHT_EDGE, %rax
    cmpq    -32(%rbp), %rax                 # if right edge < ballX
    jl      opponent_missing                # skip

    movq    -16(%rbp), %rax
    subq    $BALL_SIZE, %rax                # adjust for ball size
    cmpq    -40(%rbp), %rax                 # if top edge > ballY
    jg      opponent_missing                # skip

    movq    -16(%rbp), %rax
    addq    $PADDLE_HEIGHT, %rax
    cmpq    -40(%rbp), %rax                 # if bottom edge < ballY
    jl      opponent_missing                # skip

    movq    $OPPONENT_LEFT_EDGE, -32(%rbp)  # so that it doesnt clip on the edge

    movq    $-1, %rax                       # ballSpeedX *= -1
    imulq   -48(%rbp), %rax
    movq    %rax, -48(%rbp)

    movq    $PING, %rdi                     # play paddle hit sound
    call    _play_sound

opponent_missing:                           # player scores

    cmpq    $BALL_MAX_X, -32(%rbp)          # if (ballX < BALL_MAX_X)
    jl      ball_touching_top_wall          # skip 

    movq    $BALL_DEFAULT_X, -32(%rbp)      # ballX = default x pos
    movq    $BALL_BASE_SPEED_X, -48(%rbp)   # ballSpeedX = base x speed
    movq    $BALL_BASE_SPEED_Y, -56(%rbp)   # ballSpeedY = base y speed

    addq    $1, -64(%rbp)                   # update player score

    movq    $PONG, %rdi                     # goal sound
    call    _play_sound

ball_touching_top_wall:

    cmpq    $BALL_MIN_Y, -40(%rbp)          # if (ballY > BALL_MIN_Y)
    jg      ball_touching_bottom_wall       # skip

    movq    $BALL_MIN_Y, -40(%rbp)          # ballY = BALL_MIN_Y

    movq    $-1, %rax                       # ballSpeedY *= -1
    imulq   -56(%rbp), %rax                 # again, only on registers :)))
    movq    %rax, -56(%rbp)

    movq    $PING, %rdi                     # play wall hit sound
    call    _play_sound

    # increasing ball speed

    incq    -56(%rbp)                       # ballSpeedY++

    cmpq    $BALL_MAX_SPEED_Y, -56(%rbp)    # if (ballSpeedY < max ball speed Y)
    jl      ball_touching_bottom_wall       # skip

    movq    $BALL_MAX_SPEED_Y, -56(%rbp)    # if (ballSpeedY = max ball speed Y)

ball_touching_bottom_wall:

    cmpq    $BALL_MAX_Y, -40(%rbp)          # if (ballY < BALL_MAX_Y)
    jl      rendering                       # skip

    movq    $BALL_MAX_Y, -40(%rbp)          # ballY = BALL_MAX_Y

    movq    $-1, %rax                       # ballSpeedY *= -1
    imulq   -56(%rbp), %rax                 
    movq    %rax, -56(%rbp)

    movq    $PING, %rdi                     # play wall hit sound
    call    _play_sound

rendering:

    call    _BeginDrawing

    # set backdrop
    movq    $BLACK, %rdi
    call    _ClearBackground

    leaq    back_to_menu_prompt(%rip), %rdi # back to menu button
    movq    $OFFSET, %rsi
    movq    $OFFSET, %rdx
    movq    $FONT_SIZE / 2, %rcx
    movq    $WHITE, %r8
    call    _DrawText 

    # draw scores

    # player
    leaq    score(%rip), %rdi               # first need to convert score to string
    leaq    score_fmt(%rip), %rsi
    movq    -64(%rbp), %rdx
    call    _sprintf                        # sprintf(score, "%d", scorePlayer)

    leaq    score(%rip), %rdi               # DrawText only takes strings as the 1st arg
    movq    $WINDOW_WIDTH / 2 - 120, %rsi
    movq    $OFFSET, %rdx
    movq    $FONT_SIZE, %rcx
    movq    $WHITE, %r8
    call    _DrawText                       # DrawText(score, WINDOW_WIDTH / 2 - 120, 30, 32, WHITE)

    # computer
    leaq    score(%rip), %rdi
    leaq    score_fmt(%rip), %rsi
    movq    -72(%rbp), %rdx
    call    _sprintf                        # sprintf(score, "%d", scoreComputer)

    leaq    score(%rip), %rdi
    movq    $WINDOW_WIDTH / 2 + 100, %rsi
    movq    $OFFSET, %rdx
    movq    $FONT_SIZE, %rcx
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
