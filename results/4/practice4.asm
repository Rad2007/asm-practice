section .data
    newline db 10

section .bss
    input_buffer  resb 16
    output_buffer resb 6

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 16
    int 0x80

    mov esi, input_buffer
    xor eax, eax
    xor ebx, ebx

parse_loop:
    mov bl, [esi]
    cmp bl, 10
    je convert_done
    cmp bl, 0
    je convert_done

    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx

    inc esi
    jmp parse_loop

convert_done:
    mov ebx, 10
    mov edi, output_buffer + 6

    cmp eax, 0
    jne convert_loop

    mov byte [output_buffer], '0'
    mov edi, output_buffer
    jmp print

convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz convert_loop

print:
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, output_buffer + 6
    sub edx, edi
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80
