#!/usr/bin/env python3
"""Generates the Event Horizon art assets as standalone SVG files into ../assets/.
Run: python3 tools/gen_assets.py"""
import math, os, random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets')
for d in ('characters', 'enemies', 'objects', 'weapons', 'planets', 'backgrounds'):
    os.makedirs(os.path.join(OUT, d), exist_ok=True)

def save(path, w, h, body, defs=''):
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}"><defs>{defs}</defs>{body}</svg>'
    with open(os.path.join(OUT, path), 'w', encoding='utf-8') as f:
        f.write(svg)

def lg(id, c1, c2, x1=0, y1=0, x2=0, y2=1):
    return f'<linearGradient id="{id}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}"><stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient>'

def rg(id, stops):
    s = ''.join(f'<stop offset="{o}" stop-color="{c}" stop-opacity="{a}"/>' for o, c, a in stops)
    return f'<radialGradient id="{id}">{s}</radialGradient>'

# ---------- characters (96x128, facing right) ----------
def hero(name, suit, dark, acc, female):
    defs = lg('visor', '#3df0ff', '#16306a')
    hair = ('<path d="M34 34 C20 30 12 46 16 62" stroke="#7a3fd0" stroke-width="7" fill="none" stroke-linecap="round"/>'
            if female else
            '<path d="M42 18 L38 6" stroke="%s" stroke-width="3"/><circle cx="38" cy="6" r="3" fill="#ff7a2e"/>' % dark)
    pad = '' if female else f'<rect x="30" y="56" width="14" height="8" rx="4" fill="{suit}"/>'
    body = f'''
<rect x="26" y="52" width="10" height="34" rx="4" fill="{dark}"/>
<line x1="44" y1="64" x2="38" y2="88" stroke="{dark}" stroke-width="8" stroke-linecap="round"/>
<line x1="46" y1="86" x2="40" y2="112" stroke="{dark}" stroke-width="10" stroke-linecap="round"/><rect x="32" y="108" width="16" height="8" rx="3" fill="{acc}"/>
<rect x="34" y="50" width="30" height="40" rx="9" fill="{suit}"/><rect x="34" y="76" width="30" height="7" rx="3" fill="{acc}"/><circle cx="56" cy="62" r="3.5" fill="{acc}"/>{pad}
<line x1="52" y1="88" x2="60" y2="112" stroke="#b8c4ee" stroke-width="10" stroke-linecap="round"/><rect x="52" y="108" width="16" height="8" rx="3" fill="{acc}"/>
<circle cx="52" cy="34" r="17" fill="{suit}" stroke="{dark}" stroke-width="2"/>{hair}
<ellipse cx="58" cy="34" rx="11" ry="9" fill="url(#visor)"/><path d="M52 31 A7 7 0 0 1 60 28" stroke="#fff" stroke-opacity=".7" stroke-width="2" fill="none"/>
<line x1="56" y1="56" x2="66" y2="72" stroke="{suit}" stroke-width="8" stroke-linecap="round"/><circle cx="66" cy="73" r="4.5" fill="{acc}"/>'''
    save(f'characters/{name}.svg', 96, 128, body, defs)

hero('arin_male', '#d4e8ff', '#16264f', '#3df0ff', False)
hero('mira_female', '#e4dcff', '#2a1f55', '#ff5fa8', True)

# ---------- enemies ----------
def voidling():
    defs = rg('b', [(0, '#c59bff', 1), (1, '#3a1a7a', 1)]) + rg('g', [(0, '#a050ff', .45), (1, '#000', 0)])
    t = ''.join(f'<path d="M{64+math.sin(a)*12} 76 Q{64+math.sin(a)*22} 98 {64+math.sin(a)*26+(-1)**i*8} 116" stroke="#7b3fd6" stroke-width="5" fill="none" stroke-linecap="round"/>'
                for i, a in enumerate([(i - 2) * .45 for i in range(5)]))
    body = f'<circle cx="64" cy="64" r="60" fill="url(#g)"/>{t}<circle cx="64" cy="64" r="26" fill="url(#b)"/><ellipse cx="55" cy="61" rx="4.5" ry="7" fill="#ff7a2e"/><ellipse cx="73" cy="61" rx="4.5" ry="7" fill="#ff7a2e"/>'
    save('enemies/voidling.svg', 128, 128, body, defs)
