APP_NAME = NX_Void
SRC = main.m NXVGameView.m NXVMath.m
OBJ = $(SRC:.m=.o)

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
CC ?= clang
OBJCFLAGS ?= -Wall -Wextra -Wno-unused-parameter -std=c99 -fobjc-exceptions
LDFLAGS ?= -framework Cocoa
TARGET = $(APP_NAME).app/Contents/MacOS/$(APP_NAME)
else
CC ?= gcc
OBJCFLAGS ?= $(shell gnustep-config --objc-flags) -Wall -Wextra -std=c99
LDFLAGS ?= $(shell gnustep-config --gui-libs)
TARGET = $(APP_NAME)
endif

.PHONY: all clean run bundle

all: $(TARGET)

ifeq ($(UNAME_S),Darwin)
$(TARGET): $(OBJ) Info.plist Resources/NX_Void.icns
	mkdir -p $(APP_NAME).app/Contents/MacOS
	mkdir -p $(APP_NAME).app/Contents/Resources
	cp Info.plist $(APP_NAME).app/Contents/Info.plist
	cp Resources/NX_Void.icns $(APP_NAME).app/Contents/Resources/NX_Void.icns
	$(CC) $(OBJ) -o $@ $(LDFLAGS)

run: $(TARGET)
	open $(APP_NAME).app
else
$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $@ $(LDFLAGS)

run: $(TARGET)
	./$(TARGET)
endif

%.o: %.m
	$(CC) $(OBJCFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJ) $(APP_NAME) $(APP_NAME).app
