#!/usr/bin/env python3
import readline # optional, will allow Up/Down/History in the console
import code
import pprint

pp = pprint.PrettyPrinter(indent=2, width=30)

def pr_pair(p, pfunc=lambda x: x + ": ", sfunc=lambda x: x):
    return (f"{pfunc(p.first)}{sfunc(p.second)}")

def pr_map(m, pfunc=lambda x: x + ": ", sfunc=lambda x: x):
    return "\n".join([pr_pair(e, pfunc, sfunc) for e in m])

def pr_pi(pi):
    return (f"{pi.name}: {pi.type} --> {pi.net.name}")

def pr_pr(pr):
    return f"PortRef: {pr.cell.name} => {pr.port}"

def pr_pm(pm):
    return pr_map(pm, lambda _: "", lambda p: pr_pi(p))

def pr_ni(ni):
    return (f"net: {ni.name}\n  driver: {pr_pr(ni.driver)}\n  users: {' '.join([pr_pr(p) for p in ni.users])}\n  wires: {pp.pformat(list(ni.wires))}")

def pr_ci(ci):
    return f"Cell: {ci.name}\ntype: {ci.type}\nbel: {ci.bel}\n\nparams:\n{pr_map(ci.params)}\n\nattrs:\n{pr_map(ci.attrs)}\n\nports:\n{pr_pm(ci.ports)}\n"

def get_cells(name_part):
    return list(map(lambda c: c.second, filter(lambda c: name_part in c.first, ctx.cells)))

def get_cell(name_part):
    return get_cells(name_part)[0]

def get_nets(name_part):
    return list(map(lambda c: c.second, filter(lambda c: name_part in c.first, ctx.nets)))

def get_net(name_part):
    return get_nets(name_part)[0]

def spacer():
    print('\n'+ 50 * "=")

def cells(v=False):
    if v:
        for c in ctx.cells:
            print('\n'+ pr_ci(c.second))
            spacer()
    else:
        print(pr_map(ctx.cells, pfunc=lambda x:x, sfunc=lambda x:""))


def nets(v=False):
    if v:
        for c in ctx.nets:
            print('\n'+ pr_ni(c.second))
            spacer()
    else:
        print(pr_map(ctx.nets, pfunc=lambda x:x, sfunc=lambda x:""))

def pr_pip(pip):
    src_wire = ctx.getPipSrcWire(pip)
    dest_wire = ctx.getPipDstWire(pip)
    return f"{src_wire} -> {dest_wire}"

def pr_dh(arg):
    result = ""
    for pip in ctx.getPipsDownhill(arg):
        result += f"    {pr_pip(pip)}\n"
    print(result)

def pr_uh(arg):
    result = ""
    for pip in ctx.getPipsUphill(arg):
        result += f"    {pr_pip(pip)}\n"
    print(result)

#ctx.pack()

def pr(x):
    if isinstance(x, CellInfo):
        print(pr_ci(x))

    if isinstance(x, NetInfo):
        print(pr_ni(x))

    if isinstance(x, PortRef):
        print(pr_pr(x))

    if isinstance(x, PortInfo):
        print(pr_pi(x))

    if "\"PortMap\"" in str(type(x)):
        print(pr_pm(x))

    if "\"AttrMap\"" in str(type(x)):
        print(pr_map(x))

c=ctx.cells['GTPE2_COMMON_0']

vars = globals().copy()
vars.update(locals())
shell = code.InteractiveConsole(vars)
shell.interact()
