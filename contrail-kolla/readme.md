# OpenStack Heat Template for creating Kolla + Contrail Environment
## Prereqs
- OpenStack Environment Supporting Heat Template version '2017-02-24'
- Ubuntu 16.04 Image Prepared
- External Network Already Configured
- Deployed VM's will need internet access
- Minimum 4 Instance/FloatingIPs/SecutiryGroups will be created so check quota is enough
## Deploy Heat template
This will create the following
- Default 4 nodes, 1 Controller, 1 Contrail Node, 2 Computes
- Assign them with 2 networks with 1 network accessable to the internet
- Assign security groups and floatings ips to all instance
- Prepares for the kolla installation ( add /etc/hosts, passing ssh keys, downloading and modifying artifacts, etc...) 
```
heat stack-create -u https://raw.githubusercontent.com/mhoshino/personalmemos/master/contrail-kolla/heat-os-kolla.yaml <stack name>
```
You may change the stack parameter to fit you environment
- compute_flavor: flavor used for compute
- control_flavor: flavor used for control
- contrail_flavor: flavor used for contrail
- image: Point to name or id of Ubuntu 16.04 Image
- availability_zone: The availabilityzone to deploy the instances
- public_net: Point name or id of public network
- compute_count: number of compute nodes
- dns_servers: list of dns 
- network: Json formated network information
## Accessing the environment
```
heat output-show -a <stackname>
```
The output will contain the following
- The IP address for the control node
- The ssh private key for accessing all nodes

Login with the following command
```
ssh -i <private key> -l root <ip address of control>
```

## Install Kolla
This will create the following.
- OpenStack Environment with 1 Control and 2 Computes(computes number can be modified in heat template)
- All OpenStack services will be containerized
```
cd /kolla-ansible/ansible/
ansible-playbook -i inventory/multinode -e @../etc/kolla/globals.yml -e @../etc/kolla/passwords.yml -e action=bootstrap-servers kolla-host.yml
ansible-playbook -i inventory/multinode -e @../etc/kolla/globals.yml -e @../etc/kolla/passwords.yml -e action=deploy site.yml
```
If execution fails first check if rabbitmq is running.
In error states you well see rabbitmq status falling into a loop of "Restarting"
```
root@mhoshi3control:/kolla-ansible/ansible# docker ps --filter name=rabbitmq
CONTAINER ID        IMAGE                                COMMAND             CREATED             STATUS                              PORTS               NAMES
96fdc5f5f037        kolla/ubuntu-binary-rabbitmq:ocata   "kolla_start"       8 minutes ago       Restarting (1) About a minute ago                       rabbitmq
```
If that is the case, do the following
```
cd /var/lib/docker/volumes/rabbitmq/_data/
rm .erlang.cookie
```
Wait a minute and reexute the following
```
cd /kolla-ansible/ansible/
ansible-playbook -i inventory/multinode -e @../etc/kolla/globals.yml -e @../etc/kolla/passwords.yml -e action=deploy site.yml
```
If still failes try the following

```
cd /OpenContrail-Kolla/kolla-ansible/ansible/
ansible-playbook -i inventory/multinode -e @../etc/kolla/globals.yml -e @../etc/kolla/passwords.yml -e action=bootstrap-servers kolla-host.yml
ansible-playbook -i inventory/multinode -e @../etc/kolla/globals.yml -e @../etc/kolla/passwords.yml -e action=deploy site.yml
```
### Key Difference in kolla
- All logs files will be under /var/lib/volumes/kolla/_data
- All config files will be under /etc/kolla

## Install Conrail kolla
This will create the following.
- Adds contrail configuration to OpenStack
- Deploys and configures contrail node and compute node
```
cd /OpenContrail-Kolla/contrail-ansible/playbooks/
ansible-playbook -i inventory/my-inventory site.yml
```


## Initial OpenStack setup and verification

```
source openstackrc
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
openstack image create "cirros" \
   --file cirros-0.3.4-x86_64-disk.img \
   --disk-format qcow2 --container-format bare \
   --public
openstack flavor create --id 0 --vcpus 1 --ram 128 --disk 1 m1.nano
openstack network create test
openstack subnet create --network test --subnet-range 1.1.1.0/24 test-subnet
openstack server create --image cirros --flavor m1.nano --network test test
```

Verify the VM started correctly with the IP address

```
openstack console log show test
```

## Set Contrail For External Access

Enable simple gateway.
WIP


