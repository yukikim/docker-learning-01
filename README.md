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

---

## Templates（テンプレート）
Flaskで見栄えの良い画面を作るには、**「Templates（テンプレート）」**という仕組みを使います。

Pythonコードの中に直接HTMLを書くのではなく、専用のHTMLファイルを用意し、そこに **Jinja2（ジンジャーツー）** というエンジンを使ってデータを流し込みます。さらに、モダンな見た目にするために **Bootstrap** などのCSSフレームワークを組み合わせるのが一般的です。

以下の手順でプロジェクトを拡張してみましょう。

---

## 1. ディレクトリ構造の変更

Flaskの決まりとして、HTMLファイルは `templates` という名前のフォルダに入れる必要があります。

```text
flask-app/
├── app.py
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
└── templates/           # ← 新しく作成
    └── index.html       # ← 新しく作成

```

---

## 2. HTMLファイル（テンプレート）の作成

世界中で使われているCSSフレームワーク **Bootstrap** を読み込んで、一瞬でおしゃれなデザインにします。

**`templates/index.html`**

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flask Docker App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .main-card { margin-top: 100px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card main-card p-5 text-center">
                    <h1 class="display-4 text-primary">Flask & Docker</h1>
                    <p class="lead mt-3">{{ message }}</p> <hr>
                    <p class="text-muted">この画面はHTMLテンプレートで作成されています。</p>
                    <button class="btn btn-primary mt-3">詳しく見る</button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>

```

---

## 3. Pythonコードの修正

`render_template` という関数を使って、作成したHTMLを呼び出すように書き換えます。

**`app.py`**

```python
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def hello():
    # テンプレートに渡す変数
    msg = "モダンなデザインへようこそ！"
    # index.html を読み込み、変数を渡す
    return render_template('index.html', message=msg)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

```

---

## 4. 実行と確認

すでに `docker-compose up` でコンテナが動いている場合は、ファイルを保存するだけで自動的に反映されます（もし反映されなければ、`Ctrl + C` で一度止めてから再度 `docker-compose up` してください）。

ブラウザで `http://localhost:5000` を開くと、青い文字やカード型のデザインが適用された綺麗な画面が表示されるはずです。

---

### 今回のポイント

* **分離:** デザイン（HTML）とロジック（Python）を分けることで、管理がしやすくなりました。
* **Jinja2:** `{{ message }}` のように書くことで、Python側のデータを自由な場所に表示できます。
* **Bootstrap:** CSSを自分で細かく書かなくても、プロっぽいレイアウトが作れます。

---

## 複数ページの作成
Flaskで複数ページを作るには、**「新しいルーティング（URL）を追加する」**ことと、**「共通レイアウト（ベーステンプレート）を使って効率化する」**という2つのステップを組み合わせるのが王道です。

ページを増やすたびに同じHTML（ヘッダーやフッターなど）を書くのは大変なので、Flaskの便利な仕組みを使ってみましょう。

---

## 1. テンプレートの共通化（継承）

まず、全ページで共通して使う「枠組み」を作ります。

**`templates/base.html`** （共通枠）
`{% block content %}{% endblock %}` の部分が、各ページの中身に入れ替わる場所になります。

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>{% block title %}{% endblock %} - My Flask App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand navbar-dark bg-dark mb-4">
        <div class="container">
            <a class="navbar-brand" href="/">Flask App</a>
            <ul class="navbar-nav">
                <li class="nav-item"><a class="nav-link" href="/">ホーム</a></li>
                <li class="nav-item"><a class="nav-link" href="/about">アプリについて</a></li>
            </ul>
        </div>
    </nav>

    <div class="container">
        {% block content %}{% endblock %}
    </div>
</body>
</html>

```

---

## 2. 各ページの中身を作る

共通枠を読み込む（継承する）ように各ページを作成します。

**`templates/index.html`** （ホーム画面）

```html
{% extends "base.html" %}

{% block title %}ホーム{% endblock %}

{% block content %}
    <div class="jumbotron">
        <h1>ようこそ！</h1>
        <p>これはトップページです。</p>
    </div>
{% endblock %}

```

**`templates/about.html`** （新しく作る「アプリについて」ページ）

```html
{% extends "base.html" %}

{% block title %}About{% endblock %}

{% block content %}
    <h1>このアプリについて</h1>
    <p>DockerとFlaskを使って、複数ページのサイトを構築する練習をしています。</p>
{% endblock %}

```

---

## 3. PythonコードでURL（ルート）を増やす

それぞれのURLにアクセスされたとき、どのHTMLを表示するかを定義します。

**`app.py`**

```python
from flask import Flask, render_template

app = Flask(__name__)

# ホーム画面
@app.route('/')
def index():
    return render_template('index.html')

# 「アプリについて」画面を追加
@app.route('/about')
def about():
    return render_template('about.html')

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

```

---

## 4. 動作確認

1. `app.py` を保存し、`templates` フォルダ内に新しいファイルがあることを確認します。
2. ブラウザで `http://localhost:5000/` を開くとホーム画面が表示されます。
3. 画面上のナビゲーションバーの「アプリについて」をクリックするか、`http://localhost:5000/about` に直接アクセスすると、新しいページに切り替わります。

---

### まとめ

* **`@app.route('/パス')`** を増やすことで、ページを無限に増やせます。
* **`render_template`** で、URLごとに表示するHTMLを指定します。
* **Template Inheritance（継承）** を使えば、ヘッダーなどを一箇所直すだけで全ページに反映されるので非常に楽です。
