from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello, This is a simple Python App!"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')