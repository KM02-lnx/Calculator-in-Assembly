TITLE CALCULATOR           ; Sets the title of the program to "CALCULATOR"
.model medium              ; Specifies the memory model as medium (separate code and data segments)
.386                       ; Enables 80386 instruction set
.stack                     ; Defines a stack segment with default size
.data                      ; Begins the data segment

    p1 db '$'              ; Message placeholder for first number prompt (string terminated with '$')
    p2 db '$'              ; Message placeholder for second number prompt
    p3 db '$'              ; Message placeholder for operator prompt

.code                      ; Begins code segment
m   proc                   ; Declares procedure named "m"
  
    mov ax,@data           ; Load the address of the data segment into AX
    mov ds,ax              ; Initialize DS with the value in AX to access data segment
    mov ax,0b800h          ; Load video memory segment address for color text mode into AX
    mov es,ax              ; Set ES to point to video memory
    mov di,7d0h            ; Set DI to the start offset in video memory for display
    mov ah,10100100b       ; Set AH to a custom binary pattern (could be a color/text attr)
    mov dh,ah              ; Copy AH into DH (potentially used later for color attributes)

    mov ah,6               ; BIOS scroll function (function 06h)
    mov al,0               ; Clear entire screen (number of lines to scroll = 0 means clear)
    mov bh,01111111b       ; Set attribute for cleared area (white background, black text)
    mov ch,0               ; Set upper-left row to 0
    mov cl,0               ; Set upper-left column to 0
    mov dh,24              ; Set lower-right row to 24
    mov dl,80              ; Set lower-right column to 80
    int 10h                ; Call BIOS video interrupt to perform scroll/clear operation
    
    jmp screen             ; Jump to screen label (not included in this snippet)

loopOne:                   ; Label for loop to get first digit
    
    mov ah,2               ; Set function to move cursor
    mov bh,0               ; Page number 0
    mov dh,0               ; Row 0
    mov dl,22              ; Column 22
    int 10h                ; Call BIOS to position cursor
    
    mov ah,9               ; DOS function to print string
    mov dx,offset p1       ; Load offset of p1 (prompt message) into DX
    int 21h                ; Call DOS interrupt to display message
    
    mov ah,1               ; DOS function to read character from standard input
    int 21h                ; Call DOS to get key input
    cmp al,30h             ; Compare ASCII of input with '0'
    
    jae failedFirst        ; Jump if input >= '0'
    jmp loopOne            ; Otherwise retry loop

failedFirst:               ; Label if input >= '0'
    
    cmp al,39h             ; Compare ASCII of input with '9'
    jbe passedFirst        ; Jump if input <= '9'
    jmp loopOne            ; Otherwise retry

passedFirst:               ; Input is between '0' and '9'
    sub al,30h             ; Convert ASCII to numeric value
    push ax                ; Push number to stack

loopTwo:                   ; Label for second input loop
    
    mov ah,2               ; Set function to move cursor
    mov bh,0               ; Page number 0
    mov dh,1               ; Row 1
    mov dl,22              ; Column 22
    int 10h                ; Call BIOS to position cursor
    
    mov ah,9               ; DOS function to print string
    mov dx,offset p2       ; Load offset of p2 (prompt message) into DX
    int 21h                ; Call DOS interrupt to display message
    
    mov ah,1               ; DOS function to read character
    int 21h                ; Read character input
    
    cmp al,30h             ; Compare with ASCII '0'
    jae failedSecond       ; Jump if input >= '0'
    jmp loopTwo            ; Otherwise retry

failedSecond:              ; Input >= '0'
    
    cmp al,39h             ; Compare with ASCII '9'
    jbe passedSecond       ; Jump if input <= '9'
    jmp loopTwo            ; Otherwise retry

passedSecond:              ; Input is between '0' and '9'
    
    sub al,30h             ; Convert ASCII to numeric
    push ax                ; Push number to stack

