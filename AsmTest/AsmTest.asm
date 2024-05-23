includelib <kernel32.lib>
includelib <ucrt.lib>
includelib <legacy_stdio_definitions.lib>
includelib <legacy_stdio_wide_specifiers.lib>
includelib <msvcrt.lib>
includelib <vcruntime.lib>

EXTERN printf: PROC
EXTERN scanf: PROC
EXTERN system: PROC
EXTERN ExitProcess: PROC
EXTERN _CRT_INIT: PROC

.data

room            BYTE 0
room0_content   BYTE 1, 2, 0, 0, 0
inventory       BYTE 0, 0, 0, 0, 0

content_buf     BYTE 0, 0, 0, 0, 0

item0_name      BYTE "(No item)", 0
item1_name      BYTE "Iron sword", 0
item2_name      BYTE "Healing Potion (20pt)", 0

input           BYTE ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
input_fmt       BYTE " %s", 0
dword_fmt       BYTE "%d", 0
byte_fmt        BYTE " %x", 0

loopc           DWORD 0

__byte          BYTE 0

clear_cmd       BYTE "cls", 0
menu            BYTE "AsCrawl (Health: %d)", 10, "[1] Inventory", 10, "[2] Search room", 10, "[3] Use item", 10, "[4] Pickup item", 10, 0
newline_b       BYTE 10, 0
space_b         BYTE 32, 0

input_useitem   BYTE "Type index for item: ", 0

inventory_cmd   BYTE "1", 0
search_cmd      BYTE "2", 0
useitem_cmd     BYTE "3", 0
pickup_cmd      BYTE "4", 0

health          BYTE 100

game_running    BYTE 1




.code

main PROC
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    call    _CRT_INIT ; init crt


    lea rcx,clear_cmd ; clear screen
    call system



gameloop:
    lea rcx, menu ; print menu
    movsx rdx, health
    call printf

    lea rcx,input_fmt ; ask for input
    lea rdx,input
    call scanf

    ; perform if statement for input
    mov al, input
    mov ah, inventory_cmd
    cmp al, ah
    je inputeq_1

    mov ah, search_cmd
    cmp al, ah
    je inputeq_2

    mov ah, useitem_cmd
    cmp al, ah
    je inputeq_3

    mov ah, pickup_cmd
    cmp al, ah
    je inputeq_4

    jmp inputeq_else

inputeq_1:

    mov esi,-1

inv_loop:
    inc esi

    ; print item

    mov bl,byte ptr [inventory+esi]

    movsx rax,bl
    call getitem
    call printf

    lea rcx,space_b
    call printf

    ; condition
    mov eax,LENGTHOF inventory
    dec eax

    cmp esi,eax
    jne inv_loop

    ; loop end

    lea rcx,newline_b
    call printf

    lea rcx,newline_b
    call printf

    jmp inputeq_end

inputeq_2:

    mov esi, -1

    movsx eax,room
    call getroom_content
    ;mov content_buf, al

room_loop:
    inc esi

    ; print item

    mov bl, byte ptr [content_buf+esi]
    movsx rax,bl
    call getitem
    call printf

    lea rcx,space_b
    call printf


    mov ecx,LENGTHOF content_buf
    dec ecx

    cmp esi,ecx
    jne room_loop

    ; end

    lea rcx,newline_b
    call printf

    lea rcx,newline_b
    call printf

    jmp inputeq_end

inputeq_3:

    lea rcx,input_useitem
    call printf
    
    lea rcx,byte_fmt ; ask for input
    lea rdx,__byte
    call scanf

    dec __byte

    mov al, 4
    cmp __byte,al
    jg inputeq_end

    mov al, 0
    cmp __byte,al
    jl inputeq_end

    movsx esi, __byte

    lea rcx,byte_fmt
    mov bl,byte ptr [inventory+esi]
    movsx rdx, bl
    call printf
    
    lea rcx,clear_cmd ; clear screen
    call system
    jmp inputeq_end
    
    jmp inputeq_end

inputeq_4:

    lea rcx,input_useitem
    call printf
    
    lea rcx,byte_fmt ; ask for input
    lea rdx,__byte
    call scanf

    lea rcx,clear_cmd ; clear screen
    call system

    dec __byte

    mov al, 4
    cmp __byte,al
    jg inputeq_end

    mov al, 0
    cmp __byte,al
    jl inputeq_end

    movsx esi, __byte

    ;lea rcx,byte_fmt
    mov bl,byte ptr [room0_content+esi]
    ;movsx rdx, bl
    ;call printf

    
    
    jmp add_item
    
    jmp inputeq_end

inputeq_else:
    lea rcx,clear_cmd ; clear screen
    call system
    jmp inputeq_end

inputeq_end:
    cmp game_running, 0
    jne gameloop

_add_item_loop:
    mov eax, LENGTHOF inventory
    inc ecx
    cmp ecx,eax
    jl add_item_loop
    
    jmp add_item_end

add_item_loop:
    mov dl,[inventory+ecx]
    cmp dl,0
    je add_item_success

    jmp _add_item_loop

add_item_success:
    mov [inventory+ecx],bl
    jmp add_item_end
    
add_item: ; add item id from bl
    mov eax, LENGTHOF inventory
    mov ecx, 0 ; loop counter
    jmp add_item_loop


add_item_end:
    jmp inputeq_end


call quit

main ENDP

getitem PROC ; get item name from rax and load it in rcx
    mov edx, 1
    cmp eax,edx
    je itemeq_1

    mov edx, 2
    cmp eax,edx
    je itemeq_2

    jmp itemeq_else

itemeq_1:
    lea rcx,byte ptr [item1_name]
    jmp itemeq_end

itemeq_2:
    lea rcx,byte ptr [item2_name]
    jmp itemeq_end

itemeq_else:
    lea rcx,byte ptr [item0_name]
    jmp itemeq_end

itemeq_end:
    ret

getitem ENDP


getroom_content PROC ; get room content from eax and load it in content_buf

    mov edx,0
    cmp eax,edx
    je roomeq_0

    jmp roomeq_end

roomeq_0:
    mov al, byte ptr [room0_content+0]
    mov content_buf+0,al
    mov al, byte ptr [room0_content+1]
    mov content_buf+1,al
    mov al, byte ptr [room0_content+2]
    mov content_buf+2,al
    mov al, byte ptr [room0_content+3]
    mov content_buf+3,al
    mov al, byte ptr [room0_content+4]
    mov content_buf+4,al
    jmp roomeq_end

roomeq_end:
    ret

getroom_content ENDP

quit PROC
    mov rcx,0
    call ExitProcess ; End the process.
quit ENDP


END