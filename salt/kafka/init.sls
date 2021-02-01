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

{% from 'kafka/kafka_config.map.jinja' import kafka_defaults as kafka_config with context %}
{% set MANAGER = salt['grains.get']('master') %}

# Kafka

# Add Kafka Group
kafkagroup:
  group.present:
    - name: kafka
    - gid: 948

# Add kafka user
kafka:
  user.present:
    - uid: 948
    - gid: 948
    - home: /opt/so/conf/kafka
    - createhome: False

kafkadir:
  file.directory:
    - name: /opt/so/conf/kafka/etc
    - user: 948
    - group: 948
    - makedirs: True

kafkalogdir:
  file.directory:
    - name: /opt/so/log/kafka
    - user: 948
    - group: 939
    - makedirs: True

kafkadatadir:
  file.directory:
    - name: /nsm/kafka
    - user: 948
    - group: 939
    - makedirs: True

kafkaconf:
  file.managed:
    - name: /opt/so/conf/kafka/etc/kafka.cfg
    - user: 948
    - group: 939
    - template: jinja
    - source: salt://kafka/etc/kafka.cfg.jinja
    - context:
        kafka_config: {{ kafka_config.kafka.config }}

so-kafka:
  docker_container.running:
    - image: {{ MANAGER }}:5000/{{ IMAGEREPO }}/so-kafka:{{ VERSION }}
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
