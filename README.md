### **Ansible Directory Structure (Best Practices)**

When working with **Ansible**, organizing your files properly helps in scalability, reusability, and maintainability. Below is the recommended **directory structure** for an Ansible project.

---

## **📂 Standard Ansible Directory Format**
```
📂 my-ansible-project/
│── 📂 inventory/                # Inventory files (hosts)
│   ├── hosts                    # Main inventory file
│   ├── dev                      # Inventory for development environment
│   ├── prod                     # Inventory for production environment
│
│── 📂 group_vars/               # Variables for groups
│   ├── webservers.yml           # Variables for web servers
│   ├── dbservers.yml            # Variables for database servers
│
│── 📂 host_vars/                # Variables for specific hosts
│   ├── host1.yml                # Variables for host1
│   ├── host2.yml                # Variables for host2
│
│── 📂 roles/                    # Roles (Reusable automation components)
│   ├── webserver/               # Role for web server setup
│   │   ├── tasks/               # Main tasks for role
│   │   │   ├── main.yml
│   │   ├── handlers/            # Handlers (triggered by tasks)
│   │   │   ├── main.yml
│   │   ├── templates/           # Jinja2 templates (Dynamic configs)
│   │   │   ├── nginx.conf.j2
│   │   ├── files/               # Static files (Copy to remote)
│   │   │   ├── index.html
│   │   ├── vars/                # Role-specific variables
│   │   │   ├── main.yml
│   │   ├── defaults/            # Default variables
│   │   │   ├── main.yml
│   │   ├── meta/                # Role metadata (dependencies, author info)
│   │   │   ├── main.yml
│   │   ├── README.md            # Role documentation
│
│── 📂 playbooks/                # Main playbooks directory
│   ├── site.yml                 # Main playbook (Calls roles)
│   ├── webserver.yml            # Playbook for web servers
│   ├── dbserver.yml             # Playbook for database servers
│
│── 📂 modules/                  # Custom Ansible modules (optional)
│
│── 📂 plugins/                  # Custom plugins (optional)
│
│── 📂 library/                  # Custom Python modules (optional)
│
│── 📂 logs/                     # Logs for debugging
│
│── ansible.cfg                  # Ansible configuration file
│── requirements.yml              # Role dependencies (Ansible Galaxy)
│── README.md                     # Project documentation
```

---

## **📌 Explanation of Each Directory**
### **1️⃣ Inventory (`inventory/`)**
- Defines the list of target servers (managed nodes).
- Can have separate files for `dev`, `prod`, etc.

### **2️⃣ Group Variables (`group_vars/`)**
- Stores variables for **groups** of hosts.
- Example: `webservers.yml` contains variables for all web servers.

### **3️⃣ Host Variables (`host_vars/`)**
- Stores **host-specific** variables.
- Example: `host1.yml` contains variables only for `host1`.

### **4️⃣ Roles (`roles/`)**
- A **modular way** to organize tasks, variables, templates, etc.
- Each role has its own structure with `tasks/`, `handlers/`, `files/`, etc.

### **5️⃣ Playbooks (`playbooks/`)**
- YAML files that define **what to automate**.
- Calls roles, tasks, and variables.

### **6️⃣ ansible.cfg**
- Ansible **configuration file** (e.g., SSH settings, inventory path).
- Example:
  ```ini
  [defaults]
  inventory = inventory/hosts
  remote_user = ansible
  host_key_checking = False
  ```

### **7️⃣ requirements.yml**
- Defines **Ansible Galaxy** role dependencies.

---

## **📌 Example Playbook (`site.yml`)**
```yaml
- name: Configure Web Server
  hosts: webservers
  roles:
    - webserver
```

---

## **📌 Example Role (`roles/webserver/tasks/main.yml`)**
```yaml
- name: Install Nginx
  yum:
    name: nginx
    state: present

- name: Start Nginx Service
  service:
    name: nginx
    state: started
    enabled: yes
```

---

## **🚀 Why Use This Structure?**
✅ **Scalability** → Works well for large projects  
✅ **Reusability** → Use roles across multiple projects  
✅ **Readability** → Well-organized and easy to manage

---

I'll convert your Bash script into an **Ansible Playbook** for **Ansible 2.10**, following best practices. This will include:  
✅ **Installing MongoDB, Node.js, Git, and Nginx**  
✅ **Setting up a user (`spec`)**  
✅ **Cloning a Git repository**  
✅ **Configuring MongoDB & systemd service**  
✅ **Setting up Nginx**

