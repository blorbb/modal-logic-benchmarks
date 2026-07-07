from __future__ import annotations
from abc import ABC, abstractmethod
import argparse
import logging
import os
from pathlib import Path
import resource
import signal
import subprocess
from typing import Any, Callable, Literal
import typing
from pprint import pprint

import owl


def main():
    SOLVERS: dict[str, type[Solver]] = {
        "cegarbox": CegarBox,
        "coqk": CoqK,
        "fact++": Factpp,
        "ksp": Ksp,
        "vct-v1": VctV1,
        "vct-v2": VctV2,
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
        default=10,
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
        default="INFO",
        help="(default: %(default)s)",
    )

    args = p.parse_args()
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")

    time_limit = args.time_limit
    mem_limit = int(args.mem_limit * (1024**3))

    if args.benchmark is None:
        BENCHES = {k: v for k, v in BENCHES.items() if "/" not in k}

    def run_and_print(bench: str, solver: str) -> None:
        print(f"benchmarking {solver} against {bench}")
        b = BENCHES[bench]
        s = SOLVERS[solver]
        pprint(b(s(time_limit, mem_limit)))

    match (args.benchmark, args.solver):
        case None, None:
            for bench in BENCHES:
                for solver in SOLVERS:
                    run_and_print(bench, solver)
        case None, solver:
            for bench in BENCHES:
                run_and_print(bench, solver)
        case bench, None:
            for solver in SOLVERS:
                run_and_print(bench, solver)
        case bench, solver:
            run_and_print(bench, solver)


class DidNotSolve(Exception):
    """Solver failed to solve the problem instance."""

    pass


class IncorrectOutput(Exception):
    """Solver gave an incorrect answer."""

    pass


class Solver(ABC):
    def __init__(self, timeout_secs: float, mem_bytes: int) -> None:
        super().__init__()
        self.__timeout_secs = timeout_secs
        self.__mem_bytes = mem_bytes

    def spawn(self, args: list[str]) -> str:
        p = subprocess.Popen(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            preexec_fn=lambda: resource.setrlimit(
                resource.RLIMIT_AS, (self.__mem_bytes, self.__mem_bytes)
            ),
        )
        try:
            stdout, stderr = p.communicate(timeout=self.__timeout_secs)
        except subprocess.TimeoutExpired:
            p.kill()
            p.communicate()  # wait for the process to be fully freed
            raise DidNotSolve("time out")

        if p.returncode == 0:
            return stdout.decode("utf-8")
        elif p.returncode == -signal.SIGABRT:
            raise DidNotSolve("OOM")
        else:
            stdout = stdout.decode()
            stderr = stderr.decode()
            logging.warning(
                f"something went wrong: error {p.returncode}\nstdout:\n{stdout}\nstderr:\n{stderr}"
            )
            raise DidNotSolve(stderr)

    @abstractmethod
    def solve(self, intohylo: str) -> bool:
        """Runs the solver and returns whether the result was SAT or not.

        The solver should be ran using `self.spawn`, which raises
        a `SolverError`."""


class CoqK(Solver):
    def solve(self, intohylo: str) -> bool:
        Path("./bench.intohylo").write_text(intohylo)
        out = self.spawn(["./coqk", "./bench.intohylo"]).strip()
        if out == "SAT":
            return True
        elif out == "UNSAT":
            return False
        else:
            raise IncorrectOutput(f"malformed output:\n{out}")


class CegarBox(Solver):
    def solve(self, intohylo: str) -> bool:
        # input format is slightly different to intohylo
        formula = (
            intohylo.strip()
            .removeprefix("begin")
            .removesuffix("end")
            .replace("[r1]", "[]")
            .replace("<r1>", "<>")
            .strip()
        )
        Path("./bench.fml").write_text(formula)
        out = self.spawn(["./CEGARBox", "./bench.fml"]).strip()
        if out == "Satisfiable":
            return True
        elif out == "Unsatisfiable":
            return False
        else:
            raise IncorrectOutput(f"malformed output:\n{out}")


