# Copyright 2014,2015,2016,2017,2018 Security Onion Solutions, LLC

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
{% from 'allowed_states.map.jinja' import allowed_states %}
{% if sls in allowed_states %}

{% set MANAGER = salt['grains.get']('master') %}

# Zookeeper

# Add zookeeper Group
zkgroup:
  group.present:
    - name: zookeeper
    - gid: 947

# Add zookeeper user
zookeeper:
  user.present:
    - uid: 947
    - gid: 947
    - home: /opt/so/conf/zk
    - createhome: False

zkdir:
  file.directory:
    - name: /opt/so/conf/zk/etc
    - user: 947
    - group: 947
    - makedirs: True

zklogdir:
  file.directory:
    - name: /opt/so/log/zk
    - user: 947
    - group: 939
    - makedirs: True

zkdatadir:
  file.directory:
    - name: /nsm/zk
    - user: 947
    - group: 939
    - makedirs: True

zkconf:
  file.managed:
    - name: /opt/so/conf/zk/etc/zoo.cfg
    - user: 939
    - group: 939
    - template: jinja
    - source: salt://zk/etc/zoo.cfg

so-zk:
  docker_container.running:
    - image: {{ MANAGER }}:5000/{{ IMAGEREPO }}/so-zk:{{ VERSION }}
    - start: {{ START }}
    - privileged: True
    - environment:
      - INTERFACE={{ interface }}
    - binds:
      - /opt/so/conf/zk/etc/zoo.cfg:/conf/zoo.cfg:ro
      - /nsm/zk/:/nsm/zk:rw
    - watch:
      - file: zkconf

{% else %}

{{sls}}_state_not_allowed:
  test.fail_without_changes:
    - name: {{sls}}_state_not_allowed

{% endif %}
