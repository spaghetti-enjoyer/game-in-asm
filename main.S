.text

greeting:       .asciz "Hello world!\n"
window_name:    .asciz "Pong" 

.global _main

draw_ball:
    ret

draw_player:
    movq    $30, %rdi               # x coordinate
    movq    $10, %rsi               # y coordinate
    movq    $PADDLE_WIDTH, %rdx
    movq    $PADDLE_HEIGHT, %rcx
    movq    $WHITE, %r8
    call    _DrawRectangle 
    ret

draw_bot:
    ret

draw_paddles:
    call    draw_player
    call    draw_bot
    ret

_main:
    pushq   %rbp
    movq    %rsp, %rbp

    # Hello world!
    # leaq    greeting(%rip), %rdi
    # movb    $0, %al
    # call    _printf

    # game window init
    movq    $WINDOW_WIDTH, %rdi
    movq    $WINDOW_HEIGHT, %rsi
    leaq    window_name(%rip), %rdx
    call    _InitWindow

    movq    $60, %rdi
    call    _SetTargetFPS

main_loop:
    # should close but doesn't
    call    _WindowShouldClose
    cmpq    $1, %rax
    je      end

    # begin rendering
    call    _BeginDrawing

    movq    $BLACK, %rdi
    call    _ClearBackground

    call    draw_ball
    call    draw_paddles

    call    _EndDrawing
    jmp     main_loop

end:

    call    _CloseWindow

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rax
    ret