# Benchmarks for Modal Logic Decision Procedures

WIP.

Requires docker and docker-buildx.
[just](https://github.com/casey/just) is also recommended for easier running, but you can alternatively read the Justfile and copy the required commands.

## Running

The benchmark program prints a TSV line of every instance that was solved within the time limit, with the columns being:

```
solver  bench/category/instance  result  time  stdout  stderr
```

Some LWB instances take a very long time to generate, so they are cached in `src/lwb-instances/`.
You can also skip running benchmark instances with already known results by supplying existing result TSVs with the `-x` flag (files must be in `src/`).

```sh
just init
# Example: run vct for 10s on the LWB benchmarks
just bench -s vct -t 10 -b lwb | tee -a > src/results/lwb.tsv
# Example: run for longer and skip instances with already known results
just bench -s vct -t 20 -b lwb -x src/results/*.tsv | tee -a src/results/lwb2.tsv
# Example: run a solver on a specific InToHyLo problem
just solve -s coqk -t 3 ./src/lwb-instances/k_branch_n.0012.intohylo
```

Note some differences in benchmark methodology: most benchmarks are a set of problems that are all ran.
In this case, the performance of a solver should be counted as the number of instances solved.
Care should be taken with the `-x` flag to avoid skipping too many instances.

LWB has an unbounded number of problems of increasing difficulty in many categories.
In this case, we do a binary search to find the maximum instance number that can be solved within the time limit.
To have accurate numbers for the instances solved at several time steps, the LWB benchmark should be run at each time step you care about, instead of just one run at the maximum time limit.

## Patching Submodules

Most solvers and benchmarks are git submodules.
To make an edit to one of the submodules, run:

```sh
# apply existing patches if there are any (skip if none)
just apply-patch solvers/coq-tableaux

# make desired edits ...

# set the patch file to the current diff
just update-patch solvers/coq-tableaux
```

If the submodule does not have an existing patch, the patch should also be applied in the Dockerfile by copying the patch file and running the following in the submodule's directory.

```dockerfile
RUN patch -p1 < [dir].patch
```

## Acknowledgements

Most solvers/benchmarks are included as submodules, so their original repositories can be found through the submodule URL.
The others are:

- MQBF benchmarks: from [Cláudia Nalon](https://nalon.org/#software) ([direct download](https://nalon.org/software/MQBF.tgz)).
- 3CNF benchmarks: also from [Cláudia Nalon](https://nalon.org/#software) ([direct download](https://nalon.org/software/3CNF.tgz)).
- KSP solver: also from [Cláudia Nalon](https://nalon.org/#software), version 0.1.6 CADE-29 (final) ([direct download](https://nalon.org/software/ksp-0.1.6.tar.gz)).
  I have removed the `examples/` directory.
- 3CNFd{3,5}: Depth 3 and 5 3CNF benchmarks from the [QBF Reasoning for Modal Logic test set](https://gitlab.cs.man.ac.uk/j13280mh1/qbf-reasoning-for-modal-logic).
  These archives only contain the Spartacus `config2spart` and `config5spart` directories as they are the closest to InToHyLo, and we already have all other benchmarks they use.
  Their file names have also been 0-padded so that they are run in clause-variable-ratio order.
- Spartacus solver: from [Spartacus home page](https://www.ps.uni-saarland.de/spartacus/index.html) ([direct download](https://www.ps.uni-saarland.de/spartacus/spartacus-1.1.3.tar.bz2)).