voidling()

def guardian(name, rim, glow):
    defs = rg('c', [(0, '#ffe9c2', 1), (.5, rim, 1), (1, '#120a30', 1)]) + rg('g', [(0, glow, .55), (1, '#000', 0)])
    rings = ''.join(f'<ellipse cx="128" cy="128" rx="{58+i*14}" ry="{22+i*10}" transform="rotate({i*40+10} 128 128)" fill="none" stroke="{rim}" stroke-width="{5-i}"/>' for i in range(3))
    body = f'<circle cx="128" cy="128" r="124" fill="url(#g)"/>{rings}<circle cx="128" cy="128" r="42" fill="url(#c)"/><ellipse cx="132" cy="128" rx="15" ry="22" fill="#120a30"/><ellipse cx="132" cy="128" rx="6" ry="12" fill="#ff7a2e"/>'
    save(f'enemies/{name}.svg', 256, 256, body, defs)
guardian('guardian_aether_sentinel', '#7dffe0', '#7dffe0')
guardian('guardian_vortex', '#c58bff', '#9a5cff')

# ---------- objects ----------
def pod(name, broken):
    hull = '#7d86a8' if broken else '#cfd6f5'
    win = '#112' if broken else '#3df0ff'
    extra = '<path d="M52 40 L60 58 L70 50" stroke="#222" stroke-width="2" fill="none"/>' if broken else ''
    body = f'''<path d="M20 110 L6 118 L24 80 Z" fill="#8a93bd"/><path d="M76 110 L90 118 L72 80 Z" fill="#8a93bd"/>
<path d="M24 110 L24 58 Q48 0 72 58 L72 110 Z" fill="{hull}"/><rect x="24" y="82" width="48" height="7" fill="#ff7a2e"/>
<circle cx="48" cy="52" r="11" fill="{win}"/>{extra}'''
    save(f'objects/{name}.svg', 96, 124, body)
pod('escape_pod', False); pod('escape_pod_broken', True)

save('objects/crystal.svg', 40, 40, '<circle cx="20" cy="20" r="18" fill="#3df0ff" fill-opacity=".25"/><path d="M20 6 L28 20 L20 34 L12 20 Z" fill="#3df0ff"/><rect x="18" y="12" width="4" height="8" fill="#fff"/>')
save('objects/health_pack.svg', 40, 40, '<circle cx="20" cy="20" r="18" fill="#5dffb0" fill-opacity=".25"/><rect x="10" y="10" width="20" height="20" rx="5" fill="#5dffb0"/><rect x="18" y="13" width="4" height="14" fill="#062"/><rect x="13" y="18" width="14" height="4" fill="#062"/>')
save('objects/meteor.svg', 64, 64, '<circle cx="32" cy="32" r="30" fill="#ff9a3c" fill-opacity=".4"/><circle cx="32" cy="32" r="16" fill="#5b4a52"/><circle cx="27" cy="27" r="6" fill="#8a6a60"/>')
save('objects/forge_terminal.svg', 200, 200,
     '<path d="M30 190 L50 164 L150 164 L170 190 Z" fill="#1b1f45"/><rect x="36" y="70" width="18" height="100" rx="4" fill="#252b5e"/><rect x="146" y="70" width="18" height="100" rx="4" fill="#252b5e"/>'
     '<circle cx="100" cy="118" r="60" fill="url(#g)"/><path d="M100 98 L114 118 L100 138 L86 118 Z" fill="#3df0ff"/>',
     rg('g', [(0, '#3df0ff', .5), (1, '#000', 0)]))
shards = ''.join(f'<path d="M{20+i*14} 220 L{26+i*14} {220-60-(i*37)%110} L{34+i*14} 220 Z" fill="{"#7c6cff" if i%2 else "#78f0ff"}" fill-opacity=".8" stroke="#fff" stroke-opacity=".6"/>' for i in range(7))
save('objects/crystal_barrier.svg', 160, 230, shards)

