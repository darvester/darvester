import os
import sys

import enlighten

manager = enlighten.get_manager()
counters = {}
status_bars = {}


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
    """
    Create a new counter.

    :param name: The name of the counter.
    :type name: str
    :param total: The total number of items to count.
    :type total: int
    :param description: The description of the counter.
    :type description: str
    :param unit: The unit of the counter.
    :type unit: str
    :param leave: Whether to leave the counter running after the total is reached.
    :type leave: bool
    :param counter_format: The format of the counter.
    :type counter_format: str
    :param manager: The enlighten manager to use.
    :type manager: enlighten.Manager
    :param autorefresh: Whether to refresh the counter every second.
    :type autorefresh: bool
    :return: The counter.
    :rtype: enlighten.Counter
    """
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
    """
    Create a new status bar.

    :param name: The name of the status bar.
    :type name: str
    :param status_format: The format of the status bar.
    :type status_format: str
    :param color: The color of the status bar.
    :type color: str
    :param justify: The justification of the status bar.
    :type justify: enlighten.Justify
    :param demo: The demo to display.
    :type demo: str
    :param manager: The enlighten manager to use.
    :type manager: enlighten.Manager
    :return: The status bar.
    :rtype: enlighten.StatusBar
    """
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
