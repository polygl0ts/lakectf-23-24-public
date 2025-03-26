.PHONY: all

source:
	# -nostartfiles -nostdlib \ # no libs 
	# -mthumb \ # default to thumb to generate thumb compatible code 
	# -fomit-frame-pointer \ # to be able to use r7 everywhere 
	# -march=armv7-a \ # needed too
	# -mthumb-interwork \ # maybe needed, i don't remember
	# -ffixed-r12 \ # dont use reg r12, i need it
	arm-linux-gnueabi-gcc challenge2.c \
		-nostartfiles -nostdlib \
		-mthumb \
		-fomit-frame-pointer \
		-march=armv7-a \
		-mthumb-interwork \
		-ffixed-r12 \
		-ffixed-r11 \
		-ffixed-r10 \
		-lgcc \
		-S -o pain.S
	#sed -i "/\.syntax/d" pain.S  # remove .syntax directives
	sed -i "/\.thumb/d"  pain.S # remove .thumb directives, make all code arm
	sed -i "s/\.make_thumb/.thumb/g"  pain.S # remove .thumb directives, make all code arm
	sed -i "s/\.unmake_thumb/.arm/g"  pain.S # remove .thumb directives, make all code arm

asm:
	arm-linux-gnueabi-gcc pain.S -nostartfiles -nostdlib -o pain 
	#arm-linux-gnueabihf-strip -s pain # remove thumb detection symbols

old:
	arm-linux-gnueabihf-as -o retarded.o retarded.asm
	arm-linux-gnueabihf-ld -o retarded retarded.o
	rm retarded.o
