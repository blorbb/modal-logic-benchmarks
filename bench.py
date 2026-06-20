import os
import subprocess

# expects the lwb benchmark generator to be at ./lwb


def lwb():
    os.mkdir("./lwb/temp_target")

    categories = [
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
    index = 1
    for c in categories:
        print(f"testing {c}")
        test_lwb(c, index, "./coqk")


def test_lwb(category: str, n: int, exe: str) -> bool:
    index = str(n)
    subprocess.run(["python", "./lwb/generate.py", category, index, index, ""])
    subprocess.run(
        [exe, f"./lwb/temp_target/{category}/{index.rjust(4, '0')}.intohylo"]
    )
    return True


lwb()
