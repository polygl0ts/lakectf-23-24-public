from flask import Flask, render_template, request, session, redirect, url_for
import sqlite3 
import secrets
from uuid import uuid1
from hashlib import md5
from pyotp import TOTP
from base64 import b32encode
from os import environ

FLAG = environ.get("FLAG", "EPFL{fake_flag}")

app = Flask(__name__)
app.config['SECRET_KEY'] = secrets.token_hex(20)
app.config["mac"] = open("/sys/class/net/eth0/address").read().strip()

db = sqlite3.connect('database.db',check_same_thread=False) 
db.execute('CREATE TABLE IF NOT EXISTS USERS (id INTEGER PRIMARY KEY, username TEXT, email TEXT, password TEXT)') 

#create admin acc
db.execute("INSERT INTO USERS (username,email,password) VALUES (?,?,?)", ("admin","admin@polygl0ts.ch", secrets.token_hex(20))) 

OTP_DIC = {}

def create_otp(username):
	id = db.execute("SELECT id FROM USERS WHERE username = ?", (username,)).fetchone()[0]
	uuid = uuid1(clock_seq=id).hex.encode()
	totp = TOTP(b32encode(uuid))
	OTP_DIC[md5(uuid).hexdigest()] = {"totp":totp,"username":username}
	return md5(uuid).hexdigest()

def new_pass(username):
	new_password=secrets.token_hex(20)
	db.execute("UPDATE USERS SET password = ? WHERE username = ?", (new_password, username))
	return new_password


@app.route('/')
def index():
	if 'username' in session:
		return render_template("index.html",flag=FLAG)
	return redirect(url_for('login'))


@app.route('/register', methods=['GET', 'POST']) 
def join(): 
	if request.method == 'POST':
		username = request.form['username']
		email = request.form['email']
		password = request.form['password']
		
		if not (username and email and password):
			return render_template('register.html',error="Missing information")

		if not db.execute("SELECT * FROM USERS WHERE username=?", (username,)).fetchone():
			db.execute("INSERT INTO USERS (username,email,password) VALUES (?,?,?)", (username, email, password)) 
			session['username'] = request.form['username']
			return redirect(url_for("index"))
		
		return render_template('register.html',error="Username already exist")
	else:
		return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
	if request.method == 'POST':
		username = request.form['username']
		password = request.form['password']

		if not (username and password):
			return render_template('login.html',error="Missing information")

		if db.execute("SELECT username FROM USERS WHERE username=? AND password=?", (username, password)).fetchone():
			session['username'] = username
			return redirect(url_for('index'))
		else:
			return render_template('login.html', error="Login failed")
	return render_template("login.html")


@app.route('/forgotpass', methods=['GET', 'POST'])
def forgotpass():
	if request.method == 'GET':
		return render_template("forgotpass.html")
	else:
		username = request.form["username"]
		if db.execute("SELECT * FROM USERS WHERE username=?", (username,)).fetchone():
			md5_uuid = create_otp(username)
			return redirect(f"/forgotpass/{md5_uuid}")
		else:
			return render_template("forgotpass.html", error="Username does not exist")


@app.route('/forgotpass/<string:md5_uuid>/', methods=['GET', 'POST'])
def user_view(md5_uuid):
	if request.method == 'GET':
		return render_template("forgotpass.html", md5_uuid=md5_uuid)
	else:
		if md5_uuid in OTP_DIC:
			code = request.form["otp"]
			totp = OTP_DIC[md5_uuid]["totp"]
			username = OTP_DIC[md5_uuid]["username"]
			#TODO send mail with otp code
			if totp.verify(code):
				new_password = new_pass(username)
				return render_template("forgotpass.html", md5_uuid=md5_uuid, success=f"New password: {new_password}")
			return render_template("forgotpass.html", md5_uuid=md5_uuid, error=f"Wrong otp code")
		else:
			return render_template("forgotpass.html", md5_uuid=md5_uuid, error="md5_uuid does not exist")


@app.route('/logout')
def logout():
	session.pop('username', None)
	return redirect(url_for("login"))


if __name__ == '__main__': 
	app.run(host='0.0.0.0',port=12004) 