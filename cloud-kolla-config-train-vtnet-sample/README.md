### Usage


- Backup config

- Node: 10.254.203.2
- User: root
- Path: `cd /root/git/cloud-hht-kolla-config`
- Env: `source /root/virtualenv/kolla-ansible-train/bin/activate`
- Command:
    - Backup kolla-ansible custom config, globals.yml and inventory
    ```
    ansible-playbook -i /root/inventory/multinode_train backup_config.yml -t deployment
    ```

### Backup Database
```
#TODO
```

### Sau khi MR của backup config được merged

- Bước 1: vào pull lại: git pull orgin production-6f
- Bước 2: diff các file thay đổi trong /etc/kolla/config hoặc file globals.yml hoặc multinode_inventory
- Bước 3: copy lại các thay đổi đến thư mục tương ứng trên node deployment
