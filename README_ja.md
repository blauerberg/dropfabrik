# Drop Fabrik

Drop FabrikにはDrupalの開発を素早く行うためのDockerのコンテナーセットが含まれています。
開発マシンのスペックに応じて4種類のコンフィグが用意されており、5分から10分程度でDrupalの環境をDocker上に構築することができます。
また、ローカルマシン上で構築したものと完全に同じ環境を、AWSなどのクラウドサービスにデプロイすることもできます。

デモ動画はこちら: https://youtu.be/5VyFQplLH9M

## 概要

以下のコンテナー郡で構成されています。

| Container | Service name | Image | Exposed port |
| --------- | ------------ | ----- | ------------ |
| Nginx | web | <a href="https://hub.docker.com/_/nginx/" target="_blank">nginx</a> | 80 |
| MariaDB | db | <a href="https://hub.docker.com/_/mariadb/" target="_blank">mariadb</a> | 3306 |
| PHP-FPM 5.6 / 7.0 / 7.1 | php | <a href="https://hub.docker.com/r/blauerberg/drupal-php/" target="_blank">blauerberg/drupal-php</a> | 9000 (for Xdebug) |
| mailhog | mailhog | <a href="https://hub.docker.com/r/mailhog/mailhog/" target="_blank">mailhog/mailhog</a> | 8025 (HTTP server) |

## 動作環境