# --- comet (120x64) ---
comet_defs = rg('ct', [(0, '#fff', 1), (.3, '#ffe480', 1), (1, '#ff5f30', .0)])
comet_body = (
    # tail glow (widening gradient trail)
    '<ellipse cx="30" cy="32" rx="30" ry="14" fill="#ff9a3c" fill-opacity=".18"/>'
    '<path d="M80 32 Q55 24 6 30 Q55 40 80 32 Z" fill="#ffe480" fill-opacity=".35"/>'
    '<path d="M80 32 Q60 28 20 30 Q60 36 80 32 Z" fill="#ffe480" fill-opacity=".55"/>'
    # core
    '<circle cx="80" cy="32" r="14" fill="url(#ct)"/>'
    '<circle cx="80" cy="32" r="8" fill="#fff"/>'
    # sparkle highlights
    '<circle cx="72" cy="28" r="2" fill="#fff" fill-opacity=".7"/>'
    '<circle cx="66" cy="34" r="1.4" fill="#ffe480" fill-opacity=".5"/>'
)
save('objects/comet.svg', 120, 64, comet_body, comet_defs)

# --- asteroid (80x80) – irregular rocky shape with craters ---
asteroid_defs = rg('ast', [(0, '#a89080', 1), (.6, '#6e5c52', 1), (1, '#3a2e28', 1)])
asteroid_body = (
    # irregular rocky outline
    '<path d="M40 6 L58 10 L72 22 L76 40 L70 58 L54 72 L36 76 L18 66 L6 50 L8 30 L20 12 Z" '
    'fill="url(#ast)" stroke="#4a3e38" stroke-width="2"/>'
    # craters
    '<circle cx="34" cy="30" r="8" fill="#5a4e44" fill-opacity=".6"/>'
    '<circle cx="36" cy="28" r="3" fill="#8a7a6e" fill-opacity=".5"/>'
    '<circle cx="52" cy="50" r="6" fill="#4a3e38" fill-opacity=".5"/>'
    '<circle cx="54" cy="48" r="2.2" fill="#7a6e64" fill-opacity=".4"/>'
    '<circle cx="24" cy="54" r="4.5" fill="#5a4e44" fill-opacity=".5"/>'
    # surface highlights
    '<path d="M22 16 L34 12" stroke="#c4b4a4" stroke-width="1.2" stroke-opacity=".5" stroke-linecap="round"/>'
    '<path d="M60 30 L68 36" stroke="#c4b4a4" stroke-width="1" stroke-opacity=".4" stroke-linecap="round"/>'
)
save('objects/asteroid.svg', 80, 80, asteroid_body, asteroid_defs)

# --- satellite (128x96) – orbiting satellite with solar panels ---
sat_defs = lg('spnl', '#2244aa', '#3366dd', 0, 0, 1, 0)
sat_body = (
    # solar panel left
    '<rect x="8" y="30" width="36" height="20" rx="2" fill="url(#spnl)" stroke="#5588ee" stroke-width="1.5"/>'
    '<line x1="20" y1="30" x2="20" y2="50" stroke="#5588ee" stroke-width="1" stroke-opacity=".6"/>'
    '<line x1="32" y1="30" x2="32" y2="50" stroke="#5588ee" stroke-width="1" stroke-opacity=".6"/>'
    '<line x1="8" y1="40" x2="44" y2="40" stroke="#5588ee" stroke-width="1" stroke-opacity=".6"/>'
    # solar panel right
    '<rect x="84" y="30" width="36" height="20" rx="2" fill="url(#spnl)" stroke="#5588ee" stroke-width="1.5"/>'
    '<line x1="96" y1="30" x2="96" y2="50" stroke="#5588ee" stroke-width="1" stroke-opacity=".6"/>'
    '<line x1="108" y1="30" x2="108" y2="50" stroke="#5588ee" stroke-width="1" stroke-opacity=".6"/>'
    '<line x1="84" y1="40" x2="120" y2="40" stroke="#5588ee" stroke-width="1" stroke-opacity=".6"/>'
    # struts
    '<line x1="44" y1="40" x2="50" y2="40" stroke="#cfd6f5" stroke-width="3"/>'
    '<line x1="78" y1="40" x2="84" y2="40" stroke="#cfd6f5" stroke-width="3"/>'
    # main body
    '<rect x="50" y="28" width="28" height="24" rx="4" fill="#cfd6f5" stroke="#8a93bd" stroke-width="2"/>'
    '<rect x="54" y="32" width="8" height="8" rx="1" fill="#3df0ff" fill-opacity=".6"/>'
    '<circle cx="70" cy="36" r="2.5" fill="#ff5fa8"/>'
    '<circle cx="70" cy="44" r="1.8" fill="#5dffb0"/>'
    # antenna dish
    '<line x1="64" y1="28" x2="64" y2="14" stroke="#cfd6f5" stroke-width="2"/>'
    '<path d="M56 14 Q64 6 72 14" fill="none" stroke="#cfd6f5" stroke-width="2.5" stroke-linecap="round"/>'
    '<circle cx="64" cy="14" r="2" fill="#3df0ff"/>'
    # signal rings
    '<path d="M54 10 Q64 0 74 10" fill="none" stroke="#3df0ff" stroke-width="1" stroke-opacity=".4"/>'
    '<path d="M50 8 Q64 -4 78 8" fill="none" stroke="#3df0ff" stroke-width=".8" stroke-opacity=".25"/>'
)
save('objects/satellite.svg', 128, 96, sat_body, sat_defs)

