{{/*
Expand the name of the chart.
*/}}
{{- define "workload-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "workload-cluster.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "workload-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "workload-cluster.labels" -}}
helm.sh/chart: {{ include "workload-cluster.chart" . }}
{{ include "workload-cluster.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "workload-cluster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "workload-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Depend-on cluster annotation
*/}}
{{- define "workload-cluster.dependsOnAnnotation" -}}
config.kubernetes.io/depends-on: infrastructure.cluster.x-k8s.io/namespaces/{{ .Release.Namespace }}/GCPManagedCluster/{{ .Values.cluster.name }},infrastructure.cluster.x-k8s.io/namespaces/{{ .Release.Namespace }}/GCPManagedControlPlane/{{ .Values.cluster.name }},infrastructure.cluster.x-k8s.io/namespaces/{{ .Release.Namespace }}/GCPManagedMachinePool/{{ .Values.cluster.name }}-small-burst-on-demand,infrastructure.cluster.x-k8s.io/namespaces/{{ .Release.Namespace }}/GCPManagedMachinePool/{{ .Values.cluster.name }}-medium-burst-on-demand,infrastructure.cluster.x-k8s.io/namespaces/{{ .Release.Namespace }}/GCPManagedMachinePool/{{ .Values.cluster.name }}-large-burst-on-demand
{{- end }}

{{/*
Create a MachinePool for the given values
  ctx = . context
  name = the name of the MachinePool resource
  values = the values for this specific MachinePool resource
  defaultVals = the default values for the MachinePool resource
*/}}
{{- define "workers.machinePool" -}}
{{- $replicas := (.values | default dict).replicas | default .defaultVals.replicas }}
apiVersion: cluster.x-k8s.io/v1beta1
kind: MachinePool
metadata:
  name: {{ .ctx.Values.cluster.name }}-{{ .name }}
  annotations:
    helm.sh/resource-policy: keep
    {{- if (hasKey .values "annotations") -}}
    {{- toYaml (merge .values.annotations .defaultVals.annotations)| nindent 4 }}
    {{- else -}}
    {{- toYaml .defaultVals.annotations | nindent 4 }}
    {{- end }}
  labels:
    {{- if (hasKey .values "labels") -}}
    {{- toYaml (merge .values.labels .defaultVals.labels)| nindent 4 }}
    {{- else -}}
    {{- toYaml .defaultVals.labels | nindent 4 }}
    {{- end }}
spec:
  clusterName: {{ .ctx.Values.cluster.name }}
  replicas: {{ $replicas }}
  template:
    spec:
      version: v{{ trimPrefix "v" (.values.kubernetesVersion | default .ctx.Values.cluster.kubernetesVersion | toString) }}
      clusterName: {{ .ctx.Values.cluster.name }}
      bootstrap:
        dataSecretName: ""
      infrastructureRef:
        name: {{ .ctx.Values.cluster.name }}-{{ .name }}
        apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
        kind: GCPManagedMachinePool
{{- end }}


{{/*
Function to template an GCPManagedMachinePool resource.
Params:
  ctx = . context
  name = the name of the GCPManagedMachinePool resource
  defaultVals = the default values for the GCPManagedMachinePool resource
  values = the values for this specific GCPManagedMachinePool resource
  availabilityZones = the availability zones for the GCPManagedMachinePool
*/}}
{{- define "workers.managedMachinePool" -}}
{{- $scaling := (.values.spec | default dict).scaling | default .defaultVals.spec.scaling }}
{{- if $scaling }}
{{- if not (and (hasKey $scaling "minCount") (hasKey $scaling "maxCount")) }}
  {{- fail (printf "Invalid value for scaling. Both minCount and maxCount must be set") }}
{{- end }}
{{- end }}
{{- $management := (.values.spec | default dict).management | default .defaultVals.spec.management }}
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: GCPManagedMachinePool
metadata:
  name: {{ .ctx.Values.cluster.name }}-{{ .name }}
  annotations:
    helm.sh/resource-policy: keep
    {{- if (hasKey .values "annotations") -}}
    {{- toYaml (merge .values.annotations .defaultVals.annotations)| nindent 4 }}
    {{- else -}}
    {{- toYaml .defaultVals.annotations | nindent 4 }}
    {{- end }}
  labels:
    {{- if (hasKey .values "labels") -}}
    {{- toYaml (merge .values.labels .defaultVals.labels)| nindent 4 }}
    {{- else -}}
    {{- toYaml .defaultVals.labels | nindent 4 }}
    {{- end }}
spec:
  nodePoolName: {{ .name }}
  {{- if $scaling }}
  scaling:
    {{- toYaml $scaling | nindent 4 }}
  {{- end }}
  {{- if $management }}
  management:
    {{- toYaml $management | nindent 4 }}
  {{- end }}
  kubernetesLabels:
    {{- if (dig "spec" "kubernetesLabels" .values) }}
    {{- toYaml (merge .values.spec.kubernetesLabels .defaultVals.spec.kubernetesLabels) | nindent 4 }}
    {{- else }}
    {{- toYaml .defaultVals.spec.kubernetesLabels | nindent 4 }}
    {{- end }}
  {{- if or (.defaultVals.spec.kubernetesTaints) ((.values.spec | default dict).kubernetesTaints) }}
  kubernetesTaints:
  {{- toYaml ((.values.spec | default dict).kubernetesTaints | default .defaultVals.spec.kubernetesTaints) | nindent 4 }}
  {{- end }}
  additionalLabels:
    {{- if (dig "spec" "additionalLabels" .values) }}
    {{- toYaml (merge .values.spec.additionalLabels .defaultVals.spec.additionalLabels) | nindent 4 }}
    {{- else }}
    {{- toYaml .defaultVals.spec.additionalLabels | nindent 4 }}
    {{- end }}
  {{- if .values.spec.providerIDList }}
  providerIDList:
  {{- toYaml .values.spec.providerIDList | nindent 2 }}
  {{- end }}
  machineType: {{ (.values.spec | default dict).machineType | default .defaultVals.spec.machineType }}
  diskSizeGb: {{ (.values.spec | default dict).diskSizeGb | default .defaultVals.spec.diskSizeGb }}
  diskType: {{ (.values.spec | default dict).diskType | default .defaultVals.spec.diskType }}
  spot: {{ (.values.spec | default dict).spot | default .defaultVals.spec.spot }}
  preemptible: {{ (.values.spec | default dict).preemptible | default .defaultVals.spec.preemptible }}
  imageType: {{ (.values.spec | default dict).imageType | default .defaultVals.spec.imageType }}
---
{{- include "workers.machinePool" (dict "ctx" .ctx "name" .name "values" .values "defaultVals" .defaultVals) }}
{{- end }}
