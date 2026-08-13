# ruff: noqa: LOG015

from __future__ import annotations

import argparse
import logging
import os
import subprocess
import typing
from collections import defaultdict
from collections.abc import Callable
from pathlib import Path
from typing import Any, Literal

from solve import Solver, all_solvers


def main():
    SOLVERS: dict[str, type[Solver]] = all_solvers()
    BENCHES: dict[str, Callable[[Solver], Any]] = (
        {
            "lwb": Lwb.bench_solver,
            "mqbf": Mqbf.bench_solver,
            "3cnf": Cnf3.bench_solver,
            "3cnfd3": Cnf3d3.bench_solver,
            "3cnfd5": Cnf3d5.bench_solver,
        }
        | {f"lwb/{c}": lambda s, c=c: Lwb.bench_category(s, c) for c in Lwb.CATEGORIES}  # pyright: ignore[reportArgumentType]
        | {
            f"mqbf/{c}": lambda s, c=c: Mqbf.bench_category(s, c)  # pyright: ignore[reportArgumentType]
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
        type=str.lower,
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
    p.add_argument(
        "-x",
        "--exclude-attempted",
        nargs="+",
        metavar="FILE.tsv",
        help="Exclude running benchmarks that have been solved or ran for longer than the current time limit, as given by tsv file(s)",
        default=[],
        type=Path,
    )

    args = p.parse_args()
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")

    time_limit: float = args.time_limit
    mem_limit = int(args.mem_limit * (1024**3))

    if args.benchmark is None:
        BENCHES = {k: v for k, v in BENCHES.items() if "/" not in k}

    # solver instance (properly cased) -> problem instance -> solved?
    exclusions = defaultdict[str, dict[str, bool]](dict)
    fs: list[Path] = args.exclude_attempted
    for file in fs:
        for line in file.read_text().strip().splitlines():
            [solver, problem, result, time, _, _] = line.split("\t")

            # Skip if MLE too. Probably will result in the same time.
            if result in ("SAT", "UNSAT", "MLE") or time_limit < float(time):
                exclusions[solver][problem] = (
                    result in ("SAT", "UNSAT") and float(time) <= time_limit
                )

    def run(bench: str, solver: str) -> None:
        logging.info(f"benchmarking {solver} against {bench}")
        b = BENCHES[bench]
        s = SOLVERS[solver]
        logging.info(b(s(time_limit, mem_limit, exclusions[s.name()])))

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

    Generated files should be in ./src/temp_target"""

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
            os.mkdir("./src/lwb-instances")
        except FileExistsError:
            pass

        index = str(difficulty)
        path = Path(f"./src/lwb-instances/{category}.{index.rjust(4, '0')}.intohylo")
        # check if previously generated already
        try:
            txt = path.read_text()
            if txt.strip() == "":
                raise FileNotFoundError()
            logging.debug("using existing lwb instance")
            return txt
        except FileNotFoundError:
            subprocess.run(
                ["python3", "./benches/lwb/generate.py", category, index, index, "1"],
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


class Cnf3d3:
    @classmethod
    def bench_solver(cls, solver: Solver) -> int:
        dir = Path("./benches/3CNFd3")
        completed = 0
        for file in dir.iterdir():
            # CEGARBox++ can't handle newlines
            intohylo = "begin " + file.read_text().replace("\n", " ") + " end"
            # name is "test_NNN_NN", middle 3 are CVR.
            [_, clause_var_ratio, _] = file.stem.split("_")
            completed += solver.solve(
                f"3cnfd3/{clause_var_ratio}/{file.stem}", intohylo
            )

        return completed


class Cnf3d5:
    @classmethod
    def bench_solver(cls, solver: Solver) -> int:
        dir = Path("./benches/3CNFd5")
        completed = 0
        for file in dir.iterdir():
            # CEGARBox++ can't handle newlines
            intohylo = "begin " + file.read_text().replace("\n", " ") + " end"
            # name is "test_NNN_NN", middle 3 are CVR.
            [_, clause_var_ratio, _] = file.stem.split("_")
            completed += solver.solve(
                f"3cnfd5/{clause_var_ratio}/{file.stem}", intohylo
            )

        return completed


if __name__ == "__main__":
    main()
