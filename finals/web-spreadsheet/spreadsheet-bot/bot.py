from selenium import webdriver
import os
import time

BOT_KEY = os.getenv("BOT_KEY")

def visit(url):
  chrome_options=webdriver.ChromeOptions()
  chrome_options.add_argument("--headless")
  chrome_options.add_argument("--no-sandbox")
  driver = webdriver.Chrome(chrome_options=chrome_options)
  driver.get('http://spreadsheet-web:8888/')
  driver.add_cookie({'name' : 'bot_key', 'value' : BOT_KEY, 'sameSite' : 'Strict', 'domain': 'spreadsheet-web', 'httpOnly': True})
  driver.get(url)
  time.sleep(3)
  driver.quit()
