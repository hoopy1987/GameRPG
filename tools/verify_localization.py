#!/usr/bin/env python3
"""验证汉化后的文件状态"""
import re
from pathlib import Path

base = Path(r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\scripts")
errors = []

for gd in base.glob('*.gd'):
    with open(gd, 'r', encoding='utf-8') as f:
        text = f.read()
    if text.startswith('\ufeff'):
        errors.append(f'{gd.name}: has BOM')

if errors:
    for e in errors:
        print(f'[WARN] {e}')
else:
    print('All .gd files passed basic checks.')

print('\nScanning for remaining English user-visible text...')
patterns = [
    (r'text\s*=\s*"[A-Za-z]', 'UI text'),
    (r'print\s*\(\s*"[A-Za-z]', 'debug print'),
    (r'ToastManager\.show_toast\s*\(\s*"[A-Za-z]', 'toast'),
]

total_remaining = 0
for gd in sorted(base.glob('*.gd')):
    with open(gd, 'r', encoding='utf-8') as f:
        text = f.read()
    found = []
    for pat, label in patterns:
        for m in re.finditer(pat, text):
            snippet = text[max(0,m.start()-10):m.end()+20]
            found.append((label, snippet))
    if found:
        total_remaining += len(found)
        print(f'{gd.name}: {len(found)} items')
        for label, snippet in found[:3]:
            print(f'  -> [{label}] {snippet}')

print(f'\nTotal remaining English user-visible strings in scripts: {total_remaining}')