operator:                  ; Label for operator input
    
    mov ah,2               ; Move cursor
    mov bh,0               ; Page 0
    mov dh,2               ; Row 2
    mov dl,22              ; Column 22
    int 10h                ; Set cursor position
    
    mov ah,09h             ; DOS function to display string
    mov dx,offset p3       ; Address of operator prompt
    int 21h                ; Display operator prompt
    mov ah,01h             ; Function to get single character
    int 21h                ; Get operator input
    mov bl,al              ; Store input in BL
    mov ah,02h             ; Function to print character
    mov bl,al              ; Move input again to BL
    mov ah,02h             ; Function to print
    mov dl,0Ah             ; Newline character
    int 21h                ; Print newline

    cmp bl, '*'            ; Check if operator is multiplication
    je multiplication      ; Jump to multiplication if true

    cmp bl, '/'            ; Check if division
    je division            ; Jump to division

    cmp bl, '+'            ; Check if addition
    je addition            ; Jump to addition

    cmp bl, '-'            ; Check if subtraction
    je subtraction         ; Jump to subtraction

    jmp operator           ; If not a valid operator, repeat operator input

    jmp screen             ; Jump to screen (not defined in this snippet)

multiplication:            ; Multiplication routine
    pop bx                 ; Pop second number into BX
    pop ax                 ; Pop first number into AX
    
    mul bl                 ; Multiply AL by BL (result in AX)
                      
    mov bh,0               ; Clear BH (prepare for division)
    mov bl,10              ; Set BL to 10 to divide result into digits
    div bl                 ; Divide AX by 10 (AL = remainder, AH = quotient)
    
    add al,30h             ; Convert remainder to ASCII
    add ah,30h             ; Convert quotient to ASCII
    mov bl,ah              ; Move ASCII tens digit to BL
     
    push ax                ; Push result characters onto stack
    mov ah,2               ; Function to print character
    mov dl,0ah             ; Newline character
    int 21h
    mov dl,0dh             ; Carriage return
    int 21h    
    pop ax                 ; Retrieve result characters
    
    mov ah,2               ; Function to print
    mov bh,0
    mov dh,3               ; Row 3
    mov dl,22              ; Column 22
    int 10h                ; Set cursor
    
    mov ah,2               ; Print first digit
    mov dl,al
    int 21h    
    
    mov ah,2               ; Print second digit
    mov dl,bl
    int 21h     
   
    mov ah,2               ; Move to display label
    mov bh,0
    mov dh,3
    mov dl,40              ; Column 40
    int 10h

    jmp exit             ; Finish program

addition:                  ; Addition routine
     
    pop bx                 ; Pop second number into BX
    pop ax                 ; Pop first number into AX
     
    add AL,BL              ; Add the two numbers
    mov AH,0               ; Clear AH for AAA
    AAA                    ; Adjust result from BCD addition

    mov BX,AX              ; Move result into BX
    add BH,48              ; Convert tens digit to ASCII
    add BL,48              ; Convert units digit to ASCII
    
    push BX                ; Save result
    
    mov ah,2               ; Set cursor
    mov bh,0
    mov dh,3
    mov dl,22
    int 10h
    
    pop BX                 ; Retrieve result
    mov AH,2
    mov DL,BH              ; Print tens digit
    int 21H
     
    mov AH,2
    mov DL,BL              ; Print units digit
    int 21H

    mov ah,2               ; Move cursor to message location
    mov bh,0
    mov dh,3
    mov dl,40
    int 10h
    
    jmp exit             ; Finish program

subtraction:               ; Subtraction routine
   
    pop bx                 ; Pop second number into BX
    pop ax                 ; Pop first number into AX
    mov ch,0h              ; Clear CH flag (used for negative result check)
    cmp al,bl              ; Compare first and second number
    jb negative            ; Jump if result would be negative
solve:
    sub al,bl              ; Subtract second number from first
    add al,30h             ; Convert result to ASCII
    push ax                ; Save result
    mov ah,2               ; Print newline
    mov dl,0ah
    int 21h
    mov dl,0dh
    int 21h 
    mov ah,2               ; Set cursor
    mov bh,0
    mov dh,3
    mov dl,22
    int 10h    
    cmp ch,1h              ; Check if number was negative
    je symbol              ; Print minus symbol if negative
