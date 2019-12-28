addi x1,x0,1  ; 00000001 
addi x2,x0,2  ; 00000002
addi x3,x0,16 ; 00000010
addi x4,x0,21 ; 00000015
addi x5,x0,31 ; 0000001f
sub  x6,x2,x1 ; 00000001
sub  x7,x1,x2 ; ffffffff
add  x8,x3,x2 ; 00000012 
add  x9,x1,x1 ; 00000002
and  x10,x1,x2; 00000000
and  x11,x4,x5; 00000015
or   x12,x1,x2; 00000003
or   x13,x4,x5; 0000001f
xor  x14,x1,x2; 00000003
xor  x15,x4,x5; 0000000a