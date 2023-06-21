### Выполнено ДЗ №6 kubernetes-monitoring

- [x] Homework done

## В процессе сделано:
 - собран и запушен имейдж - нгинкс со статусом
 - созданы деплойменты роли сервисы и тд
 - подняты 3 реплики нгинкс
 - поднят 1 экспортер
 - поднят 1 прометей
 - проброшены порты
 - проверена работа сервисов через консоль, а так же через GUI

## Запуск:

```
cd kubernetes-monitoring && \
kubectl apply -f nginx.yaml && \
kubectl apply -f nginx-exporter.yaml && \
kubectl apply -f servicemonitor.yaml && \
kubectl create -f prometheus.yaml 
```
получаем деплойменты и все остальное

![deployments](./screenshots/deployments.png?raw=true "k9s")

проброс портов
```
kubectl port-forward deployments/nginx 8000:80
```
```
kubectl port-forward deployments/nginx-exporter 9113:9113
```
```
kubectl port-forward deployments/prometheus-deployment 9090:9090
```
проверяем нгинкс
```
curl localhost:8000
curl localhost:8000/basic_status
```
увидим сначала стартовую страницу nginx, а по второй команде статус
```
Active connections: 1 
server accepts handled requests
 1553 1553 779 
Reading: 0 Writing: 1 Waiting: 0 
```

проверяем прометея
```
curl localhost:9090
```
проверяем метрики
```
curl localhost:9113/metrics
```
увидим
```
# HELP nginx_connections_accepted Accepted client connections
# TYPE nginx_connections_accepted counter
nginx_connections_accepted 1140
# HELP nginx_connections_active Active client connections
# TYPE nginx_connections_active gauge
nginx_connections_active 1
# HELP nginx_connections_handled Handled client connections
# TYPE nginx_connections_handled counter
nginx_connections_handled 1140
# HELP nginx_connections_reading Connections where NGINX is reading the request header
# TYPE nginx_connections_reading gauge
nginx_connections_reading 0
# HELP nginx_connections_waiting Idle client connections
# TYPE nginx_connections_waiting gauge
nginx_connections_waiting 0
# HELP nginx_connections_writing Connections where NGINX is writing the response back to the client
# TYPE nginx_connections_writing gauge
nginx_connections_writing 1
# HELP nginx_http_requests_total Total http requests
# TYPE nginx_http_requests_total counter
nginx_http_requests_total 2377
# HELP nginx_up Status of the last metric scrape
# TYPE nginx_up gauge
nginx_up 1
# HELP nginxexporter_build_info Exporter build information
# TYPE nginxexporter_build_info gauge
nginxexporter_build_info{commit="7a03d0314425793cf4001f0d9b0b2cfd19563433",date="2021-12-21T19:24:34Z",version="0.10.0"} 1
```
в браузере зайдем на страницу прометея увидим в джобах
![deployments](./screenshots/exporter-metrics.png?raw=true "k9s")

так же можно посмотреть остальные джобы
![deployments](./screenshots/other-jobs-1.png?raw=true "k9s")
![deployments](./screenshots/other-jobs-2.png?raw=true "k9s")

одна джоба не работает, не стал уже разбираться.

правильно ли я понял что в такой сборке сервисмонитор не нужен?

так же пробовал через оператор поднять

## PR checklist:
 - [x] Выставлен label с темой домашнего задания