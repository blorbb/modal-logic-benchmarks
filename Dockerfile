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
FROM rocq/rocq-prover:9.2.0 AS build-vct
RUN opam update && opam install -y dune menhir minisat rocq-equations ppx_inline_test

WORKDIR /build
COPY --chown=rocq:rocq solvers/vct .

RUN opam exec -- make clean && make

WORKDIR /build/src
RUN opam exec -- dune build ./bin/main.exe --release


# ===== Build DepQBF + Translation =====
FROM build-c AS build-depqbf
RUN apt-get install -y wget
WORKDIR /build
COPY solvers/DepQBF .
RUN ./compile.sh

FROM build-c AS build-ktoqbf
WORKDIR /build
COPY solvers/KtoQBF .
RUN make

# ===== Build Spartacus =====
# NOTE: this cannot be ubuntu 26.04.
# Spartacus often crashes for some reason.
# But it works fine on 24.04.
# MLton doesn't exist on apt on 22.04 either.
FROM ubuntu:24.04 AS build-spartacus
RUN apt-get update && apt-get install -y mlton make

WORKDIR /build
COPY solvers/spartacus .
RUN make spartacus

# ===== Build Konclude =====
FROM ubuntu:24.04 AS build-konclude
RUN apt-get update && apt-get install -y curl unzip

WORKDIR /build
RUN curl -L -o konclude.zip "https://github.com/konclude/Konclude/releases/download/v0.7.0-1138/Konclude-v0.7.0-1138-Linux-x64-GCC-Static-Qt5.12.10.zip" \
    && unzip -j konclude.zip "Konclude-v0.7.0-1138-Linux-x64-GCC-Static-Qt5.12.10/Binaries/Konclude" \
    && rm konclude.zip

# ===== Run benchmarks =====
FROM ubuntu:24.04 AS runner
RUN apt-get update && apt-get install -y \
  python3 python3-lark \
  libgoogle-perftools-dev libgoogle-perftools4 libboost-all-dev \
  patch tar \
  libpcre3 libglib2.0-0

WORKDIR /app

COPY --from=build-cegar /build/dist/build/CEGARBox/CEGARBox .
COPY --from=build-coq /build/Verified-tableaux-for-K-KT-S4/src/_build/default/main.exe ./coqk
COPY --from=build-factpp /build/target/FaCT++/FaCT++ .
COPY --from=build-ksp /build/ksp .
COPY --from=build-vct /build/src/_build/default/bin/main.exe ./vct
COPY ./solvers/CEGARBox++/kaleidoscope ./CEGARBox++
# CEGARBox++(KSP) needs extra binaries and makes extra files, so put in its own dir
COPY ./solvers/CEGARBox++(KSP)/kaleidoscope ./cbpp/CEGARBox++KSP
COPY ./solvers/CEGARBox++(KSP)/ksp ./cbpp/ksp
COPY ./solvers/CEGARBox++(KSP)/ksp.conf ./cbpp/ksp.conf
COPY --from=build-depqbf /build/depqbf ./DepQBF
COPY --from=build-ktoqbf /build/ktoqbf ./KtoQBF
COPY --from=build-spartacus /build/spartacus ./Spartacus
COPY --from=build-konclude /build/Konclude ./Konclude

COPY benches ./benches

# apply benchmark patches
WORKDIR ./benches/lwb
RUN patch -p1 < ../lwb.patch

WORKDIR /app/benches
RUN mkdir 3CNFd3 && tar -xf 3CNFd3.tgz -C 3CNFd3
RUN mkdir 3CNFd5 && tar -xf 3CNFd5.tgz -C 3CNFd5
RUN mkdir MQBF && tar -xf MQBF.tgz -C MQBF
# will already extract to 3CNF/
RUN tar -xf 3CNF.tgz

WORKDIR /app

COPY solvers/ksp-0.1.6/conf.files/ijcar-2022/cord_mlple_K.conf ./ksp.conf

# NOTE: src needs to be mounted via docker cli.
# See Justfile.

CMD ["python3", "src/bench.py"]
