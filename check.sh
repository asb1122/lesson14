#!/bin/bash
# Проверка сервиса: systemd-статус + HTTP-ответ.
# Возвращает 0, если обе проверки прошли, иначе 1.

SERVICE_NAME="${SERVICE_NAME:-web_server.service}"
CHECK_URL="${CHECK_URL:-http://127.0.0.1:8000/}"

fail=0

state="$(systemctl is-active "${SERVICE_NAME}" 2>/dev/null || true)"
if [ "${state}" = "active" ]; then
  echo "OK: ${SERVICE_NAME} is active"
else
  echo "FAIL: ${SERVICE_NAME} state is '${state}'"
  fail=1
fi

code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "${CHECK_URL}" 2>/dev/null || true)"
if [ "${code}" -ge 200 ] 2>/dev/null && [ "${code}" -lt 400 ]; then
  echo "OK: HTTP ${code} from ${CHECK_URL}"
else
  echo "FAIL: HTTP ${code:-no-response} from ${CHECK_URL}"
  fail=1
fi

if [ "${fail}" -ne 0 ]; then
  echo "--- last 20 lines of ${SERVICE_NAME} ---"
  sudo journalctl -u "${SERVICE_NAME}" -b --no-pager | tail -n 20
fi

exit "${fail}"


