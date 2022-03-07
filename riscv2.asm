.data 
sseg:    .byte  0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs

.text
init:   mv x9, x0     #ones digit
        mv x10, x0    #tens digit
        li x20, 0x1100C004   #SSEG register
        li x21, 0x1100C008   #anodes
	la x23, sseg
	la x6, ISR
	csrrw x0, mtvec, x6
 	li x11, 1
	li x12, 0xF
	li x13, 10
	li x14, 5
 	
multi: 	 csrrw x0, mie, x11

        #display multiplexing function
	 li    x12, 0xF
	 sw    x12, 0(x21)     # turn off anode
	 add   x27,x23,x9 
	 lbu   x27,0(x27)  # get data
	 sb    x27, 0(x20)  #ones digit 
	 li    x12, 0x7
	 sw    x12, 0(x21)
	 call delay_ff
	 
	 li    x12, 0xF
	 sw    x12, 0(x21)     # turn off anode
	 add   x27, x23, x10 
	 lbu   x27,0(x27)   # get data
	 sb    x27, 0(x20)  # tens digit 
	 li    x12, 0xB
	 sw    x12, 0(x21)
	 call delay_ff

	 j multi


delay_ff:       
            li    x31,0xFF       # load count 
loop:       beq   x31,x0,done    # leave if done 
            addi  x31,x31,-1     # decrement count 
            j     loop           # rinse, repeat 
done:       ret                  # leave it all behind 

#Count settings, number has to be less than 50	 
carry:  
	addi x10, x10, 1 #add 1 to tens digit
	mv x9, x0        #clear ones
	beq x10, x14, clear
	ret
	 
clear:                  #clear 10s if number is 50
	mv x10, x0
	ret

##############################
ISR:    addi x9, x9, 1
	beq x9, x13, carry
        mret