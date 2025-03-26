all: libnotmalloc chal

libnotmalloc:
	gcc -g -shared -o libnotmalloc.so -fPIC notmalloc.c

chal:
	gcc -g -Wl,-z,relro,-z,now -o chal chal.c -I. -L. -lnotmalloc
	patchelf --set-rpath . chal
	patchelf --set-interpreter ./ld-linux-x86-64.so.2 chal

clean:
	rm libnotmalloc.so chal

