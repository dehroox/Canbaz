# Compiler and flags
CC = clang
BASE_CFLAGS = -Wall -Wextra -Wpedantic -Werror \
			  -Wconversion -Wsign-conversion -Wnull-dereference \
			  -Wdouble-promotion -Wformat=2 -Wuninitialized \
			  -Wstrict-prototypes -Wold-style-definition \
			  -Wmissing-prototypes -Wmissing-declarations \
			  -Wmissing-variable-declarations -Wmissing-field-initializers \
			  -Wshadow -Wcast-qual -Wcast-align -Wbad-function-cast \
			  -Wwrite-strings -Wundef \
			  -Wunused-macros -Wdisabled-optimization \
			  -fstack-protector-strong -g -Iinclude \
			  -I/mingw64/include -I/mingw64/lib/clang/*/include

LDFLAGS =
CPPFLAGS =

# Directories
SRCDIR = src
INCDIR = include
BINDIR = bin

# Files
SOURCES = $(wildcard $(SRCDIR)/*.c)

# Default build type
BUILD_TYPE ?= dev

# Conditionally define directories and flags based on BUILD_TYPE
ifeq ($(BUILD_TYPE),debug)
	OBJDIR := obj/debug
	TARGET := $(BINDIR)/main-debug.exe
	CFLAGS := $(BASE_CFLAGS) -DDEBUG -O0
else ifeq ($(BUILD_TYPE),release)
	OBJDIR := obj/release
	TARGET := $(BINDIR)/main-release.exe
	CFLAGS := $(BASE_CFLAGS) -DNDEBUG -O3 -ffast-math -flto -pipe
else
	OBJDIR := obj/dev
	TARGET := $(BINDIR)/main-dev.exe
	CFLAGS := $(BASE_CFLAGS) -O2
endif

# Derive objects from sources
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

# Default target
.PHONY: all clean build debug release install help

all: build

# Create directories if they don't exist
$(OBJDIR) $(BINDIR):
	mkdir -p $@

# Link executable
$(TARGET): $(OBJECTS) | $(BINDIR)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)
	@echo "Build complete: $@"

# Compile source files
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

# Generate compile_commands.json for clangd
compile_commands.json: $(SOURCES)
	@echo "[" > $@.tmp
	@count=0; \
	for src in $(SOURCES); do \
		if [ $$count -gt 0 ]; then \
			echo "," >> $@.tmp; \
		fi; \
		obj=$(OBJDIR)/$$(basename $$src .c).o; \
		echo "  {" >> $@.tmp; \
		echo "	\"directory\": \"$$(pwd)\"," >> $@.tmp; \
		echo "	\"command\": \"$(CC) $(CFLAGS) $(CPPFLAGS) -c $$src -o $$obj\"," >> $@.tmp; \
		echo "	\"file\": \"$$src\"" >> $@.tmp; \
		echo "  }" >> $@.tmp; \
		count=$$((count + 1)); \
	done
	@echo "]" >> $@.tmp
	@mv $@.tmp $@
	@echo "Generated compile_commands.json for clangd"

# Build with compile_commands.json
build: compile_commands.json $(TARGET)

# Clean build files
clean:
	rm -rf obj bin compile_commands.json
	@echo "Clean complete"

# Very clean - remove all generated files
distclean: clean
	rm -f tags cscope.*

# Generate tags for navigation (optional)
tags: $(SOURCES)
	ctags -R $(SRCDIR) $(INCDIR)

# Help target
help:
	@echo "Available targets:"
	@echo "  all	  - Build default (dev)"
	@echo "  build	- Build with compile_commands.json"
	@echo "  debug	- Build with debug flags"
	@echo "  release  - Build with optimization flags"
	@echo "  clean	- Remove build files"
	@echo "  distclean - Remove all generated files"
	@echo "  tags	 - Generate ctags file"
	@echo "  help	 - Show this help"

# Print variables for debugging
print-vars:
	@echo "BUILD_TYPE = $(BUILD_TYPE)"
	@echo "SOURCES = $(SOURCES)"
	@echo "OBJECTS = $(OBJECTS)"
	@echo "CFLAGS = $(CFLAGS)"

# Specific build targets
debug:
	$(MAKE) BUILD_TYPE=debug

release:
	$(MAKE) BUILD_TYPE=release

.DEFAULT_GOAL := build