# cbledger - batch ledger in COBOL
COBC     ?= cobc
COBFLAGS ?= -x -Wall -I copy

ifeq ($(OS),Windows_NT)
EXE := .exe
endif

BIN  := bin/ledger$(EXE)
MAIN := src/ledger.cbl
SUBS := $(filter-out $(MAIN),$(wildcard src/*.cbl))
CPYS := $(wildcard copy/*.cpy)

.PHONY: all clean test run check demo

all: $(BIN)

$(BIN): $(MAIN) $(SUBS) $(CPYS) | bin
	$(COBC) $(COBFLAGS) -o $@ $(MAIN) $(SUBS)

bin out:
	mkdir -p $@

run: $(BIN) | out
	$(BIN)

check:
	sh tools/check-columns.sh

demo: $(BIN) | out
	$(BIN) || true
	cat out/ledger.rpt

test: $(BIN)
	sh tests/run_tests.sh

clean:
	rm -rf bin out
