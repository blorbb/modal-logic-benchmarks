# Benchmarks for Modal Logic Decision Procedures

TODO.

Requires docker and docker-buildx.

```sh
docker buildx build -t benchmarks .
```

Setting up solver builds:

Each directory is a git submodule.
We need to make some minor patches in some cases to build executables.

```sh
git submodule update --init --recursive
git apply solvers/coq-tableaux.patch --directory solvers/coq-tableaux/
```

To make an edit, first apply the patch, then make any edits, then run within `coq-tableaux`:

```sh
git add --intent-to-add .
git diff > ../coq-tableaux.patch
```
