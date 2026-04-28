section .data
    seed        dd  12345
    n           dd  500
    freq        times 10 dd 0
    lcg_a       dd  1103515245
    lcg_c       dd  12345
    newline     db  10
    colon_sp    db  ': '
    sp_op       db  ' ('
    cl_par      db  ')'

section .bss
    digit_buf   resb 12
    hash_buf    resb 1024

section .text
    global _start

_start:
    mov     ecx, [n]
    mov     eax, [seed]

.gen_loop:
    push    ecx
    imul    eax, [lcg_a]
    add     eax, [lcg_c]
    and     eax, 0x7FFFFFFF
    mov     [seed], eax

    mov     edx, 0
    mov     ebx, 10
    div     ebx
    mov     ebx, edx
    mov     ecx, freq
    add     ecx, ebx
    add     ecx, ebx
    add     ecx, ebx
    add     ecx, ebx
    inc     dword [ecx]

    pop     ecx
    loop    .gen_loop

    mov     esi, 0

.print_loop:
    cmp     esi, 10
    jge     .done

    mov     eax, 4
    mov     ebx, 1
    lea     ecx, [digit_buf]
    mov     edx, esi
    add     edx, '0'
    mov     [digit_buf], dl
    mov     edx, 1
    int     0x80

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, colon_sp
    mov     edx, 2
    int     0x80

    mov     eax, freq
    mov     ebx, esi
    shl     ebx, 2
    add     eax, ebx
    mov     ecx, [eax]
    push    ecx

    mov     edi, 0
.hash_loop:
    cmp     edi, ecx
    jge     .hash_done
    mov     byte [hash_buf + edi], '#'
    inc     edi
    jmp     .hash_loop
.hash_done:
    cmp     edi, 0
    je      .skip_hash
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, hash_buf
    mov     edx, edi
    int     0x80
.skip_hash:

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, sp_op
    mov     edx, 2
    int     0x80

    pop     ecx
    push    esi
    call    print_int
    pop     esi

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, cl_par
    mov     edx, 1
    int     0x80

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, newline
    mov     edx, 1
    int     0x80

    inc     esi
    jmp     .print_loop

.done:
    mov     eax, 1
    mov     ebx, 0
    int     0x80

print_int:
    push    ebp
    mov     ebp, esp
    push    edi
    push    edx
    push    eax

    mov     eax, ecx
    lea     edi, [digit_buf + 11]
    mov     byte [edi], 0
    dec     edi

    cmp     eax, 0
    jne     .conv_loop
    mov     byte [edi], '0'
    dec     edi
    jmp     .print_num

.conv_loop:
    cmp     eax, 0
    je      .print_num
    mov     edx, 0
    mov     ebx, 10
    div     ebx
    add     dl, '0'
    mov     [edi], dl
    dec     edi
    jmp     .conv_loop

.print_num:
    inc     edi
    lea     eax, [digit_buf + 11]
    sub     eax, edi

    push    eax
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, edi
    pop     edx
    int     0x80

    pop     eax
    pop     edx
    pop     edi
    pop     ebp
    ret
