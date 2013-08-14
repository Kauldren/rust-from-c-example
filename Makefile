SRCDIR := src
OBJDIR := build/objects
ISODIR := build/isodir

RSFILES := $(shell find $(SRCDIR) -type f -name "*.rs")
SRCKERNEL := $(SRCDIR)/kernel/kernel.rc
MULTIBOOTS := $(SRCDIR)/boot/multiboot.S
OBJFILES := $(OBJDIR)/boot/multiboot.o $(OBJDIR)/kernel/kernel.o $(OBJDIR)/support/zero.o 
LD := gcc
LINKFLAGS := -m32 -T src/linker.ld -ffreestanding -O2 -nostdlib
RUSTC := rustc
RUSTFLAGS := -O --target i386-intel-linux -L $(SRCDIR)
AS := yasm
ASFLAGS = -felf
CC := clang
CCFLAGS := -ffreestanding -m32 -std=gnu99 -O2 -Wall -Wextra

all: rustos.iso

rustos.iso: $(OBJDIR)/kernel.bin
	mkdir -p $(ISODIR)/boot/grub
	cp $(OBJDIR)/kernel.bin $(ISODIR)/boot/kernel.bin
	cp $(SRCDIR)/boot/grub.cfg $(ISODIR)/boot/grub/grub.cfg
	grub-mkrescue -o rustos.iso $(ISODIR)

$(OBJDIR)/kernel.bin: $(OBJFILES) $(SRCDIR)/linker.ld
	$(LD) $(LINKFLAGS) -o $(OBJDIR)/kernel.bin $(OBJFILES)

$(OBJDIR)/kernel/kernel.o: $(SRCKERNEL) $(RSFILES)
	@mkdir -p $(@D)
	$(RUSTC) $(RUSTFLAGS) -c $< -o $@

$(OBJDIR)/boot/multiboot.o: $(SRCDIR)/boot/multiboot.S
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/support/zero.o: $(SRCDIR)/support/zero.c
	@mkdir -p $(@D)
	$(CC) $(CCFLAGS) -c $< -o $@

#main.o: main.rs
#	rustc --target i386-intel-linux -c main.rs

#multiboot.o: multiboot.S
#	yasm -felf multiboot.S -o multiboot.o

#kernel: multiboot.o main.o zero.o
#	gcc -m32 -T linker.ld -o kernel.bin -ffreestanding -O2 -nostdlib multiboot.o zero.o main.o
 
#zero.o: zero.c
#	clang -ffreestanding -m32 -target=i586-elf -std=gnu99 -ffreestanding -O2 -Wall -Wextra -c zero.c -o zero.o

clean:
	-$(RM) $(wildcard $(OBJFILES) rustos.iso $(OBJDIR)/kernel.bin)
	-$(RM) -r $(OBJDIR) $(ISODIR)
