#!/bin/bash

echo "=== Ping backend container ==="
ansible -i inventory.yml backend -m ping

echo ""
echo "=== Check database container ==="
ansible -i inventory.yml database -m raw -a "hostname"

echo ""
echo "=== Check backend hostname ==="
ansible -i inventory.yml backend -m command -a "hostname"

echo ""
echo "=== Check database hostname ==="
ansible -i inventory.yml database -m raw -a "hostname"
