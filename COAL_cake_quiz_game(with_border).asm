org 100h
bits 16

section .text

; ==============================================
; PROGRAM START
; ==============================================
start:
    ; Run shutter animation first
    call run_shutter_animation
    
    ; After shutter, show cake animation with title
    call show_cake_animation_with_title
    
    ; After cake animation, start the main menu
    mov byte [menu_selection], 1
    call clear_screen
    jmp main_loop

; ==============================================
; SHUTTER ANIMATION
; ==============================================
run_shutter_animation:
    ; Set video mode to 13h (320x200, 256 colors)
    mov ax, 0x0013
    int 0x10

    ; Set ES to VGA memory segment
    mov ax, 0xA000
    mov es, ax

    ; Fill entire screen with striped brown pattern
    call fill_screen_striped
    
    ; Display the text message
    call display_message
    
    ; Wait for space key press
    call wait_for_space
    
    ; Clear the text (by redrawing the striped pattern)
    call fill_screen_striped
    
    ; Create the shutter animation
    call shutter_animation
    
    ; Clear screen using BIOS before exiting
    mov ax, 0x0003         ; Text mode 80x25
    int 0x10
    
    ret

wait_for_space:
    mov ah, 0x00
    int 0x16
    cmp al, 0x20           ; Space key ASCII
    jne wait_for_space
    ret

display_message:
    ; Draw simple blocky text at center
    ; Position text in center
    mov di, (100 * 320) + 110  ; Center position
    
    ; Draw "PRESS SPACE TO CONTINUE"
    ; Draw 'P'
    mov si, P_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'R'
    mov si, R_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'E'
    mov si, E_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'S'
    mov si, S_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'S'
    mov si, S_data
    call draw_simple_char
    add di, 5
    
    ; Space
    add di, 5
    
    ; Draw 'S'
    mov si, S_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'P'
    mov si, P_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'A'
    mov si, A_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'C'
    mov si, C_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'E'
    mov si, E_data
    call draw_simple_char
    add di, 5
    
    ; Space
    add di, 5
    
    ; Draw 'T'
    mov si, T_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'O'
    mov si, O_data
    call draw_simple_char
    add di, 5
    
    ; Space
    add di, 5
    
    ; Draw 'C'
    mov si, C_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'O'
    mov si, O_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'N'
    mov si, N_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'T'
    mov si, T_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'I'
    mov si, I_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'N'
    mov si, N_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'U'
    mov si, U_data
    call draw_simple_char
    add di, 5
    
    ; Draw 'E'
    mov si, E_data
    call draw_simple_char
    ret

draw_simple_char:
    ; Draw 3x5 character from data at SI
    push di
    mov cx, 5
.row_loop:
    push cx
    mov al, [si]
    mov cx, 3
.pixel_loop:
    test al, 0x04
    jz .skip
    mov byte [es:di], 15  ; White color
.skip:
    shl al, 1
    inc di
    loop .pixel_loop
    pop cx
    add di, 317  ; Next line (320 - 3)
    inc si
    loop .row_loop
    pop di
    ret

fill_screen_striped:
    xor di, di
    mov bx, 0
.row_loop:
    mov ax, bx
    xor dx, dx
    mov cx, 8
    div cx
    cmp dx, 4
    jl .dark_stripe
    mov al, 42  ; Light brown
    jmp .draw_row
.dark_stripe:
    mov al, 6   ; Dark brown
.draw_row:
    mov cx, 320
    rep stosb
    inc bx
    cmp bx, 200
    jl .row_loop
    ret

shutter_animation:
    ; Start from bottom
    mov bx, 200
    
.animation_loop:
    ; Move up 2 rows at a time
    sub bx, 2
    jle .clear_screen     ; If we reach top, clear the screen
    
    ; Draw current brown rows
    call draw_brown_rows
    
    ; Small delay for animation
    call fast_delay
    
    jmp .animation_loop
    
.clear_screen:
    ; Clear the entire screen using BIOS
    mov ax, 0x0600       ; BIOS scroll up function
    mov bh, 0x00         ; Black background
    mov cx, 0x0000       ; Upper left corner (0,0)
    mov dx, 0x184F       ; Lower right corner (24,79)
    int 0x10
    
    ret

; Draw multiple rows of brown pattern at position BX
draw_brown_rows:
    pusha
    
    ; Draw two rows for animation
    mov cx, 2
.draw_rows_loop:
    push cx
    push bx
    
    ; Calculate starting position in video memory
    ; Position = (row * screen_width)
    mov ax, bx
    mov cx, 320
    mul cx
    mov di, ax
    
    ; Determine stripe color for this row
    mov ax, bx
    xor dx, dx
    mov cx, 8
    div cx
    
    cmp dx, 4
    jl .use_dark_brown
    
.use_light_brown:
    mov al, 42  ; Light brown
    jmp .draw_single_row
    
.use_dark_brown:
    mov al, 6   ; Dark brown
    
.draw_single_row:
    ; Draw one row
    mov cx, 320
    rep stosb
    
    pop bx
    pop cx
    
    ; Next row up
    dec bx
    loop .draw_rows_loop
    
    ; Clear everything below using BIOS
    call clear_below_with_bios
    
    popa
    ret

; Clear all rows below current position using BIOS
clear_below_with_bios:
    pusha
    
    ; Calculate text row position (approximate)
    ; Each character row is about 8 pixels, so convert pixel row to text row
    mov ax, bx
    mov cl, 8
    div cl              ; Divide by 8 to get approximate text row
    
    ; AH contains remainder, AL contains text row
    mov dh, al          ; Start row for BIOS clear
    inc dh              ; Start from row below current
    
    cmp dh, 25          ; If beyond screen, skip
    jge .done_clear
    
    ; Use BIOS to clear from current position to bottom
    mov ax, 0x0600      ; Scroll up function
    mov bh, 0x00        ; Black attribute
    mov ch, dh          ; Start row
    mov cl, 0           ; Start column
    mov dh, 24          ; End row (24)
    mov dl, 79          ; End column (79)
    int 0x10
    
