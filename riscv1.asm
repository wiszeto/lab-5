PWM: 
.data 
sseg:    .byte  0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs

.text
init: li x20, 0x1100C004   #SSEG register
      li x22, 0x1100C008   #anodes
      li x21, 0x09         #last value of LUT
      la x23, sseg         #LUT address
      li x14, 0xF
      lb x19, 0(x23)       #load first value of LUT
      sb x19, 0(x20)       #turn on first number
      li x13, 0x7
      sb x13, 0(x22)
      

fade:  
       li    x10, 125000    #10ms delay
       li    x11, 125000    #10ms delay
       li    x12, 3         #number of times we delay
       mv    x30, x10       # copying number of times delayed for on
       mv    x31, x11       # copying number of times delayed for off
       call  delay
       
       li    x10, 112500   #9ms delay
       li    x11, 125000   #10ms delay
       li    x12, 4        #number of times we delay
       mv    x30, x10      # copying number of times delayed for on
       mv    x31, x11      # copying number of times delayed for off
       call  delay
       
       li    x10, 100000    #8ms delay
       li    x11, 125000    #10ms delay
       li    x12, 5         #number of times we delay
       mv    x30, x10       # copying number of times delayed for on
       mv    x31, x11       # copying number of times delayed for off
       call  delay
       
       li    x10, 87500    #7ms delay
       li    x11, 125000   #10ms delay
       li    x12, 6        #number of times we delay
       mv    x30, x10      # copying number of times delayed for on
       mv    x31, x11      # copying number of times delayed for off
       call  delay
       
       li    x10, 75000    #6ms delay
       li    x11, 125000   #10ms delay
       li    x12, 7        #number of times we delay
       mv    x30, x10      #copying number of times delayed for on
       mv    x31, x11      #copying number of times delayed for off
       call  delay
       
       li    x10, 62500    #5ms delay
       li    x11, 125000   #10ms delay
       li    x12, 8        #number of times we delay
       mv    x30, x10      #copying number of times delayed for on
       mv    x31, x11      #copying number of times delayed for off
       call  delay
       
       li    x10, 50000   #4ms delay
       li    x11, 125000  #10ms delay
       li    x12, 9       #number of times we delay
       mv    x30, x10     # copying number of times delayed for on
       mv    x31, x11     # copying number of times delayed for off
       call  delay
       
       li    x10, 37500   #3ms delay
       li    x11, 125000  #10ms delay
       li    x12, 10      #number of times we delay
       mv    x30, x10     # copying number of times delayed for on
       mv    x31, x11     # copying number of times delayed for off
       call  delay
       
       li    x10, 25000   #2ms delay
       li    x11, 125000  #10ms delay
       li    x12, 11      #number of times we delay
       mv    x30, x10     # copying number of times delayed for on
       mv    x31, x11     # copying number of times delayed for off
       call  delay
       
       li    x10, 12500   #1ms delay
       li    x11, 125000  #10ms delay
       li    x12, 12      #number of times we delay
       mv    x30, x10     #copying number of times delayed for on
       mv    x31, x11     #copying number of times delayed for off
       call  delay
       
       J admin

admin:        
       li    x10, 2         #0 ms delay
       li    x11, 500000    #14 ms delay
       li    x12, 6         #number of times we delay
       mv    x30, x10       # copying number of times delayed for on
       mv    x31, x11       # copying number of times delayed for off
       call  delay
       
       j next_num


next_num:    addi x23, x23, 1
	     lb   x19, 0(x23)            
      	     sb   x19, 0(x20) 
             beq  x19, x0, reset      #if led is at first one, reset
                    
             li    x10, 2         #0msdelay
             li    x11, 500000    #14 ms delay
             li    x12, 6         #number of times we delay
             mv    x30, x10       # copying number of times delayed for on
             mv    x31, x11       # copying number of times delayed for off
             call  delay
             
             j fade

reset:       addi x23, x23, -10
             lb x19, 0(x23)
	     sb x19, 0(x20)
             j fade

delay: addi    x30, x10, 0
       addi    x31, x11, 0

repeat: sw  x13, 0(x22) #turn on led

on_delay: addi x10, x10, -1          #decrement the delay on
          bne  x10, x0, on_delay    #delay by a0 after turn on
          
          add  x10, x10, x30          #reset the delay until loop is done
          
          sw x14, 0(x22)             #turn off led

off_delay: addi x11, x11, -1         #decrement the delay off
           bne x11, x0, off_delay   #delay by a1 after turn on       
           add x11, x0, x31		   #reset the delay until loop is done
           
           addi x12, x12, -1         #decrement the number of times we delay
           bne x12, x0, repeat       #Do it again if loop is not done
           ret                       #Done with the loop