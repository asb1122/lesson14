# lesson14

1. Написать скрипт для поиска свободного порта из диапазона M-N, где M и N - передаются скрипту как аргументы

запускаем скрипт c аргументами ````./search_port.sh 8000 8020````

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
Свободные порты в диапазоне 8000-8020:
8001 8002 8003 8004 8005 8006 8007 8008 8009 8010 8011 8012 8013 8014 8015 8016 8017 8018 8019 8020

Всего свободно: 20
````
===========================================================================

2. Написать скрипт, для деплоя лендинга https://gitlab.com/dos-26/cmdb/frontend и скрипт для его проверки

запускаем деплой через ````sudo ./deploy.sh````

````
#!/bin/bash
set -euo pipefail

APP_NAME="landing14"
PORT="8000"
APP_URL="http://127.0.0.1:${PORT}"

APP_USER="webadmin"
APP_GROUP="webgroup"
OWNER="${APP_USER}:${APP_GROUP}"
REPO_URL="https://gitlab.com/dos-26/cmdb/frontend.git"

APP_DIR="/opt/srv/${APP_NAME}"
VENV_DIR="${APP_DIR}/venv"
UNIT_FILE="/home/artsiom/home_works/lesson_14/lesson14/web_server.service"

SERVICE_NAME="web_server.service"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}"

git_clone() {
  if [ -d "${APP_DIR}/.git" ]; then
    echo "Updating project from remote repo"
    git -C "${APP_DIR}" fetch origin
    git -C "${APP_DIR}" reset --hard origin/main
  else
    echo "GIT CLONE ${REPO_URL}"
    git clone "${REPO_URL}" "${APP_DIR}"
  fi
}

create_venv() {
  if [ ! -x "${VENV_DIR}/bin/python3" ]; then
    echo "Creating venv in ${VENV_DIR}"
    sudo python3 -m venv "${VENV_DIR}"
  else
    echo "venv already exists: ${VENV_DIR}"
  fi
}

set_permission() {
  chown -R "${OWNER}" "${APP_DIR}"
  find "${APP_DIR}/public" -type d -exec chmod 755 {} \;
  find "${APP_DIR}/public" -type f -exec chmod 644 {} \;
}

copy_systemd() {
  if [ -f "${SERVICE_PATH}" ]; then
    if cmp -s "${UNIT_FILE}" "${SERVICE_PATH}"; then
      echo "systemd unit already up-to-date: ${SERVICE_PATH}"
    else
      echo "systemd unit exists but differs. backing up and updating"
      cp "${SERVICE_PATH}" "${SERVICE_PATH}.bak.$(date +%Y%m%d%H%M%S)"
      cp "${UNIT_FILE}" "${SERVICE_PATH}"
      chmod 644 "${SERVICE_PATH}"
    fi
  else
    echo "Installing systemd unit ${SERVICE_PATH}"
    cp "${UNIT_FILE}" "${SERVICE_PATH}"
    chmod 644 "${SERVICE_PATH}"
  fi

  systemctl daemon-reload
  systemctl enable "${SERVICE_NAME}"
  systemctl restart "${SERVICE_NAME}"
}

git_clone
create_venv
set_permission
copy_systemd

````

результат:
````
artsiom@ubundu26:/etc/systemd/system$ ll -la /opt/srv/landing14/
total 24
drwxr-xr-x 4 webadmin webgroup 4096 Oct 24 12:35 ./
drwxr-xr-x 4 root     root     4096 Oct 24 02:22 ../
drwxr-xr-x 7 webadmin webgroup 4096 Oct 24 13:13 .git/
-rw-r--r-- 1 webadmin webgroup  896 Oct 24 12:35 .gitlab-ci.yml
drwxr-xr-x 2 webadmin webgroup 4096 Oct 24 12:35 public/
-rwxr-xr-x 1 webadmin webgroup  198 Oct 24 03:00 web_server.py*
artsiom@ubundu26:/etc/systemd/system$ ll -la /opt/srv/landing14/public/
total 20
drwxr-xr-x 2 webadmin webgroup 4096 Oct 24 12:35 ./
drwxr-xr-x 4 webadmin webgroup 4096 Oct 24 12:35 ../
-rw-r--r-- 1 webadmin webgroup 1241 Oct 24 12:35 index.html
-rw-r--r-- 1 webadmin webgroup 1298 Oct 24 12:35 script.js
-rw-r--r-- 1 webadmin webgroup  599 Oct 24 12:35 style.css
artsiom@ubundu26:/etc/systemd/system$ sudo systemctl status web_server.service
● web_server.service - Landing14
     Loaded: loaded (/etc/systemd/system/web_server.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-10-24 13:20:54 +03; 10s ago
 Invocation: 81c0f7a73934473690fc8e08d1648c36
   Main PID: 421157 (python3)
      Tasks: 1 (limit: 2338)
     Memory: 9.3M (peak: 9.4M)
        CPU: 28ms
     CGroup: /system.slice/web_server.service
             └─421157 /opt/srv/landing14/venv/bin/python3 /opt/srv/landing14/web_server.py

Oct 24 13:20:54 ubundu26 systemd[1]: Started web_server.service - Landing14.
artsiom@ubundu26:/etc/systemd/system$ curl http://localhost:8000
<!DOCTYPE html>
<html>
<head>
    <title>CMDB System</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Configuration Management Database</h1>

        <div class="form-section">
            <h2>Add New Asset</h2>
            <input type="text" id="name" placeholder="Asset Name">
            <select id="type">
                <option value="server">Server</option>
                <option value="network">Network Device</option>
                <option value="storage">Storage</option>
            </select>
            <textarea id="description" placeholder="Description"></textarea>
            <button onclick="addAsset()">Add Asset</button>
        </div>

        <div class="assets-list">
            <h2>Assets</h2>
            <table id="assetsTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Type</th>
                        <th>Description</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
    <script src="script.js"></script>

````
===========================================================================


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

