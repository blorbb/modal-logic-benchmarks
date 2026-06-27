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
        choices=["cegarbox", "coqk", "fact++", "vct"],
    )
    p.add_argument(
        "-b",
        "--benchmark",
        choices=["lwb"],
    )
    p.add_argument(
        "-c",
        "--category",
        choices=Lwb.CATEGORIES,
        metavar="LWB_CATEGORY",
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

    if args.benchmark != "lwb" and args.category is not None:
        p.error("category is only supported with the LWB benchmark")
    if args.benchmark == "lwb" and args.category is not None:
        args.benchmark = f"{args.benchmark}/{args.category}"

    time_limit = args.time_limit
    mem_limit = int(args.mem_limit * (1024**3))

    solvers: dict[str, type[Solver]] = {
        "cegarbox": CegarBox,
        "coqk": CoqK,
        "fact++": Factpp,
        "vct": Vct,
    }
    benches: dict[str, Callable[[Solver], Any]] = {"lwb": Lwb.bench_solver} | {
        f"lwb/{c}": lambda s: Lwb.bench_category(s, c) for c in Lwb.CATEGORIES
    }

    def run_and_print(bench: str, solver: str) -> None:
        print(f"benchmarking {solver} against {bench}")
        b = benches[bench]
        s = solvers[solver]
        pprint(b(s(time_limit, mem_limit)))

    match (args.benchmark, args.solver):
        case None, None:
            for bench in benches:
                for solver in solvers:
                    run_and_print(bench, solver)
        case None, solver:
            for bench in benches:
                run_and_print(bench, solver)
        case bench, None:
            for solver in solvers:
                run_and_print(bench, solver)
        case bench, solver:
            run_and_print(bench, solver)


class Solver(ABC):
    def __init__(self, timeout_secs: float, mem_bytes: int) -> None:
        super().__init__()
        self.__timeout_secs = timeout_secs
        self.__mem_bytes = mem_bytes

    def spawn(self, args: list[str]) -> str:
        stderr_pipe = (
            None
            if logging.getLogger().getEffectiveLevel() <= logging.DEBUG
            else subprocess.DEVNULL
        )
        p = subprocess.Popen(
            args,
            stdout=subprocess.PIPE,
            stderr=stderr_pipe,
            preexec_fn=lambda: resource.setrlimit(
                resource.RLIMIT_AS, (self.__mem_bytes, self.__mem_bytes)
            ),
        )
        try:
            stdout, stderr = p.communicate(timeout=self.__timeout_secs)
        except subprocess.TimeoutExpired:
            raise TimeoutError("time out")

        if p.returncode == 0:
            return stdout.decode("utf-8")
        elif p.returncode == -signal.SIGABRT:
            raise MemoryError("OOM")
        else:
            raise ChildProcessError(
                f"something went wrong: error {p.returncode}\n{stderr}"
            )

    @abstractmethod
    def solve(self, intohylo: str) -> bool:
        """Runs the solver and returns whether the result was SAT or not.

        The solver should be ran using `self.spawn`, which raises
        a `TimeoutError` or `MemoryError`."""


class CoqK(Solver):
    def solve(self, intohylo: str) -> bool:
        Path("./bench.intohylo").write_text(intohylo)
        out = self.spawn(["./coqk", "./bench.intohylo"]).strip()
        if out == "SAT":
            return True
        elif out == "UNSAT":
            return False
        else:
            raise ChildProcessError(f"malformed output:\n{out}")


class CegarBox(Solver):
    def solve(self, intohylo: str) -> bool:
        # input format is slightly different to intohylo
        [_start, formula, _end] = intohylo.strip().splitlines()
        formula = formula.replace("[r1]", "[]").replace("<r1>", "<>")
        Path("./bench.fml").write_text(formula)
        out = self.spawn(["./CEGARBox", "./bench.fml"]).strip()
        if out == "Satisfiable":
            return True
        elif out == "Unsatisfiable":
            return False
        else:
            raise ChildProcessError(f"malformed output:\n{out}")


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
            raise ChildProcessError(f"malformed output:\n{out}")


class Vct(Solver):
    def solve(self, intohylo: str) -> bool:
        Path("./bench.intohylo").write_text(intohylo)
        out = self.spawn(["./vct", "./bench.intohylo"]).strip()
        if out == "SAT":
            return True
        elif out == "UNSAT":
            return False
        else:
            raise ChildProcessError(f"malformed output:\n{out}")


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
            except (TimeoutError, MemoryError) as e:
                logging.debug(f"failed due to {e}")
                return False

            if result == should_be_sat:
                return True
            else:
                raise ChildProcessError(
                    f"result of solving {c} #{i} should be {should_be_sat}, got {result}"
                )

        return max_solves(solve_single)


if __name__ == "__main__":
    main()
