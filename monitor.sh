#!/bin/bash

SYSTEM_STATS="System Check: RAM is $(free -m | awk '/Mem:/ {print $7}') | Disk is $(df -m / | tail -1 | awk '{print $4}')"
