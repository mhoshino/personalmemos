# Play with Heat plugins
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
root@mhoshicontrol:~# heat resource-type-list | grep -i contrail
WARNING (shell) "heat resource-type-list" is deprecated, please use "openstack orchestration resource type list" instead
| OS::ContrailV2::AccessControlList                 |
| OS::ContrailV2::Alarm                             |
| OS::ContrailV2::AliasIp                           |
| OS::ContrailV2::AliasIpPool                       |
| OS::ContrailV2::AnalyticsNode                     |
| OS::ContrailV2::ApiAccessList                     |
| OS::ContrailV2::BgpAsAService                     |
| OS::ContrailV2::BgpRouter                         |
| OS::ContrailV2::Bgpvpn                            |
| OS::ContrailV2::BridgeDomain                      |
| OS::ContrailV2::ConfigNode                        |
| OS::ContrailV2::ConfigRoot                        |
| OS::ContrailV2::CustomerAttachment                |
| OS::ContrailV2::DatabaseNode                      |
| OS::ContrailV2::DiscoveryServiceAssignment        |
| OS::ContrailV2::Domain                            |
| OS::ContrailV2::DsaRule                           |
| OS::ContrailV2::FloatingIp                        |
| OS::ContrailV2::FloatingIpPool                    |
| OS::ContrailV2::ForwardingClass                   |
| OS::ContrailV2::GlobalAnalyticsConfig             |
| OS::ContrailV2::GlobalQosConfig                   |
| OS::ContrailV2::GlobalSystemConfig                |
| OS::ContrailV2::GlobalVrouterConfig               |
| OS::ContrailV2::InstanceIp                        |
| OS::ContrailV2::InterfaceRouteTable               |
| OS::ContrailV2::Loadbalancer                      |
| OS::ContrailV2::LoadbalancerHealthmonitor         |
| OS::ContrailV2::LoadbalancerListener              |
| OS::ContrailV2::LoadbalancerMember                |
| OS::ContrailV2::LoadbalancerPool                  |
| OS::ContrailV2::LogicalInterface                  |
| OS::ContrailV2::LogicalRouter                     |
| OS::ContrailV2::Namespace                         |
| OS::ContrailV2::NetworkIpam                       |
| OS::ContrailV2::NetworkPolicy                     |
| OS::ContrailV2::PhysicalInterface                 |
| OS::ContrailV2::PhysicalRouter                    |
| OS::ContrailV2::PortTuple                         |
| OS::ContrailV2::Project                           |
| OS::ContrailV2::ProviderAttachment                |
| OS::ContrailV2::QosConfig                         |
| OS::ContrailV2::QosQueue                          |
| OS::ContrailV2::RouteAggregate                    |
| OS::ContrailV2::RouteTable                        |
| OS::ContrailV2::RouteTarget                       |
| OS::ContrailV2::RoutingInstance                   |
| OS::ContrailV2::RoutingPolicy                     |
| OS::ContrailV2::SecurityGroup                     |
| OS::ContrailV2::SecurityLoggingObject             |
| OS::ContrailV2::ServiceAppliance                  |
| OS::ContrailV2::ServiceApplianceSet               |
| OS::ContrailV2::ServiceHealthCheck                |
| OS::ContrailV2::ServiceInstance                   |
| OS::ContrailV2::ServiceTemplate                   |
| OS::ContrailV2::StructuredSyslogApplicationRecord |
| OS::ContrailV2::StructuredSyslogConfig            |
| OS::ContrailV2::StructuredSyslogHostnameRecord    |
| OS::ContrailV2::StructuredSyslogMessage           |
| OS::ContrailV2::Subnet                            |
| OS::ContrailV2::VirtualDns                        |
| OS::ContrailV2::VirtualDnsRecord                  |
| OS::ContrailV2::VirtualIp                         |
| OS::ContrailV2::VirtualMachine                    |
| OS::ContrailV2::VirtualMachineInterface           |
| OS::ContrailV2::VirtualNetwork                    |
| OS::ContrailV2::VirtualRouter                     |
```
