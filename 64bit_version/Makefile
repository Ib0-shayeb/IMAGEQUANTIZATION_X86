EXEFILE = main
OBJECTS = main.o uquantize64.o
CCFMT = -m64
NASMFMT = -f elf64
CCOPT = -g
NASMOPT = -g -w+all

%.o: %.c
	cc $(CCFMT) $(CCOPT) -c $<

%.o: %.asm
	nasm $(NASMFMT) $(NASMOPT) -l $*.lst $<

$(EXEFILE): $(OBJECTS)
	cc $(CCFMT) $(CCOPT) -o $@ $^
	
clean:
	rm *.o *.lst $(EXEFILE)