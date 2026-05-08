from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "DevOps CI/CD Pipeline Running!"

@app.route("/health")
def health():
    return "OK"

app.run(host="0.0.0.0", port=3000)
