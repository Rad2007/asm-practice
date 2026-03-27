section .data
    ; I/O
    newline         db 10
    space           db ' '

    msg_min         db 'min='
    len_msg_min     equ $ - msg_min

    msg_idx         db ' index='
    len_msg_idx     equ $ - msg_idx

    msg_max         db 'max='
    len_msg_max     equ $ - msg_max

section .bss
    ; memory
    input_buffer    resb 16
    output_buffer   resb 16
    arr             resd 50
    n_value         resd 1
    min_value       resd 1
    max_value       resd 1
    min_index       resd 1
    max_index       resd 1

section .text
    global _start

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 16
    int 0x80

    ; parse
    mov esi, input_buffer
    call atoi
    mov [n_value], eax

    ; logic
    xor ecx, ecx

generate_loop:
    ; loops
    mov eax, [n_value]
    cmp ecx, eax
    jge generate_done

    ; math
    mov eax, ecx
    imul eax, 3
    add eax, 7
    mov edx, ecx
    and edx, 1
    shl edx, 2
    sub eax, edx

    ; memory
    mov [arr + ecx*4], eax

    inc ecx
    jmp generate_loop

generate_done:
    ; logic
    mov eax, [arr]
    mov [min_value], eax
    mov [max_value], eax
    mov dword [min_index], 0
    mov dword [max_index], 0

    mov ecx, 1

find_loop:
    ; loops
    mov eax, [n_value]
    cmp ecx, eax
    jge find_done

    ; memory
    mov eax, [arr + ecx*4]

    ; logic
    cmp eax, [min_value]
    jge check_max
    mov [min_value], eax
    mov [min_index], ecx

check_max:
    cmp eax, [max_value]
    jle next_find
    mov [max_value], eax
    mov [max_index], ecx

next_find:
    inc ecx
    jmp find_loop

find_done:
    xor ecx, ecx

print_array_loop:
    ; loops
    mov eax, [n_value]
    cmp ecx, eax
    jge print_array_done

    ; memory
    mov eax, [arr + ecx*4]

    ; I/O
    call print_eax

    mov eax, [n_value]
    dec eax
    cmp ecx, eax
    je no_space_after

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

no_space_after:
    inc ecx
    jmp print_array_loop

print_array_done:
    call print_newline

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_min
    mov edx, len_msg_min
    int 0x80

    mov eax, [min_value]
    call print_eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, len_msg_idx
    int 0x80

    mov eax, [min_index]
    call print_eax_newline_unsigned

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max
    mov edx, len_msg_max
    int 0x80

    mov eax, [max_value]
    call print_eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, len_msg_idx
    int 0x80

    mov eax, [max_index]
    call print_eax_newline_unsigned

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    ; parse
    xor eax, eax
    xor ebx, ebx

atoi_loop:
    ; loops
    mov bl, [esi]
    cmp bl, 10
    je atoi_done
    cmp bl, 13
    je atoi_done
    cmp bl, 0
    je atoi_done

    ; math
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp atoi_loop

atoi_done:
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

print_eax:
    call itoa_signed

    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_eax_newline_unsigned:
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
