from flask import Flask, request, redirect, render_template, abort
from html_sanitizer import Sanitizer
import csv
import os
import re
import requests

SHEET_PATTERN = re.compile(r'^[a-zA-Z0-9]{32}$')
DEMO_SHEETS = ['create', 'maze', 'data', 'pi']

BOT_KEY = os.getenv('BOT_KEY', 'bot_key')

app = Flask(__name__)

sanitizer = Sanitizer({
        "tags": {
            "a",
            "h1",
            "h2",
            "h3",
            "h4",
            "h5",
            "h6",
            "strong",
            "em",
            "ul",
            "ol",
            "li",
        },
        'attributes': {"a":("href",)},
        'empty': set(),
        'separate': set(),
        "keep_typographic_whitespace": True
    })

def filter_value(value):
    value = ''.join(c for c in value if ord(c)>=ord(' ') and c != ',' and c != '&')
    if '"' in value:
        value = '"' + value.replace('"', '""') + '"'
    value = sanitizer.sanitize(value)
    return value

def render_sheet(sheetname):
    try:
        with open(f'sheets/{sheetname}.csv','r') as f:
            reader = csv.reader(f)
            return render_template("sheet.jinja2", reader=reader, sheetname=sheetname)
        
    except FileNotFoundError as e:
        return abort(404)

def update_sheet(sheetname):
    try:
        with open(f'sheets/{sheetname}.csv','r') as f:
            table_csv = f.read()

    except FileNotFoundError as e:
        return abort(404)
    
    if '[INPUT]' not in table_csv:
        return redirect(f'/sheet/{sheetname}')
    else:
        print("Found at", table_csv.index('[INPUT]'))

    input_values = request.form.getlist('value')
    if len(input_values) != table_csv.count('[INPUT]'):
        return "Wrong number of inputs", 400

    for value in request.form.getlist('value'):
        table_csv = table_csv.replace('[INPUT]', filter_value(value), 1)

    if len(table_csv) > 10000:
        return "Spreadsheet too large", 400
    
    comma_count = max(line.count(',') for line in table_csv.splitlines())
    table_csv = '\n'.join(line + ','*(comma_count - line.count(',')) for line in table_csv.splitlines())

    new_sheetname = os.urandom(16).hex()

    with open(f'sheets/{new_sheetname}.csv','w') as f:
        f.write(table_csv)
        
    return redirect(f'/sheet/{new_sheetname}')
    

@app.get('/sheet/<sheetname>')
def get_sheet(sheetname):
    if SHEET_PATTERN.fullmatch(sheetname) is None and sheetname not in DEMO_SHEETS:
        return abort(404)

    return render_sheet(sheetname)

@app.post('/sheet/<sheetname>')
def post_sheet(sheetname):
    if SHEET_PATTERN.fullmatch(sheetname) is None and sheetname not in DEMO_SHEETS:
        return abort(404)

    return update_sheet(sheetname)
    
@app.get('/visit/<sheetname>')
def visit_sheet(sheetname):
    if SHEET_PATTERN.fullmatch(sheetname) is None and sheetname not in DEMO_SHEETS:
        return abort(404)
    if request.cookies.get('bot_key') is not None:
        return abort(401)

    r = requests.post(f"http://spreadsheet-bot:4000/submit", data={'url': f'http://spreadsheet-web:8888/sheet/{sheetname}'})
    r.raise_for_status()

    return render_template("visit.jinja2", message=r.text)

@app.get('/flag')
def get_flag():
    if request.cookies.get('bot_key') != BOT_KEY:
        return abort(401)
    
    return render_sheet('flag')

@app.post('/flag')
def post_flag():
    if request.cookies.get('bot_key') != BOT_KEY:
        return abort(401)
    
    return update_sheet('flag')

@app.get('/')
def index():
    return render_template("index.jinja2")

if __name__ == '__main__':
    app.run(host='::', port=8888, debug=False)