---

### **📌 Ansible Playbook (`site.yml`)**
```yaml
- name: Setup MongoDB, Node.js, and Nginx
  hosts: all
  become: true
  vars:
    db_user: "prasad"
    db_pass: "123Prasad"
    mongo_repo_file: "/etc/yum.repos.d/mongodb-org-7.0.repo"
    mongo_service_file: "/etc/systemd/system/spec.service"
  
  tasks:
    - name: Install DNF package manager
      ansible.builtin.yum:
        name: dnf
        state: present
    
    - name: Copy MongoDB repository configuration
      ansible.builtin.copy:
        src: mongodb-org-7.0.repo
        dest: "{{ mongo_repo_file }}"
    
    - name: Install MongoDB
      ansible.builtin.dnf:
        name: mongodb-org
        state: present
        disable_excludes: AppStream
    
    - name: Allow external MongoDB connections
      ansible.builtin.replace:
        path: /etc/mongod.conf
        regexp: '127.0.0.1'
        replace: '0.0.0.0'
    
    - name: Restart MongoDB
      ansible.builtin.systemd:
        name: mongod
        state: restarted
        enabled: true
    
    - name: Add user 'spec'
      ansible.builtin.user:
        name: spec
        shell: /bin/bash
        create_home: yes
    
    - name: Install Node.js and Git
      ansible.builtin.yum:
        name:
          - nodejs
          - git
        state: present
    
    - name: Clone application repository
      ansible.builtin.git:
        repo: "https://github.com/OpsInfinity/app.git"
        dest: /home/spec/app
        update: yes
        version: master
    
    - name: Run application setup script
      ansible.builtin.shell: cat package.sh | bash
      args:
        chdir: /home/spec/app
      become_user: spec
    
    - name: Set MongoDB environment variables
      ansible.builtin.lineinfile:
        path: "{{ mongo_service_file }}"
        line: "Environment='MONGO_ENDPOINT=mongodb+srv://{{ db_user }}:{{ db_pass }}@cluster0.3zmmc.mongodb.net/login-app-db?retryWrites=true&w=majority'"
        create: yes
    
    - name: Copy systemd service file
      ansible.builtin.copy:
        src: files/spec.service
        dest: "{{ mongo_service_file }}"
    
    - name: Restart spec service
      ansible.builtin.systemd:
        name: spec
        state: restarted
        enabled: true
    
    - name: Install Nginx
      ansible.builtin.yum:
        name: nginx
        state: present
    
    - name: Copy Nginx configuration
      ansible.builtin.copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
    
    - name: Copy Node.js Nginx configuration
      ansible.builtin.copy:
        src: files/nodejs.conf
        dest: /etc/nginx/conf.d/nodejs.conf
    
    - name: Disable SELinux enforcement (temporary)
      ansible.builtin.command: setenforce 0
      ignore_errors: yes
    
    - name: Restart Nginx
      ansible.builtin.systemd:
        name: nginx
        state: restarted
        enabled: true

```

---

### **📌 Folder Structure**
```
📂 ansible-setup/
│── 📂 files/
│   ├── mongodb-org-7.0.repo      # MongoDB repo file
│   ├── spec.service              # Systemd service file for the app
│   ├── nginx.conf                # Nginx configuration
│   ├── nodejs.conf               # Node.js reverse proxy config
│
│── 📄 site.yml                    # Main Ansible playbook
│── 📄 inventory                    # Inventory file (list of servers)
│── 📄 ansible.cfg                   # Ansible configuration (optional)
```

---

### **📌 How to Run the Playbook**
1️⃣ **Ensure Ansible is installed on your control node:**
   ```bash
   ansible --version
   ```

2️⃣ **Update the `inventory` file with your server IPs:**
   ```
   [servers]
   your_server_ip ansible_user=your_user
   ```

3️⃣ **Run the Playbook:**
   ```bash
   ansible-playbook -i inventory site.yml
   ```

---

### **🚀 Advantages of Using Ansible Instead of Bash**
✅ **Idempotency** → Runs only when needed  
✅ **Easier Maintenance** → Structured and modular  
✅ **Scalability** → Works on multiple servers

#####################################################################################

I'll separate the playbooks for **MongoDB**, **Node.js**, and **Nginx** into different YAML files. This modular approach is better for **reusability** and **maintainability**.

---

