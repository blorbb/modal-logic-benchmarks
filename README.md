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
git submodule update --init --recursive --no-fetch --depth 1
```

To make an edit in e.g., `coq-tableaux`:

```sh
cd solvers/coq-tableaux
git apply ../coq-tableaux.patch # apply existing patches (if any)
# make edits ...
git add --intent-to-add .
git diff > ../coq-tableaux.patch
```
