# 🚀 Ansible Integration with Podman & PostgreSQL

## 📌 Overview
This project demonstrates how to use **Ansible** to interact with running containers **without SSH**, using the **Podman connection plugin**.

The system consists of:
- 🟢 Backend container (FastAPI application)
- 🟡 Database container (PostgreSQL)

Ansible connects directly to both containers and executes commands inside them.

---

## 🏗️ Architecture

- Backend → FastAPI + SQLAlchemy
- Database → PostgreSQL (`postgres:15`)
- Container runtime → Podman
- Automation → Ansible (no SSH)

---

## ⚙️ Setup

### 1. Start containers

```bash
podman compose up -d
```

Check running containers:

```bash
podman ps --format "table {{.Names}}\t{{.Image}}"
```

---

## 🗄️ PostgreSQL Configuration

### `.env`

```env
DATABASE_URL=postgresql+psycopg2://postgres:postgres@genesis-db:5432/postgres
API_KEY=your_api_key
APP_ENV=development
```

### Requirements

```bash
pip install psycopg2-binary
```

---

## 📂 Ansible Inventory

```yaml
all:
  children:
    backend:
      hosts:
        genesis-backend:
          ansible_connection: containers.podman.podman
          ansible_python_interpreter: /usr/local/bin/python3.11

    database:
      hosts:
        genesis-db:
          ansible_connection: containers.podman.podman
```

---

## ▶️ Execution Script

```bash
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
```

---

## 🧪 Run Test

```bash
./ansible-ping.sh
```

---

## 🧠 Notes

- No SSH is used
- Backend supports full Ansible modules
- PostgreSQL container uses `raw` module only (no Python inside)

---

## 📦 Files

- inventory.yml
- ansible.cfg
- ansible-ping.sh
- ansible-output.md
