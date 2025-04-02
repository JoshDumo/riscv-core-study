# If successful, it should write the value 4140 (0x102C) to address 216 (0xd8).
# RISC-V Assembly Description Address Machine Code
main: addi x2, x0, 5 # x2 = 5 0 00500113
addi x3, x0, 12 # x3 = 12 4 00C00193
addi x7, x3, -9 # x7 = (12 - 9) = 3 8 FF718393
or x4, x7, x2 # x4 = (3 OR 5) = 7 C 0023E233
and x5, x3, x4 # x5 = (12 AND 7) = 4 10 0041F2B3
add x5, x5, x4 # x5 = (4 + 7) = 11 14 004282B3
sll x5, x5, x3 # x5 = 11 << 12 = 45,056 18 003292b3
srl x5, x5, x2 # x5 = 45,056 >> 5 = 1408 1C 0022d2b3
bne x5, x3, skip # 1408 != 12: branch taken 20 00329463
sll x5, x5, x3 # shouldn't execute 24 003292b3
skip: beq x5, x7, end # shouldn't be taken 28 02728863
slt x4, x3, x4 # x4 = (12 < 7) = 0 2C 0041A233
beq x4, x0, around # should be taken 30 00020463
addi x5, x0, 0 # shouldn't execute 34 00000293
around: slt x4, x7, x2 # x4 = (3 < 5) = 1 38 0023A233
add x7, x4, x5 # x7 = (1 + 1408) = 1409 3C 005203B3
sub x7, x7, x2 # x7 = (1409 - 5) = 1404 40 402383B3
sw x7, 200(x3) # [212] = 1404 44 0c71a423
lw x2, 212(x0) # x2 = [212] = 1404 48 0d402103
add x9, x2, x5 # x9 = (1404 + 1408) = 2812 4C 005104B3
jal x3, end # jump to end, x3 = 0x54 50 008001EF
addi x2, x0, 1 # shouldn't execute 54 00100113
end: add x2, x2, x9 # x2 = (1404 + 2812) = 4216 58 00910133
addi x4, x0, -1 # x4 = 0xFFFFFFFF 5C fff00213
addi x5, x0, 1 # x5 = 1 60 00100293
addi x6, x0, 31 # x6 = 31 64 01f00313
sll x6, x5, x6 # x6 = 0x80000000 68 00629333
xor x5, x4, x6 # x5 = 0x7FFFFFFF 6C 006242b3
slt x6, x5, x4 # x6 = 0 70 0042a333
wrong: bne x6, x0, wrong # shouldn't be taken 74 00031063
xor x2, x2, x3 # x2 = 4216 ^ 0x54 = 4140 78 00314133
sw x2, 0x84(x3) # mem[216] = 0x102C = 4140 7C 0821a223
done: beq x2, x2, done # infinite loop 80 00210063