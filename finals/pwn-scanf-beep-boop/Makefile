chal:
	gcc -Wl,-no-pie,-z,relro,-z,now -o run chal.c -I. -L.
	patchelf --set-rpath . run
	patchelf --set-interpreter ./ld-linux-x86-64.so.2 run

clean:
	rm run

all: clean chal
