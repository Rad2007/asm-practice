section .data
    ; memory
    newline         db 10

    msg_signed      db 'SIGNED: '
    len_msg_signed  equ $ - msg_signed

    msg_unsigned    db 'UNSIGNED: '
    len_msg_unsigned equ $ - msg_unsigned

    msg_max_signed  db 'max_signed(a,b): '
    len_msg_max_signed equ $ - msg_max_signed

    msg_max_unsigned db 'max_unsigned(a,b): '
    len_msg_max_unsigned equ $ - msg_max_unsigned

    txt_lt          db 'a < b'
    len_txt_lt      equ $ - txt_lt

    txt_eq          db 'a = b'
    len_txt_eq      equ $ - txt_eq

    txt_gt          db 'a > b'
    len_txt_gt      equ $ - txt_gt

section .bss
    ; memory
    input_buffer    resb 64
    output_buffer   resb 16
    a_value         resd 1
    b_value         resd 1

section .text
    global _start

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 64
    int 0x80

    ; parse
    mov esi, input_buffer
    call atoi
    mov [a_value], eax

skip_sep_1:
    ; loops
    mov bl, [esi]
    cmp bl, ' '
    je skip_space_1
    cmp bl, 9
    je skip_space_1
    cmp bl, 10
    je skip_space_1
    cmp bl, 13
    je skip_space_1
    jmp parse_second

skip_space_1:
    inc esi
    jmp skip_sep_1

parse_second:
    call atoi
    mov [b_value], eax

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_signed
    mov edx, len_msg_signed
    int 0x80

    ; logic
    call cmp_signed_print
    call print_newline

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_unsigned
    mov edx, len_msg_unsigned
    int 0x80

    ; logic
    call cmp_unsigned_print
    call print_newline

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max_signed
    mov edx, len_msg_max_signed
    int 0x80

    ; logic
    mov eax, [a_value]
    mov ebx, [b_value]
    cmp eax, ebx
    jge max_signed_a
    mov eax, ebx
max_signed_a:
    call print_eax_newline

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max_unsigned
    mov edx, len_msg_max_unsigned
    int 0x80

    ; logic
    mov eax, [a_value]
    mov ebx, [b_value]
    cmp eax, ebx
    jae max_unsigned_a
    mov eax, ebx
max_unsigned_a:
    call print_eax_unsigned_newline

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    ; parse
    xor eax, eax
    xor ebx, ebx
    xor edx, edx

    mov bl, [esi]
    cmp bl, '-'
    jne atoi_loop
    mov dl, 1
    inc esi

atoi_loop:
    ; loops
    mov bl, [esi]
    cmp bl, '0'
    jb atoi_done
    cmp bl, '9'
    ja atoi_done

    ; math
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp atoi_loop

atoi_done:
    ; logic
    cmp dl, 1
    jne atoi_ret
    neg eax
atoi_ret:
    ret

cmp_signed_print:
    ; logic
    mov eax, [a_value]
    mov ebx, [b_value]
    cmp eax, ebx
    jl signed_lt
    jg signed_gt
    je signed_eq

signed_lt:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_lt
    mov edx, len_txt_lt
    int 0x80
    ret

signed_eq:
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_eq
    mov edx, len_txt_eq
    int 0x80
    ret

signed_gt:
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_gt
    mov edx, len_txt_gt
    int 0x80
    ret

cmp_unsigned_print:
    ; logic
    mov eax, [a_value]
    mov ebx, [b_value]
    cmp eax, ebx
    jb unsigned_lt
    ja unsigned_gt
    je unsigned_eq

unsigned_lt:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_lt
    mov edx, len_txt_lt
    int 0x80
    ret

unsigned_eq:
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_eq
    mov edx, len_txt_eq
    int 0x80
    ret

unsigned_gt:
    mov eax, 4
    mov ebx, 1
    mov ecx, txt_gt
    mov edx, len_txt_gt
    int 0x80
    ret

itoa_signed:
    ; memory
    mov edi, output_buffer + 16
    xor esi, esi
    mov ebx, 10

    ; logic
    cmp eax, 0
    jne itoa_signed_check
    dec edi
    mov byte [edi], '0'
    mov ecx, edi
    mov edx, 1
    ret

itoa_signed_check:
    cmp eax, 0
    jge itoa_signed_loop
    neg eax
    mov esi, 1

itoa_signed_loop:
    ; loops
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz itoa_signed_loop

    cmp esi, 1
    jne itoa_signed_done
    dec edi
    mov byte [edi], '-'

itoa_signed_done:
    mov ecx, edi
    mov edx, output_buffer + 16
    sub edx, ecx
    ret

itoa_unsigned:
    ; memory
    mov edi, output_buffer + 16
    mov ebx, 10

    ; logic
    cmp eax, 0
    jne itoa_unsigned_loop
    dec edi
    mov byte [edi], '0'
    mov ecx, edi
    mov edx, 1
    ret

itoa_unsigned_loop:
    ; loops
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz itoa_unsigned_loop

    mov ecx, edi
    mov edx, output_buffer + 16
    sub edx, ecx
    ret

print_eax_newline:
    call itoa_signed

    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80

    call print_newline
    ret

print_eax_unsigned_newline:
    call itoa_unsigned

    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80

    call print_newline
    ret

print_newline:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
