section .data
    h           dd  9
    trunk_h     dd  2

section .bss
    line_buf    resb 60

section .text
    global _start

_start:
    mov     esi, 1

.row_loop:
    mov     eax, [h]
    cmp     esi, eax
    jg      .trunk_start

    mov     edi, 0

    mov     ecx, [h]
    sub     ecx, esi
    cmp     ecx, 0
    je      .stars

.space_loop:
    mov     byte [line_buf + edi], ' '
    inc     edi
    dec     ecx
    jnz     .space_loop

.stars:
    mov     ecx, esi
    shl     ecx, 1
    dec     ecx

.star_loop:
    mov     byte [line_buf + edi], '*'
    inc     edi
    dec     ecx
    jnz     .star_loop

    mov     byte [line_buf + edi], 10
    inc     edi

    push    esi
    mov     ecx, line_buf
    mov     edx, edi
    call    print_line
    pop     esi

    inc     esi
    jmp     .row_loop

.trunk_start:
    mov     esi, 0

.trunk_loop:
    mov     eax, [trunk_h]
    cmp     esi, eax
    jge     .done

    mov     edi, 0

    mov     ecx, [h]
    sub     ecx, 2
    cmp     ecx, 0
    je      .trunk_stars

.trunk_space_loop:
    mov     byte [line_buf + edi], ' '
    inc     edi
    dec     ecx
    jnz     .trunk_space_loop

.trunk_stars:
    mov     ecx, 3

.trunk_star_loop:
    mov     byte [line_buf + edi], '*'
    inc     edi
    dec     ecx
    jnz     .trunk_star_loop

    mov     byte [line_buf + edi], 10
    inc     edi

    push    esi
    mov     ecx, line_buf
    mov     edx, edi
    call    print_line
    pop     esi

    inc     esi
    jmp     .trunk_loop

.done:
    mov     eax, 1
    mov     ebx, 0
    int     0x80

print_line:
    mov     eax, 4
    mov     ebx, 1
    int     0x80
    ret
