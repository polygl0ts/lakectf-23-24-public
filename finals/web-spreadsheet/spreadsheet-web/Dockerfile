FROM python:3.12

WORKDIR /app
RUN pip install Flask==3.0.3 gunicorn==22.0.0 html-sanitizer==2.4.1 requests==2.31.0
COPY . .
CMD ["gunicorn", "-b", "0.0.0.0:8888", "-w", "4", "app:app"]