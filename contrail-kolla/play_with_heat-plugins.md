# Play with plugins
## Clone the contrai-heat repo
```
git clone https://github.com/Juniper/contrail-heat
```
## modify heat.conf on controller node
```
root@mhoshicontrol:~# cd /etc/kolla/heat-api
root@mhoshicontrol:/etc/kolla/heat-api# diff heat.conf heat.conf.org
14d13
< plugin_dirs = /var/lib/kolla/config_files/plugin
```
## Make the plugin dirs
```
root@mhoshicontrol:/etc/kolla/heat-api# mkdir /etc/kolla/heat-api/plugin
```

