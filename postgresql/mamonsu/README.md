Установка mamonsu на клиентов для мониторинга баз PostgreSQL. Оффициальный репозитарий - https://github.com/postgrespro/mamonsu и https://postgrespro.ru/products/extensions/mamonsu. Mamonsu работает параллельно с zabbix-agent. Mamonsu сам отправляет данные в Zabbix.

#Установка:
```bash
apt -y install python-pip
pip install mamonsu
copy file agent.conf --> /etc/mamonsu/agent.conf
useradd -->> mamonsu
mkdir /var/log/mamonsu/touch && /var/log/mamonsu/agent.log && /var/log/mamonsu/localhost.log
chown -R mamonsu:mamonsu /var/log/mamonsu/
copy file mamonsu --> /etc/init.d/
chmod 755 /etc/init.d/mamonsu
systemctl enable mamonsu
service mamonsu start
tail -f /var/log/mamonsu/agent.log
copy file postgresql.conf --> /etc/zabbix/zabbix_agentd.conf.d/
```

#Файл конфигурации agent.conf:
```bash
[postgres]
user = zabbix
password = ********
database = mamonsu
host = 10.55.0.43
port = 6432
[zabbix]
client = pgPROC
```

Библиотеки mamonsu зависят от версии питона и лежат примерно в /usr/local/lib/python2.7/dist-packages/mamonsu/

* [Файл postgresql.conf](http://devgit/configs/zabbix/blob/master/mamonsu/etc/zabbix/zabbix_agentd.conf.d/postgresql.conf)
* [Файл agent.conf](http://devgit/configs/zabbix/blob/master/mamonsu/etc/mamonsu/agent.conf)
* [Файл mamonsu](http://devgit/configs/zabbix/blob/master/mamonsu/etc/init.d/mamonsu)
