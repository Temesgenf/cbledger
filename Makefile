# cbledger - batch ledger in COBOL
COBC     ?= cobc
COBFLAGS ?= -x -I copy

ifeq ($(OS),Windows_NT)
EXE := .exe
endif

BIN  := bin/ledger$(EXE)
MAIN := src/ledger.cbl
SUBS := $(filter-out $(MAIN),$(wildcard src/*.cbl))
CPYS := $(wildcard copy/*.cpy)

.PHONY: all clean

all: $(BIN)

$(BIN): $(MAIN) $(SUBS) $(CPYS) | bin
	$(COBC) $(COBFLAGS) -o $@ $(MAIN) $(SUBS)

bin out:
	mkdir -p $@

clean:
	rm -rf bin out
