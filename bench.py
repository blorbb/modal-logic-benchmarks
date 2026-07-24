from __future__ import annotations
from abc import ABC, abstractmethod
import argparse
import logging
import os
from pathlib import Path
import resource
import signal
import subprocess
import time
from typing import Any, Callable, Literal
import typing

import owl


def log_run(
    solver: str,
    problem: str,
    result: Literal["SAT", "UNSAT", "TLE", "MLE", "UNKNOWN"],
    elapsed: float,
    stdout="",
    stderr="",
):
    print(
        "\t".join([solver, problem, result, str(elapsed), repr(stdout), repr(stderr)])
    )


def main():
    SOLVERS: dict[str, type[Solver]] = {
        "cegarbox": CegarBox,
        "cegarbox++": CegarBoxpp,
        "coqk": CoqK,
        "fact++": Factpp,
        "ksp": Ksp,
        "vct": Vct,
    }
    BENCHES: dict[str, Callable[[Solver], Any]] = (
        {
            "lwb": Lwb.bench_solver,
            "mqbf": Mqbf.bench_solver,
            "3cnf": Cnf3.bench_solver,
        }
        | {f"lwb/{c}": lambda s, c=c: Lwb.bench_category(s, c) for c in Lwb.CATEGORIES}
        | {
            f"mqbf/{c}": lambda s, c=c: Mqbf.bench_category(s, c)
            for c in Mqbf.CATEGORIES
        }
    )

    p = argparse.ArgumentParser()
    p.add_argument(
        "-t",
        "--time-limit",
        type=float,
        default=1,
        metavar="SECONDS",
        help="(default: %(default)s s)",
    )
    p.add_argument(
        "-m",
        "--mem-limit",
        type=float,
        default=16,
        metavar="GiB",
        help="(default: %(default)s GiB)",
    )
    p.add_argument(
        "-s",
        "--solver",
        choices=SOLVERS.keys(),
    )
    p.add_argument(
        "-b",
        "--benchmark",
        choices=BENCHES.keys(),
    )
    p.add_argument(
        "-l",
        "--log-level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        default="WARNING",
        help="(default: %(default)s)",
    )

    args = p.parse_args()
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")

    time_limit = args.time_limit
    mem_limit = int(args.mem_limit * (1024**3))

    if args.benchmark is None:
        BENCHES = {k: v for k, v in BENCHES.items() if "/" not in k}

    def run(bench: str, solver: str) -> None:
        logging.info(f"benchmarking {solver} against {bench}")
        b = BENCHES[bench]
        s = SOLVERS[solver]
        logging.info(b(s(time_limit, mem_limit)))

    match (args.benchmark, args.solver):
        case None, None:
            for bench in BENCHES:
                for solver in SOLVERS:
                    run(bench, solver)
        case None, solver:
            for bench in BENCHES:
                run(bench, solver)
        case bench, None:
            for solver in SOLVERS:
                run(bench, solver)
        case bench, solver:
            run(bench, solver)


class Solver(ABC):
    def __init__(self, timeout_secs: float, mem_bytes: int) -> None:
        super().__init__()
        self.__timeout_secs = timeout_secs
        self.__mem_bytes = mem_bytes

    @abstractmethod
    def name(self) -> str: ...

    @abstractmethod
    def convert(self, intohylo: str) -> str: ...

    @abstractmethod
    def run_args(self, bench_path: str) -> list[str]: ...

    @abstractmethod
    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]: ...

    def solve(self, problem: str, intohylo: str) -> bool:
        """Runs the solver and returns whether the solver managed to solve
        the problem within the time/memory limits."""

        solver_format = self.convert(intohylo)
        Path("./input.txt").write_text(solver_format)
        args = self.run_args("./input.txt")

        start_time = time.time()
        p = subprocess.Popen(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            preexec_fn=lambda: resource.setrlimit(
                resource.RLIMIT_AS, (self.__mem_bytes, self.__mem_bytes)
            ),
        )

        try:
            stdout, stderr = p.communicate(timeout=self.__timeout_secs)
        except subprocess.TimeoutExpired:
            elapsed = time.time() - start_time
            p.kill()
            p.communicate()  # wait for the process to be fully freed
            log_run(
                solver=self.name(),
                problem=problem,
                result="TLE",
                elapsed=elapsed,
            )
            return False

        elapsed = time.time() - start_time

        if p.returncode == 0:
            result = self.interpret_output(stdout.strip())
        elif p.returncode == -signal.SIGABRT:
            result = "MLE"
        else:
            result = "UNKNOWN"

        log_run(
            solver=self.name(),
            problem=problem,
            result=result,
            elapsed=elapsed,
            stdout=stdout,
            stderr=stderr,
        )
        return result in ("SAT", "UNSAT")


