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

# C building
FROM ubuntu:22.04 AS build-c
RUN apt-get update && apt-get install -y cmake gcc build-essential libgoogle-perftools-dev google-perftools

# ===== Build FaCT++ =====
FROM build-c AS build-factpp

WORKDIR /build
COPY solvers/factplusplus/ .
COPY solvers/factplusplus.patch .
RUN patch -p1 < factplusplus.patch

WORKDIR /build/target
RUN cmake ..
RUN make -j$(nproc)

# ===== Build KSP =====
FROM build-c AS build-ksp

WORKDIR /build
COPY solvers/ksp-0.1.6/ .

RUN make -j$(nproc)

# ===== Build vct =====
FROM rocq/rocq-prover:9.2.0 AS build-rocq
RUN opam update && opam install -y dune menhir minisat rocq-equations

# ==== v1 ====
FROM build-rocq AS build-vct-v1
WORKDIR /build
COPY --chown=rocq:rocq solvers/vct-v1 .

RUN opam exec -- make clean && make

WORKDIR /build/src
RUN opam exec -- dune build ./bin/main.exe --release

# ==== v2 ====
FROM build-rocq AS build-vct-v2
RUN opam install -y rocq-stdpp

WORKDIR /build
COPY --chown=rocq:rocq solvers/vct-v2 .

RUN opam exec -- make clean && make

WORKDIR /build/src
RUN opam exec -- dune build ./bin/main.exe --release

# ===== Run benchmarks =====
FROM python:3.14 AS runner
RUN apt-get update && apt-get install -y google-perftools
RUN pip install lark

WORKDIR /run

COPY --from=build-cegar /build/dist/build/CEGARBox/CEGARBox .
COPY --from=build-coq /build/Verified-tableaux-for-K-KT-S4/src/_build/default/main.exe ./coqk
COPY --from=build-factpp /build/target/FaCT++/FaCT++ .
COPY --from=build-ksp /build/ksp .
COPY --from=build-vct-v1 /build/src/_build/default/bin/main.exe ./vct-v1
COPY --from=build-vct-v2 /build/src/_build/default/bin/main.exe ./vct-v2

COPY benches ./benches

# apply benchmark patches
WORKDIR ./benches/lwb
RUN patch -p1 < ../lwb.patch

WORKDIR /run/benches
RUN mkdir MQBF && tar -xf MQBF.tgz -C MQBF
# will already extract to 3CNF/
RUN tar -xf 3CNF.tgz

WORKDIR /run

COPY bench.py .
COPY owl.py .
COPY solvers/ksp-0.1.6/conf.files/ijcar-2022/cord_mlple_K.conf ./ksp.conf

CMD ["python3", "./bench.py"]