- macOS Sierra上で動作する[Docker for MAC](https://docs.docker.com/docker-for-mac/)の最新版
- Windows 10上で動作する[Docker for Windows](https://docs.docker.com/docker-for-windows/)の最新版
- Linux上で動作する[Docker engine](https://docs.docker.com/engine/installation/linux/ubuntulinux/)の最新版
- Docker for Windowsを使う場合は、 [共有ドライブ](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/) を有効にしてください。


## Getting started

### コンテナーを起動する

初めにレポジトリをクローンします。
```bash
$ git clone https://github.com/blauerberg/dropfabrik.git
$ cd dropfabrik
```

レポジトリの中には開発マシンのスペックに応じた4種類のコンフィグが用意されています。

- [micro](https://github.com/blauerberg/dropfabrik/tree/master/micro): メモリが4GB以下のマシン向け
- [small](https://github.com/blauerberg/dropfabrik/tree/master/small): メモリが4〜8GBのマシン向け
- [large](https://github.com/blauerberg/dropfabrik/tree/master/large): メモリが8〜16GBのマシン向け
- [xlarge](https://github.com/blauerberg/dropfabrik/tree/master/xlarge): 16GB以上のメモリを持つマシン向け

例えば、メモリが8GBのWindowsもしくはmacOSを使っている場合は、`small` を利用すると良いでしょう。
```bash
$ cd small
```

次にDrupalのソースコードをマウントするためのディレクトリを作成します。
デフォルトの設定では、ホストマシンの `volumes/drupal` をコンテナーのデータボリュームとしてマウントします。

```bash
$ mkdir -p volumes/drupal
```

Drupalのソースコードをダウンロードして展開します。
```bash
# Note: replace "X.Y.Z" in below to  Drupal's version you'd like to use.
$ curl https://ftp.drupal.org/files/projects/drupal-X.Y.Z.tar.gz | tar zx --strip=1 -C volumes/drupal
```

コンテナーを生成して起動します。
```bash
$ docker-compose up -d
```

ホストマシンがLinuxの場合は、ディレクトリの権限を修正する必要があります。
```bash
$ docker-compose exec php chown -R www-data:www-data /var/www/html/sites/default
```

Drupalにアクセスします。
```bash
$ open http://localhost # もしくはブラウザで http://localhost へアクセス
```

Note: `docker-compose` コマンドは `docker-compose.yml` があるディレクトリ内で実行する必要があります。

### Drupalのインストール

データベースの認証情報は `docker-compose.override.yml` で設定されています。
デフォルト値は以下になります。

- Database Name: `drupal`
- Username: `drupal`
- Password: `drupal`

詳細については https://hub.docker.com/_/mariadb/ の "Environment Variables" を参照してください。

このコンテナーセットではnginx、mariadb、php-fpmは全て別々のコンテナーで動作します。
そのため、インストール時にデータベースサーバーのホスト名に `localhost` ではなく `db` を指定する必要があります。

ブラウザからウィザードでインストールする代わりに、以下のようにDrushを使ってインストールすることもできます。

```bash
$ docker-compose exec php drush -y --root="/var/www/html" site-install standard --site-name="Drupal on Docker" --account-name="drupal" --account-pass="drupal" --db-url="mysql://drupal:drupal@db/drupal" --locale=ja
$ docker-compose exec php drush -y config-set system.theme admin bartik
```

## コンテナーを停止する

```
$ docker-compose stop
```

## Other tips

### コンテナの内部にアクセスする

sshではなく `docker-compose exec` を使いましょう。

```bash
$ docker-compose exec {Service name} /bin/bash
# ex. docker-compose exec php /bin/bash
```

### Drushを使う

Drushは`php`コンテナーにインストールされています。

```bash
$ docker-compose exec php drush st
```

### 既存のサイトのデータベースをリストアする

gzipで圧縮されたSQLのダンプファイルを `initdb.sql.gz` という名前で配置し、`docker-compose.override.yml` の以下の行のコメントアウトを解除してください。
コンテナの生成時に一度だけこのファイルがロードされ、データベースが復元されます。

```
- ./initdb.sql.gz:/docker-entrypoint-initdb.d/initdb.sql.gz
```

### データベースに接続する

Drush経由で接続する:
```bash
$ docker-compose exec php drush sql-cli
```

データベースコンテナーは 127.0.0.1上でport 3306をlistenします。そのため、[MysqlWorkbench](https://www.mysql.com/products/workbench/) や [Sequel Pro](https://www.sequelpro.com/) のようなホストOS上で動作するGUIアプリケーションからコンテナー内のデータベースに接続することができます。

### Production環境へのデプロイ (example)

このコンテナーセットは(例えばAmazon EC2のような)Production環境へデプロイすることも出来ます。
例えば、Amazon EC2へのデプロイは次のように行います。

まず、Amazon EC2にDocker engineを作成します。
```
$ docker-machine create --driver amazonec2 --amazonec2-instance-type t2.large --amazonec2-region ap-northeast-1 --amazonec2-zone c dropfabrik
```

Note: デフォルトでは `docker-machine` というセキュリティーグループが使われますが、このグループは全てのHTTP通信を拒否します。そのため、セキュリティグループの設定を変更しHTTP通信を許可するようにしてください。

作成したDocker engineを使うために環境変数を設定します。
```
eval $(docker-machine env dropfabrik)
```

次に、Drupalのソースコードとデータベースのダンプを配置します。
```
$ git clone https://github.com/blauerberg/dropfabrik.git
$ cd dropfabrik/standard

# Drupalのソースコードをダウンロード
$ mkdir volumes
$ git clone {YOUR_GIT_REPO_URI} volumes/drupal
# 既存のサイトのデータベースのダンプを mysql/initdb.sql.gz という名前でコピーする。
$ cp /some/path/your_site_db.sql.gz mysql/initdb.sql.gz

もしくは、新しいサイトを立ち上げるためにデフォルトのDrupalのソースコードをダウンロードします。

$ mkdir -p volumes/drupal
$ curl https://ftp.drupal.org/files/projects/drupal-X.Y.Z.tar.gz | tar zx --strip=1 -C volumes/drupal
# 英語以外の言語でインストールを行いたい場合は、 sites/default/files/translations ディレクトリを作成します。
$ mkdir -p volumes/drupal/sites/default/files/translations
```

最後にイメージを生成してデプロイします。
```
$ docker-compose -f docker-compose.yml -f docker-compose.production.yml up --build
```

Note: Note: `docker-compose.production.yml` はシンプルなユースケース向けのサンプルです。セキュリティなどの設定は必要に応じて変更してください。

## Supporting Organizations
- https://annai.co.jp
