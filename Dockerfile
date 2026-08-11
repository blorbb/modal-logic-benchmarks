# ===== Build CEGARBox =====
FROM haskell:8.4 AS build-cegar

COPY solvers/CEGARBox /build
WORKDIR /build

RUN cabal update && cabal install --only-dependencies
RUN cabal configure
RUN cabal build


# TODO: figure out exactly which CEGARBox++ version to use
# ===== Build CEGARBox++ =====
# instructions copied from their README
# The kaleidoscope binary in the repo seems to be outdated.
# FROM ubuntu:22.04 AS build-cegarboxcpp-deps
# RUN apt-get update && apt-get install -y build-essential wget unzip tar cmake libz-dev libgoogle-glog-dev git libboost-all-dev

# FROM build-cegarboxcpp-deps AS build-cegarboxpp

# COPY solvers/CEGARBox++ /build
# WORKDIR /build

# RUN git clone https://github.com/agurfinkel/minisat.git && cd minisat && make config prefix=/usr && make install
# RUN wget https://nalon.org/software/ltl2snf-0.1.0.tar.gz && tar xzf ltl2snf-0.1.0.tar.gz && cd ltl2snf-0.1.0 && make && mv ./ltl2snf ../ && cd .. && rm -rf ltl2snf-0.1.0*
# RUN export ANTLR_DIR=/antlr4 && wget https://www.antlr.org/download/antlr4-cpp-runtime-4.13.0-source.zip && \
#   mkdir -p $ANTLR_DIR && unzip -q antlr4-cpp-runtime-4.13.0-source.zip -d $ANTLR_DIR && \
#   mkdir -p $ANTLR_DIR/build $ANTLR_DIR/run && cd $ANTLR_DIR/build && cmake .. && make install

# RUN make

# TODO: CEGARBox++(KSP) build not working
# CEGARBox++(KSP)
# FROM build-cegarboxcpp-deps AS build-cegarboxppksp

# COPY solvers/CEGARBox++(KSP) /build
# WORKDIR /build

# RUN git clone https://github.com/agurfinkel/minisat.git && cd minisat && make config prefix=/usr && make install
# RUN wget https://nalon.org/software/ltl2snf-0.1.0.tar.gz && tar xzf ltl2snf-0.1.0.tar.gz && cd ltl2snf-0.1.0 && make && mv ./ltl2snf ../ && cd .. && rm -rf ltl2snf-0.1.0*
# RUN export ANTLR_DIR=/antlr4 && wget https://www.antlr.org/download/antlr4-cpp-runtime-4.13.0-source.zip && \
#   mkdir -p $ANTLR_DIR && unzip -q antlr4-cpp-runtime-4.13.0-source.zip -d $ANTLR_DIR && \
#   mkdir -p $ANTLR_DIR/build $ANTLR_DIR/run && cd $ANTLR_DIR/build && cmake .. && make install

# RUN make

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

# ===== Run benchmarks =====
FROM python:3.14-slim AS runner
RUN apt-get update && apt-get install -y google-perftools patch tar
RUN pip install lark

WORKDIR /run

COPY --from=build-cegar /build/dist/build/CEGARBox/CEGARBox .
COPY --from=build-coq /build/Verified-tableaux-for-K-KT-S4/src/_build/default/main.exe ./coqk
COPY --from=build-factpp /build/target/FaCT++/FaCT++ .
COPY --from=build-ksp /build/ksp .
COPY --from=build-vct /build/src/_build/default/bin/main.exe ./vct
COPY ./solvers/CEGARBox++/kaleidoscope ./CEGARBox++
# RUN mkdir 'CEGARBox++(KSP)'
# COPY --from=build-cegarboxppksp /build/kaleidoscope /build/ksp /build/ksp/conf './CEGARBox++(KSP)/'
COPY --from=build-depqbf /build/depqbf ./DepQBF
COPY --from=build-ktoqbf /build/ktoqbf ./KtoQBF

COPY benches ./benches

# apply benchmark patches
WORKDIR ./benches/lwb
RUN patch -p1 < ../lwb.patch

WORKDIR /run/benches
RUN mkdir 3CNFd3 && tar -xf 3CNFd3.tgz -C 3CNFd3
RUN mkdir 3CNFd5 && tar -xf 3CNFd5.tgz -C 3CNFd5
RUN mkdir MQBF && tar -xf MQBF.tgz -C MQBF
# will already extract to 3CNF/
RUN tar -xf 3CNF.tgz

WORKDIR /run

COPY solvers/ksp-0.1.6/conf.files/ijcar-2022/cord_mlple_K.conf ./ksp.conf
COPY owl.py .
COPY depqbf.sh .
COPY bench.py .

CMD ["python3", "./bench.py"]