.done_clear:
    popa
    ret

fast_delay:
    push cx
    push dx
    mov cx, 0x0000
    mov dx, 0x5000       ; Delay for animation
    mov ah, 0x86
    int 0x15
    pop dx
    pop cx
    ret

; ==============================================
; CAKE ANIMATION WITH TITLE
; ==============================================
show_cake_animation_with_title:
    ; Set video mode to text mode
    mov ax, 0003h
    int 10h
    
    ; Hide cursor
    mov ah, 01h
    mov cx, 2607h
    int 10h
    
    ; Clear screen with black background
    call clear_screen_text
    
    ; Slide the cake from right to left
    call slide_cake_with_title
    
    ; Blinking candle animation (for a while, then return to menu)
    call blink_candle_timed_with_title
    
    ret

clear_screen_text:
    ; Clear entire screen with black background
    mov ax, 0600h
    mov bh, 00h         ; Black background
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    ret

slide_cake_with_title:
    ; Start position: beyond right edge
    mov byte [cake_x], 85  ; Start from beyond right edge
    
.slide_loop:
    ; ONLY draw if cake_x is on the screen (0-79)
    ; This prevents drawing when cake is off-screen on the left
    mov al, [cake_x]
    cmp al, 79          ; Check if any part is still on screen
    jg .skip_draw       ; Skip if completely off-screen to the right
    cmp al, 0
    jl .skip_draw       ; Skip if completely off-screen to the left
    
    ; Clear the ENTIRE area where cake could be
    call clear_cake_area_full
    
    ; Draw the complete cake at current X position
    call draw_complete_cake
    
    ; Draw "CAKE CUIZ" title under the cake (only when cake is visible)
    cmp byte [cake_x], 79
    jg .skip_title
    cmp byte [cake_x], 0
    jl .skip_title
    call draw_cake_title
    
.skip_title:
.skip_draw:
    ; Wait for animation frame
    mov cx, 0
    mov dx, 35000
    mov ah, 86h
    int 15h
    
    ; Move cake left by 1 position
    dec byte [cake_x]
    
    ; Stop when cake reaches MIDDLE of screen (column 30)
    cmp byte [cake_x], 30
    jg .slide_loop      ; Continue while cake_x > 30
    
    ; Draw final cake at position 30 (centered)
    mov byte [cake_x], 30
    call clear_cake_area_full
    call draw_complete_cake
    call draw_cake_title  ; Draw final title position
    
    ret

draw_cake_title:
    ; Draw "CAKE CUIZ" under the cake (row 21-22)
    ; Position: centered under the cake (cake is 20 columns wide)
    mov al, [cake_x]
    add al, 2           ; Adjust for centering
    
    ; Row 21: "CAKE CUIZ"
    mov dh, 21
    mov dl, al
    call set_cursor
    mov si, cake_title_line
    call print_string
    
    ; Row 22: Decorative line
    mov dh, 22
    mov dl, al
    call set_cursor
    mov si, cake_title_decor
    call print_string
    ret

blink_candle_timed_with_title:
    ; Blink candle for a few seconds, then fade out title and return
    mov byte [blink_counter], 10  ; Blink 5 times (10 states)
    
.blink_loop:
    ; Turn flame ON (bright yellow)
    call flame_on
    
    ; Wait with key check
    call wait_and_check_key_cake
    cmp byte [exit_cake], 1
    je .fade_title
    
    ; Turn flame OFF (black/invisible)
    call flame_off
    
    ; Wait with key check
    call wait_and_check_key_cake
    cmp byte [exit_cake], 1
    je .fade_title
    
    ; Decrement counter and check
    dec byte [blink_counter]
    jnz .blink_loop
    
.fade_title:
    ; Fade out the title before returning
    call fade_cake_title
    
    ret

fade_cake_title:
    ; Clear the title area with animation
    pusha
    
    ; Clear title area (rows 21-22)
    mov dh, 21
    mov dl, 0
    mov cx, 2
    mov si, 80
    call clear_block
    
    ; Small delay for smooth transition
    mov cx, 1
    mov dx, 0
    mov ah, 86h
    int 15h
    
    popa
    ret

flame_on:
    ; Draw candle flame ON (bright yellow) - ABOVE the red candle
    mov dh, 6           ; Row 6 (ABOVE the red candle)
    mov dl, [cake_x]
    add dl, 9           ; Same center as candle
    mov cx, 1           ; Height: 1 row
    mov si, 2           ; Width: 2 columns
    mov bl, 0Eh         ; Color: BRIGHT YELLOW (flame ON)
    call draw_block
    ret

flame_off:
    ; Draw candle flame OFF (black - disappears)
    mov dh, 6
    mov dl, [cake_x]
    add dl, 9
    mov cx, 1
    mov si, 2
    mov bl, 00h         ; Color: BLACK (flame disappears)
    call draw_block
    ret

wait_and_check_key_cake:
    ; Wait for flame duration - SLOWER
    mov cx, 1           ; ~0.065 seconds * 16 = ~1 second
    mov dx, 0
    mov ah, 86h
    int 15h
    
    ; Check for key press
    mov ah, 01h
    int 16h
    jz .no_key          ; If no key pressed, continue
    
    ; Key was pressed - set exit flag and clear buffer
    mov ah, 00h         ; Clear the key from buffer
    int 16h
    mov byte [exit_cake], 1
    
.no_key:
    ret

; Clear FULL area where cake could be (prevents color spill)
clear_cake_area_full:
    pusha
    
    ; Clear entire rows 6-22 (candle flame to title)
    mov dh, 6           ; Start from top of candle FLAME (row 6)
    mov dl, 0           ; Start from column 0
    mov cx, 17          ; Height: 17 rows (6 to 22)
    mov si, 80          ; Width: entire screen width
    call clear_block
    
    popa
    ret

