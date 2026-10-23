# lesson14

1. Написать скрипт для поиска свободного порта из диапазона M-N, где M и N - передаются скрипту как аргументы

````
#!/bin/bash


START=${1:?} ; END=${2:?}

free_ports=()
for port in $(seq "$START" "$END"); do
    [ -z "$(ss -tulnH "sport = :$port" 2>/dev/null)" ] && free_ports+=("$port")
done

if [ ${#free_ports[@]} -eq 0 ]; then
    echo "Свободных портов в диапазоне $START-$END нет"
    exit 1
fi

echo "Свободные порты в диапазоне $START-$END:"
echo "${free_ports[*]}"
echo
echo "Всего свободно: ${#free_ports[@]}"

````

результат
````
artsiom@ubundu26:~/home_works/lesson_14/lesson14$ ./search_port.sh 8000 8100
Свободные порты в диапазоне 8000-8100:
8001 8002 8003 8004 8005 8006 8007 8008 8009 8010 8011 8012 8013 8014 8015 8016 8017 8018 8019 8020 8021 8022 8023 8024 8025 8026 8027 8028 8029 8030 8031 8032 8033 8034 8035 8036 8037 8038 8039 8040 8041 8042 8043 8044 8045 8046 8047 8048 8049 8050 8051 8052 8053 8054 8055 8056 8057 8058 8059 8060 8061 8062 8063 8064 8065 8066 8067 8068 8069 8070 8071 8072 8073 8074 8075 8076 8077 8078 8079 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8091 8092 8093 8094 8095 8096 8097 8098 8099 8100

Всего свободно: 99
````


2. Написать скрипт, для деплоя лендинга https://gitlab.com/dos-26/cmdb/frontend и скрипт для его проверки


3. Развернуть Python-веб-сервер как systemd демон

unint file
````
artsiom@ubundu26:/etc/systemd/system$ cat web_server14.service 
[Unit]
Description=PythonWebServer
After=network.target

[Service]
Type=simple
User=webadmin
Group=webgroup 
WorkingDirectory=/opt/srv/webapp
ExecStart=/opt/srv/webapp/venv/bin/python3 /opt/srv/webapp/web_server.py
Restart=Always
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target

````

активный сервис
````
artsiom@ubundu26:/etc/systemd/system$ sudo systemctl status web_server14.service
● web_server14.service - PythonWebServer
     Loaded: loaded (/etc/systemd/system/web_server14.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-10-24 01:12:16 +03; 2min 43s ago
 Invocation: c432a1f8c8b149c69086ba8f1650d9ea
   Main PID: 387740 (python3)
      Tasks: 1 (limit: 2338)
     Memory: 11.6M (peak: 11.6M)
        CPU: 371ms
     CGroup: /system.slice/web_server14.service
             └─387740 /opt/srv/webapp/venv/bin/python3 /opt/srv/webapp/web_server.py

Oct 24 01:12:13 ubundu26 systemd[1]: web_server14.service: Failed with result 'exit-code'.
Oct 24 01:12:16 ubundu26 systemd[1]: web_server14.service: Scheduled restart job, restart counter is at 79.
Oct 24 01:12:16 ubundu26 systemd[1]: Started web_server14.service - PythonWebServer.
Oct 24 01:12:26 ubundu26 systemd[1]: /etc/systemd/system/web_server14.service:11: Failed to parse Restart=Always, ignoring: Inval>
Oct 24 01:13:00 ubundu26 python3[387740]: 127.0.0.1 - - [24/Oct/2026 01:13:00] "GET / HTTP/1.1" 200 -
Oct 24 01:14:50 ubundu26 python3[387740]: 127.0.0.1 - - [24/Oct/2026 01:14:50] "GET / HTTP/1.1" 200 -
````
проверка работы
````
artsiom@ubundu26:/etc/systemd/system$ curl http://localhost:8000
<!DOCTYPE html>
<html>
<head>
    <title>Приветствие</title>
    <style>
        .greeting {
            border: 5px solid orange; 
            padding: 20px; 
            font-size: 48px;
            text-align: center; 
            margin: 50px auto; 
            width: fit-content;
            border-radius: 15px;
            background-color: #fff8f0; 
            font-family: Arial, sans-serif;
            box-shadow: 0 0 15px rgba(255, 165, 0, 0.3); 
        }
    </style>
</head>
<body>
    <div class="greeting">Hello, DOS-37-ONL! You are amazing!</div>
</body>
</html>

````

юзер webadmin webgroup
````
artsiom@ubundu26:/opt/srv/webapp$ ll -la
total 20
drwxr-xr-x 4 webadmin webgroup 4096 Oct 24 01:12 ./
drwxr-xr-x 3 root     root     4096 Oct 23 23:33 ../
drwxr-xr-x 2 webadmin webgroup 4096 Oct 24 01:14 content/
drwxr-xr-x 5 webadmin webgroup 4096 Oct 24 00:22 venv/
-rwxr-xr-x 1 webadmin webgroup  196 Oct 24 01:12 web_server.py
````

