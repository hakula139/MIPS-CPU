# Pipeline MIPS CPU

32 位流水线 MIPS 指令集 CPU，使用 SystemVerilog 编写。[^1]

## 1. MIPS 指令集

同单周期，详见[单周期实验报告](../Single-Cycle/README.md)。

## 2. 部件构成及分析

### 2.0 总览

![CPU](./assets/cpu.png)

如图所示为流水线 MIPS CPU 的整体概览，与单周期 MIPS CPU 是一样的，区别在于 CPU 核心 mips 的实现。以下将仅介绍与单周期不同的部分，其余请参见单周期实验报告。

### 2.1 mips

本流水线 CPU 的实现中，将 datapath 按照流水线的 5 个阶段划分为了 5 个模块（Fetch, Decode, Execute, Memory, Writeback），并增加了一个用于处理冲突的冲突单元（Hazard Unit）。其中各模块的作用如下 [^1]：

- Fetch：取指令阶段，从指令存储器中读取指令
- Decode：译码阶段，从寄存器文件中读取源操作数，并对指令译码以产生控制信号
- Execute：执行阶段，使用 ALU 执行计算
- Memory：存储器阶段，读写数据存储器
- Writeback：写回阶段，按需将结果写回到寄存器文件
- Hazard Unit：冲突单元，用于发现及处理数据冲突和控制冲突

方便起见，将 Fetch 阶段和 Decode 阶段之间的流水线寄存器命名为 decode_reg，并置于 Fetch 模块中，其余流水线寄存器同理。

具体模块功能分析将在下文阐述。这里 mips 的作用就是将这些模块连接起来，其中相同名称的端口即连通。除此以外特殊的几条连线如下所示：

- mips 读端口 reset, instr, readdata 分别与 rst, instr_f, read_data_m 连通
- mips 写端口 aluout, memwrite 分别与 alu_out_m, mem_write_m 连通

了解了以上连接规则后，展示 mips 的完整总览图就不那么必要。比起大而繁乱的连线总览图，直接看代码甚至都更为直观。

代码见[这里](./src/mips.sv)。

### 2.2 fetch

![Fetch stage](./assets/fetch.png)

Fetch 阶段，通过 pc_f 输出指令地址 PC 到 imem，从 imem 取得的指令通过 instr_f 读入，存储到流水线寄存器 decode_reg 中，在下一个时钟上升沿到达时从 instr_d 输出。

此外，本阶段还需要完成 PC 的更新。pc_next（新的 PC 值）的选择逻辑同单周期实验报告第 2.8 节所述，这里就不再赘述了。需要注意的是 Fetch 阶段需要用到一些 Decode 阶段的数据，也就是上一条指令计算得到的相对寻址地址 `pc_branch_d`、用于指令 jr 跳转的 `reg_data_1_d`（此时为寄存器 `$ra` 存储的地址值）、指令解析得到的 `pc_src_d`, `jump_d` 信号，用来确定 pc_next 的值。

在需要解决冲突的情况下，通过 `stall_f`, `stall_d`, `flush_d` 信号决定是否保持（stall）或清空（flush）对应流水线寄存器保存的数据，其中 `stall_f` 为 `1` 时保持当前 PC 值不更新，`stall_d` 为 `1` 时保持当前 decode_reg 的数据不更新，`flush_d` 为 `1` 时清空 decode_reg 的数据。具体这些信号在何时为何值，将在 hazard_unit 章节详细阐述。

代码见[这里](./src/pipeline_stages/fetch.sv)。

#### 2.2.1 fetch_reg

![Fetch stage pipeline register](./assets/fetch_reg.png)

Fetch 阶段流水线寄存器。结构很简单，就是将 PC 寄存器 pc_reg 封装了一下。但相较于单周期版本的 flip_flop，流水线版本做了一些调整。

代码见[这里](./src/pipeline_registers/fetch_reg.sv)。

##### 2.2.1.1 flip_flop

![Flip-flop](./assets/flip_flop.png)

这里只说与单周期版本的区别，其余请参见单周期实验报告第 2.10 节。

首先增加了一个清零信号 CLR，当 CLR 为 `1` 时，将保存的数据同步清零（RST 为异步清零），用于 `flush` 信号。尽管这里 fetch_reg 并不需要用到，但其他流水线寄存器可能会需要，这里是出于部件复用的考虑。其次增加了一个**低电平**有效的保持信号 EN，当 EN 为 `0` 时，保持数据不变。对于 fetch_reg 来说，其值即 `~stall_f`。

代码见[这里](./src/flip_flop.sv)。

#### 2.2.2 decode_reg

![Decode stage pipeline register](./assets/decode_reg.png)