; Draw the complete cake (all three layers) at current cake_x position
draw_complete_cake:
    ; Only draw if cake_x is on screen (0-79)
    mov al, [cake_x]
    cmp al, 80
    jge .skip_draw  ; Skip if beyond right edge
    cmp al, 0
    jl .skip_draw   ; Skip if beyond left edge
    
    ; YELLOW LAYER - Bottom cake (20 columns wide, 5 rows high)
    mov dh, 15          ; Row 15 (bottom)
    mov dl, [cake_x]
    mov cx, 5           ; Height: 5 rows
    mov si, 20          ; Width: 20 columns
    mov bl, 0Eh         ; Color: YELLOW
    call draw_block
    
    ; PINK LAYER - Top cake (18 columns wide, 3 rows high)
    mov dh, 12          ; Row 12 (above yellow)
    mov dl, [cake_x]
    add dl, 1           ; Center: (20-18)/2 = 1 offset
    mov cx, 3           ; Height: 3 rows
    mov si, 18          ; Width: 18 columns
    mov bl, 0Dh         ; Color: PINK
    call draw_block
    
    ; RED LAYER - Candle (2 columns wide, 5 rows high) - Taller candle
    mov dh, 7           ; Row 7 (above pink)
    mov dl, [cake_x]
    add dl, 9           ; Center: (20-2)/2 = 9 offset
    mov cx, 5           ; Height: 5 rows (taller candle)
    mov si, 2           ; Width: 2 columns
    mov bl, 0Ch         ; Color: RED
    call draw_block
    
    ; Candle flame (initial state - OFF/black, will blink later)
    mov dh, 6           ; Row 6 (ABOVE the red candle)
    mov dl, [cake_x]
    add dl, 9           ; Same center as candle
    mov cx, 1           ; Height: 1 row
    mov si, 2           ; Width: 2 columns
    mov bl, 00h         ; Color: BLACK (flame OFF initially - invisible)
    call draw_block
    
.skip_draw:
    ret

; Draw a solid block
; DH=row, DL=col, CX=height, SI=width, BL=color
draw_block:
    pusha
    mov [temp_row], dh
    mov [temp_col], dl
    mov [temp_height], cx
    mov [temp_color], bl
    
.draw_row:
    ; Check if we're on screen
    cmp byte [temp_row], 0
    jl .next_row
    cmp byte [temp_row], 25
    jg .next_row
    
    ; Set cursor position
    mov ah, 02h
    mov bh, 00h
    mov dh, [temp_row]
    mov dl, [temp_col]
    int 10h
    
    ; Draw a row of blocks
    mov ah, 09h
    mov al, 0DBh        ; Solid block character
    mov bh, 00h
    mov bl, [temp_color]
    mov cx, si          ; Width
    int 10h
    
.next_row:
    ; Next row
    inc byte [temp_row]
    
    ; Loop for all rows
    dec word [temp_height]
    jnz .draw_row
    
    popa
    ret

; Clear a block with spaces (black background)
; DH=row, DL=col, CX=height, SI=width
clear_block:
    pusha
    mov [temp_row], dh
    mov [temp_col], dl
    mov [temp_height], cx
    
.clear_row:
    ; Set cursor position
    mov ah, 02h
    mov bh, 00h
    mov dh, [temp_row]
    mov dl, [temp_col]
    int 10h
    
    ; Clear with spaces (black on black)
    mov ah, 09h
    mov al, ' '         ; Space character
    mov bh, 00h
    mov bl, 00h         ; Black on black
    mov cx, si          ; Width
    int 10h
    
    ; Next row
    inc byte [temp_row]
    
    ; Loop for all rows
    dec word [temp_height]
    jnz .clear_row
    
    popa
    ret

; ==============================================
; MAIN PROGRAM - Menu and Quiz System
; ==============================================
main_loop:
    call draw_menu
    call handle_input
    jmp main_loop

; ==============================================
; CLEAR SCREEN (text mode version)
; ==============================================
clear_screen:
    mov ax, 0003h
    int 10h
    ret

; ==============================================
; DRAW MENU WITH COLORED BORDERS
; ==============================================
draw_menu:
    call clear_screen
    
    ; Draw colored borders around entire screen
    call draw_screen_border
    
    ; Big title - centered (corrected spelling to "CAKE CUIZ")
    mov dh, 5
    mov dl, 28  ; Centered position (80 columns - 25 chars) / 2 = 27.5 ≈ 28
    call set_cursor
    mov si, game_title_line1
    call print_string
    
    mov dh, 6
    mov dl, 28
    call set_cursor
    mov si, game_title_line2
    call print_string
    
    mov dh, 7
    mov dl, 28
    call set_cursor
    mov si, game_title_line3
    call print_string
    
    ; Draw colored border around menu area
    call draw_menu_border
    
    ; Menu options - centered
    mov dh, 10
    mov dl, 33  ; Center for "[1] Start Game" (15 chars)
    call set_cursor
    cmp byte [menu_selection], 1
    jne .opt1_norm
    mov si, menu_option1_selected
    jmp .print1
.opt1_norm:
    mov si, menu_option1
.print1:
    call print_string
    
    mov dh, 12
    mov dl, 36  ; Center for "[2] Rules" (9 chars)
    call set_cursor
    cmp byte [menu_selection], 2
    jne .opt2_norm
    mov si, menu_option2_selected
    jmp .print2
.opt2_norm:
    mov si, menu_option2
.print2:
    call print_string
    
    mov dh, 14
    mov dl, 34  ; Center for "[3] Settings" (11 chars)
    call set_cursor
    cmp byte [menu_selection], 3
    jne .opt3_norm
    mov si, menu_option3_selected
    jmp .print3
.opt3_norm:
    mov si, menu_option3
.print3:
    call print_string
    
    mov dh, 16
    mov dl, 36  ; Center for "[4] Exit" (8 chars)
    call set_cursor
    cmp byte [menu_selection], 4
    jne .opt4_norm
    mov si, menu_option4_selected
    jmp .print4
.opt4_norm:
    mov si, menu_option4
