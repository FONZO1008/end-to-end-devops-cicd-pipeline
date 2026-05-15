FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Don't run as root
RUN useradd -m appuser
USER appuser

EXPOSE 3000

# Use gunicorn instead of Flask dev server
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:3000", "app:app"]