show:
    
    pop ax                 ; Get result
    mov ah,2
    mov dl,al              ; Display result
    int 21h

    mov ah,2               ; Move to message area
    mov bh,0
    mov dh,3
    mov dl,40
    int 10h
    
    jmp exit                ; Finish program

negative:                  ; Handles if subtraction result is negative
    mov dl,al              ; Save AL to DL
    mov al,bl              ; Swap AL and BL
    mov bl,dl
    mov ch,1h              ; Set CH to indicate negative result
    jmp solve              ; Go to solve

symbol:                    ; Prints minus sign
    mov dl,'-'             
    int 21h
    jmp show               ; Then show result

division:                  ; Division routine
        
    pop bx                 ; Pop divisor
    mov bh,0h              ; Clear upper byte
    cmp bx,0h              ; Check for division by zero
    je ifzero              ; Jump if zero
    pop ax                 ; Pop dividend
    mov ah,0h              ; Clear AH
    
    div bl                 ; Divide AX by BL (quotient in AL, remainder in AH)
    
    add al,30h             ; Convert quotient to ASCII
    add ah,30h             ; Convert remainder to ASCII
    mov bl,ah              ; Save remainder in BL

    mov ah,2               ; Move to display quotient
    mov bh,0
    mov dh,3
    mov dl,22
    int 10h
 
    mov ah,2               ; Print quotient value
    mov dl,al
    int 21h
    
    mov ah,2               ; Move to display remainder
    mov bh,0
    mov dh,3
    mov dl,26
    int 10h
    
    mov ah,2               ; Print remainder
    mov dl,bl
    int 21h

    mov ah,2               ; Move cursor to display message
    mov bh,0
    mov dh,3
    mov dl,40
    int 10h

    jmp exit                ; Finish program

ifzero:
    ; Move cursor to row 3, column 22
    mov ah,2
    mov bh,0
    mov dh,3
    mov dl,22
    int 10h

    jmp exit                ; Finish program

