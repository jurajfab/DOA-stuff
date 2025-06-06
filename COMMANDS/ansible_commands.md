
# ANSIBLE COMMANDS

###  Instalacia PIP 
``` bash curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py ```
### Instalacia Ansible 
``` bash
python3 get-pip.py
python3 -m pip -V
python3 -m pip install ansible
python3 -m pip install ansible-core
python3 -m pip install --upgrade ansible 
```

### Pridat cestu do .bashrc 
``` export PATH="$PATH:/home/ubuntu/.local/bin" ```

###  Overenie ci je nainstalovany 
``` ansible --version ```

### Vytvorenie  INVENTORY FILE = hosts ( vsetky hosty kam sa chcem pripajat, vratane mastra) 
- cestu k tomuto filu definujem v **.ansible.cfg**

```
# <name>         <host>                     <port>                   <user>
vm_ubuntu  ansible_connection=local    ansible_user=ubuntu
vm_debian  ansible_host=18.197.129.95  ansible_port=22         ansible_user=admin
vm_redhat  ansible_host=52.59.200.251  ansible_port=22         ansible_user=ec2-user

[webservers]    # skupina webovych serverov
vm_debian
vm_ubuntu

[dbservers]     # skupina db serverov
vm_redhat
```

priklad inventory file 
```
[all]
vm_ubuntu  ansible_connection=local                          ansible_user=ubuntu
vm_debian  ansible_host=18.197.129.95  ansible_port=22       ansible_user=admin
vm_redhat  ansible_host=52.59.200.251  ansible_port=22       ansible_user=ec2-user
#ubuntu  ansible_host=127.0.0.1  ansible_port=22  ansible_user=ubuntu

[all:vars]
ansible_user=admin          # zadefinujem usera pre vsetky hosty

[webservers]
vm_debian
vm_redhat                   

[webservers:vars]
ansible_user=<user>          # zadefinujes usera pre konkretnu skupinu hostov = webservers 
ansible_port=22              # zadefinujes port pre konkretnu skupinu hostov = webservers 

[dbservers]
vm_ubuntu
```


### PING TEST 
``` 
ansible <vm_name> -i <inventory_file> -m <modul>
ansible vm_ubuntu -i /tmp/hosts -m ansible.builtin.ping                # urobi ping na dany host
ansible webservers -m ping
```

### ANSIBLE CONFIG FILE 
```
[defaults]
inventory=/tmp/hosts            # nastavi odkial ma brat defaultne hosty 
```
``` export ANSIBLE_CONFIG=/tmp/ansible.cfg``` # nastavi premenneu na nejaku cestu ku config file 

### Hranie sa s modulmi
```
ansible vm_ubuntu -m apt -a "name=vim" -b           # nainstaluje balicek vim, -b znamena ze to spravi so sudom
ansible vm_ubuntu -m shell -a "date"                # spusti prikaz date na machine
ansible all -m setup                                # vypise info o vsetkych hostoch z inventory fileu
ansible vm_debian -m copy -a "path=/home/ubuntu/test.txt dest=/tmp"      # copy file src -> dest
```

Viem to aj bez modulu:
``` ansible vm_debian -a "date" ```

## PLAYBOOK
```
ansible-playbook playbook.yml                       # spusti playbook
ansible-playbook playbook.yml --tags "shell"        # spusti playbook ale len tie so zadanym tagom
ansible-playbook playbook.yml --skip-tags "shell"   # spusti playbook ale skipne zadane tagy
```

## HOW TO CREATE VAR AND PRINT IT AFTER END
``` 
    - name: Check PHP version
      ansible.builtin.shell: php --version
      register: php_version_out
      tags: debug

    - name: Display
      ansible.builtin.debug: 
        var: php_version_out.stdout_lines[0]
      tags: debug
```

## ANSIBLE VAULT
```
ansible-vault create <filename>
ansible-vault create passwd.yml     # vytvoris si subor s heslami pre ansible 
ansible-vault edit passwd.yml       # edituje subor s heslami 
ansible-vault decrypt passwd.yml    # decryptuje subor s heslami 
    ubuntu@ip-172-31-42-181:~$ cat passwd.yml 
    ubuntu_sudo_passwd: heslo
    api_token: 46484sdf8549dfa984984df9ad8
ansible-vault encrypt passwd.yml
```
Viem najprv vytovit subor s heslami a potom zacryptovat 
```
* vytvorenie sifrovaneho suboru
ansible-vault create passwds.yml

* editacia
ansible-vault edit passwds.yml

* sifrovanie
ansible-vault encrypt passwds.yml

* desifrovanie
ansible-vault decrypt passwds.yml

* spustenie playbooku s vyziadanim BECOME hesla
ansible-playbook playbook.yml -e @passwds.yml --ask-become-pass
- ak mam vytvoreny vault a zadane heslo na vault v ansible.cfg spustam playbook a heslo na sudo, ak nemam v hosts zadefinovane ansible_become_pass

* spustenie playbooku s vyziadanim hesla na odsifrovanie @passwds.yml runtime
ansible-playbook playbook.yml -e @passwds.yml --ask-vault-pass
- ak mam vytvoreny vault tak tymto prikazom spustim playbook ale vyziada ma na zaciatku heslo na vault
```

### CREATING NEW ROLES 
``` 
ansible-galaxy init <role_name>
ansible-galaxy init --force oracle 
```
