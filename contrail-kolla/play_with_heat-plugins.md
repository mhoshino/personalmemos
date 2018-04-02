# Play with Heat plugins
## Clone the contrai-heat repo
```
git clone https://github.com/Juniper/contrail-heat
```
## Get necessary python libraries from neturon-server container
```
docker cp neutron_server:/usr/lib/python2.7/dist-packages/vnc_api ~/
docker cp neutron_server:/usr/lib/python2.7/dist-packages/vnc_api-0.1.dev0.egg-info ~/
docker cp neutron_server:/usr/lib/python2.7/dist-packages/cfgm_common ~/
docker cp neutron_server:/usr/lib/python2.7/dist-packages/cfgm_common-0.1.dev0.egg-info ~/
docker cp ~/vnc_api heat_engine:/usr/lib/python2.7/dist-packages/vnc_api
docker cp ~/vnc_api-0.1.dev0.egg-info heat_engine:/usr/lib/python2.7/dist-packages/vnc_api-0.1.dev0.egg-info
docker cp ~/cfgm_common heat_engine:/usr/lib/python2.7/dist-packages/cfgm_common
docker cp ~/cfgm_common-0.1.dev0.egg-info heat_engine:/usr/lib/python2.7/dist-packages/cfgm_common-0.1.dev0.egg-info
```
## modify heat.conf on controller node
```
root@mhoshicontrol:~# cd /etc/kolla/heat-engine
root@mhoshicontrol:/etc/kolla/heat-engin# vi heat.conf
vi heat.conf
[DEFAULT]
...
plugin_dirs = /usr/lib/python2.7/dist-packages/vnc_api/gen/heat/resources

[clients_contrail]
user = admin
password = contrail1
tenant = admin
api_server = 192.168.0.11
api_base_url = /
```
## Restart heat_api container
```
docker restart heat_engine
```
## Verify installation
```
root@mhoshicontrol:/etc/kolla/heat-engine# heat resource-type-list | grep -i contrail
WARNING (shell) "heat resource-type-list" is deprecated, please use "openstack orchestration resource type list" instead
| OS::Contrail::AttachPolicy               |
| OS::Contrail::NetworkIpam                |
| OS::Contrail::NetworkPolicy              |
| OS::Contrail::PhysicalInterface          |
| OS::Contrail::PhysicalRouter             |
| OS::Contrail::PortTuple                  |
| OS::Contrail::RouteTable                 |
| OS::Contrail::ServiceHealthCheck         |
| OS::Contrail::ServiceInstance            |
| OS::Contrail::ServiceTemplate            |
| OS::Contrail::VirtualMachineInterface    |
| OS::Contrail::VirtualNetwork             |
| OS::Contrail::VnSubnet                   |
```
