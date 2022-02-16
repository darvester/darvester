import os
import sys

import enlighten

manager = enlighten.get_manager()
counters = {}
status_bars = {}


def set_title(title: str):
    if sys.platform == "win32":
        os.system(f"title {title}")
    else:
        sys.stdout.write(f"\x1b]2;{title}\x07")
        print(f"\33]0;{title}\a", end="", flush=True)
        sys.stdout.flush()


def new_counter(
    name: str,
    total: int,
    description: str,
    unit: str,
    leave: bool = None,
    counter_format: str = "{desc}{desc_pad}{count:d} {unit}{unit_pad}{elapsed}, \
{rate:.2f}{unit_pad}{unit}/s]{fill}",
    manager: enlighten.Manager = manager,
    autorefresh: bool = True,
):
    if name in counters:
        if isinstance(counters[name], enlighten.Counter):
            try:
                counters[name].close()
            except KeyError:
                pass
        manager.remove(counters[name])

    _c = manager.counter(
        total=total,
        desc=description,
        unit=unit,
        leave=leave,
        autorefresh=autorefresh,
        counter_format=counter_format,
    )
    counters.update({name: _c})
    return _c


def new_status_bar(
    name: str,
    status_format: str = "Darvester{fill}{demo}{fill}{elapsed}",
    color: str = "bold_underline_bright_white_on_lightslategray",
    justify=enlighten.Justify.CENTER,
    demo: str = None,
    manager: enlighten.Manager = manager,
):
    if name in status_bars:
        if isinstance(status_bars[name], enlighten.StatusBar):
            try:
                status_bars[name].close()
            except KeyError:
                pass
        manager.remove(status_bars[name])

    _s = manager.status_bar(
        status_format=status_format,
        color=color,
        justify=justify,
        demo=demo,
        autorefresh=True,
        min_delta=0.5,
    )
    status_bars.update({name: _s})
    return _s
