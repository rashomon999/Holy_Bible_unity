import sys, json, os, glob, re
sys.path.insert(0,'/home/claude/work')
from unity import load_objects

def ref(v):
    if isinstance(v, dict) and 'fileID' in v:
        try: return int(v['fileID'])
        except: return 0
    return 0

def num(v, k, d=0.0):
    try: return float((v or {}).get(k, d))
    except: return d

def extract(path):
    objs = load_objects(path)
    quiz = None
    for o in objs.values():
        if o['kind']=='MonoBehaviour' and 'respuestaCorrecta1' in o['data']:
            quiz = o['data']; break
    if not quiz: return None
    n = 0
    while f'respuestaCorrecta{n+1}' in quiz: n += 1
    answers = [quiz.get(f'respuestaCorrecta{i}') for i in range(1, n+1)]

    comp_owner = {o['fid']: ref(o['data']['m_GameObject']) for o in objs.values() if 'm_GameObject' in o['data']}
    go_comps = {o['fid']: [ref(c.get('component')) for c in (o['data'].get('m_Component') or [])]
                for o in objs.values() if o['kind']=='GameObject'}

    go_input = {}
    for i in range(1, n+1):
        f = ref(quiz.get(f'input{i}'))
        g = comp_owner.get(f)
        if g: go_input[g] = i

    tr = {o['fid']: o for o in objs.values() if o['kind'] in ('RectTransform','Transform')}
    go_tr = {ref(o['data'].get('m_GameObject')): o['fid'] for o in tr.values()}

    # absolute position by accumulating anchoredPosition up the parent chain
    def abspos(tfid, depth=0):
        x = y = 0.0
        cur = tfid
        while cur and depth < 40:
            t = tr.get(cur)
            if not t: break
            ap = t['data'].get('m_AnchoredPosition') or {}
            x += num(ap,'x'); y += num(ap,'y')
            # anchor offset (columns anchored differently)
            amin = t['data'].get('m_AnchorMin') or {}
            x += num(amin,'x')*0.0
            cur = ref(t['data'].get('m_Father')); depth += 1
        return x, y

    items = []
    for g, idx in go_input.items():
        t = go_tr.get(g)
        if not t: continue
        x, y = abspos(t)
        items.append({'kind':'input','idx':idx,'x':x,'y':y})
    for o in objs.values():
        if o['kind']!='MonoBehaviour' or 'm_text' not in o['data']: continue
        s = str(o['data'].get('m_text') or '').replace('​','').strip()
        if not s or len(s) > 3 or s[0].isalnum(): continue
        g = comp_owner.get(o['fid'])
        # skip texts that belong to an input field subtree
        t = go_tr.get(g)
        if not t: continue
        # is ancestor an input GO?
        cur, isin = t, False
        d = 0
        c = t
        while c and d < 12:
            gg = ref(tr[c]['data'].get('m_GameObject')) if c in tr else 0
            if gg in go_input: isin = True; break
            c = ref(tr[c]['data'].get('m_Father')) if c in tr else 0
            d += 1
        if isin: continue
        x, y = abspos(t)
        items.append({'kind':'punct','txt':s,'x':x,'y':y})

    items.sort(key=lambda i: (-round(i['y']/12.0), i['x']))
    return {'n': n, 'answers': answers, 'items': items}
