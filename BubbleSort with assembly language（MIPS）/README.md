## <center> 实验报告 </center>

实验题目：MIPS实现冒泡排序

* ##### 实验目的

  * 使用MIPS汇编语言编写一个程序实现冒泡排序，完成调试执行过程以及执行时间测量

* ##### 实验内容

  * 工具

    MARS 4.5

    

  * 参考帮助

    [MARS环境搭建、安装、使用教程](https://blog.csdn.net/y_universe/article/details/82875244)

    [MARS 系统调用（syscall）指令帮助](http://courses.missouristate.edu/KenVollmar/MARS/Help/SyscallHelp.html)

    [MIPS实现冒泡排序](<https://blog.csdn.net/qq_33559972/article/details/77801685?utm_source=blogxgwz1>)

    

  * 源代码

    ``` c
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
        li $v0, 30				   #系统调用第一次计时
        syscall
        
        move $t9, $a0			   #存入t9
        
        la $t0, sortarray          #数组起始地址
        add $t1, $zero, $t0        #指向数组起始地址
        addi $t8, $t0, 40          #数组终止地址
    
        addi $t3, $zero, 0         #输入计数器
        inputData:
            li $v0, 5              #输入整型数据/read_int
            syscall
            sw $v0, 0($t1)         #存入数组
    
            addi $t1, $t1, 4       #指向数组下一个地址
            addi $t3, $t3, 1       #输入计数器加1
            slti $s0, $t3, 10      #计数器小于10，继续输入
            bnez $s0, inputData
    
            addi $t3, $zero, 0     #外层循环计数器i = 0
        outLoop:
            add $t1, $zero, $t0	   #每次进入排序循环，让$t1指向数组起始地址
            slti $s0, $t3, 10      #i < 10，进入内层循环
            beqz $s0, print            #i > 10, 退出循环，打印排序后的数组
    
            addi $t4, $t3, -1      #j = i - 1
        inLoop:
            slti $s0, $t4, 0       #j < 0，退出内层循环
            bnez $s0, exitInLoop
    
            sll $t5, $t4, 2        #$t5 = j * 4
            add $t5, $t1, $t5	   #$t5 = 数组起始地址 + j * 4
            lw $t6, 0($t5)         #$t6 = a[j]
            lw $t7, 4($t5)         #$t7 = a[j + 1]
            slt $s0, $t6, $t7      #a[j] < a[j + 1]，交换
            bnez $s0, swap
            addi $t4, $t4, -1      #j--
            j inLoop               #继续内层循环
    
        swap:
            sw $t6, 4($t5)         #$t6 = a[j + 1]
            sw $t7, 0($t5)         #$t7 = a[j]
            addi $t4, $t4, -1      #j--
            j inLoop               #继续内层循环
    
        exitInLoop:
            addi $t3, $t3, 1       #i++
            j outLoop              #进入外层循环
    
        print:
            lw $a0, 0($t0)         #要打印的数据存到$a0
            li $v0, 1              #系统调用/print_int
            syscall
    
            la $a0, separate       #打印空格
            li $v0, 4              #系统调用/print_string
            syscall
    
            addi $t0, $t0, 4       #数组的下一个地址
            bne $t0, $t8, print    #在数组终止地址前继续打印
    
            la $a0, line           #数组打印完后换行
            li $v0, 4              
            syscall
    
            j exit                 #退出程序
    
        exit:
        	li $v0, 30			   #系统调用第二次计时
        	syscall
        	
        	move $t0, $a0		   #存入t0 
        	
        	sub $t1, $t0, $t9	   #第一次第二次计时相减（由于程序较小，运行时间较短，只用低32位）
    
        						   #print time taken
        	li $v0, 1
       		move $a0, $t1
        	syscall
        	
            li $v0, 10             #系统调用/退出程序
            syscall
    
    
    ```

* ##### 实验总结

  * 本次实验主要学习了MIPS汇编语言的语法，指令与设计方法，熟悉了常用MIPS指令与逻辑，并应用MARS软件调试编译汇编程序。细节方面，学习了有：

    * 常用MIPS汇编指令的用法；
    * 汇编语言编写程序时的逻辑；
    * MARS下的系统调用；
    * 汇编指令与硬件操作的对应关系
  * 主要反思有：
    * 汇编语言与高级语言逻辑有很大不同，需注意每个寄存器对应的值；
    * 要注意每个寄存器的位数以及地址；
    * 注意操作数的前后逻辑关系，不可弄混；
    * 注意指令类型，以及是立即数还是地址。

