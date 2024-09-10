#! /bin/bash

# Чтобы скрипт завершался, если есть ошибки
set -xe

# Устанавливаем переменные
echo "VERSION=${VERSION}" > deploy.env
echo "CI_REGISTRY_IMAGE=${CI_REGISTRY_IMAGE}" >> deploy.env
echo REPORT_PATH="/var/www-data/htdocs" >> deploy.env

# Подключаемся к хранилищу образов.
sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}

# Получаем ID запущенных контейнеров blue/green.
BLUE=$(docker ps -f name=blue --format "{{.ID}}")
GREEN=$(docker ps -f name=green --format "{{.ID}}")

# Проверяем запущенную версию и устанавливаем новую.
if [ -n "$${q}BLUE" ]; then # [Синий] -> [Зеленый]
     echo "Blue version is active. Deploying green version."
     echo REPLICAS_GREEN=1 >> deploy.env
     sudo docker compose --env-file deploy.env up -d backend-green --pull "always" --force-recreate
     
     # Проверям что backend запустился и удаляем [Синий]. Таймаут 1m.
     counter=0
     while [ $${q}counter -le 12 ]; do
          if [ "$(docker ps -f name=green -f health=healthy --format "{{.ID}}")" ]; then
               docker rm -f $${q}BLUE
               break
          else
               sleep 5s
               let "counter+=1"
          fi
     done

elif [ -n "$${q}GREEN" ]; then # [Зеленый] -> [Синий]
     echo "Green version is active. Deploying blue version."
     echo REPLICAS_BLUE=1 >> deploy.env
     sudo docker compose --env-file deploy.env up -d backend-blue --pull "always" --force-recreate
     
     # Проверям что backend запустился и удаляем [Зеленый]. Таймаут 1m.
     counter=0
     while [ $${q}counter -le 12 ]; do
          if [ "$(docker ps -f name=blue -f health=healthy --format "{{.ID}}")" ]; then
               docker rm -f $${q}GREEN
               break
          else
               sleep 5s
               let "counter+=1"
          fi
     done

else # Пусто. Запускаем [Синий] по умолчанию.
     echo "No deploy version. Deploying blue version as default."
     echo REPLICAS_BLUE=1 >> deploy.env
     sudo docker compose --env-file deploy.env up -d backend-blue --pull "always" --force-recreate
fi

sudo rm -f /home/${DEV_USER}/docker-compose.yml || true
sudo rm -f deploy.env || true