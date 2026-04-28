section .data
    x           dd  305441741
    p           dd  1
    q           dd  7
    r           dd  3

    msg_bin     db  'Binary: ', 0
    msg_bin_len equ $ - msg_bin - 1
    msg_pop     db  'Popcount: ', 0
    msg_pop_len equ $ - msg_pop - 1
    msg_res     db  'Result: ', 0
    msg_res_len equ $ - msg_res - 1
    newline     db  10
    space       db  ' '

section .bss
    bin_buf     resb 40
    num_buf     resb 12

section .text
    global _start

_start:
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_bin
    mov     edx, msg_bin_len
    int     0x80

    mov     eax, [x]
    mov     ecx, 31
    mov     edi, 0

.bin_loop:
    mov     edx, eax
    shr     edx, cl
    and     edx, 1
    add     dl, '0'
    mov     [bin_buf + edi], dl
    inc     edi

    mov     edx, 31
    sub     edx, ecx
    inc     edx
    test    edx, 3
    jnz     .no_space
    cmp     ecx, 0
    je      .no_space
    mov     byte [bin_buf + edi], ' '
    inc     edi
.no_space:

    cmp     ecx, 0
    je      .bin_done
    dec     ecx
    jmp     .bin_loop

.bin_done:
    mov     byte [bin_buf + edi], 10
    inc     edi

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, bin_buf
    mov     edx, edi
    int     0x80

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_pop
    mov     edx, msg_pop_len
    int     0x80

    mov     eax, [x]
    mov     ecx, 0

.pop_loop:
    cmp     eax, 0
    je      .pop_done
    mov     edx, eax
    and     edx, 1
    add     ecx, edx
    shr     eax, 1
    jmp     .pop_loop

.pop_done:
    call    print_int

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, newline
    mov     edx, 1
    int     0x80

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_res
    mov     edx, msg_res_len
    int     0x80

    mov     eax, [x]

    mov     ecx, [p]
    mov     edx, 1
    shl     edx, cl
    or      eax, edx

    mov     ecx, [q]
    mov     edx, 1
    shl     edx, cl
    or      eax, edx

    mov     ecx, [r]
    mov     edx, 1
    shl     edx, cl
    not     edx
    and     eax, edx

    mov     ecx, eax
    call    print_int

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, newline
    mov     edx, 1
    int     0x80

    mov     eax, 1
    mov     ebx, 0
    int     0x80

print_int:
    push    eax
    push    ebx
    push    edx
    push    edi

    mov     eax, ecx
    lea     edi, [num_buf + 11]
    mov     byte [edi], 0
    dec     edi

    cmp     eax, 0
    jne     .pi_loop
    mov     byte [edi], '0'
    dec     edi
    jmp     .pi_print

.pi_loop:
    cmp     eax, 0
    je      .pi_print
    mov     edx, 0
    mov     ebx, 10
    div     ebx
    add     dl, '0'
    mov     [edi], dl
    dec     edi
    jmp     .pi_loop

.pi_print:
    inc     edi
    lea     eax, [num_buf + 11]
    sub     eax, edi
    mov     edx, eax
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, edi
    int     0x80

    pop     edi
    pop     edx
    pop     ebx
    pop     eax
    ret
