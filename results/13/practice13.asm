section .data
    msg_orig        db "Original:", 10
    msg_orig_len    equ $ - msg_orig
    msg_rev         db "Reversed:", 10
    msg_rev_len     equ $ - msg_rev
    msg_yes         db "PALINDROME: YES", 10
    msg_yes_len     equ $ - msg_yes
    msg_no          db "PALINDROME: NO", 10
    msg_no_len      equ $ - msg_no
    minus_sign      db '-'
    space_char      db ' '
    newline_char    db 10

section .bss
    input_buf   resb 4096
    num_buf     resb 16
    arr         resd 200
    rev         resd 200
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
    mov ecx, msg_orig
    mov edx, msg_orig_len
    int 0x80

    mov dword [idx], 0
.print_orig_loop:
    mov eax, [idx]
    cmp eax, [n_val]
    jge .print_orig_done
    mov ebx, [idx]
    mov eax, [arr + ebx*4]
    call print_int
    mov eax, [idx]
    mov ebx, [n_val]
    dec ebx
    cmp eax, ebx
    je .orig_skip_sp
    mov eax, 4
    mov ebx, 1
    mov ecx, space_char
    mov edx, 1
    int 0x80
.orig_skip_sp:
    inc dword [idx]
    jmp .print_orig_loop
.print_orig_done:
    call print_nl

    mov edi, [n_val]
    mov dword [idx], 0
    mov ecx, edi
    dec ecx
.build_rev_loop:
    mov ebx, [idx]
    cmp ebx, edi
    jge .build_rev_done
    mov eax, [arr + ecx*4]
    mov [rev + ebx*4], eax
    inc dword [idx]
    dec ecx
    jmp .build_rev_loop
.build_rev_done:

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_rev
    mov edx, msg_rev_len
    int 0x80

    mov dword [idx], 0
.print_rev_loop:
    mov eax, [idx]
    cmp eax, [n_val]
    jge .print_rev_done
    mov ebx, [idx]
    mov eax, [rev + ebx*4]
    call print_int
    mov eax, [idx]
    mov ebx, [n_val]
    dec ebx
    cmp eax, ebx
    je .rev_skip_sp
    mov eax, 4
    mov ebx, 1
    mov ecx, space_char
    mov edx, 1
    int 0x80
.rev_skip_sp:
    inc dword [idx]
    jmp .print_rev_loop
.print_rev_done:
    call print_nl

    mov edi, [n_val]
    mov dword [idx], 0
    mov ecx, edi
    dec ecx
.pal_loop:
    mov ebx, [idx]
    cmp ebx, ecx
    jge .is_palindrome
    mov eax, [arr + ebx*4]
    mov edx, [arr + ecx*4]
    cmp eax, edx
    jne .not_palindrome
    inc dword [idx]
    dec ecx
    jmp .pal_loop
.is_palindrome:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_yes
    mov edx, msg_yes_len
    int 0x80
    jmp .exit
.not_palindrome:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_no
    mov edx, msg_no_len
    int 0x80
.exit:
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
