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
