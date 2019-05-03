#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

export BEEUCSITE="https://www.beeuc.com"
envsubst < _config.yml.template > _config.yml
rm -rf ./_site
bundle exec jekyll build

# 进入生成的文件夹
cd ./_site/
rm github*
rm package*
rm gulp*
rm README*



git init
git add -A
git commit -m 'deploy'

# 如果发布到 https://<USERNAME>.github.io
git push -f git@github.com:beeuc-corp/develop.git master

# 如果发布到 https://<USERNAME>.github.io/<REPO>
# git push -f git@github.com:<USERNAME>/<REPO>.git master:gh-pages

cd -
