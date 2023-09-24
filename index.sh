#!/bin/bash

#Создание цепочки для адресов, которым разрешено все
iptables -N ALLOW_ALL
iptables -A ALLOW_ALL -j ACCEPT

#Создание цепочки для адресов серверов баз данных и контейнеров с приложением, которым разрешено все
iptables -N ALLOW_DB_SERVERS
iptables -A ALLOW_DB_SERVERS -j ACCEPT