class CoqK(Solver):
    def name(self) -> str:
        return "coqk"

    def convert(self, intohylo: str) -> str:
        return intohylo

    def run_args(self, bench_path: str) -> list[str]:
        return ["./coqk", bench_path]

    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]:
        if output in ("SAT", "UNSAT"):
            return output
        else:
            return "UNKNOWN"


class CegarBox(Solver):
    def name(self) -> str:
        return "cegarbox"

    def convert(self, intohylo: str) -> str:
        return (
            intohylo.strip()
            .removeprefix("begin")
            .removesuffix("end")
            .replace("[r1]", "[]")
            .replace("<r1>", "<>")
            .strip()
        )

    def run_args(self, bench_path: str) -> list[str]:
        return ["./CEGARBox", bench_path]

    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]:
        if output == "Satisfiable":
            return "SAT"
        elif output == "Unsatisfiable":
            return "UNSAT"
        else:
            return "UNKNOWN"


class CegarBoxpp(Solver):
    def name(self) -> str:
        return "cegarbox++"

    def convert(self, intohylo: str) -> str:
        return (
            intohylo.strip()
            .removeprefix("begin")
            .removesuffix("end")
            .replace("[r1]", "[]")
            .replace("<r1>", "<>")
            .replace("->", "=>")
            .replace("<->", "<=>")
            .replace("true", "$true")
            .replace("false", "$false")
            .strip()
        )

    def run_args(self, bench_path: str) -> list[str]:
        return ["./cegarboxpp", "-f", bench_path]

    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]:
        if output == "Satisfiable":
            return "SAT"
        elif output == "Unsatisfiable":
            return "UNSAT"
        else:
            return "UNKNOWN"


class Factpp(Solver):
    def name(self) -> str:
        return "fact++"

    def convert(self, intohylo: str) -> str:
        return owl.from_intohylo(intohylo)

    def run_args(self, bench_path: str) -> list[str]:
        fact_conf = f"""
[LeveLogger]
    file = reasoning.log
    allowedLevel = 0

[Tuning]

[Query]
    Target = D0
    TBox = {bench_path}
"""
        Path("fact.conf").write_text(fact_conf)
        return ["./FaCT++", "./fact.conf"]

    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]:
        if "is satisfiable w.r.t. TBox" in output:
            return "SAT"
        elif "is unsatisfiable w.r.t. TBox" in output:
            return "UNSAT"
        else:
            return "UNKNOWN"


class Ksp(Solver):
    def name(self) -> str:
        return "ksp"

    def convert(self, intohylo: str) -> str:
        # See ksp/USAGE for formula format. Same as CEGARBox.
        formula = (
            intohylo.strip()
            .removeprefix("begin")
            .removesuffix("end")
            .replace("[r1]", "[]")
            .replace("<r1>", "<>")
            .strip()
        )
        return f"sos(formulas).\n{formula}.\nend_of_list."

    def run_args(self, bench_path: str) -> list[str]:
        # See Dockerfile for which config this ksp.conf is.
        return ["./ksp", "-c", "./ksp.conf", "-i", bench_path]

    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]:
        # sometimes prints some extra info (solved during preprocessing)
        if "Satisfiable." in output:
            return "SAT"
        elif "Unsatisfiable." in output:
            return "UNSAT"
        else:
            return "UNKNOWN"


class Vct(Solver):
    def name(self) -> str:
        return "vct"

    def convert(self, intohylo: str) -> str:
        return intohylo

    def run_args(self, bench_path: str) -> list[str]:
        return ["./vct", bench_path]

    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]:
        if output == "SAT":
            return "SAT"
        elif output == "UNSAT":
            return "UNSAT"
        else:
            return "UNKNOWN"


