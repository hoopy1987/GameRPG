with open(r'C:\Users\lenovo\AppData\Roaming\Godot\app_userdata\炭火村传说\save_0.json', 'rb') as f:
    raw = f.read()
print('Raw bytes length:', len(raw))

# Find the name field
start = raw.find(b'"name"')
if start >= 0:
    snippet = raw[start:start+50]
    print('Raw bytes around name:', snippet)
    print('Hex:', snippet.hex())
    
    try:
        decoded = snippet.decode('utf-8')
        print('UTF-8 decoded:', decoded)
    except Exception as e:
        print('UTF-8 decode error:', e)
    
    try:
        decoded = snippet.decode('gbk')
        print('GBK decoded:', decoded)
    except Exception as e:
        print('GBK decode error:', e)
        
    try:
        decoded = snippet.decode('latin-1')
        print('Latin-1 decoded:', decoded)
    except Exception as e:
        print('Latin-1 decode error:', e)

# Also check the full file decoded as UTF-8
try:
    full = raw.decode('utf-8')
    print('\nFull file is valid UTF-8')
except Exception as e:
    print('\nFull file UTF-8 error:', e)
    
try:
    full = raw.decode('gbk')
    print('Full file is valid GBK')
except Exception as e:
    print('Full file GBK error:', e)
