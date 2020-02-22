include mkinc_utf8.mak
CFLAGS=-fPIC -O2
CPPFLAGS=-Iinclude
LDFLAGS=-shared
all: libstemmer.o libstemmer.so
libstemmer.o: $(snowball_sources:.c=.o)
	$(AR) -cru $@ $^
libstemmer.so: examples/stemwords.o libstemmer.o
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ $^
clean:
	rm -f libstemmer.so *.o src_c/*.o examples/*.o runtime/*.o libstemmer/*.o