def max_solves(pred: Callable[[int], bool]) -> int:
    """Finds the maximum number that passes the predicate via binary search.

    The predicate should return true for all ints up to the max, and false on all ints over the max."""
    lb = 1
    # find an upper bound
    while pred(lb * 2):
        logging.debug(f"succeeded at {lb * 2}")
        lb = lb * 2

    logging.debug(f"failed at {lb * 2}")
    ub = lb * 2
    # binary search between lb and ub
    while lb <= ub:
        i = (lb + ub) // 2
        if pred(i):
            logging.debug(f"succeeded at {i}")
            lb = i + 1
        else:
            logging.debug(f"failed at {i}")
            ub = i - 1

    return lb - 1


class Lwb:
    """LWB benchmark generator should be at ./benches/lwb/generate.py

    Generated files should be in ./temp_target/"""

    type Category = Literal[
        "k_branch_n",
        "k_branch_p",
        "k_d4_n",
        "k_d4_p",
        "k_dum_n",
        "k_dum_p",
        "k_grz_n",
        "k_grz_p",
        "k_lin_n",
        "k_lin_p",
        "k_path_n",
        "k_path_p",
        "k_ph_n",
        "k_ph_p",
        "k_poly_n",
        "k_poly_p",
        "k_t4p_n",
        "k_t4p_p",
    ]
    CATEGORIES: tuple[Category, ...] = typing.get_args(Category.__value__)

    @classmethod
    def generate_intohylo(cls, category: Category, difficulty: int) -> str:
        try:
            os.mkdir("./temp_target")
        except FileExistsError:
            pass

        index = str(difficulty)
        path = Path(f"./temp_target/{category}.{index.rjust(4, '0')}.intohylo")
        # check if previously generated already
        try:
            txt = path.read_text()
            if txt.strip() == "":
                raise FileNotFoundError()
            logging.debug("using existing lwb instance")
            return txt
        except FileNotFoundError:
            subprocess.run(
                ["python", "./benches/lwb/generate.py", category, index, index, "1"],
                stdout=subprocess.DEVNULL,
                check=True,
            )
        return path.read_text()

    @classmethod
    def bench_solver(cls, solver: Solver) -> dict[Category, int]:
        max_solves = dict[Lwb.Category, int]()

        for c in cls.CATEGORIES:
            logging.debug(f"finding max for {c}")
            max_solves[c] = cls.bench_category(solver, c)

        return max_solves

    @classmethod
    def bench_category(cls, solver: Solver, c: Category) -> int:
        def solve_single(i: int):
            return solver.solve(f"lwb/{c}/{i:04}", cls.generate_intohylo(c, i))

        return max_solves(solve_single)


class Mqbf:
    type Category = Literal["qbf", "qbfL", "qbfML", "qbfMS", "qbfS"]
    CATEGORIES: tuple[Category, ...] = typing.get_args(Category.__value__)

    @classmethod
    def bench_solver(cls, solver: Solver) -> dict[Mqbf.Category, int]:
        max_solves = dict[Mqbf.Category, int]()

        for c in cls.CATEGORIES:
            logging.debug(f"finding max for {c}")
            max_solves[c] = cls.bench_category(solver, c)

        return max_solves

    @classmethod
    def bench_category(cls, solver: Solver, c: Category) -> int:
        dir = Path(f"./benches/MQBF/{c}")
        completed = 0
        for subdir in sorted(dir.iterdir()):
            for file in sorted(subdir.iterdir()):
                # slight variation of InToHyLo, variables are prefixed with
                # v instead of p.
                intohylo = file.read_text().replace("v", "p")
                completed += solver.solve(f"mqbf/{c}/{file.stem}", intohylo)

        return completed


class Cnf3:
    @classmethod
    def bench_solver(cls, solver: Solver) -> int:
        dir = Path("./benches/3CNF")
        completed = 0
        for file in dir.iterdir():
            # one of the files uses c<n> instead of p<n> for variables.
            intohylo = file.read_text().replace("c", "p")
            completed += solver.solve(f"3cnf/{file.stem}", intohylo)

        return completed


if __name__ == "__main__":
    main()
