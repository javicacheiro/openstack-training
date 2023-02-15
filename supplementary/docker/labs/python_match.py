"""Sample program to test match statement

   It requires python 3.10 or higher to run.
"""
from dataclasses import dataclass

@dataclass
class Circle:
    r: float


def recognize(subject):
    match subject:
        case Circle(r):
            print(f"Circle with radius {r}")
        case (x, y):
            print(f"Two element tuple: x = {x}")
        case (x, y, z):
            print(f"Three element tuple: z = {z}")
        case _:
            print("Not recognized")


if __name__ == "__main__":
    surprise = Circle(10)
    recognize(surprise)
    surprise = (1, 2)
    recognize(surprise)
    surprise = (1, 2, 3)
    recognize(surprise)
    surprise = 10
    recognize(surprise)
