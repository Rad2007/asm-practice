section .data
    h           dd  9

section .bss
    line_buf    resb 60

section .text
    global _start

_start:
    mov     esi, 1

.row_loop:
    mov     eax, [h]
    cmp     esi, eax
    jg      .done

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

.done:
    mov     eax, 1
    mov     ebx, 0
    int     0x80

print_line:
    mov     eax, 4
    mov     ebx, 1
    int     0x80
    ret
