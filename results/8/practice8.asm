section .data
    newline db 10
    space   db ' '

section .bss
    input_buf  resb 512
    output_buf resb 16
    arr        resd 100
    idxs       resd 100
    n_val      resd 1
    target     resd 1
    count      resd 1
    first      resd 1

section .text
global _start
_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 512
    int 0x80
    mov esi, input_buf
    call atoi
    mov [n_val], eax
    xor ecx, ecx
.read_array:
    cmp ecx, [n_val]
    jge .read_target
    call skip_ws
    call atoi
    mov [arr + ecx*4], eax
    inc ecx
    jmp .read_array

.read_target:
    call skip_ws
    call atoi
    mov [target], eax
    mov dword [first], -1
    mov dword [count], 0

    xor ecx, ecx
.search_loop:
    cmp ecx, [n_val]
    jge .print_results

    mov eax, [arr + ecx*4]
    cmp eax, [target]
    jne .next

    cmp dword [first], -1
    jne .not_first
    mov [first], ecx
.not_first:
    mov eax, [count]
    mov [idxs + eax*4], ecx
    inc dword [count]

.next:
    inc ecx
    jmp .search_loop
.print_results:
    mov eax, [first]
    call print_int_nl
    mov eax, [count]
    call print_int_nl
    xor edi, edi
.print_idx:
    cmp edi, [count]
    jge .print_nl_exit

    cmp edi, 0
    je .no_space
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

.no_space:
    mov eax, [idxs + edi*4]
    call print_int

    inc edi
    jmp .print_idx

.print_nl_exit:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    xor eax, eax

.loop:
    movzx ebx, byte [esi]
    cmp bl, '0'
    jb  .done
    cmp bl, '9'
    ja  .done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp .loop
.done:
    ret

skip_ws:
    movzx ebx, byte [esi]
    cmp bl, ' '
    je  .skip
    cmp bl, 10
    je  .skip
    cmp bl, 13
    je  .skip
    ret

.skip:
    inc esi
    jmp skip_ws

itoa:
    mov edi, output_buf + 15
    mov ebx, 10
    cmp eax, 0
    jne .loop
    mov byte [edi], '0'
    mov ecx, edi
    mov edx, 1
    ret

.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .loop
    inc edi
    mov ecx, edi
    mov edx, output_buf + 16
    sub edx, ecx
    ret

print_int:
    call itoa
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_int_nl:
    call itoa
    mov eax, 4
    mov ebx, 1
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