.print4:
    call print_string
    
    ret

; ==============================================
; DRAW SCREEN BORDER (YELLOW/PINK)
; ==============================================
draw_screen_border:
    pusha
    
    ; Top border (row 0, columns 0-79) - YELLOW
    mov dh, 0
    mov dl, 0
    call set_cursor
    mov ah, 09h
    mov al, 0CDh        ; Horizontal line character
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW color
    mov cx, 80
    int 10h
    
    ; Bottom border (row 24, columns 0-79) - PINK
    mov dh, 24
    mov dl, 0
    call set_cursor
    mov ah, 09h
    mov al, 0CDh
    mov bh, 00h
    mov bl, 0Dh         ; PINK color
    mov cx, 80
    int 10h
    
    ; Left border (rows 1-11, column 0) - YELLOW
    mov dh, 1
    mov dl, 0
.left_border_yellow:
    call set_cursor
    mov ah, 09h
    mov al, 0BAh        ; Vertical line character
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 12
    jl .left_border_yellow
    
    ; Left border (rows 12-23, column 0) - PINK
.left_border_pink:
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 24
    jl .left_border_pink
    
    ; Right border (rows 1-11, column 79) - YELLOW
    mov dh, 1
    mov dl, 79
.right_border_yellow:
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 12
    jl .right_border_yellow
    
    ; Right border (rows 12-23, column 79) - PINK
.right_border_pink:
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 24
    jl .right_border_pink
    
    ; Corners
    mov dh, 0
    mov dl, 0
    call set_cursor
    mov ah, 09h
    mov al, 0C9h        ; Top-left corner
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 0
    mov dl, 79
    call set_cursor
    mov ah, 09h
    mov al, 0BBh        ; Top-right corner
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 24
    mov dl, 0
    call set_cursor
    mov ah, 09h
    mov al, 0C8h        ; Bottom-left corner
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    mov dh, 24
    mov dl, 79
    call set_cursor
    mov ah, 09h
    mov al, 0BCh        ; Bottom-right corner
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    ; Draw diagonal color transition at middle
    mov dh, 12
    mov dl, 0
    call set_cursor
    mov ah, 09h
    mov al, 0B7h        ; Gradient character
    mov bh, 00h
    mov bl, 0Eh         ; Yellow on top half
    mov cx, 1
    int 10h
    
    mov dh, 12
    mov dl, 79
    call set_cursor
    mov ah, 09h
    mov al, 0B7h        ; Gradient character
    mov bh, 00h
    mov bl, 0Dh         ; Pink on bottom half
    mov cx, 1
    int 10h
    
    popa
    ret

; ==============================================
; DRAW MENU BORDER (YELLOW WITH PINK ACCENTS)
; ==============================================
draw_menu_border:
    pusha
    
    ; Menu area: rows 8-18, columns 25-55
    
    ; Top border of menu (row 8, columns 25-55) - YELLOW
    mov dh, 8
    mov dl, 25
    call set_cursor
    mov ah, 09h
    mov al, 0CDh        ; Horizontal line character
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW color
    mov cx, 31          ; 55-25+1 = 31 columns
    int 10h
    
    ; Bottom border of menu (row 18, columns 25-55) - PINK
    mov dh, 18
    mov dl, 25
    call set_cursor
    mov ah, 09h
    mov al, 0CDh
    mov bh, 00h
    mov bl, 0Dh         ; PINK color
    mov cx, 31
    int 10h
    
    ; Left border of menu (rows 9-13, column 25) - YELLOW
    mov dh, 9
.left_border_yellow:
    mov dl, 25
    call set_cursor
    mov ah, 09h
    mov al, 0BAh        ; Vertical line character
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 14
    jl .left_border_yellow
    
    ; Left border of menu (rows 14-17, column 25) - PINK
.left_border_pink:
    mov dl, 25
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 18
    jl .left_border_pink
    
    ; Right border of menu (rows 9-13, column 55) - YELLOW
    mov dh, 9
.right_border_yellow:
    mov dl, 55
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 14
    jl .right_border_yellow
    
    ; Right border of menu (rows 14-17, column 55) - PINK
.right_border_pink:
    mov dl, 55
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 18
    jl .right_border_pink
    
    ; Menu corners - YELLOW top, PINK bottom
    mov dh, 8
    mov dl, 25
    call set_cursor
    mov ah, 09h
    mov al, 0C9h        ; Top-left corner
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 8
    mov dl, 55
    call set_cursor
    mov ah, 09h
    mov al, 0BBh        ; Top-right corner
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 18
    mov dl, 25
    call set_cursor
    mov ah, 09h
    mov al, 0C8h        ; Bottom-left corner
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    mov dh, 18
    mov dl, 55
    call set_cursor
    mov ah, 09h
    mov al, 0BCh        ; Bottom-right corner
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    ; Draw decorative corners inside menu border
    mov dh, 9
    mov dl, 26
    call set_cursor
    mov ah, 09h
    mov al, 0B0h        ; Light shade
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 9
    mov dl, 54
    call set_cursor
    mov ah, 09h
    mov al, 0B0h
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 17
    mov dl, 26
    call set_cursor
    mov ah, 09h
    mov al, 0B0h
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    mov dh, 17
    mov dl, 54
    call set_cursor
    mov ah, 09h
    mov al, 0B0h
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    popa
    ret

; ==============================================
; HANDLE INPUT
; ==============================================
handle_input:
    mov ah, 00h
    int 16h
    
    cmp al, 'w'
    je .up
    cmp al, 'W'
    je .up
    cmp ah, 48h
    je .up
    
    cmp al, 's'
    je .down
    cmp al, 'S'
    je .down
    cmp ah, 50h
    je .down
    
    cmp al, 0Dh
    je .select
    
    cmp al, 1Bh
    je .exit
    
    ret

.up:
    cmp byte [menu_selection], 1
    jle .wrap_bottom
    dec byte [menu_selection]
    ret
.wrap_bottom:
    mov byte [menu_selection], 4
    ret

