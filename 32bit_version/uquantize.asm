section .text
global uquantize

uquantize:
    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    mov esi, [ebp + 8]      ; ESI = pixels (pointer to the start of image data)
    
    mov ecx, [ebp + 12]     ; ECX = width
    mov ebx, [ebp + 16]     ; EBX = height (used as outer loop counter)
    mov edi, [ebp + 20]     ; EDI = stride

    lea ecx, [ecx + ecx*2]
    mov [ebp + 12], ecx     ; store width_in_bytes in place of width

    sub edi, ecx    ; stride - width_bytes = PADDING

    ; Dimentions check
    test ebx, ebx
    jz done
    test ecx, ecx
    jz done

    mov eax, 256
    mov ecx, [ebp + 24]     ; number of levels
    xor edx, edx
    div ecx                 ; 256 / no_levels = interval length
    mov [ebp + 16], eax     ; interval length -> [ebp + 16]
    shr eax, 1
    mov [ebp + 24], eax     ; half interval len -> [ebp + 24]

row_loop:
    mov ecx, [ebp + 12]     ; ECX = width_bytes (used as column counter)         

col_loop: 
    movzx eax, byte [esi]   ; EAX <- curent intensity for one color (r, g, or b)

quantize:
    mov dl, al

    div byte [ebp + 16]

    sub dl, ah       

    add dl, [ebp + 24]

write_back:
    mov [esi], dl

    inc esi                

col_done:
    dec ecx                 
    jnz col_loop            

row_done:
    add esi, edi            ; add the padding length to skip to the next row
    
    dec ebx
    jnz row_loop

done:
    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret