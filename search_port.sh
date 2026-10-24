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
