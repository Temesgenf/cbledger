# Contributing

- Source is fixed-format COBOL, keep lines within 72 columns (`make check`).
- Run `make test` before sending a change. If the output of a case changes on
  purpose, regenerate it with `sh tests/run_tests.sh --update` and look at the
  diff of `tests/cases/*/expected` before committing.
- New reject reasons need a code in `copy/RETCODES.cpy`, a line in
  `docs/FILE-FORMATS.md` and a text in `RPTWRT`.