.down:
    cmp byte [menu_selection], 4
    jge .wrap_top
    inc byte [menu_selection]
    ret
.wrap_top:
    mov byte [menu_selection], 1
    ret

.select:
    cmp byte [menu_selection], 1
    je .start_game
    cmp byte [menu_selection], 2
    je .show_rules
    cmp byte [menu_selection], 3
    je .show_settings
    cmp byte [menu_selection], 4
    je .exit
    ret

.start_game:
    call start_game_action
    ret

.show_rules:
    call show_rules_action
    ret

.show_settings:
    call show_settings_action
    ret

.exit:
    mov ax, 4C00h
    int 21h

; ==============================================
; START GAME
; ==============================================
start_game_action:
    mov byte [score], 0
    mov byte [current_question], 1
    call run_quiz
    ret

; ==============================================
; RUN QUIZ
; ==============================================
run_quiz:
    ; Question 1
    mov si, q1_text
    mov di, q1_options
    mov al, 'b'  ; Correct answer
    call ask_question
    
    ; Question 2
    mov si, q2_text
    mov di, q2_options
    mov al, 'b'  ; Correct answer
    call ask_question
    
    ; Question 3
    mov si, q3_text
    mov di, q3_options
    mov al, 'a'  ; Correct answer
    call ask_question
    
    ; Question 4
    mov si, q4_text
    mov di, q4_options
    mov al, 'c'  ; Correct answer
    call ask_question
    
    ; Question 5
    mov si, q5_text
    mov di, q5_options
    mov al, 'a'  ; Correct answer
    call ask_question
    
    call show_final_score
    ret

; ==============================================
; ASK QUESTION - FIXED TO AVOID BORDER CUTOFF
; Input: SI = question text, DI = options array, AL = correct answer
; ==============================================
ask_question:
    pusha  ; Save all registers including AL (correct answer)
    
    call clear_screen
    call draw_quiz_border  ; Add colored border to question screens
    
    ; Show question number - MOVED AWAY FROM BORDER
    mov dh, 2
    mov dl, 3  ; Moved from 5 to 3 to avoid left border
    call set_cursor
    mov si, question_number_text
    call print_string
    mov al, [current_question]
    add al, '0'
    mov ah, 0Eh
    int 10h
    mov al, '/'
    int 10h
    mov al, '5'
    int 10h
    
    ; Show current score - MOVED AWAY FROM BORDER
    mov dh, 2
    mov dl, 63  ; Moved from 65 to 63 to avoid right border
    call set_cursor
    mov si, current_score_text
    call print_string
    mov al, [score]
    add al, '0'
    mov ah, 0Eh
    int 10h
    
    ; Display question - ADJUSTED POSITION TO AVOID BORDER CUTOFF
    popa  ; Restore registers
    pusha ; Save them again
    mov dh, 6
    mov dl, 5  ; Moved from 10 to 5 to avoid left border
    call set_cursor
    call print_string  ; SI has question text
    
    ; Draw border around question area - ADJUSTED TO FIT QUESTION
    call draw_question_border_fixed
    
    ; Display option A - ADJUSTED POSITION
    popa
    pusha
    mov si, di  ; DI has options array
    mov dh, 9
    mov dl, 10  ; Moved from 15 to 10
    call set_cursor
    call print_string
    
    ; Move to option B
.find_option_b:
    lodsb
    cmp al, 0
    jne .find_option_b
    
    mov dh, 11
    mov dl, 10  ; Moved from 15 to 10
    call set_cursor
    call print_string
    
    ; Move to option C
.find_option_c:
    lodsb
    cmp al, 0
    jne .find_option_c
    
    mov dh, 13
    mov dl, 10  ; Moved from 15 to 10
    call set_cursor
    call print_string
    
    ; Get user answer - ADJUSTED POSITION
.get_answer:
    mov dh, 15
    mov dl, 10  ; Moved from 15 to 10
    call set_cursor
    mov si, answer_prompt
    call print_string
    
    ; Wait for key
    mov ah, 00h
    int 16h
    
    ; Convert to lowercase if needed
    cmp al, 'A'
    jb .check_lower
    cmp al, 'Z'
    ja .check_lower
    add al, 32  ; Convert uppercase to lowercase
    
.check_lower:
    ; Validate input
    cmp al, 'a'
    je .valid
    cmp al, 'b'
    je .valid
    cmp al, 'c'
    je .valid
    
    ; Invalid input - ADJUSTED POSITION
    mov dh, 17
    mov dl, 10  ; Moved from 15 to 10
    call set_cursor
    mov si, invalid_msg
    call print_string
    
    ; Short delay and clear
    call delay_short
    mov dh, 17
    mov dl, 10  ; Moved from 15 to 10
    call set_cursor
    mov si, clear_line
    call print_string
    
    jmp .get_answer

.valid:
    mov [user_answer], al
    
    ; Show selection - ADJUSTED POSITION
    mov dh, 15
    mov dl, 40  ; Moved from 35 to 40 (better position)
    call set_cursor
    mov ah, 0Eh
    mov al, '['
    int 10h
    mov al, [user_answer]
    int 10h
    mov al, ']'
    int 10h
    
    ; Check answer
    popa  ; Get original AL (correct answer) from pusha
    push ax  ; Save AX
    
    mov al, [user_answer]
    pop bx  ; Get correct answer into BL
    
    cmp al, bl
    jne .wrong
    
    ; Correct answer - ADJUSTED POSITION
    mov dh, 17
    mov dl, 10  ; Moved from 15 to 10
    call set_cursor
    mov si, correct_msg
    call print_string
    inc byte [score]  ; Increase score
    jmp .next

.wrong:
    ; Wrong answer - ADJUSTED POSITION
    mov dh, 17
    mov dl, 10  ; Moved from 15 to 10
    call set_cursor
    mov si, wrong_msg
    call print_string

.next:
    ; Wait 2 seconds then auto-advance
    call delay_long
    
    ; Increment question counter
    inc byte [current_question]
    
    ret