screen:
    ; The following blocks draw the layout of the calculator screen
    ; Draw button area using BIOS interrupt with color attributes

    ; Display area
    mov al,0
    mov bh,00001111b ; Color
    mov ch,0 ; Up row
    mov cl,22 ; Left column
    mov dh,3 ; Down row
    mov dl,58 ; Right column
    int 10h

    ; Number 1 area
    mov al,0
    mov bh,00001111b
    mov ch,5 
    mov cl,22 
    mov dh,7 
    mov dl,32 
    int 10h

    ; Number 2 area
    mov al,0
    mov bh,00001111b  
    mov ch,5 
    mov cl,35 
    mov dh,7 
    mov dl,45 
    int 10h

    ; Number 3 area
    mov al,0
    mov bh,00001111b  
    mov ch,5 
    mov cl,48 
    mov dh,7 
    mov dl,58 
    int 10h

    ; Number 4 area
    mov al,0
    mov bh,00001111b
    mov ch,9 
    mov cl,22 
    mov dh,11 
    mov dl,32 
    int 10h

    ; Number 5 area
    mov al,0
    mov bh,00001111b  
    mov ch,9 
    mov cl,35 
    mov dh,11 
    mov dl,45 
    int 10h

    ; Number 6 area
    mov al,0
    mov bh,00001111b   
    mov ch,9 
    mov cl,48
    mov dh,11 
    mov dl,58 
    int 10h

    ; Number 7 area
    mov al,0
    mov bh,00001111b
    mov ch,13 
    mov cl,22 
    mov dh,15 
    mov dl,32 
    int 10h

    ; Number 8 area
    mov al,0
    mov bh,00001111b   
    mov ch,13 
    mov cl,35 
    mov dh,15 
    mov dl,45 
    int 10h

    ; Number 9 area
    mov al,0
    mov bh,00001111b   
    mov ch,13 
    mov cl,48 
    mov dh,15 
    mov dl,58 
    int 10h

    ; Plus area
    mov al,0
    mov bh,00001111b
    mov ch,17 
    mov cl,22 
    mov dh,19 
    mov dl,32 
    int 10h

    ; Number 0 area
    mov al,0
    mov bh,00001111b  
    mov ch,17 
    mov cl,35 
    mov dh,19 
    mov dl,45 
    int 10h

    ; Multiply area
    mov al,0
    mov bh,00001111b  
    mov ch,17 
    mov cl,48 
    mov dh,19 
    mov dl,58 
    int 10h

    ; Minus area
    mov al,0
    mov bh,00001111b
    mov ch,21 
    mov cl,22 
    mov dh,23 
    mov dl,32 
    int 10h

    ; Equal area
    mov al,0
    mov bh,00001111b  
    mov ch,21
    mov cl,35 
    mov dh,23 
    mov dl,45
    int 10h

    ; Divide area
    mov al,0
    mov bh,00001111b  
    mov ch,21 
    mov cl,48 
    mov dh,23 
    mov dl,58 
    int 10h

    ; Display '1' at row 6, column 27
    mov ah,2   
    mov bh,0
    mov dh,6
    mov dl,27
    int 10h
    mov ah,2    
    mov dl,31h
    int 21h

    ; Display '2' at row 6, column 40
    mov ah,2  
    mov bh,0
    mov dh,6
    mov dl,40
    int 10h
    mov ah,2    
    mov dl,32h
    int 21h

    ; Display '3' at row 6, column 53
    mov ah,2   
    mov bh,0
    mov dh,6
    mov dl,53
    int 10h
    mov ah,2    
    mov dl,33h
    int 21h

    ; Display '4' at row 10, column 27
    mov ah,2   
    mov bh,0
    mov dh,10
    mov dl,27
    int 10h
    mov ah,2     
    mov dl,34h
    int 21h

    ; Display '5' at row 10, column 40
    mov ah,2  
    mov bh,0
    mov dh,10
    mov dl,40
    int 10h
    mov ah,2    
    mov dl,35h
    int 21h

    ; Display '6' at row 10, column 53
    mov ah,2   
    mov bh,0
    mov dh,10
    mov dl,53
    int 10h
    mov ah,2    
    mov dl,36h
    int 21h

    ; Display '7' at row 14, column 27
    mov ah,2   
    mov bh,0
    mov dh,14
    mov dl,27
    int 10h
    mov ah,2    
    mov dl,37h
    int 21h  

    ; Display '8' at row 14, column 40
    mov ah,2  
    mov bh,0
    mov dh,14
    mov dl,40
    int 10h
    mov ah,2    
    mov dl,38h
    int 21h

    ; Display '9' at row 14, column 53
    mov ah,2   
    mov bh,0
    mov dh,14
    mov dl,53
    int 10h
    mov ah,2    
    mov dl,39h
    int 21h 

    ; Display '+' at row 18, column 27
    mov ah,2   
    mov bh,0
    mov dh,18
    mov dl,27
    int 10h
    mov ah,2     
    mov dl,2bh
    int 21h 

    ; Display '0' at row 18, column 40
    mov ah,2  
    mov bh,0
    mov dh,18
    mov dl,40
    int 10h
    mov ah,2     
    mov dl,30h
    int 21h 

    ; Display '*' at row 18, column 53
    mov ah,2   
    mov bh,0
    mov dh,18
    mov dl,53
    int 10h
    mov ah,2    
    mov dl,2ah
    int 21h 

    ; Display '-' at row 22, column 27
    mov ah,2   
    mov bh,0
    mov dh,22
    mov dl,27
    int 10h
    mov ah,2    
    mov dl,2dh
    int 21h 

    ; Display '=' at row 22, column 40
    mov ah,2   
    mov bh,0
    mov dh,22
    mov dl,40
    int 10h
    mov ah,2    
    mov dl,3dh
    int 21h 

    ; Display '/' at row 22, column 53
    mov ah,2   
    mov bh,0
    mov dh,22
    mov dl,53
    int 10h
    mov ah,2    
    mov dl,2fh
    int 21h

    ; Jump to loopOne to get new inputs
    jmp loopOne
     
exit:   
    ; Exit program using DOS interrupt
    mov ah,4ch
    int 21h
        
m   endp   ; End of main procedure
end m      ; End of program