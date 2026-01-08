# docker-learning-01
**「Python (Flask) でアクセスカウンターを作り、Redis (データベース) に保存する」**という構成のサンプルを作成します。

この構成では、Python環境は自分でカスタマイズするため **Dockerfile** を使い、Redisは公式のものをそのまま使うため **docker-compose.yml** で管理します。

---

### 1. Dockerfile (アプリの環境構築)

まずは、Pythonアプリを動かすための「料理のレシピ」です。

```dockerfile
# 1. ベースとなるイメージ（Python 3.9）を指定
FROM python:3.9-slim

# 2. コンテナ内の作業ディレクトリを設定
WORKDIR /app

# 3. 必要なライブラリのリストをコピーしてインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. アプリのソースコードをコンテナ内にコピー
COPY . .

# 5. アプリを起動するコマンド
CMD ["python", "app.py"]

```

---

### 2. docker-compose.yml (全体の構成図)

次に、アプリとデータベースをどう連携させるかの「指示書」です。

```yaml
version: '3.8'

services:
  # --- Webアプリのサービス ---
  web:
    build: .          # カレントディレクトリの Dockerfile を使ってビルド
    ports:
      - "5000:5000"   # PCの5000番ポートをコンテナの5000番に繋ぐ
    volumes:
      - .:/app        # PC上のコード変更をリアルタイムでコンテナに反映
    depends_on:
      - redis         # redisが起動してから起動する

  # --- データベース(Redis)のサービス ---
  redis:
    image: "redis:alpine" # 公式が用意しているイメージをそのまま使う

```

---

### 3. その他必要なファイル

このサンプルを動かすために必要な最小限のコードです。

**`app.py`** (メインのプログラム)

```python
from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379) # docker-composeで定義したサービス名で通信可能

@app.route('/')
def hello():
    count = redis.incr('hits')
    return f'こんにちは！あなたは {count} 番目の訪問者です。'

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

```

**`requirements.txt`** (必要なライブラリ)

```text
flask
redis

```

---

### 4. 実行方法

1. 上記の4つのファイルを同じフォルダに保存します。
2. ターミナル（コマンドプロンプト）でそのフォルダに移動します。
3. 以下のコマンドを実行します。

```bash
docker-compose up

```

これで、`localhost:5000` にアクセスすると、リロードするたびに数字が増えるアプリが立ち上がります。

---

### ポイントのまとめ

* **Dockerfile** は「Pythonを入れ、ライブラリを入れ、アプリをコピーする」という**自分専用の環境**を作るために使っています。
* **docker-compose.yml** は「自作のWebアプリ」と「既製品のRedis」を**ガッチャンコして繋げる**ために使っています。

このサンプルを実際にあなたのPCで動かしてみたいですか？もしエラーが出たり、特定の行の意味をもっと詳しく知りたければ教えてくださいね。