# ---------- weapons (icons) ----------
save('weapons/energy_sword.svg', 128, 128, '<g transform="rotate(-40 64 64)"><rect x="60" y="8" width="8" height="82" rx="4" fill="#3df0ff"/><rect x="62" y="12" width="4" height="74" fill="#fff"/><rect x="50" y="90" width="28" height="6" rx="3" fill="#ffd166"/><rect x="60" y="96" width="8" height="22" rx="3" fill="#3b2a7a"/></g>')
save('weapons/plasma_blaster.svg', 128, 128, '<path d="M14 62 H84 L100 54 H116 V78 H100 L90 86 H64 L56 108 H40 L46 86 H14 Z" fill="#cfd6f5" stroke="#16264f" stroke-width="3"/><rect x="92" y="60" width="18" height="12" fill="#3df0ff"/><circle cx="120" cy="66" r="6" fill="#3df0ff" fill-opacity=".5"/>')
save('weapons/phase_shield.svg', 128, 128, '<path d="M64 12 L108 28 V64 C108 90 88 108 64 118 C40 108 20 90 20 64 V28 Z" fill="#3df0ff" fill-opacity=".2" stroke="#3df0ff" stroke-width="5"/><path d="M64 34 L88 44 V64 C88 78 78 88 64 96 C50 88 40 78 40 64 V44 Z" fill="#3df0ff" fill-opacity=".35"/>')
save('weapons/gravity_lance.svg', 128, 128, '<g transform="rotate(-35 64 64)"><rect x="60" y="14" width="8" height="100" rx="4" fill="#c58bff"/><path d="M64 4 L74 26 H54 Z" fill="#e6ccff"/><circle cx="64" cy="64" r="20" fill="none" stroke="#e6ccff" stroke-width="3"/><circle cx="64" cy="64" r="32" fill="none" stroke="#c58bff" stroke-opacity=".5" stroke-width="3"/></g>')

# ---------- planets & black hole ----------
def planet(name, c1, c2, c3, bands=None, ring=None):
    defs = rg('p', [(0, c1, 1), (.55, c2, 1), (1, c3, 1)])
    b = ''
    if bands:
        b = f'<clipPath id="k"><circle cx="256" cy="256" r="200"/></clipPath><g clip-path="url(#k)">' + ''.join(f'<rect x="56" y="{110+i*52}" width="400" height="14" fill="{bands}" fill-opacity="{.12+.05*(i%3)}"/>' for i in range(8)) + '</g>'
    r = f'<ellipse cx="256" cy="256" rx="250" ry="42" transform="rotate(-18 256 256)" fill="none" stroke="{ring}" stroke-opacity=".55" stroke-width="7"/>' if ring else ''
    shade = '<circle cx="256" cy="256" r="200" fill="url(#s)"/>'
    defs += '<linearGradient id="s" x1="0" y1="0" x2="1" y2="0"><stop offset=".45" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".7"/></linearGradient>'
    save(f'planets/{name}.svg', 512, 512, f'<circle cx="256" cy="256" r="200" fill="url(#p)"/>{b}{shade}{r}', defs)
