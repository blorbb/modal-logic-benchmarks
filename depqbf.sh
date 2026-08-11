#!/bin/bash

# only print the wall time to stderr
TIMEFORMAT="%R"

time ./KtoQBF "$1" "$1.qdimacs"
# This exits with code 10 for sat, 20 for unsat.
time ./DepQBF \
  --no-sdcl --no-qbce-dynamic --no-dynamic-nenofex \
  --no-empty-formula-watching --no-trivial-falsity \
  --no-trivial-truth "$1.qdimacs"
ec=$?

if [[ "$ec" -eq 10 || "$ec" -eq 20 ]]; then
    exit 0
else
    exit "$ec"
fi
