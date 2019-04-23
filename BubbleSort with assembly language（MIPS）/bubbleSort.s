.data
    sortarray:
        .space 40
    separate:
        .asciiz " "
    line:
        .asciiz "\n"

.text
.globl main

main:
    li $v0, 30
    syscall
    
    move $t9, $a0
    
    la $t0, sortarray          #数组起始地址
    add $t1, $zero, $t0         #指向数组起始地址
    addi $t8, $t0, 40            #数组终止地址

    addi $t3, $zero, 0           #输入计数器
    inputData:
        li $v0, 5              #输入整型数据/read_int
        syscall
        sw $v0, 0($t1)         #存入数组

        addi $t1, $t1, 4     #指向数组下一个地址
        addi $t3, $t3, 1     #输入计数器加1
        slti $s0, $t3, 10        #计数器小于10，继续输入
        bnez $s0, inputData

        addi $t3, $zero, 0       #外层循环计数器i = 0
    outLoop:
        add $t1, $zero, $t0		#每次进入排序循环，让$t1指向数组起始地址
        slti $s0, $t3, 10       #i < 10，进入内层循环
        beqz $s0, print            #i > 10, 退出循环，打印排序后的数组

        addi $t4, $t3, -1       #j = i - 1
    inLoop:
        slti $s0, $t4, 0        #j < 0，退出内层循环
        bnez $s0, exitInLoop

        sll $t5, $t4, 2         #$t5 = j * 4
        add $t5, $t1, $t5		#$t5 = 数组起始地址 + j * 4
        lw $t6, 0($t5)            #$t6 = a[j]
        lw $t7, 4($t5)            #$t7 = a[j + 1]
        slt $s0, $t6, $t7      #a[j] < a[j + 1]，交换
        bnez $s0, swap
        addi $t4, $t4, -1       #j--
        j inLoop                #继续内层循环

    swap:
        sw $t6, 4($t5)            #$t6 = a[j + 1]
        sw $t7, 0($t5)            #$t7 = a[j]
        addi $t4, $t4, -1       #j--
        j inLoop                #继续内层循环

    exitInLoop:
        addi $t3, $t3, 1        #i++
        j outLoop               #进入外层循环

    print:
        lw $a0, 0($t0)            #要打印的数据存到$a0
        li $v0, 1              #系统调用/print_int
        syscall

        la $a0, separate       #打印空格
        li $v0, 4              #系统调用/print_string
        syscall

        addi $t0, $t0, 4        #数组的下一个地址
        bne $t0, $t8, print     #在数组终止地址前继续打印

        la $a0, line           #数组打印完后换行
        li $v0, 4              #系统调用/print_string
        syscall

        j exit                  #退出程序

    exit:
    	li $v0, 30
    	syscall
    	
    	move $t0, $a0
    	
    	sub $t1, $t0, $t9

    	#print time taken
    	li $v0, 1
   	move $a0, $t1
    	syscall
    	
        li $v0, 10             #系统调用/退出程序
        syscall
