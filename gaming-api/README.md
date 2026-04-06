## Ansible Integration

### Overview
This project integrates Ansible to interact with the running backend container without using SSH.  
It uses Ansible’s native container connection (`podman`) to execute commands directly inside the container.

---

### Setup

#### 1. Start the application

```bash
podman compose up -d
```

Verify container is running:

```bash
podman ps
```

---

#### 2. Ansible Inventory

File: `inventory.yml`

```yaml
all:
  children:
    backend:
      hosts:
        genesis-backend:
          ansible_connection: podman
```

---

#### 3. Ansible Configuration

File: `ansible.cfg`

```ini
[defaults]
remote_tmp = /tmp/.ansible/tmp
host_key_checking = False
```

---

#### 4. Execution Script

File: `ansible-ping.sh`

```bash
#!/bin/bash

echo "===== Backend container test ====="
ansible backend -i inventory.yml -m raw -a "echo pong"
```

Make it executable:

```bash
chmod +x ansible-ping.sh
```

---

### Run Test

```bash
./ansible-ping.sh
```

Expected output:

```bash
genesis-backend | CHANGED | rc=0 >>
pong
```

---

### Notes

- The project uses SQLite, which runs inside the backend container.
- No separate database container is required.
- Ansible connects directly to the container without SSH.

---

### Files Added

- inventory.yml
- ansible.cfg
- ansible-ping.sh
- ansible-output.md
