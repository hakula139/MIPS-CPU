# Single-Cycle MIPS CPU

单周期 MIPS 指令集 CPU，使用 SystemVerilog 编写。

## 1. MIPS 指令集

### 1.1 实现指令集一览

```assembly
add     $rd, $rs, $rt                   # [rd] = [rs] + [rt]
sub     $rd, $rs, $rt                   # [rd] = [rs] - [rt]
and     $rd, $rs, $rt                   # [rd] = [rs] & [rt]
or      $rd, $rs, $rt                   # [rd] = [rs] | [rt]
slt     $rd, $rs, $rt                   # [rd] = [rs] < [rt] ? 1 : 0
sll     $rd, $rt, shamt                 # [rd] = [rt] << shamt
srl     $rd, $rt, shamt                 # [rd] = [rt] >> shamt
sra     $rd, $rt, shamt                 # [rd] = [rt] >>> shamt
addi    $rt, $rs, imm                   # [rt] = [rs] + SignImm
andi    $rt, $rs, imm                   # [rt] = [rs] & ZeroImm
ori     $rt, $rs, imm                   # [rt] = [rs] | ZeroImm
slti    $rt, $rs, imm                   # [rt] = [rs] < SignImm ? 1 : 0
lw      $rt, imm($rs)                   # [rt] = [Address]
sw      $rt, imm($rs)                   # [Address] = [rt]
j       label                           # PC = JTA
jal     label                           # [ra] = PC + 4, PC = JTA
jr      $rs                             # PC = [rs]
beq     $rs, $rt, label                 # if ([rs] == [rt]) PC = BTA
bne     $rs, $rt, label                 # if ([rs] != [rt]) PC = BTA
nop                                     # No operation
```

其中使用的符号释义如下：

- `[reg]`：寄存器 `$reg` 中的内容
- `imm`：I 类型指令的 16 位立即数字段
- `addr`：J 类型指令的 26 位地址字段
- `label`：指定指令地址的文本
- `SignImm`：32 位符号扩展的立即数（`= {{16{imm[15]}}, imm}`）
- `ZeroImm`：32 位 0 扩展的立即数（`= {16'b0, imm}`）
- `Address`：`[rs] + SignImm`
- `[Address]`：存储器单元 `Address` 地址中的内容
- `JTA`：跳转目标地址（`= (PC + 4)[31:28], addr, 2'b0`）
- `BTA`：分支目标地址（`= PC + 4 + (SignImm << 2)`）

### 1.2 对应机器码格式

```text
add:    0000 00ss ssst tttt dddd d--- --10 0000
sub:    0000 00ss ssst tttt dddd d--- --10 0010
and:    0000 00ss ssst tttt dddd d--- --10 0100
or:     0000 00ss ssst tttt dddd d--- --10 0101
slt:    0000 00ss ssst tttt dddd d--- --10 1010
sll:    0000 00ss ssst tttt dddd dhhh hh00 0000
srl:    0000 00-- ---t tttt dddd dhhh hh00 0010
sra:    0000 00-- ---t tttt dddd dhhh hh00 0011
addi:   0010 00ss ssst tttt iiii iiii iiii iiii
andi:   0011 00ss ssst tttt iiii iiii iiii iiii
ori:    0011 01ss ssst tttt iiii iiii iiii iiii
slti:   0010 10ss ssst tttt iiii iiii iiii iiii
lw:     1000 11ss ssst tttt iiii iiii iiii iiii
sw:     1010 11ss ssst tttt iiii iiii iiii iiii
j:      0000 10aa aaaa aaaa aaaa aaaa aaaa aaaa
jal:    0000 11aa aaaa aaaa aaaa aaaa aaaa aaaa
jr:     0000 00ss sss- ---- ---- ---- --00 1000
beq:    0001 00ss ssst tttt iiii iiii iiii iiii
bne:    0001 01ss ssst tttt iiii iiii iiii iiii
nop:    0000 0000 0000 0000 0000 0000 0000 0000
```

## 参考资料

1. David Money Harris, Sarah L. Harris: *Digital Design and Computer Architecture Second Edition*
2. [MIPS Instruction Set · MIPT-ILab/mipt-mips Wiki](https://github.com/MIPT-ILab/mipt-mips/wiki/MIPS-Instruction-Set)

## 贡献者

- [**Hakula Chen**](https://github.com/hakula139)<[i@hakula.xyz](mailto:i@hakula.xyz)> - Fudan University

## 许可协议

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](./LICENSE) file for details.
