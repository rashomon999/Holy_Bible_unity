import sys; sys.path.insert(0,'/home/claude/work')
from extract2 import extract as raw_extract

def ordered(path):
    r = raw_extract(path)
    if not r: return None
    items = r['items']
    inputs = [i for i in items if i['kind']=='input']
    puncts = [i for i in items if i['kind']=='punct']
    inputs.sort(key=lambda i: i['idx'])
    # cluster inputs into rows by y
    rows = []
    for i in sorted(inputs, key=lambda i: -i['y']):
        for row in rows:
            if abs(row['y'] - i['y']) <= 30:
                row['els'].append(i); row['y'] = sum(e['y'] for e in row['els'])/len(row['els']); break
        else:
            rows.append({'y': i['y'], 'els': [i]})
    for p in puncts:
        if not rows: break
        best = min(rows, key=lambda r_: abs(r_['y'] - p['y']))
        if abs(best['y'] - p['y']) <= 90:
            best['els'].append(p)
    rows.sort(key=lambda r_: -r_['y'])
    seq = []
    for row in rows:
        for e in sorted(row['els'], key=lambda e: e['x']):
            seq.append(('input', e['idx']) if e['kind']=='input' else ('punct', e['txt']))
    return {'n': r['n'], 'answers': r['answers'], 'seq': seq}
