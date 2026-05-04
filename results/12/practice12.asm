section .data
    text        db  'hello world hello foo hello', 0
    pattern     db  'hello', 0

    msg_pos     db  'Position: ', 0
    msg_pos_len equ $ - msg_pos - 1
    msg_cnt     db  'Count: ', 0
    msg_cnt_len equ $ - msg_cnt - 1
    msg_none    db  '-1', 10, 0
    msg_none_len equ $ - msg_none - 1
    newline     db  10

section .bss
    num_buf     resb 12

section .text
    global _start

_start:
    mov     ecx, pattern
    call    strlen
    mov     ebx, eax
    cmp     ebx, 0
    je      .empty_pattern

    mov     ecx, text
    call    strlen
    mov     edx, eax

    cmp     edx, 0
    je      .not_found_first

    mov     esi, 0
    mov     edi, -1
    mov     dword [num_buf], 0

    push    edx
    push    ebx

.outer:
    pop     ebx
    pop     edx
    mov     eax, edx
    sub     eax, ebx
    cmp     esi, eax
    jg      .print_results
    push    edx
    push    ebx

    push    esi
    mov     ecx, 0

.inner:
    cmp     ecx, ebx
    je      .match_found

    movzx   eax, byte [text + esi + ecx]
    movzx   edx, byte [pattern + ecx]
    cmp     eax, edx
    jne     .no_match

    inc     ecx
    jmp     .inner

.match_found:
    pop     esi
    cmp     edi, -1
    jne     .not_first
    mov     edi, esi
.not_first:
    add     dword [num_buf], 1
    pop     ebx
    pop     edx
    add     esi, ebx
    push    edx
    push    ebx
    jmp     .outer

.no_match:
    pop     esi
    inc     esi
    jmp     .outer

.print_results:
    pop     ebx
    pop     edx

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_pos
    mov     edx, msg_pos_len
    int     0x80

    cmp     edi, -1
    je      .print_none

    mov     ecx, edi
    call    print_int
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, newline
    mov     edx, 1
    int     0x80
    jmp     .print_count

.print_none:
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_none
    mov     edx, msg_none_len
    int     0x80

.print_count:
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_cnt
    mov     edx, msg_cnt_len
    int     0x80

    mov     ecx, [num_buf]
    call    print_int
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, newline
    mov     edx, 1
    int     0x80

    jmp     .exit

.not_found_first:
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_pos
    mov     edx, msg_pos_len
    int     0x80
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_none
    mov     edx, msg_none_len
    int     0x80
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_cnt
    mov     edx, msg_cnt_len
    int     0x80
    mov     ecx, 0
    call    print_int
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, newline
    mov     edx, 1
    int     0x80
    jmp     .exit

.empty_pattern:
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_pos
    mov     edx, msg_pos_len
    int     0x80
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_none
    mov     edx, msg_none_len
    int     0x80
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_cnt
    mov     edx, msg_cnt_len
    int     0x80
    mov     ecx, 0
    call    print_int
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, newline
    mov     edx, 1
    int     0x80

.exit:
    mov     eax, 1
    mov     ebx, 0
    int     0x80

strlen:
    push    ebx
    mov     eax, 0
.sl_loop:
    movzx   ebx, byte [ecx + eax]
    cmp     ebx, 0
    je      .sl_done
    inc     eax
    jmp     .sl_loop
.sl_done:
    pop     ebx
    ret

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
    jge     .pi_pos
    mov     byte [edi], '-'
    dec     edi
    neg     eax

.pi_pos:
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