; ==============================================
; DRAW QUIZ BORDER (YELLOW/PINK) - ADJUSTED
; ==============================================
draw_quiz_border:
    pusha
    
    ; Top border (row 0, columns 0-79) - YELLOW
    mov dh, 0
    mov dl, 0
    call set_cursor
    mov ah, 09h
    mov al, 0CDh
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 80
    int 10h
    
    ; Bottom border (row 24, columns 0-79) - PINK
    mov dh, 24
    mov dl, 0
    call set_cursor
    mov ah, 09h
    mov al, 0CDh
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 80
    int 10h
    
    ; Left border (rows 1-23, column 0) - YELLOW on top, PINK on bottom
    mov dh, 1
    mov dl, 0
.left_border_yellow:
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 12
    jl .left_border_yellow
    
.left_border_pink:
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 24
    jl .left_border_pink
    
    ; Right border (rows 1-23, column 79) - YELLOW on top, PINK on bottom
    mov dh, 1
    mov dl, 79
.right_border_yellow:
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 12
    jl .right_border_yellow
    
.right_border_pink:
    call set_cursor
    mov ah, 09h
    mov al, 0BAh
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 24
    jl .right_border_pink
    
    ; Corners
    mov dh, 0
    mov dl, 0
    call set_cursor
    mov ah, 09h
    mov al, 0C9h
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 0
    mov dl, 79
    call set_cursor
    mov ah, 09h
    mov al, 0BBh
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 24
    mov dl, 0
    call set_cursor
    mov ah, 09h
    mov al, 0C8h
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    mov dh, 24
    mov dl, 79
    call set_cursor
    mov ah, 09h
    mov al, 0BCh
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    popa
    ret

; ==============================================
; DRAW QUESTION BORDER - FIXED TO FIT QUESTIONS
; ==============================================
draw_question_border_fixed:
    pusha
    
    ; Draw a colored border around the question area (rows 5-16, columns 5-75)
    ; WIDER AREA TO FIT QUESTIONS BETTER
    
    ; Top border (row 5, columns 5-75) - YELLOW
    mov dh, 5
    mov dl, 5
    call set_cursor
    mov ah, 09h
    mov al, 0C4h        ; Single horizontal line
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW color
    mov cx, 71          ; 75-5+1 = 71 (wider)
    int 10h
    
    ; Bottom border (row 16, columns 5-75) - PINK
    mov dh, 16
    mov dl, 5
    call set_cursor
    mov ah, 09h
    mov al, 0C4h
    mov bh, 00h
    mov bl, 0Dh         ; PINK color
    mov cx, 71
    int 10h
    
    ; Left border (rows 6-10, column 5) - YELLOW
    mov dh, 6
.left_border_yellow:
    mov dl, 5
    call set_cursor
    mov ah, 09h
    mov al, 0B3h        ; Single vertical line
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 11
    jl .left_border_yellow
    
    ; Left border (rows 11-15, column 5) - PINK
.left_border_pink:
    mov dl, 5
    call set_cursor
    mov ah, 09h
    mov al, 0B3h
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 16
    jl .left_border_pink
    
    ; Right border (rows 6-10, column 75) - YELLOW
    mov dh, 6
.right_border_yellow:
    mov dl, 75
    call set_cursor
    mov ah, 09h
    mov al, 0B3h
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 11
    jl .right_border_yellow
    
    ; Right border (rows 11-15, column 75) - PINK
.right_border_pink:
    mov dl, 75
    call set_cursor
    mov ah, 09h
    mov al, 0B3h
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    inc dh
    cmp dh, 16
    jl .right_border_pink
    
    ; Corners
    mov dh, 5
    mov dl, 5
    call set_cursor
    mov ah, 09h
    mov al, 0DAh        ; Top-left
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 5
    mov dl, 75
    call set_cursor
    mov ah, 09h
    mov al, 0BFh        ; Top-right
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 1
    int 10h
    
    mov dh, 16
    mov dl, 5
    call set_cursor
    mov ah, 09h
    mov al, 0C0h        ; Bottom-left
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    mov dh, 16
    mov dl, 75
    call set_cursor
    mov ah, 09h
    mov al, 0D9h        ; Bottom-right
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 1
    int 10h
    
    popa
    ret

; ==============================================
; SHOW FINAL SCORE - ADJUSTED POSITIONS
; ==============================================
show_final_score:
    call clear_screen
    call draw_quiz_border
    
    ; Title - ADJUSTED POSITION
    mov dh, 5
    mov dl, 5  ; Moved from 10 to 5
    call set_cursor
    mov si, final_title
    call print_string
    
    ; Draw colored border around score area - ADJUSTED WIDTH
    mov dh, 7
    mov dl, 5  ; Moved from 10 to 5
    call set_cursor
    mov ah, 09h
    mov al, 0C4h
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW top
    mov cx, 70          ; Adjusted width
    int 10h
    
    ; Score display - ADJUSTED POSITION
    mov dh, 9
    mov dl, 5  ; Moved from 10 to 5
    call set_cursor
    mov si, your_score_text
    call print_string
    
    ; Display score - ADJUSTED POSITION
    mov dh, 9
    mov dl, 17  ; Moved from 22 to 17
    call set_cursor
    mov al, [score]
    add al, '0'
    mov ah, 0Eh
    int 10h
    mov al, '/'
    int 10h
    mov al, '5'
    int 10h
    
    ; Message based on score - ADJUSTED POSITION
    mov dh, 11
    mov dl, 5  ; Moved from 10 to 5
    call set_cursor
    
    mov al, [score]
    cmp al, 5
    je .excellent
    cmp al, 4
    je .very_good
    cmp al, 3
    je .good
    cmp al, 2
    je .average
    cmp al, 1
    je .poor
    jmp .very_poor

.excellent:
    mov si, msg_excellent
    jmp .show_msg
.very_good:
    mov si, msg_very_good
    jmp .show_msg
.good:
    mov si, msg_good
    jmp .show_msg
