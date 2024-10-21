ASM = nasm
LD = gcc
ASFLAGS =  -g -f elf64
LDFLAGS = -no-pie -L. -lncurses 

TARGET = othello

OBJ = othello.o

all: $(TARGET)

$(OBJ): othello.asm
	$(ASM) $(ASFLAGS) othello.asm -o $(OBJ)

$(TARGET): $(OBJ)
	$(LD) -o $(TARGET) $(OBJ) $(LDFLAGS)  
