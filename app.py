from flask import Flask, render_template
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379) # docker-composeで定義したサービス名で通信可能

@app.route('/')
def hello():
    count = redis.incr('hits')
    return render_template('index.html', message=f'こんにちは！あなたは {count} 番目の訪問者です。')

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8800)
