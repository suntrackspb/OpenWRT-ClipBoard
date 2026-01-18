#!/bin/bash

# Скрипт для создания systemd service на Linux

SERVICE_NAME="clipboard-client"
BINARY_PATH="/usr/local/bin/clipboard-client"
SERVER_URL="${SERVER_URL:-ws://192.168.1.1:8080/ws}"

echo "🔧 Установка clipboard-client как systemd сервис"
echo "================================================"
echo ""

# Проверяем права root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Запустите скрипт с правами root (sudo)"
    exit 1
fi

# Копируем бинарник
echo "📦 Копирование бинарника..."
if [ ! -f "bin/clipboard-client-linux" ]; then
    echo "❌ Файл bin/clipboard-client-linux не найден!"
    echo "Сначала соберите клиент: make client-linux"
    exit 1
fi

cp bin/clipboard-client-linux "$BINARY_PATH"
chmod +x "$BINARY_PATH"
echo "✓ Бинарник скопирован в $BINARY_PATH"
echo ""

# Создаем systemd unit файл
echo "📝 Создание systemd unit файла..."
cat > "/etc/systemd/system/${SERVICE_NAME}.service" << EOF
[Unit]
Description=OpenWRT Clipboard Client
After=network.target

[Service]
Type=simple
User=$SUDO_USER
Environment="DISPLAY=:0"
Environment="XAUTHORITY=/home/$SUDO_USER/.Xauthority"
ExecStart=$BINARY_PATH -server $SERVER_URL
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "✓ Unit файл создан: /etc/systemd/system/${SERVICE_NAME}.service"
echo ""

# Перезагружаем systemd и запускаем сервис
echo "🚀 Запуск сервиса..."
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl start "$SERVICE_NAME"

echo ""
echo "===================================="
echo "✅ Установка завершена!"
echo ""
echo "📊 Статус сервиса:"
systemctl status "$SERVICE_NAME" --no-pager
echo ""
echo "📝 Полезные команды:"
echo "   Статус:      systemctl status $SERVICE_NAME"
echo "   Остановка:   systemctl stop $SERVICE_NAME"
echo "   Запуск:      systemctl start $SERVICE_NAME"
echo "   Перезапуск:  systemctl restart $SERVICE_NAME"
echo "   Логи:        journalctl -u $SERVICE_NAME -f"
echo "   Удаление:    systemctl stop $SERVICE_NAME && systemctl disable $SERVICE_NAME"
echo ""