## **📌 Folder Structure**
```
📂 ansible-setup/
│── 📂 files/
│   ├── mongodb-org-7.0.repo      # MongoDB repo file
│   ├── spec.service              # Systemd service file for the app
│   ├── nginx.conf                # Nginx configuration
│   ├── nodejs.conf               # Node.js reverse proxy config
│
│── 📄 site.yml                    # Main Ansible playbook (includes all roles)
│── 📄 inventory                    # Inventory file (list of servers)
│── 📂 roles/
│   ├── mongodb/
│   │   ├── tasks/main.yml
│   ├── nodejs/
│   │   ├── tasks/main.yml
│   ├── nginx/
│   │   ├── tasks/main.yml
│── 📄 ansible.cfg                   # Ansible configuration (optional)
```

---

## **1️⃣ Main Playbook (`site.yml`)**
This playbook includes all **three roles** (MongoDB, Node.js, and Nginx).
```yaml
- name: Setup MongoDB, Node.js, and Nginx
  hosts: all
  become: true
  roles:
    - mongodb
    - nodejs
    - nginx
```

---

## **2️⃣ MongoDB Playbook (`roles/mongodb/tasks/main.yml`)**
```yaml
- name: Install DNF package manager
  ansible.builtin.yum:
    name: dnf
    state: present

- name: Copy MongoDB repository configuration
  ansible.builtin.copy:
    src: mongodb-org-7.0.repo
    dest: /etc/yum.repos.d/mongodb-org-7.0.repo

- name: Install MongoDB
  ansible.builtin.dnf:
    name: mongodb-org
    state: present
    disable_excludes: AppStream

- name: Allow external MongoDB connections
  ansible.builtin.replace:
    path: /etc/mongod.conf
    regexp: '127.0.0.1'
    replace: '0.0.0.0'

- name: Restart MongoDB
  ansible.builtin.systemd:
    name: mongod
    state: restarted
    enabled: true
```

---

## **3️⃣ Node.js Playbook (`roles/nodejs/tasks/main.yml`)**
```yaml
- name: Add user 'spec'
  ansible.builtin.user:
    name: spec
    shell: /bin/bash
    create_home: yes

- name: Install Node.js and Git
  ansible.builtin.yum:
    name:
      - nodejs
      - git
    state: present

- name: Clone application repository
  ansible.builtin.git:
    repo: "https://github.com/OpsInfinity/app.git"
    dest: /home/spec/app
    update: yes
    version: master

- name: Run application setup script
  ansible.builtin.shell: cat package.sh | bash
  args:
    chdir: /home/spec/app
  become_user: spec

- name: Set MongoDB environment variables
  ansible.builtin.lineinfile:
    path: /etc/systemd/system/spec.service
    line: "Environment='MONGO_ENDPOINT=mongodb+srv://prasad:123Prasad@cluster0.3zmmc.mongodb.net/login-app-db?retryWrites=true&w=majority'"
    create: yes

- name: Copy systemd service file
  ansible.builtin.copy:
    src: files/spec.service
    dest: /etc/systemd/system/spec.service

- name: Restart spec service
  ansible.builtin.systemd:
    name: spec
    state: restarted
    enabled: true
```

---

## **4️⃣ Nginx Playbook (`roles/nginx/tasks/main.yml`)**
```yaml
- name: Install Nginx
  ansible.builtin.yum:
    name: nginx
    state: present

- name: Copy Nginx configuration
  ansible.builtin.copy:
    src: files/nginx.conf
    dest: /etc/nginx/nginx.conf

- name: Copy Node.js Nginx configuration
  ansible.builtin.copy:
    src: files/nodejs.conf
    dest: /etc/nginx/conf.d/nodejs.conf

- name: Disable SELinux enforcement (temporary)
  ansible.builtin.command: setenforce 0
  ignore_errors: yes

- name: Restart Nginx
  ansible.builtin.systemd:
    name: nginx
    state: restarted
    enabled: true
```

---

## **📌 How to Run the Playbook**
1️⃣ **Ensure Ansible is installed:**
   ```bash
   ansible --version
   ```

2️⃣ **Update the `inventory` file with your server IPs:**
   ```
   [servers]
   your_server_ip ansible_user=your_user
   ```

3️⃣ **Run the Playbook:**
   ```bash
   ansible-playbook -i inventory site.yml
   ```

---

### **🚀 Benefits of Separating Roles**
✅ **Modular & Reusable** – You can use MongoDB, Node.js, or Nginx independently  
✅ **Easier Maintenance** – Fix MongoDB without affecting Nginx  
✅ **Scalable** – Add more services easily

Let me know if you need any changes! 🚀🔥