LOOP:
lw x1, 0(x0)
lw x2, 4(x0)
lw x3, 8(x0)
lw x4, 12(x0)
lw x5, 16(x0)
lw x6, 20(x0)
add x7, x1, x2
sub x8, x3, x1
or x9, x3, x1
sll x10, x1, x2
lw x11, 0(x0)
addi x12, x10, 1
jal x0,LOOP

