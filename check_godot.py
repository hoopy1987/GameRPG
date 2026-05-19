import subprocess, sys, os

# Run Godot and capture ALL output
result = subprocess.run(
    [r'D:\Godot\godot.bat', '--headless', '--verbose', '--path', r'C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg', '--editor', '--quit'],
    capture_output=True,
    text=True,
    encoding='utf-8',
    errors='replace'
)

with open(r'C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\godot_full.log', 'w', encoding='utf-8') as f:
    f.write(f'=== STDOUT ===\n{result.stdout}\n')
    f.write(f'=== STDERR ===\n{result.stderr}\n')
    f.write(f'=== RETURN CODE ===\n{result.returncode}\n')

print(f'Exit code: {result.returncode}')
print(f'Stdout lines: {len(result.stdout.splitlines())}')
print(f'Stderr lines: {len(result.stderr.splitlines())}')

# Check for error keywords
errors = []
for line in result.stdout.splitlines() + result.stderr.splitlines():
    lower = line.lower()
    if any(k in lower for k in ['error', 'failed', 'cannot', 'invalid', 'broken', 'parse', 'exception']):
        errors.append(line)

if errors:
    print('\n=== ERRORS FOUND ===')
    for e in errors:
        print(e)
else:
    print('\nNo errors found in output.')
