addi x1,  x0,  1  ; x1  = 00000001
addi x2,  x0,  3  ; x2  = 00000003
addi x3,  x0,  6  ; x3  = 00000006
loop1:
sll  x4,  x2,  x1 ; x4  = 00000006
srl  x5,  x3,  x1 ; x5  = 00000003
lw  x6,  0    (x2); x6  = 00000000
and  x7,  x2,  x4 ; x7  = 00000002
or   x8,  x2,  x4 ; x8  = 00000007
xor  x9,  x2,  x4 ; x9  = 00000005
add  x10, x1,  x1 ; x10 = 00000002
sub  x11, x10, x1 ; x11 = 00000001
blt  x4,  x5,  loop2
jal  x0, loop1
loop2:
sw   x2,  0   (x12)

