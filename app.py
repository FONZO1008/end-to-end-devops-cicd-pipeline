from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return "DevOps CI/CD Pipeline Running!"


@app.route("/health")
def health():
    return "OK"
