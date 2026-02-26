#!/bin/bash

if rpm -q nginx >/dev/null 2>&1; then
    echo "Nginx already installed"
else
    sudo dnf install -y nginx
    echo "Nginx installed successfully."
fi

cd /var/www/html/

for i in {1..3}; do
    sudo touch page$i.html
    echo "Created page$i.html file"
    sudo chmod 644 page$i.html
    sudo chown nginx:nginx page$i.html
done

if systemctl is-active --quiet nginx; then
    echo "Nginx is running. Force restarting now..."
    sudo systemctl restart nginx
else
    echo "Nginx is dead. Starting it now..."
    sudo systemctl -l start nginx
fi

echo "Checking the nginx logs..."

journalctl -u nginx.service -n 5

