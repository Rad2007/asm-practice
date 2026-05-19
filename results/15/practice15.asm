section .data
    msg_fact        db "fact(n) = "
    msg_fact_len    equ $ - msg_fact
    msg_calls       db "calls = "
    msg_calls_len   equ $ - msg_calls
    newline_char    db 10
    minus_sign      db '-'

section .bss
    input_buf   resb 64
    num_buf     resb 16
    calls       resd 1

section .text
global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 64
    int 0x80

    mov esi, input_buf
    call skip_ws
    call parse_int

    mov dword [calls], 0

    call fact

    push eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_fact
    mov edx, msg_fact_len
    int 0x80

    pop eax
    call print_int
    call print_nl

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_calls
    mov edx, msg_calls_len
    int 0x80

    mov eax, [calls]
    call print_int
    call print_nl

    mov eax, 1
    xor ebx, ebx
    int 0x80

fact:
    push ebp
    mov ebp, esp
    push ebx

    inc dword [calls]

    mov ebx, eax
    cmp ebx, 0
    jne .recurse
    mov eax, 1
    jmp .done

.recurse:
    cmp ebx, 1
    jne .do_recurse
    mov eax, 1
    jmp .done

.do_recurse:
    mov eax, ebx
    dec eax
    call fact
    imul eax, ebx

.done:
    pop ebx
    pop ebp
    ret

skip_ws:
    mov al, [esi]
    cmp al, ' '
    je .skip
    cmp al, 10
    je .skip
    cmp al, 13
    je .skip
    cmp al, 9
    je .skip
    ret
.skip:
    inc esi
    jmp skip_ws

parse_int:
    push ebx
    push ecx
    push edx
    xor eax, eax
    xor edx, edx
    cmp byte [esi], '-'
    jne .digits
    inc esi
    mov edx, 1
.digits:
    movzx ebx, byte [esi]
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done
    imul eax, eax, 10
    sub bl, '0'
    add eax, ebx
    inc esi
    jmp .digits
.done:
    test edx, edx
    jz .ret
    neg eax
.ret:
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
    jns .pos
    neg edx
    push edx
    mov eax, 4
    mov ebx, 1
    mov ecx, minus_sign
    mov edx, 1
    int 0x80
    pop edx
.pos:
    mov eax, edx
    lea esi, [num_buf + 15]
    mov byte [esi], 0
    dec esi
    mov ecx, 10
.digit_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    mov [esi], dl
    dec esi
    test eax, eax
    jnz .digit_loop
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
