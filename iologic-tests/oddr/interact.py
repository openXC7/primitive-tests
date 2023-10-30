#!/usr/bin/env python3
import readline # optional, will allow Up/Down/History in the console
import code
import pprint

pp = pprint.PrettyPrinter(indent=2, width=30)

def pr_pair(p, pfunc=lambda x: x + ": ", sfunc=lambda x: x):
    return (f"{pfunc(p.first)}{sfunc(p.second)}")

def pr_map(m, pfunc=lambda x: x + ": ", sfunc=lambda x: x):
    return "\n".join([pr_pair(e, pfunc, sfunc) for e in m])

def cell_by_name(name_part):
    return list(filter(lambda c: name_part in c.first, ctx.cells))

def pr_pi(pi):
    return (f"{pi.name}: {pi.type}")

def pr_pr(pr):
    return f"PortRef: {pr.cell.name} => {pr.port}"

def pr_pm(pm):
    return pr_map(pm, lambda _: "", lambda p: pr_pi(p))

def pr_ni(ni):
    return (f"net: {ni.name}\n  driver: {pr_pr(ni.driver)}\n  users: {pp.pformat(ni.users)}\n  wires: {pp.pformat(list(ni.wires))}")

def pr_ci(ci):
    return f"Cell: {ci.name}\ntype: {ci.type}\nbel: {ci.bel}\n\nparams:\n{pr_map(ci.params)}\n\nattrs:\n{pr_map(ci.attrs)}\n\nports:\n{pr_pm(ci.ports)}\n"

#d = get_ddr()[0]
#ci = d.second
    
vars = globals().copy()
vars.update(locals())
shell = code.InteractiveConsole(vars)
shell.interact()
