platform = armv8

#INCLIB = /usr/local/include
#LDLIB = /usr/local/lib
OPENCV = $(shell pkg-config --cflags opencv4) $(shell pkg-config --libs opencv4)
USB =  -I libusb/ -L libusb/  
LIBSPATH = -L../lib/$(platform) -I../include
DEFS = -D_LIN -D_DEBUG 

CFLAGS = -Wall -Wno-psabi -g  -I $(INCLIB) -L $(LDLIB) $(DEFS) $(COMMON) $(LIBSPATH)  -lpthread  $(USB) -DGLIBC_20

ifeq ($(platform), armv6)
CC = arm-linux-gnueabihf-g++
AR= arm-linux-gnueabihf-ar
CFLAGS += -march=armv6
CFLAGS += -lrt
endif

ifeq ($(platform), armv7)
CC = arm-linux-gnueabihf-g++
AR= arm-linux-gnueabihf-ar
CFLAGS += -march=armv7 -mthumb
endif


ifeq ($(platform), armv8)
CC = aarch64-poky-linux-g++
AR= aarch64-poky-linux-ar
CFLAGS += -march=armv8-a+crc+simd 
endif

all:capture_RPiHQ startrails keogram sunwait-remove-precompiled sunwait

sunwait-remove-precompiled:
ifneq ("arm", $(findstring $(platform), "arm"))
	@rm -f sunwait
endif

sunwait:
		git submodule init
		git submodule update
		$(MAKE) -C sunwait-src
		cp sunwait-src/sunwait .

capture_RPiHQ:capture_RPiHQ.cpp
	$(CC)  capture_RPiHQ.cpp lib/$(platform)/libASICamera2.a -o capture_RPiHQ $(CFLAGS) $(OPENCV) -lusb-1.0

startrails:startrails.cpp
	$(CC)  startrails.cpp -o startrails $(CFLAGS) $(OPENCV)

keogram:keogram.cpp
	$(CC)  keogram.cpp -o keogram $(CFLAGS) $(OPENCV)

clean:
	rm -f capture_RPiHQ startrails keogram
#pkg-config libusb-1.0 --cflags --libs
#pkg-config opencv --cflags --libs
