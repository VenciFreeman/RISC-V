addi x1,x0,10; iterations
addi x2,x0,0
addi x3,x0,0
addi x6,x0,2 
loop1:
sll  x4,x3,x6
lw   x5,0(x4)
add  x2,x2,x5;  sum 
addi x3,x3,1
bge  x3,x1,loop2
jal  x0,loop1
loop2:
sw   x2,0(x0)

