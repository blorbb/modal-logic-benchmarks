# ruff: noqa: PLW1509 LOG015

"""Run a specific solver on a specific problem."""

from __future__ import annotations

import argparse
import logging
import os
import resource
import signal
import subprocess
import time
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Literal

import owl


def all_solvers() -> dict[str, type[Solver]]:
    return {
        s.name().lower(): s
        for s in (CegarBox, CegarBoxpp, CoqK, Factpp, Ksp, Vct, DepQbf)
    }


def log_run(
    solver: str,
    problem: str,
    result: Literal["SAT", "UNSAT", "TLE", "MLE", "UNKNOWN"],
    elapsed: float,
    stdout,
    stderr,
):
    print(
        "\t".join([solver, problem, result, str(elapsed), repr(stdout), repr(stderr)])
    )


class Solver(ABC):
    def __init__(
        self,
        timeout_secs: float,
        mem_bytes: int,
        exclude: dict[str, bool] | None = None,
    ) -> None:
        """
        Args:
            exclude (list[str] | None, optional): Problem instances to ignore.
                Keys should only be the full "bench/cat/instance" name.
                Value should be whether the instance was solved under the
                current time limit.
        """
        super().__init__()
        self.__timeout_secs = timeout_secs
        self.__mem_bytes = mem_bytes
        self.__exclude = exclude or {}

    @classmethod
    @abstractmethod
    def name(cls) -> str: ...

    @abstractmethod
    def convert(self, intohylo: str) -> str: ...

    @abstractmethod
    def run_args(self, bench_path: str) -> list[str]: ...

    @abstractmethod
    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]: ...

    def solve(self, problem: str, intohylo: str) -> bool:
        """Runs the solver and returns whether the solver managed to solve
        the problem within the time/memory limits."""

        if (finished := self.__exclude.get(problem)) is not None:
            logging.debug(f"{problem} excluded: previously {finished = }")
            return finished

        solver_format = self.convert(intohylo)
        Path("./input.txt").write_text(solver_format)
        args = self.run_args("./input.txt")

        start_time = time.time()
        p = subprocess.Popen(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            # Make new process group to make sure all child processes are also killed
            start_new_session=True,
            preexec_fn=lambda: resource.setrlimit(
                resource.RLIMIT_AS, (self.__mem_bytes, self.__mem_bytes)
            ),
        )

        try:
            stdout, stderr = p.communicate(timeout=self.__timeout_secs)
        except subprocess.TimeoutExpired:
            elapsed = time.time() - start_time
            os.killpg(os.getpgid(p.pid), signal.SIGKILL)
            try:
                # wait for the process to be fully freed
                stdout, stderr = p.communicate(timeout=5.0)
            except subprocess.TimeoutExpired:
                raise RuntimeError("BUG: solver process did not die after being killed")
            log_run(
                solver=self.name(),
                problem=problem,
                result="TLE",
                elapsed=elapsed,
                stdout=stdout,
                stderr=stderr,
            )
            return False

        elapsed = time.time() - start_time

        if p.returncode == 0:
            finished = self.interpret_output(stdout.strip())
        elif p.returncode == -signal.SIGABRT:
            finished = "MLE"
        else:
            finished = "UNKNOWN"

        log_run(
            solver=self.name(),
            problem=problem,
            result=finished,
            elapsed=elapsed,
            stdout=stdout,
            stderr=stderr,
        )
        return finished in ("SAT", "UNSAT")


class CoqK(Solver):
    @classmethod
    def name(cls) -> str:
        return "CoqK"

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
    @classmethod
    def name(cls) -> str:
        return "CEGARBox"

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
    @classmethod
    def name(cls) -> str:
        return "CEGARBox++"

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
        return ["./CEGARBox++", "-f", bench_path]

    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]:
        if output == "Satisfiable":
            return "SAT"
        elif output == "Unsatisfiable":
            return "UNSAT"
        else:
            return "UNKNOWN"


class CegarBoxppKsp(Solver):
    @classmethod
    def name(cls) -> str:
        return "CEGARBox++(KSP)"

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
        return ["./CEGARBox++(KSP)", "-f", bench_path]

    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]:
        if output == "Satisfiable":
            return "SAT"
        elif output == "Unsatisfiable":
            return "UNSAT"
        else:
            return "UNKNOWN"


class Factpp(Solver):
    @classmethod
    def name(cls) -> str:
        return "FaCT++"

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
    @classmethod
    def name(cls) -> str:
        return "KSP"

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
    @classmethod
    def name(cls) -> str:
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


class DepQbf(Solver):
    """DepQBF + K to QBF translation"""

    @classmethod
    def name(cls) -> str:
        return "DepQBF"

    def convert(self, intohylo: str) -> str:
        # K to QBF conversion is non-trivial so we include it in the solve time.
        return intohylo.removeprefix("begin").removesuffix("end").strip()

    def run_args(self, bench_path: str) -> list[str]:
        # depqbf.sh is relative to this file, not relative to invocation
        cwd = Path(__file__).parent
        return [f"{cwd}/depqbf.sh", bench_path]

    def interpret_output(self, output: str) -> Literal["SAT", "UNSAT", "UNKNOWN"]:
        # Sometimes KtoQBF outputs "flag" as well
        if "UNSAT" in output:
            return "UNSAT"
        elif "SAT" in output:
            return "SAT"
        else:
            return "UNKNOWN"


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
        default=16,
        metavar="GiB",
        help="(default: %(default)s GiB)",
    )
    p.add_argument(
        "-s",
        "--solver",
        choices=all_solvers().keys(),
        type=str.lower,
    )
    p.add_argument(
        "file",
        type=Path,
        help="Problem instance (InToHyLo format)",
    )
    args = p.parse_args()

    solver = all_solvers()[args.solver](
        args.time_limit, int(args.mem_limit * (1024**3))
    )

    solver.solve(str(args.file), args.file.read_text())


if __name__ == "__main__":
    main()
