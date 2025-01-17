#!/bin/bash

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -x

{{- if ( has "openvswitch" .Values.network.backend ) }}
if [[ "$(hostname)" =~ "comp" ]]; then
  tee > /tmp/pod-shared/l3-agent.ini << EOF
[DEFAULT]
agent_mode = dvr
interface_driver = openvswitch
EOF
else
  tee > /tmp/pod-shared/l3-agent.ini << EOF
[DEFAULT]
agent_mode = dvr_snat
interface_driver = openvswitch
EOF
fi
{{- end }}

exec neutron-l3-agent \
      --config-file /etc/neutron/neutron.conf \
      --config-file /etc/neutron/metadata_agent.ini \
{{- if and ( empty .Values.conf.neutron.DEFAULT.host ) ( .Values.pod.use_fqdn.neutron_agent ) }}
  --config-file /tmp/pod-shared/neutron-agent.ini \
{{- end }}
{{- if ( has "openvswitch" .Values.network.backend ) }}
      --config-file /etc/neutron/plugins/ml2/openvswitch_agent.ini \
      --config-file /tmp/pod-shared/l3-agent.ini \
{{- end }}
{{- if ( has "linuxbridge" .Values.network.backend ) }}
      --config-file /etc/neutron/l3_agent.ini \
{{- end }}
      --config-file /etc/neutron/plugins/ml2/ml2_conf.ini