.average:
    mov si, msg_average
    jmp .show_msg
.poor:
    mov si, msg_poor
    jmp .show_msg
.very_poor:
    mov si, msg_very_poor

.show_msg:
    call print_string
    
    ; Bottom border - ADJUSTED
    mov dh, 13
    mov dl, 5  ; Moved from 10 to 5
    call set_cursor
    mov ah, 09h
    mov al, 0C4h
    mov bh, 00h
    mov bl, 0Dh         ; PINK bottom
    mov cx, 70          ; Adjusted width
    int 10h
    
    ; Return option - ADJUSTED POSITION
    mov dh, 18
    mov dl, 5  ; Moved from 10 to 5
    call set_cursor
    mov si, return_to_menu
    call print_string
    
.wait_key:
    mov ah, 00h
    int 16h
    cmp al, 0Dh  ; Enter
    je .return
    jmp .wait_key
    
.return:
    ret

; ==============================================
; SHOW RULES - CENTER ALIGNED WITH COLORED BORDER - ADJUSTED
; ==============================================
show_rules_action:
    call clear_screen
    call draw_quiz_border
    
    ; Title - centered
    mov dh, 5
    mov dl, 28  ; Center position for 80-column screen
    call set_cursor
    mov si, rules_title
    call print_string
    
    ; Draw colored border around rules text - ADJUSTED WIDTH
    mov dh, 7
    mov dl, 15  ; Moved from 20 to 15 (wider)
    call set_cursor
    mov ah, 09h
    mov al, 0C4h
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 50          ; Increased width
    int 10h
    
    ; Rules text - centered line by line - ADJUSTED POSITIONS
    mov dh, 8
    mov dl, 15  ; Moved from 20 to 15
    call set_cursor
    mov si, rules_line1
    call print_string
    
    mov dh, 9
    mov dl, 15
    call set_cursor
    mov si, rules_line2
    call print_string
    
    mov dh, 10
    mov dl, 15
    call set_cursor
    mov si, rules_line3
    call print_string
    
    mov dh, 11
    mov dl, 15
    call set_cursor
    mov si, rules_line4
    call print_string
    
    mov dh, 12
    mov dl, 15
    call set_cursor
    mov si, rules_line5
    call print_string
    
    mov dh, 13
    mov dl, 15
    call set_cursor
    mov si, rules_line6
    call print_string
    
    ; Bottom border - ADJUSTED
    mov dh, 14
    mov dl, 15  ; Moved from 20 to 15
    call set_cursor
    mov ah, 09h
    mov al, 0C4h
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 50          ; Increased width
    int 10h
    
    ; Back option - centered
    mov dh, 18
    mov dl, 25
    call set_cursor
    mov si, back_option
    call print_string
    
.wait:
    mov ah, 00h
    int 16h
    cmp al, 'b'
    je .back
    cmp al, 'B'
    je .back
    cmp al, 0Dh
    je .back
    jmp .wait
    
.back:
    ret

; ==============================================
; SHOW SETTINGS - WITH TOGGLE SOUND FEATURE (M key)
; ==============================================
show_settings_action:
    call clear_screen
    call draw_quiz_border
    
    ; Title - centered
    mov dh, 5
    mov dl, 36  ; Center position for "SETTINGS"
    call set_cursor
    mov si, settings_title
    call print_string
    
    ; Draw colored border around settings - ADJUSTED WIDTH
    mov dh, 7
    mov dl, 25
    call set_cursor
    mov ah, 09h
    mov al, 0C4h
    mov bh, 00h
    mov bl, 0Eh         ; YELLOW
    mov cx, 30
    int 10h
    
    ; Sound setting with toggle
    mov dh, 8
    mov dl, 25
    call set_cursor
    mov si, settings_sound
    call print_string
    
    ; Display current sound setting (ON/OFF)
    mov dh, 8
    mov dl, 32
    call set_cursor
    cmp byte [sound_enabled], 1
    je .sound_on
    mov si, settings_off
    jmp .show_sound
.sound_on:
    mov si, settings_on
.show_sound:
    call print_string
    
    ; Display instructions for toggling
    mov dh, 10
    mov dl, 25
    call set_cursor
    mov si, settings_toggle_inst
    call print_string
    
    ; Difficulty setting (static for now)
    mov dh, 12
    mov dl, 25
    call set_cursor
    mov si, settings_difficulty
    call print_string
    
    ; Version info
    mov dh, 14
    mov dl, 25
    call set_cursor
    mov si, settings_version
    call print_string
    
    ; Bottom border - ADJUSTED
    mov dh, 16
    mov dl, 25
    call set_cursor
    mov ah, 09h
    mov al, 0C4h
    mov bh, 00h
    mov bl, 0Dh         ; PINK
    mov cx, 30
    int 10h
    
    ; Back option - centered
    mov dh, 20
    mov dl, 25
    call set_cursor
    mov si, back_option
    call print_string
    
.wait:
    mov ah, 00h
    int 16h
    
    ; Check for 'm' to toggle sound
    cmp al, 'm'
    je .toggle_sound
    cmp al, 'M'
    je .toggle_sound
    
    ; Check for back/exit
    cmp al, 'b'
    je .back
    cmp al, 'B'
    je .back
    cmp al, 0Dh
    je .back
    jmp .wait

.toggle_sound:
    ; Toggle the sound setting (1 = ON, 0 = OFF)
    xor byte [sound_enabled], 1
    
    ; Play sound feedback if enabled
    call play_toggle_feedback
    
    ; Redraw settings screen with updated state
    jmp show_settings_action

.back:
    ret

; ==============================================
; PLAY TOGGLE FEEDBACK (beep if sound is enabled)
; ==============================================
play_toggle_feedback:
    cmp byte [sound_enabled], 0
    je .no_sound
    
    ; Play a short beep using PC speaker
    ; Enable speaker
    in al, 61h
    or al, 00000011b
    out 61h, al
    
    ; Set frequency for beep (1000 Hz)
    mov al, 0B6h
    out 43h, al
    mov ax, 1193  ; 1193180 / 1000
    out 42h, al
    mov al, ah
    out 42h, al
    
    ; Short delay
    mov cx, 2
