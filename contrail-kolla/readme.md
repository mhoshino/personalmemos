```
cd /OpenContrail-Kolla/kolla-ansible/ansible/
ansible-playbook -i inventory/multinode -e @../etc/kolla/globals.yml -e @../etc/kolla/passwords.yml -e action=bootstrap-servers kolla-host.yml
ansible-playbook -i inventory/multinode -e @../etc/kolla/globals.yml -e @../etc/kolla/passwords.yml -e action=deploy site.yml
cd /OpenContrail-Kolla/contrail-ansible/playbooks/
ansible-playbook -i my-inventory site.yml
```
