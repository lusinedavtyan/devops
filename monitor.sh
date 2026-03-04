#!/bin/bash

SYSTEM_STATS="System Check: Root Disk Available is $(df -m / | tail -1 | awk '{print $4}')"
