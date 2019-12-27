addi x1,x0,1  ; 00001 
addi x2,x0,2  ; 00010
addi x3,x0,16 ; 10000
addi x4,x0,21 ; 10101
addi x5,x0,31 ; 11111
sub  x6,x2,x1 ; 00001
sub  x7,x1,x2 ; 11111(-1)
add  x8,x3,x2 ; 10010 
add  x9,x1,x1 ; 00010
and  x10,x1,x2; 00000
and  x11,x4,x5; 10101
or   x12,x1,x2; 00011
or   x13,x4,x5; 11111
xor  x14,x1,x2; 11100
xor  x15,x4,x5; 00000