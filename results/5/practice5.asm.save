section .data
    newline db 10

section .bss
    input_buffer  resb 16
    output_buffer resb 16
    x_value       resd 1
    sum_value     resd 1
    len_value     resd 1

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 16
    int 0x80

    mov esi, input_buffer
    call atoi
    mov [x_value], eax

    mov eax, [x_value]
    xor ecx, ecx
    xor edi, edi
    mov ebx, 10

count_loop:
    cmp eax, 0
    je count_done

    xor edx, edx
    div ebx
    add edi, edx
    inc ecx
    jmp count_loop

count_done:
    mov [sum_value], edi
    mov [len_value], ecx

    mov eax, [sum_value]
    call print_eax_newline

    mov eax, [len_value]
    call print_eax_newline

    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    xor eax, eax
    xor ebx, ebx

atoi_loop:
    mov bl, [esi]
    cmp bl, 10
    je atoi_done
    cmp bl, 13
    je atoi_done
    cmp bl, 0
    je atoi_done

    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp atoi_loop

atoi_done:
    ret

itoa:
    mov edi, output_buffer + 16
    mov ebx, 10

    cmp eax, 0
    jne itoa_loop

    dec edi
    mov byte [edi], '0'
    mov ecx, edi
    mov edx, 1
    ret

itoa_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz itoa_loop

    mov ecx, edi
    mov edx, output_buffer + 16
    sub edx, ecx
    ret

print_eax_newline:
    push eax

    call itoa

    mov eax, 4
    mov ebx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    pop eax
    ret
