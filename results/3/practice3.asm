section .data
    buffer db '      ', 10
    buf_len equ $ - buffer

section .text
    global _start

_start:
    mov eax, 123456
    test eax, eax
    jnz init_conversion
    mov byte [buffer + 5], '0'
    mov ecx, buffer + 5
    mov edx, 2
    jmp print_result

init_conversion:
    mov edi, buffer + 5
    mov ebx, 10

convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz convert_loop
    inc edi
    mov ecx, edi
    mov edx, buffer + buf_len
    sub edx, edi

print_result:
    mov eax, 4
    mov ebx, 1
    int 0x80

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80
