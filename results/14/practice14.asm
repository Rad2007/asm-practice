section .data
    msg_before      db "Before:", 10
    msg_before_len  equ $ - msg_before
    msg_after       db "After:", 10
    msg_after_len   equ $ - msg_after
    msg_median      db "Median: "
    msg_median_len  equ $ - msg_median
    minus_sign      db '-'
    space_char      db ' '
    newline_char    db 10

section .bss
    input_buf   resb 4096
    num_buf     resb 16
    arr         resd 100
    n_val       resd 1
    idx         resd 1

section .text
global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 4096
    int 0x80

    mov esi, input_buf

    call skip_ws
    call parse_int
    mov [n_val], eax

    mov dword [idx], 0
.read_loop:
    mov eax, [idx]
    cmp eax, [n_val]
    jge .read_done
    call skip_ws
    call parse_int
    mov ebx, [idx]
    mov [arr + ebx*4], eax
    inc dword [idx]
    jmp .read_loop
.read_done:

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_before
    mov edx, msg_before_len
    int 0x80

    mov dword [idx], 0
.print_before_loop:
    mov eax, [idx]
    cmp eax, [n_val]
    jge .print_before_done
    mov ebx, [idx]
    mov eax, [arr + ebx*4]
    call print_int
    mov eax, [idx]
    mov ebx, [n_val]
    dec ebx
    cmp eax, ebx
    je .before_skip_sp
    mov eax, 4
    mov ebx, 1
    mov ecx, space_char
    mov edx, 1
    int 0x80
.before_skip_sp:
    inc dword [idx]
    jmp .print_before_loop
.print_before_done:
    call print_nl

    mov dword [idx], 0
.outer_loop:
    mov eax, [idx]
    mov ecx, [n_val]
    dec ecx
    cmp eax, ecx
    jge .sort_done

    mov eax, [idx]
    mov [min_idx], eax

    mov eax, [idx]
    inc eax
    mov [jdx], eax
.inner_loop:
    mov eax, [jdx]
    cmp eax, [n_val]
    jge .inner_done

    mov ebx, [min_idx]
    mov eax, [arr + ebx*4]
    mov ecx, [jdx]
    mov edx, [arr + ecx*4]
    cmp eax, edx
    jle .no_update
    mov eax, [jdx]
    mov [min_idx], eax
.no_update:
    inc dword [jdx]
    jmp .inner_loop
.inner_done:
    mov eax, [min_idx]
    cmp eax, [idx]
    je .no_swap

    mov ebx, [idx]
    mov eax, [arr + ebx*4]
    mov [tmp_val], eax

    mov ecx, [min_idx]
    mov eax, [arr + ecx*4]
    mov ebx, [idx]
    mov [arr + ebx*4], eax

    mov eax, [tmp_val]
    mov ecx, [min_idx]
    mov [arr + ecx*4], eax
.no_swap:
    inc dword [idx]
    jmp .outer_loop
.sort_done:

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_after
    mov edx, msg_after_len
    int 0x80

    mov dword [idx], 0
.print_after_loop:
    mov eax, [idx]
    cmp eax, [n_val]
    jge .print_after_done
    mov ebx, [idx]
    mov eax, [arr + ebx*4]
    call print_int
    mov eax, [idx]
    mov ebx, [n_val]
    dec ebx
    cmp eax, ebx
    je .after_skip_sp
    mov eax, 4
    mov ebx, 1
    mov ecx, space_char
    mov edx, 1
    int 0x80
.after_skip_sp:
    inc dword [idx]
    jmp .print_after_loop
.print_after_done:
    call print_nl

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_median
    mov edx, msg_median_len
    int 0x80

    mov eax, [n_val]
    mov ebx, 2
    xor edx, edx
    div ebx
    dec eax
    mov ebx, eax
    mov eax, [arr + ebx*4]
    call print_int
    call print_nl

    mov eax, 1
    xor ebx, ebx
    int 0x80

skip_ws:
    mov al, [esi]
    cmp al, ' '
    je .do_skip
    cmp al, 10
    je .do_skip
    cmp al, 13
    je .do_skip
    cmp al, 9
    je .do_skip
    ret
.do_skip:
    inc esi
    jmp skip_ws

parse_int:
    push ebx
    push ecx
    push edx
    xor eax, eax
    xor edx, edx
    cmp byte [esi], '-'
    jne .parse_digits
    inc esi
    mov edx, 1
.parse_digits:
    movzx ebx, byte [esi]
    cmp bl, '0'
    jl .parse_end
    cmp bl, '9'
    jg .parse_end
    imul eax, eax, 10
    sub bl, '0'
    add eax, ebx
    inc esi
    jmp .parse_digits
.parse_end:
    test edx, edx
    jz .parse_ret
    neg eax
.parse_ret:
    pop edx
    pop ecx
    pop ebx
    ret

print_int:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov edx, eax
    test edx, edx
    jns .pi_pos
    neg edx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, minus_sign
    mov edx, 1
    int 0x80
    pop edx
.pi_pos:
    mov eax, edx
    lea esi, [num_buf + 15]
    mov byte [esi], 0
    dec esi
    mov ecx, 10
.pi_digit_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    mov [esi], dl
    dec esi
    test eax, eax
    jnz .pi_digit_loop
    inc esi

    lea edx, [num_buf + 15]
    sub edx, esi
    mov ecx, esi
    mov eax, 4
    mov ebx, 1
    int 0x80

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_nl:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, newline_char
    mov edx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

section .bss
    min_idx     resd 1
    jdx         resd 1
    tmp_val     resd 1O
