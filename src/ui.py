import enlighten
import os
import sys

manager = enlighten.get_manager()
counters = {}
status_bars = {}


def set_title(title: str):
    if sys.platform == "win32":
        os.system(f"title {title}")
    else:
        sys.stdout.write(f"\x1b]2;{title}\x07")
        print(f'\33]0;{title}\a', end='', flush=True)
        sys.stdout.flush()


def new_counter(
        name: str,
        total: int,
        description: str,
        unit: str,
        leave: bool = None,
        manager: enlighten.Manager = manager,
        autorefresh: bool = True
):
    if name in counters:
        counters[name].close()
        manager.remove(counters[name])

    _c = manager.counter(
        total=total,
        desc=description,
        unit=unit,
        leave=leave,
        autorefresh=autorefresh
    )
    counters.update({name: _c})
    return _c


def new_status_bar(
        name: str,
        status_format: str = None,
        color: str = 'bold_underline_bright_white_on_lightslategray',
        justify=enlighten.Justify.CENTER,
        demo: str = None,
        manager: enlighten.Manager = manager,
):
    if name == "guild":
        _tag = "Guild"
    elif name == "member":
        _tag = "Member"

    if name in status_bars:
        status_bars[name].close()
        manager.remove(status_bars[name])

    _s = manager.status_bar(
        status_format=status_format if not None else
        u'%s{fill}{demo}{fill}{elapsed}' % _tag,
        color=color,
        justify=justify,
        demo=demo,
        autorefresh=True,
        min_delta=0.5
    )
    status_bars.update({name: _s})
    return _s
