import urllib.request, json

try:
    req = urllib.request.Request('https://api.telegram.org/bot8791743330:AAHhyV3I68c5i3IjCurjIqT45-Feq6j14K8/getUpdates')
    with urllib.request.urlopen(req) as resp:
        res = json.loads(resp.read().decode())
        print(res)
except Exception as e:
    print(e)
