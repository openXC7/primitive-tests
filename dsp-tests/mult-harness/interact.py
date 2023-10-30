#!/usr/bin/env python3
import readline # optional, will allow Up/Down/History in the console
import code
import pprint

pp = pprint.PrettyPrinter(indent=2, width=30)

def pr_pair(p, pfunc=lambda x: x + ": ", sfunc=lambda x: x):
    return (f"{pfunc(p.first)}{sfunc(p.second)}")
def ppair(p, pfunc=lambda x: x + ": ", sfunc=lambda x: x):
    print(pr_pair(p, pfunc, sfunc))

def pr_map(m, pfunc=lambda x: x + ": ", sfunc=lambda x: x):
    return "\n".join([pr_pair(e, pfunc, sfunc) for e in m])
def pmap(m, pfunc=lambda x: x + ": ", sfunc=lambda x: x):
    print(pr_map(m, pfunc, sfunc))

def cell_by_name(name_part):
    return list(filter(lambda c: name_part in c.first, ctx.cells))

def pr_pi(pi):
    return (f"{pi.name}: {pi.type}")
def ppi(pi):
    print(pr_pi(pi))
    print(pr_ni(pi.net))

def pr_pr(pr):
    return f"PortRef: {pr.cell.name} => {pr.port}"
def ppr(pr):
    print(pr_pr(pr))

def pr_pm(pm):
    return pr_map(pm, lambda _: "", lambda p: pr_pi(p))
def ppm(pm):
    print(pr_pm(pm))

def pr_ni(ni):
    return (f"net: {ni.name}\n  driver: {pr_pr(ni.driver)}\n  users: {pp.pformat(ni.users)}\n  wires: {pp.pformat(list(ni.wires))}")
def pni(ni):
    print(pr_ni(ni))

def pr_ci(ci):
    return f"Cell: {ci.name}\ntype: {ci.type}\nbel: {ci.bel}\n\nparams:\n{pr_map(ci.params)}\n\nattrs:\n{pr_map(ci.attrs)}\n\nports:\n{pr_pm(ci.ports)}\n"
def pci(ci):
    print(pr_ci(ci))

cnames=[c.first for c in ctx.cells]
l=list(filter(lambda s: ".mul.genblk" in s and not "const" in s, cnames))
dsps=[ctx.cells[i] for i in l]
for d in dsps:
    print("DSP " + d.name)
    pts=[p.first for p in d.ports if "COUT" in p.first]
    print("cascade ports: " + str(pts))
    for p in pts:
        if p.endswith("0"):
            ppi(d.ports[p])
    
#for c in dsps:
#    print(f"===> cell: {c.name}:")
#    port = c.ports['PCOUT[0]']
#    print(str(port))
#    if port: pni(port.net)

vars = globals().copy()
vars.update(locals())
shell = code.InteractiveConsole(vars)
shell.interact()