class Factpp(Solver):
    def solve(self, intohylo: str) -> bool:
        owl_str = owl.from_intohylo(intohylo)
        fact_conf = """
[LeveLogger]
    file = reasoning.log
    allowedLevel = 0

[Tuning]

[Query]
    Target = D0
    TBox = bench.tbox
"""
        Path("fact.conf").write_text(fact_conf)
        Path("bench.tbox").write_text(owl_str)
        out = self.spawn(["./FaCT++", "./fact.conf"])
        if "is satisfiable w.r.t. TBox" in out:
            return True
        elif "is unsatisfiable w.r.t. TBox" in out:
            return False
        else:
            raise IncorrectOutput(f"malformed output:\n{out}")


class Ksp(Solver):
    def solve(self, intohylo: str) -> bool:
        # See ksp/USAGE for formula format. Same as CEGARBox.
        formula = (
            intohylo.strip()
            .removeprefix("begin")
            .removesuffix("end")
            .replace("[r1]", "[]")
            .replace("<r1>", "<>")
            .strip()
        )
        formula = f"sos(formulas).\n{formula}.\nend_of_list."
        Path("./bench.ksp").write_text(formula)

        # See Dockerfile for which config this ksp.conf is.
        out = self.spawn(["./ksp", "-c", "./ksp.conf", "-i", "./bench.ksp"]).strip()

        # sometimes prints some extra info (solved during preprocessing)
        if "Satisfiable." in out:
            return True
        elif "Unsatisfiable." in out:
            return False
        else:
            raise IncorrectOutput(f"malformed output:\n{out}")


class Vct(Solver):
    @classmethod
    @abstractmethod
    def bin_path(cls) -> str: ...

    def solve(self, intohylo: str) -> bool:
        Path("./bench.intohylo").write_text(intohylo)
        out = self.spawn([self.bin_path(), "./bench.intohylo"]).strip()
        if out == "SAT":
            return True
        elif out == "UNSAT":
            return False
        else:
            raise IncorrectOutput(f"malformed output:\n{out}")


class VctV1(Vct):
    @classmethod
    def bin_path(cls) -> str:
        return "./vct-v1"


class VctV2(Vct):
    @classmethod
    def bin_path(cls) -> str:
        return "./vct-v2"


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
        subprocess.run(
            ["python", "./benches/lwb/generate.py", category, index, index, "1"],
            stdout=subprocess.DEVNULL,
            check=True,
        )
        path = f"./temp_target/{category}.{index.rjust(4, '0')}.intohylo"
        return Path(path).read_text()

    @classmethod
    def bench_solver(cls, solver: Solver) -> dict[Category, int]:
        max_solves = dict[Lwb.Category, int]()

        for c in cls.CATEGORIES:
            logging.debug(f"finding max for {c}")
            max_solves[c] = cls.bench_category(solver, c)

        return max_solves

    @classmethod
    def bench_category(cls, solver: Solver, c: Category) -> int:
        should_be_sat = c.endswith("n")

        def solve_single(i: int):
            try:
                result = solver.solve(cls.generate_intohylo(c, i))
            except DidNotSolve as e:
                logging.debug(f"failed due to {e}")
                return False

            if result == should_be_sat:
                return True
            else:
                raise IncorrectOutput(
                    f"result of solving {c} #{i} should be {should_be_sat}, got {result}"
                )

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
        # within each category, there are directories of increasing difficulty
        # which are in alphabetical order.
        for subdir in sorted(dir.iterdir()):
            for file in sorted(subdir.iterdir()):
                # slight variation of InToHyLo, variables are prefixed with
                # v instead of p.
                intohylo = file.read_text().replace("v", "p")
                try:
                    result = solver.solve(intohylo)
                except DidNotSolve as e:
                    logging.debug(f"{file.name}: failed due to {e}")
                    return completed

                logging.debug(f"{file.name}: {'SAT' if result else 'UNSAT'}")
                completed += 1

        return completed


class Cnf3:
    @classmethod
    def bench_solver(cls, solver: Solver) -> int:
        dir = Path("./benches/3CNF")
        completed = 0
        for file in dir.iterdir():
            # one of the files uses c<n> instead of p<n> for variables.
            intohylo = file.read_text().replace("c", "p")

            try:
                result = solver.solve(intohylo)
            except DidNotSolve as e:
                logging.debug(f"{file.name}: failed due to {e}")
                # 3CNF are not sorted by difficulty, so just count how many can be solved
                continue

            logging.debug(f"{file.name}: {'SAT' if result else 'UNSAT'}")
            completed += 1

        return completed


if __name__ == "__main__":
    main()