planet('fractured_moon', '#d9c9ff', '#6a5aa8', '#1a1240', '#ffffff')
planet('aether_7', '#aef7e8', '#2a9d9a', '#08202c', '#ffd166', '#ffe08a')
planet('cinder_moon', '#ffb27a', '#c4421a', '#2a0a05', '#ffd166')
planet('cryos', '#e6f8ff', '#5ea4d8', '#0b2447', '#ffffff', '#d8f4ff')
planet('vortex_prime', '#d9b0ff', '#6a3fd0', '#150736', '#3df0ff', '#c58bff')
planet('earth', '#bfe8ff', '#2a6fc4', '#06142e', '#5dffb0')

defs = rg('d', [(0, '#ff7a2e', .55), (.4, '#8a3cdc', .28), (1, '#000', 0)])
rings = ''.join(f'<ellipse cx="400" cy="400" rx="{250+i*70}" ry="{50+i*16}" transform="rotate(-20 400 400)" fill="none" stroke="{c}" stroke-width="{16-i*3}" stroke-opacity=".55"/>'
                for i, c in enumerate(['#ffaa50', '#ff5fa8', '#9a6eff', '#ffdca0']))
save('planets/black_hole_devourer.svg', 800, 800, f'<circle cx="400" cy="400" r="400" fill="url(#d)"/>{rings}<circle cx="400" cy="400" r="170" fill="#000" stroke="#ffc88c" stroke-width="4"/>', defs)

# ---------- parallax backdrops (1920x540, one per world) ----------
WORLDS = {
    'world1_fractured_moon': ('#05071a', '#1a1250', '#150f3a', '#221858', '#e8a05a', '#7a6cff'),
    'world2_aether7': ('#031a1c', '#0e4a52', '#082e33', '#0f4a50', '#ffd166', '#7dffe0'),
    'world3_cinder_moon': ('#1a0503', '#4a1208', '#2a0b07', '#4a160c', '#ff9a4a', '#ff7a2e'),
    'world4_cryos': ('#04122a', '#123c6a', '#0b2447', '#173b6a', '#b8e6ff', '#d8f4ff'),
    'world5_vortex_prime': ('#0a0220', '#2a0a5a', '#180646', '#2c0f6a', '#6a3fd0', '#c58bff'),
    'world6_earth': ('#0a1f4a', '#3d86d0', '#1a4a3a', '#26664a', '#ffd166', '#9dffb8'),
}
def ridge(rnd, base, amp, color, w=1920):
    pts = [f'0,540']
    for x in range(0, w + 24, 24):
        y = base - amp * (.5 + .5 * math.sin(x * .004 + rnd)) - amp * .4 * math.sin(x * .011 + rnd * 2) + math.sin(x * .05) * 3
        pts.append(f'{x},{y:.1f}')
    pts.append(f'{w},540')
    return f'<polygon points="{" ".join(pts)}" fill="{color}"/>'
for i, (name, (s1, s2, m1, m2, planet_c, rim)) in enumerate(WORLDS.items()):
    rnd = random.Random(i + 3)
    stars = ''.join(f'<circle cx="{rnd.random()*1920:.0f}" cy="{rnd.random()*400:.0f}" r="{rnd.choice([.8,1.1,1.6,2.2])}" fill="#fff" fill-opacity="{rnd.uniform(.35,1):.2f}"/>' for _ in range(160))
    defs = lg('sky', s1, s2) + rg('pl', [(0, planet_c, 1), (1, '#10081f', 1)])
    neb = ''.join(f'<ellipse cx="{300+k*480}" cy="{150+(k%2)*200}" rx="320" ry="150" fill="{rim}" fill-opacity=".07"/>' for k in range(4))
    body = (f'<rect width="1920" height="540" fill="url(#sky)"/>{neb}{stars}<circle cx="1400" cy="140" r="64" fill="url(#pl)"/>'
            f'<ellipse cx="1400" cy="140" rx="106" ry="20" transform="rotate(-20 1400 140)" fill="none" stroke="#fff" stroke-opacity=".2" stroke-width="3"/>'
            + ridge(1 + i, 330, 70, m1) + ridge(2.7 + i, 385, 60, m2))
    save(f'backgrounds/{name}.svg', 1920, 540, body, defs)

print('assets written to', os.path.abspath(OUT))
