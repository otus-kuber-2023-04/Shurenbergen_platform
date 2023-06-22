
# Выполнено ДЗ №8 kubernetes-operators

 - [x] 🐍 Основное ДЗ

## В процессе сделано:
 - подготовлены манифесты согласно инструкции
 - подготовлен и запушен имейдж
 - подготовлен оператор
 - протестирована работа

 ## Запуск:
 создание crd & cr и запуск mysql оператора:
 ```
 cd kubernetes-operators && \
 kubectl apply -f deploy/crd.yml && \
 kubectl apply -f deploy/cr.yml && \
 cd build/ && \
 kopf run mysql-operator.py
```
 получаем вывод о запущенном mysql-instance

```
[2023-06-22 10:11:46,361] kopf._core.engines.a [INFO    ] Initial authentication has been initiated.
[2023-06-22 10:11:46,375] kopf.activities.auth [INFO    ] Activity 'login_via_client' succeeded.
[2023-06-22 10:11:46,375] kopf._core.engines.a [INFO    ] Initial authentication has finished.
[2023-06-22 10:12:03,858] kopf.objects         [WARNING ] [default/mysql-instance] Patching failed with inconsistencies: (('remove', ('status', 'kopf'), {'dummy': '2023-06-22T07:12:03.824992'}, None),)
{'api_version': 'v1',
 'kind': 'PersistentVolume',
 'metadata': {'annotations': None,
              'creation_timestamp': datetime.datetime(2023, 6, 22, 7, 12, 4, tzinfo=tzutc()),
              'deletion_grace_period_seconds': None,
              'deletion_timestamp': None,
              'finalizers': ['kubernetes.io/pv-protection'],
              'generate_name': None,
              'generation': None,
              'labels': {'pv-usage': 'backup-mysql-instance'},
              'managed_fields': [{'api_version': 'v1',
                                  'fields_type': 'FieldsV1',
                                  'fields_v1': {'f:metadata': {'f:labels': {'.': {},
                                                                            'f:pv-usage': {}}},
                                                'f:spec': {'f:accessModes': {},
                                                           'f:capacity': {'.': {},
                                                                          'f:storage': {}},
                                                           'f:hostPath': {'.': {},
                                                                          'f:path': {},
                                                                          'f:type': {}},
                                                           'f:persistentVolumeReclaimPolicy': {},
                                                           'f:volumeMode': {}}},
                                  'manager': 'OpenAPI-Generator',
                                  'operation': 'Update',
                                  'subresource': None,
                                  'time': datetime.datetime(2023, 6, 22, 7, 12, 4, tzinfo=tzutc())}],
              'name': 'backup-mysql-instance-pv',
              'namespace': None,
              'owner_references': None,
              'resource_version': '995',
              'self_link': None,
              'uid': '527504a9-7b84-47f6-bbdb-9deafa572645'},
 'spec': {'access_modes': ['ReadWriteOnce'],
          'aws_elastic_block_store': None,
          'azure_disk': None,
          'azure_file': None,
          'capacity': {'storage': '1Gi'},
          'cephfs': None,
          'cinder': None,
          'claim_ref': None,
          'csi': None,
          'fc': None,
          'flex_volume': None,
          'flocker': None,
          'gce_persistent_disk': None,
          'glusterfs': None,
          'host_path': {'path': '/data/pv-backup/', 'type': ''},
          'iscsi': None,
          'local': None,
          'mount_options': None,
          'nfs': None,
          'node_affinity': None,
          'persistent_volume_reclaim_policy': 'Retain',
          'photon_persistent_disk': None,
          'portworx_volume': None,
          'quobyte': None,
          'rbd': None,
          'scale_io': None,
          'storage_class_name': None,
          'storageos': None,
          'volume_mode': 'Filesystem',
          'vsphere_volume': None},
 'status': {'message': None, 'phase': 'Pending', 'reason': None}}
[2023-06-22 10:12:04,242] kopf.objects         [INFO    ] [default/mysql-instance] Handler 'mysql_on_create' succeeded.
[2023-06-22 10:12:04,242] kopf.objects         [INFO    ] [default/mysql-instance] Creation is processed: 1 succeeded; 0 failed.
```
далее применяем манифесты:
```
cd kubernetes-operators && \
kubectl apply -f deploy/service-account.yaml && \
kubectl apply -f deploy/role.yaml && \
kubectl apply -f deploy/role-binding.yaml && \
kubectl apply -f deploy/deploy-operator.yaml 
```
проверяем командой 
```
kubectl get pvc
```
видим
```
NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
backup-mysql-instance-pvc   Bound    pvc-9c906b62-5327-49b9-9da1-5c785b5bd0d7   1Gi        RWO            standard       56s
mysql-instance-pvc          Bound    pvc-1f489f2b-8ab6-485d-a7f8-f8e660cde1e2   1Gi        RWO            standard       56s
```
заполнение базы данных:
Заполним базу созданного mysql-instance: 
```
export MYSQLPOD=$(kubectl get pods -l app=mysql-instance -o jsonpath="{.items[*].metadata.name}") && \
kubectl exec -it $MYSQLPOD -- mysql -u root -potuspassword -e "CREATE TABLE operator ( id smallint unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key (id) );" otus-database && \
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO operator ( id, name ) VALUES ( null, 'kubernetes-operators' );" otus-database && \
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "INSERT INTO operator ( id, name ) VALUES ( null, 'k8s-operators' );" otus-database && \
kubectl exec -it $MYSQLPOD -- mysql -potuspassword -e "select * from operator;" otus-database
```
вывод:
```
+----+----------------------+
| id | name                 |
+----+----------------------+
|  1 | kubernetes-operators |
|  2 | k8s-operators        |
+----+----------------------+
```
удаляем инстанс:
```
kubectl delete mysqls.otus.homework mysql-instance
```
смотрим:
```
kubectl get pv
```
```
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                               STORAGECLASS   REASON   AGE
backup-mysql-instance-pv                   1Gi        RWO            Retain           Available                                                               4m13s
mysql-instance-pv                          1Gi        RWO            Delete           Available                                                               4m13s
```
смотрим
```
kubectl get jobs
```
получаем
```
NAME                         COMPLETIONS   DURATION   AGE
backup-mysql-instance-job    1/1           5s         45s
restore-mysql-instance-job   0/1           7m26s      7m26s
```
пруфы

![deployments](./screenshots/table.png?raw=true "k9s")
![deployments](./screenshots/pvc.png?raw=true "k9s")
![deployments](./screenshots/backup.png?raw=true "k9s")
![deployments](./screenshots/restore.png?raw=true "k9s")