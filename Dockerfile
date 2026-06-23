# ===== Build CEGARBox =====
FROM haskell:8.4 AS build-cegar

COPY solvers/CEGARBox /build
WORKDIR /build

RUN cabal update && cabal install --only-dependencies
RUN cabal configure
RUN cabal build

# ===== Build Coq tableaux =====
FROM coqorg/coq:8.17.1 AS build-coq
RUN opam update && opam install -y dune menhir

WORKDIR /build
COPY --chown=coq:coq solvers/coq-tableaux/ .
COPY --chown=coq:coq solvers/coq-tableaux.patch .
RUN patch -p1 < coq-tableaux.patch

WORKDIR ./Verified-tableaux-for-K-KT-S4
RUN opam exec -- make

WORKDIR ./src
RUN opam exec -- dune build ./main.exe --release

# ===== Build FaCT++ =====
FROM ubuntu:24.04 AS build-factpp
RUN apt-get update && apt-get install -y cmake gcc build-essential

WORKDIR /build
COPY solvers/factplusplus/ .
COPY solvers/factplusplus.patch .
RUN patch -p1 < factplusplus.patch

WORKDIR /build/target
ENV CXXFLAGS="-include cstdint -std=c++14"
RUN cmake ..
RUN make -j$(nproc)

# ===== Run benchmarks =====
FROM python:3.14 AS runner

WORKDIR /run

COPY --from=build-cegar /build/dist/build/CEGARBox/CEGARBox .
COPY --from=build-coq /build/Verified-tableaux-for-K-KT-S4/src/_build/default/main.exe ./coqk
COPY --from=build-factpp /build/target/FaCT++/FaCT++ .

COPY benches ./benches
COPY bench.py .

# apply benchmark patches
WORKDIR ./benches/lwb
RUN patch -p1 < ../lwb.patch
WORKDIR /run

CMD ["python3", "./bench.py"]
