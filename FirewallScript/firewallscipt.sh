#Создание цепочки для адресов, которым разрешено все (все порты):
sudo iptables -N ALLOW_ALL 
sudo iptables -A ALLOW_ALL -j ACCEPT 

#Создание цепочки для адресов серверов баз данных и контейнеров с приложением, которым разрешено все:
sudo iptables -N DB_APP_SERVERS  
sudo iptables -A DB_APP_SERVERS -j ACCEPT  

#Создание цепочки, в которую будут заноситься адреса пользователей, которым нужен доступ по требованию. Им также разрешено все:
sudo iptables -N ON_DEMAND_ACCESS 
sudo iptables -A ON_DEMAND_ACCESS -j ACCEPT 

#Создание цепочки, в которую будут заноситься адреса пользователей с временным доступом, им разрешены только определенные порты:
sudo iptables -N TEMP_ACCESS — создает новую пользовательскую цепочку с именем «TEMP_ACCESS».
sudo iptables -A TEMP_ACCESS -p tcp --dport <порт> -j ACCEPT 
sudo iptables -A TEMP_ACCESS -p udp --dport <порт> -j ACCEPT 

#Создание цепочки, в которую заносятся порты, смотрящие в мир:
sudo iptables -N PUBLIC_PORTS 
sudo iptables -A PUBLIC_PORTS -j ACCEPT 

#Блокирование остального трафика и логирование:
sudo touch /var/log/block_traffic.log 
sudo iptables -P INPUT DROP 
sudo iptables -A INPUT -j LOG --log-prefix "BLOCKED TRAFFIC: " --log-file /var/log/block_traffic.log


#Для каждой цепочки организовать свой файл лога:
sudo iptables -A ALLOW_ALL -j LOG --log-prefix "ALLOW_ALL: " --log-level 4 --log-file /var/log/allow_all.log 
sudo iptables -A DB_APP_SERVERS -j LOG --log-prefix "DB_APP_SERVERS: " --log-level 4 --log-file /var/log/db_app_servers.log 
sudo iptables -A ON_DEMAND_ACCESS -j LOG --log-prefix "ON_DEMAND_ACCESS: " --log-level 4 --log-file /var/log/on_demand_access.log 
sudo iptables -A TEMP_ACCESS -j LOG --log-prefix "TEMP_ACCESS: " --log-level 4 --log-file /var/log/temp_access.log
sudo iptables -A PUBLIC_PORTS -j LOG --log-prefix "PUBLIC_PORTS: " --log-level 4 --log-file /var/log/public_ports.log 


#Применим все правила и сохраним их, чтобы они применялись после перезагрузки системы:
sudo iptables-save > /etc/iptables/firewallscipt.sh
