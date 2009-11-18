CC = g++
CXXFLAGS = -Wall
LDFLAGS = -licuuc -licule -framework AppKit
bundle_contents = hello.app/Contents

hello_bundle: hello
	mkdir -p $(bundle_contents)/MacOS
	mkdir -p $(bundle_contents)/Resources
	echo "APPL????" > $(bundle_contents)/PkgInfo
	cp $< $(bundle_contents)/MacOS/

hello: hello.o CGFontInstance.o FontTableCache.o cmaps.o

test1: test1.o CGFontInstance.o FontTableCache.o cmaps.o

test1.o: test1.mm
	$(CC) $(CXXFLAGS) -c $^ -o $@

hello.o: hello.mm
	$(CC) $(CXXFLAGS) -c $^ -o $@

