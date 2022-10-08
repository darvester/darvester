import os
import sys


def set_title(title: str):
    """
    Set the title of the terminal window.

    :param title: The title to set.
    :type title: str
    """
    if sys.platform == "win32":
        os.system(f"title {title}")
    else:
        sys.stdout.write(f"\x1b]2;{title}\x07")
        print(f"\33]0;{title}\a", end="", flush=True)
        sys.stdout.flush()
