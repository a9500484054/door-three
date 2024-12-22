#!/usr/bin/env sh

# Остановка выполнения при ошибках
set -e

# Сборка проекта
npm run build

# Переход в папку сборки
cd dist

# Инициализация Git в папке сборки
git init
git add -A
git commit -m 'deploy'

# Деплой в ветку `gh-pages`
git push -f https://github.com/a9500484054/door-three.git main:gh-pages

cd -