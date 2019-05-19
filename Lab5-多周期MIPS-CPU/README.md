## <center> 实验报告 </center>

* ##### 实验要求

  * 设计实现多周期MIPS-CPU，可执行如下指令：

    * add,sub,and,or,xor,nor,slt
    * addi,andi,ori,xori,slti
    * lw,sw
    * beq,bne,j

  * 设计实现调试和显示单元DDU(Debug and Display Unit)，满足如下要求：

    * 控制CPU运行方式：
      * cont = 1时CPU连续执行指令
      * cont = 0时，每按动step一次，run输出维持一个时钟周期的脉冲，控制CPU执行一条指令
    * 查看CPU运行状态：
      * mem：1-查看MEM；0-查看RF
      * inc/dec：增加或减小待查看RF/MEM的地址addr
      * reg_data/mem_data：从RF/MEM读取的数据
      * 8位数码管显示RF/MEM的一个32位数据
      * 16位LED指示RF/MEM的地址和PC的值

  * 完成MIPS-CPU和DDU的逻辑设计和下载测试

  * 查看电路性能和资源使用情况

  * 检查仿真结果是否正确

    

* ##### 实验内容

  * 总控制单元与数据通路电路图

    * CPU：MIPS-CPU

    * MEM：DataMem和InstructionMem合并，调用IP核 Distributed Memory Generator 中的 Dual Port RAM 实现

    * DDU：调试和显示单元

      ![1557844820689](assets/1557844820689.png)

    

  * CPU

    * 数据通路

      ![1557844870050](assets/1557844870050.png)

    

    * 控制单元状态机

      ![1557844951372](assets/1557844951372.png)


* ##### 实验总结

  * 本次实验可以说是目前为止收获最多的硬件相关实验，多周期CPU设计不仅综合了前几次实验的结果，还考验对于多周期CPU原理与结构、不同类型MIPS指令的执行流程、控制单元不同阶段对应的不同信号以及存储与计算之间的相互调用的熟悉程度，本次实验大大加深了本人对于多周期MIPS-CPU的熟悉与理解。细节方面，学习了有：

    * 不同状态下控制单元产生的信号变化及其作用；
    * 加强了对于时序逻辑和组合逻辑并存的复杂情况的分析能力；
    * RAM的IP核的初始化
    * 编译预处理操作，如宏定义\`define和"文件包含"处理 `include
  * 主要反思有：
    * 状态机最好写三段式，并且一定要规范，比如三个always块对应不同的时序控制变量；

    * 控制单元状态机状态改变时有些参数要复位，比如IRWrite在译码阶段要重置为0；

    * 时钟分频时新时钟要用寄存器变量产生高/低电平，不能用组合逻辑。