.delay:
    push cx
    mov cx, 0FFFFh
.inner_delay:
    nop
    loop .inner_delay
    pop cx
    loop .delay
    
    ; Turn off speaker
    in al, 61h
    and al, 11111100b
    out 61h, al
    
.no_sound:
    ret

; ==============================================
; UTILITY FUNCTIONS
; ==============================================
set_cursor:
    mov ah, 02h
    mov bh, 00h
    int 10h
    ret

print_string:
    pusha
    mov ah, 0Eh
    mov bh, 0
.print_char:
    lodsb
    cmp al, 0
    je .done
    int 10h
    jmp .print_char
.done:
    popa
    ret

delay_short:
    push cx
    mov cx, 0FFFFh
.delay1:
    nop
    loop .delay1
    pop cx
    ret

delay_long:
    push cx
    mov cx, 4  ; About 2 seconds
.delay2:
    push cx
    mov cx, 0FFFFh
.delay3:
    nop
    loop .delay3
    pop cx
    loop .delay2
    pop cx
    ret

; ==============================================
; DATA SECTION
; ==============================================
section .data

; Shutter animation font data
P_data: db 0x07, 0x05, 0x07, 0x04, 0x04
R_data: db 0x07, 0x05, 0x07, 0x05, 0x05
E_data: db 0x07, 0x04, 0x07, 0x04, 0x07
S_data: db 0x07, 0x04, 0x07, 0x01, 0x07
A_data: db 0x02, 0x05, 0x07, 0x05, 0x05
C_data: db 0x07, 0x04, 0x04, 0x04, 0x07
T_data: db 0x07, 0x02, 0x02, 0x02, 0x02
O_data: db 0x07, 0x05, 0x05, 0x05, 0x07
N_data: db 0x05, 0x07, 0x07, 0x07, 0x05
I_data: db 0x07, 0x02, 0x02, 0x02, 0x02
U_data: db 0x05, 0x05, 0x05, 0x05, 0x07

; Cake animation variables
cake_x: db 0
temp_row: db 0
temp_col: db 0
temp_height: dw 0
temp_color: db 0
blink_counter: db 0
exit_cake: db 0

; Menu variables
menu_selection: db 1
score: db 0
current_question: db 1
user_answer: db 0
sound_enabled: db 1  ; 1 = ON, 0 = OFF

; Cake animation title strings
cake_title_line: db 'CAKE CUIZ', 0
cake_title_decor: db '~~~~~~~~', 0

; Game strings - CORRECTED SPELLING TO "CAKE CUIZ"
game_title_line1: db '=========================', 0
game_title_line2: db '    CAKE CUIZ GAME       ', 0
game_title_line3: db '=========================', 0

menu_option1: db '[1] Start Game', 0
menu_option1_selected: db '> [1] Start Game <', 0
menu_option2: db '[2] Rules', 0
menu_option2_selected: db '> [2] Rules <', 0
menu_option3: db '[3] Settings', 0
menu_option3_selected: db '> [3] Settings <', 0
menu_option4: db '[4] Exit', 0
menu_option4_selected: db '> [4] Exit <', 0

; Quiz strings
question_number_text: db 'Question: ', 0
current_score_text: db 'Score: ', 0
answer_prompt: db 'Enter your answer (a/b/c): ', 0
invalid_msg: db 'Invalid input! Use a, b, or c.', 0
correct_msg: db 'Correct! +1 point', 0
wrong_msg: db 'Wrong answer!', 0
clear_line: db '                             ', 0

; Questions and answers - SHORTENED TO FIT BORDERS
q1_text: db 'Main ingredient in cake?', 0
q1_options: db 'a) Salt', 0, 'b) Flour', 0, 'c) Pepper', 0

q2_text: db 'What makes cakes rise?', 0
q2_options: db 'a) Water', 0, 'b) Baking powder', 0, 'c) Sugar', 0

q3_text: db 'Which is a type of cake?', 0
q3_options: db 'a) Chocolate', 0, 'b) Pizza', 0, 'c) Salad', 0

q4_text: db 'Best baking temperature?', 0
q4_options: db 'a) 100C', 0, 'b) 200C', 0, 'c) 180C', 0

q5_text: db 'Frosting is made of?', 0
q5_options: db 'a) Sugar+butter', 0, 'b) Flour+water', 0, 'c) Salt+oil', 0

; Final score screen
final_title: db 'QUIZ COMPLETED!', 0
your_score_text: db 'Your score: ', 0
msg_excellent: db 'Excellent! Cake expert!', 0
msg_very_good: db 'Very good! Know cakes!', 0
msg_good: db 'Good! Know cake facts!', 0
msg_average: db 'Average. Bake more!', 0
msg_poor: db 'Poor. Eat more cake!', 0
msg_very_poor: db 'Very poor. Like cake?', 0
return_to_menu: db 'Press Enter to return...', 0

; Rules screen
rules_title: db 'GAME RULES', 0
rules_line1: db '1. Answer 5 cake questions', 0
rules_line2: db '2. Choose a, b, or c', 0
rules_line3: db '3. Each correct = 1 point', 0
rules_line4: db '4. W/S or arrows to navigate', 0
rules_line5: db '5. Enter to select', 0
rules_line6: db '6. Esc to exit game', 0
back_option: db 'Press B or Enter to go back', 0

; Settings screen strings (updated with toggle feature)
settings_title: db 'SETTINGS', 0
settings_sound: db 'Sound:', 0
settings_on: db '[ON]', 0
settings_off: db '[OFF]', 0
settings_toggle_inst: db 'Press M to toggle sound', 0
settings_difficulty: db 'Difficulty: Normal', 0
settings_version: db 'Version: Cake Quiz 1.0', 0

section .bss
; Reserve space for temporary variables