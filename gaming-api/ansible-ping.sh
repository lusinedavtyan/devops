#!/bin/bash

echo "===== Backend container test ====="
ansible backend -i inventory.yml -m raw -a "mkdir -p /tmp/.ansible/tmp && echo pong"
