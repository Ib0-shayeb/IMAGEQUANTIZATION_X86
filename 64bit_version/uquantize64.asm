section .text
global uquantize

uquantize:
    ; Parameter Relocation & Setup
    mov r11d, edx               ; r11d = height

    lea r10d, [esi + esi*2]     ; r10d = width_bytes
    
    ; Calculate Padding
    mov esi, ecx                ; rsi = stride
    sub esi, r10d               ; rsi = stride - width_bytes = PADDING

    ; Calculate Intervals
    mov eax, 256
    xor edx, edx
    div r8d                     
    
    mov r8d, eax                ; r8d = interval
    shr eax, 1
    mov r9d, eax                ; r9d = half_interval

    ; Dimentions Checks
    test r11d, r11d             
    jz done
    test r10d, r10d             
    jz done

row_loop:
    mov ecx, r10d               ; ECX = width_bytes 

col_loop:
    movzx eax, byte [rdi]       

quantize:
    mov dl, al               
    div r8b                    

    sub dl, ah
               
    add dl, r9b                

write_back:
    mov byte [rdi], dl          
    inc rdi                     

    dec ecx                     
    jnz col_loop

row_done:
    ; RDI is currently pointing to padding bytes at the end of the row
    ; add the padding length to skip to the next row
    add rdi, rsi                
    
    dec r11d                    
    jnz row_loop

done:
    ret