Fetch 阶段和 Decode 阶段之间的流水线寄存器。中转一下 `instr` 和 `pc_plus_4`。为什么需要用触发器中转数据？因为流水线上需要同时跑多条指令（这里是 5 条），需要控制每个阶段各自只在执行一条指令。

这里 instr_reg 的 CLR 信号为 `~stall_d & flush_d`，是为了使 `stall_d` 和 `flush_d` 信号互斥，且强制 `stall_d` 的优先级更高（当 `stall_d` 为 `1` 时，`flush_d` 无效，不允许清零），否则当两者同时为 `1` 时会导致错误（因为在触发器的实现中，`flush` 的优先级更高，这将导致指令丢失）。pc_plus_4_reg 不需要清零，因此 CLR 信号恒为 `0`。

代码见[这里](./src/pipeline_registers/decode_reg.sv)。

### 2.3 decode

![Decode stage](./assets/decode.png)

图比较大，如果看不清字可以直接查看[原图](./assets/decode.png)。

Decode 阶段，读入指令 `instr_d`，由控制单元 control_unit 解析，决定各个控制信号。control_unit 相较于单周期版本没有实质变化，为了调试方便将控制信号中的无关项 `x` 都改成了 `0`。

此外，本阶段还需要完成相对寻址地址 `pc_branch_d` 的计算，然后交给下一条指令的 Fetch 阶段。

作为**静态分支预测**，本阶段新增了比较器 equal_cmp，用来比较从寄存器中读出的两个数 `src_a`, `src_b` 是否相等，其作用是将指令 beq, bne 的比较过程提前到 Decode 阶段，提前得到 `pc_src` 信号，从而提高效率。这里需要用到 Memory 阶段的数据 `alu_out_m` 以应对数据冒险，`src_a`, `src_b` 取值的选择由 `forward_a_d`, `forward_b_d` 信号控制。具体这些信号在何时为何值，将在 hazard_unit 章节详细阐述。

在实现中，将寄存器文件 reg_file 放在了 Decode 模块里，因此 Writeback 阶段的寄存器写入操作也将在这里完成。所以这里需要用到一些 Writeback 阶段的数据，也就是 `reg_write_w` 信号、目标寄存器 `write_reg_w`、写入数据 `result_w`。

在需要解决冲突的情况下，通过 `stall_e`, `flush_e` 信号决定是否保持或清空 execute_reg 保存的数据。

代码见[这里](./src/pipeline_stages/decode.sv)。

#### 2.3.1 equal_cmp

![Equality Comparer](./assets/equal_cmp.png)

32 位比较器，用于比较两个数是否相等。

使用时读入 A 和 B，若 A 和 B 相等则从 RESULT 输出 `1`。

代码见[这里](./src/utils.sv)。

#### 2.3.2 reg_file

![Register File](./assets/reg_file.png)

流水线版本中，寄存器文件调整为在时钟**下降沿**将数据写入，其余同单周期版本。

代码见[这里](./src/reg_file.sv)。

#### 2.3.3 execute_reg

![Execute stage pipeline register](./assets/execute_reg.png)

Decode 阶段和 Execute 阶段之间的流水线寄存器。中转一下 `control`, `pc_plus_4`, `reg_data_1`, `reg_data_2`, `rs`, `rt`, `rd`, `shamt`, `sign_imm`，其中：

- `control` 是控制信号 `reg_write`, `reg_dst`, `alu_src`, `alu_control`, `jump`, `mem_write`, `mem_to_reg` 的集合，这样代码写起来方便一点
- `pc_plus_4` 是 `PC + 4` 的值；由于指令 jal 在之后还需要用到这个值，因此需要继续传到 Execute 阶段
- `reg_data_1`, `reg_data_2` 是寄存器文件读出的两个值
- `rs`, `rt`, `rd`, `shamt` 分别是 `instr_d[25:21]`, `instr_d[20:16]`, `instr_d[15:11]`, `instr_d[10:6]`
- `sign_imm` 是 32 位符号扩展的 `instr_d[15:0]`

结构及原理同 decode_reg，不再赘述。

代码见[这里](./src/pipeline_registers/execute_reg.sv)。

## 3. 样例测试

### 3.1 测试结果

![Benchtest 1 ~ 3](./assets/test_1-3.png)

![Benchtest 4 ~ 6](./assets/test_4-6.png)

### 3.2 测试环境

- OS: Windows 10 Version 2004 (OS Build 19041.172)
- Using Vivado v2019.1 (64-bit)

## 4. 贡献者

- [**Hakula Chen**](https://github.com/hakula139)<[i@hakula.xyz](mailto:i@hakula.xyz)> - Fudan University

## 5. 许可协议

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](../LICENSE) file for details.

## 6. 参考资料

[^1]: David Money Harris, Sarah L. Harris: *Digital Design and Computer Architecture Second Edition*
