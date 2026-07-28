import yaml, re

class L(yaml.SafeLoader): pass
def unk(loader, suffix, node):
    if isinstance(node, yaml.MappingNode): return loader.construct_mapping(node, deep=True)
    if isinstance(node, yaml.SequenceNode): return loader.construct_sequence(node, deep=True)
    return loader.construct_scalar(node)
L.add_multi_constructor('', unk)
L.add_multi_constructor('tag:unity3d.com,2011:', unk)

HDR = re.compile(r'^--- !u!(\d+) &(\d+).*$', re.M)

def load_objects(path):
    raw = open(path, encoding='utf-8', errors='replace').read()
    raw = re.sub(r'^%(TAG|YAML).*$', '', raw, flags=re.M)
    parts = []
    matches = list(HDR.finditer(raw))
    for i, m in enumerate(matches):
        start = m.end()
        end = matches[i+1].start() if i+1 < len(matches) else len(raw)
        parts.append((int(m.group(1)), int(m.group(2)), raw[start:end]))
    objs = {}
    for cls, fid, body in parts:
        try:
            d = yaml.load(body, Loader=L)
        except Exception:
            continue
        if not isinstance(d, dict) or not d: continue
        kind = list(d.keys())[0]
        objs[fid] = {'cls': cls, 'fid': fid, 'kind': kind, 'data': d[kind] or {}}
    return objs
