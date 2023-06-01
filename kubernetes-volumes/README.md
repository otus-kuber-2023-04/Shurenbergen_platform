### Выполненное Д/З №4 kubernetes-volumes

- [x] Основное ДЗ
- [x] Задание со *

## В процессе сделано:
 - Запущен kind
 - Создан statefulSet minio
 - Создан headless service для minio
 - Проверена работа minio
 - Создан файл с секретами логина и пароля
 - Произведена замена переменных логина и пароля в statefulSet
 - проверена передача секретов в под

## Как проверить работоспособность:
### добавление секретов
```shell
kubectl apply -f mysecret.yaml
```
### запуск statefulset
```shell
kubectl apply -f minio-statefulset.yaml
```
### запуск headless service
```shell
kubectl apply -f minio-headlessservice.yaml
```
### проброс портов для UI
```shell
kubectl port-forward minio-0 9000:9000
```
### можно залогиниться в UI хранлища по адресу http://localhost:9000
## PR checklist:
 - [x] Выставлен label с темой домашнего задания