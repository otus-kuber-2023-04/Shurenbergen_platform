# Выполнено ДЗ №2

 - [x] Основное ДЗ
 - [x] ReplicaSet
 - [x] Deployment
 - [x] Deployment | Задание со *
 - [x] Probes
 - [x] DaemonSet | Задание со *
 - [x] DaemonSet | Задание с **

## В процессе сделано:
 - Установлен kind и создан кластер: 1 мастер и 3 воркера
 - Изучены основы работы с ReplicaSet
 - Не хватало селектора меток
 - Проверена отказоустойчивость репликасета (после удаления пода, поднимаются новые)
 - Версия образа не обновилась потому что для этих целей надо использовать Deployment, в данной сущности мы управляем количеством реплик
 - Создан манифест для paymentService, запушены имейджи с двумя тэгами в репозиторий докерхаба
 - Изучены основы работы с Deployment
 - Изучена работа с обновлением Deployment
 - Изучена работа с Rollback Deployment
 - Изчена документация kubernetes по использованию maxSurge и masUnavaliable
 - Созданы и протестированы дополнительные деплойменты для стратегий развертывания
 - Изучены основы работы с Probes
 - Изучены основы работы с DaemonSet
 - Создан манифест для node-exporter взятый за основу из гитхаб
 - Модернизирован для деплоя на мастер ноде (control-plane), протестирована работа

## Как запустить проект:
 - предварительно необходимо установить kind.
 - затем клонируем репозиторй и переходим в дирректорию kubernetes-controllers

 ```
 git clone https://github.com/otus-kuber-2023-04/Shurenbergen_platform.git && cd kubernetes-controllers
 ```
- cоздаем кластер из конфига

 ```
 kind create cluster --config kind-config.yaml
 ```
 - убедимся в работе кластера
 ```
 kubectl get nodes 
 ```
 - применяем манифест с репликасет фронтенд приложения
 ```
 kubectl apply -f frontend-replicaset.yaml 
 ```
 - применяем манифест с репликасет платежного приложения
 ```
 kubectl apply -f paymentservice-replicaset.yaml
 ```
 - применяем манифест с деплоймент платежного приложения
 ```
 kubectl apply -f paymentservice-deployment.yaml
 ```
 - проверяем деплойменты
 ```
 kubectl get deployments
 ```
 - для проверки стратегий деплоймента требуется применить манифест, затем изменить тэг (версию имейджа), затем снова применить манифест с отслеживанием в реальном времени
 ```
 kubectl apply -f paymentservice-deployment-bg.yaml  | kubectl get pods -l app=paymentservice -w
 ```
 ```
 kubectl apply -f paymentservice-deployment-reverse.yaml  | kubectl get pods -l app=paymentservice -w
 ```
- для проверки риднес пробы применяем деплоймент и дескрайбим под
 ```
 kubectl apply -f frontend-deployment.yaml
 kubectl describe pod
 ```
- работы экспортера применяем демонсет, пробрасываем порты и курлим метрики
 ```
 kubectl apply -f node-exporter-daemonset.yaml
 kubectl port-forward node-exporter-<номер пода> 9100:9100 
 curl localhost:9100/metrics
 ```
 - по количеству нод экспортеров можно понять на скольких нодах работает экспортер (4 ноды значит и 4 экспортера)
 
## Как проверить работоспособность:
 - перейти по ссылке http://localhost:9100/metrics - метрики экспортера

## PR checklist:
 - [x] Выставлен label с темой домашнего задания
