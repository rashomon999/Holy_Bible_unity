import sys, json, os, glob, re
sys.path.insert(0,'/home/claude/work')
from order import ordered

META = {
 'Apocalipsis_21_4': ('apocalipsis_21_4', 1, 'Apocalipsis 21:4-8', 'Revelation 21:4-8'),
 'eclesiastes':      ('eclesiastes_9_7_10', 2, 'Eclesiastés 9:7-10', 'Ecclesiastes 9:7-10'),
 'Job_1_18_22':      ('job_1_18_22', 3, 'Job 1:18-22', 'Job 1:18-22'),
 'Romanos_2_12_16':  ('romanos_2_12_16', 4, 'Romanos 2:12-16', 'Romans 2:12-16'),
 'Salmo_23':         ('salmo_23', 5, 'Salmo 23', 'Psalm 23'),
 'Timoteo':          ('timoteo_2_9_13', 6, '1 Timoteo 2:9-13', '1 Timothy 2:9-13'),
}
PLACEHOLDER = re.compile(r'^(Respuesta|Answer)\s*\d+$', re.I)

out = {}
for p in sorted(glob.glob('/mnt/user-data/uploads/Holy_Bible/Assets/Scenes/*/*.unity')):
    base = os.path.basename(p)[:-len('.unity')]
    lang, key = base.split('_', 1)
    pid, order, es_title, en_title = META[key]
    r = ordered(p)
    seq = r['seq']
    used = set()
    segs = []
    for i, (kind, val) in enumerate(seq):
        if kind != 'input' or val in used: continue
        used.add(val)
        a = r['answers'][val-1]
        a = ('' if a is None else str(a)).replace('\u0133','ij').replace('\u0132','IJ').strip()
        if not a or PLACEHOLDER.match(a): continue
        punct = ''
        if i+1 < len(seq) and seq[i+1][0] == 'punct':
            punct = seq[i+1][1]
        segs.append({'answer': a, 'punct': punct})
    # Respuestas que quedaron en el script pero cuyo input ya no existe en la
    # escena: se agregan solo si no son un duplicado de una frase ya presente
    # (en Unity quedaron varias copias huerfanas de campos borrados).
    known = {s['answer'] for s in segs}
    for idx in range(1, r['n']+1):
        if idx in used: continue
        a = r['answers'][idx-1]
        a = ('' if a is None else str(a)).replace('\u0133','ij').replace('\u0132','IJ').strip()
        if not a or PLACEHOLDER.match(a) or a in known: continue
        known.add(a)
        segs.append({'answer': a, 'punct': ''})
    if segs and not segs[-1]['punct']:
        segs[-1]['punct'] = '.'
    for n, s in enumerate(segs, 1):
        s['i'] = n
    entry = out.setdefault(pid, {'id': pid, 'order': order, 'locales': {}})
    entry['locales'][lang] = {
        'title': es_title if lang == 'ES' else en_title,
        'segments': [{'i': s['i'], 'answer': s['answer'], 'punct': s['punct']} for s in segs],
    }

data = {'version': 1, 'passages': sorted(out.values(), key=lambda x: x['order'])}
os.makedirs('/home/claude/work/holy_bible/assets/data', exist_ok=True)
json.dump(data, open('/home/claude/work/holy_bible/assets/data/passages.json', 'w'),
          ensure_ascii=False, indent=2)
for pa in data['passages']:
    for lg in ('ES', 'EN'):
        loc = pa['locales'][lg]
        txt = ' '.join(s['answer'] + s['punct'] for s in loc['segments'])
        print(f"{loc['title']:24s} {lg} {len(loc['segments']):3d}  {txt[:90]}")
