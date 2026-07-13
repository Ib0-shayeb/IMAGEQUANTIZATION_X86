EXEFILE = main
OBJECTS = main.o uquantize.o
CCFMT = -m32
NASMFMT = -f elf32
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