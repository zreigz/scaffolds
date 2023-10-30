{{/*
Expand the name of the chart.
*/}}
{{- define "cluster-api-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cluster-api-cluster.fullname" -}}
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
{{- define "cluster-api-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cluster-api-cluster.labels" -}}
helm.sh/chart: {{ include "cluster-api-cluster.chart" . }}
{{ include "cluster-api-cluster.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cluster-api-cluster.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cluster-api-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cluster-api-cluster.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cluster-api-cluster.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Creates the Kubernetes version for the cluster
# TODO: this should actually be used to sanatize the `.Values.cluster.kubernetesVersion` value to what the providers support instead of defining these static versions
*/}}
{{- define "cluster.kubernetesVersion" -}}
{{- if .Values.cluster.kubernetesVersion -}}
{{ .Values.cluster.kubernetesVersion }}
{{- else if eq .Values.provider "kind" -}}
v1.25.11
{{- end }}
{{- end }}

{{/*
Create the kind for the infrastructureRef for the cluster
*/}}
{{- define "cluster.infrastructure.kind" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
AWSManagedCluster
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
AzureManagedCluster
{{- end }}
{{- if and (eq .Values.provider "gcp") (eq .Values.type "managed") -}}
GCPManagedCluster
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
DockerCluster
{{- end }}
{{- end }}

{{/*
Create the apiVersion for the infrastructureRef for the cluster
*/}}
{{- define "cluster.infrastructure.apiVersion" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta2
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "gcp") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- end }}

{{/*
Create the kind for the controlPlaneRef for the cluster
*/}}
{{- define "cluster.controlPlane.kind" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
AWSManagedControlPlane
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
AzureManagedControlPlane
{{- end }}
{{- if and (eq .Values.provider "gcp") (eq .Values.type "managed") -}}
GCPManagedControlPlane
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
KubeadmControlPlane
{{- end }}
{{- end }}

{{/*
Create the apiVersion for the controlPlaneRef for the cluster
*/}}
{{- define "cluster.controlPlane.apiVersion" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
controlplane.cluster.x-k8s.io/v1beta2
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "gcp") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
controlplane.cluster.x-k8s.io/v1beta1
{{- end }}
{{- end }}

{{/*
Create the kind for the infrastructureRef for the worker MachinePools
*/}}
{{- define "workers.infrastructure.kind" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
AWSManagedMachinePool
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
AzureManagedMachinePool
{{- end }}
{{- if and (eq .Values.provider "gcp") (eq .Values.type "managed") -}}
GCPManagedMachinePool
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
DockerMachinePool
{{- end }}
{{- end }}

{{/*
Create the apiVersion for the infrastructureRef for the worker MachinePools
*/}}
{{- define "workers.infrastructure.apiVersion" -}}
{{- if and (eq .Values.provider "aws") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta2
{{- end }}
{{- if and (eq .Values.provider "azure") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "gcp") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
infrastructure.cluster.x-k8s.io/v1beta1
{{- end }}
{{- end }}

{{/*
Create the configRef for the worker MachinePools
*/}}
{{- define "workers.configref" -}}
{{- if and (eq .Values.provider "kind") (eq .Values.type "managed") -}}
configRef:
  apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
  kind: KubeadmConfig
  name: worker-mp-config
{{- end }}
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
  name: {{ .name }}
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
      {{- if or (eq .ctx.Values.provider "gcp") (eq .ctx.Values.provider "azure") (eq .ctx.Values.provider "kind") }}
      version: {{ .values.kubernetesVersion | default (include "cluster.kubernetesVersion" .ctx) | quote }}
      {{- end }}
      clusterName: {{ .ctx.Values.cluster.name }}
      bootstrap:
        {{- if or (eq .ctx.Values.provider "gcp") (eq .ctx.Values.provider "azure") (eq .ctx.Values.provider "aws") }}
        dataSecretName: ""
        {{- end }}
        {{- if eq .ctx.Values.provider "kind" }}
        {{- include "workers.configref" .ctx | nindent 8 }}
        {{- end }}
      infrastructureRef:
        name: {{ .name }}
        apiVersion: {{ include "workers.infrastructure.apiVersion" .ctx }}
        kind: {{ include "workers.infrastructure.kind" .ctx }}
{{- end }}

{{/*
Name of the AzureClusterIdentity used for bootstrapping
*/}}
{{- define "azure-bootstrap.cluster-identity-name" -}}
{{- printf "%s-azure-bootstrap-identity" .Release.Name | trunc 63 }}
{{- end }}

{{/*
Name of the secret for the AzureClusterIdentity used for bootstrapping
*/}}
{{- define "azure-bootstrap.identity-credentials" -}}
{{- printf "%s-azure-bootstrap-credentials" .Release.Name | trunc 63 }}
{{- end }}

{{/*
Name of the AAD Pod Identity used for bootstrapping
*/}}
{{- define "azure-bootstrap.pod-identity-name" -}}
{{- printf "%s-%s-%s" .Values.cluster.name .Release.Namespace (include "azure-bootstrap.cluster-identity-name" .) }}
{{- end }}

{{/*
Name of the AAD Pod Identity Binding used for bootstrapping
*/}}
{{- define "azure-bootstrap.pod-identity-binding" -}}
{{- printf "%s-binding" (include "azure-bootstrap.pod-identity-name" .) }}
{{- end }}

{{/*
Function to template an AzureManagedMachinePool resource.
Params:
  ctx = . context
  name = the name of the AzureManagedMachinePool resource
  defaultVals = the default values for the AzureManagedMachinePool resource
  values = the values for this specific AzureManagedMachinePool resource
  availabilityZones = the availability zones for the AzureManagedMachinePool
*/}}
{{- define "workers.azure.managedMachinePool" -}}
{{- $scaling := (.values.spec | default dict).scaling | default .defaultVals.spec.scaling }}
{{- if $scaling }}
{{- if not (and (hasKey $scaling "minSize") (hasKey $scaling "maxSize")) }}
  {{- fail (printf "Invalid value for scaling. Both minSize and maxSize must be set") }}
{{- end }}
{{- end }}
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: AzureManagedMachinePool
metadata:
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
  name: {{ .name }}
spec:
  name: {{ .name }}
  additionalTags:
    {{- if (dig "spec" "additionalTags" .values) -}}
    {{- toYaml (merge .values.spec.additionalTags .defaultVals.spec.additionalTags)| nindent 4 }}
    {{- else }}
    {{- toYaml .defaultVals.spec.additionalTags | nindent 4 }}
    {{- end }}
  mode: {{ (.values.spec | default dict).mode | default .defaultVals.spec.mode }}
  sku: {{ (.values.spec | default dict).sku | default .defaultVals.spec.sku }}
  osDiskSizeGB: {{ (.values.spec | default dict).osDiskSizeGB | default .defaultVals.spec.osDiskSizeGB }}
  availabilityZones: {{- toYaml .availabilityZones | nindent 2 }}
  nodeLabels:
    {{- if (dig "spec" "nodeLabels" .values) -}}
    {{- toYaml (merge .values.spec.nodeLabels .defaultVals.spec.nodeLabels)| nindent 4 }}
    {{- else -}}
    {{- toYaml .defaultVals.spec.nodeLabels | nindent 4 }}
    {{- end }}
  {{- if or (.defaultVals.spec.taints) ((.values.spec | default dict).taints) }}
  taints:
  {{- toYaml ((.values.spec | default dict).taints | default .defaultVals.spec.taints) | nindent 2 }}
  {{- end }}
  {{- if $scaling }}
  scaling:
    {{- toYaml $scaling | nindent 4 }}
  {{- end }}
  {{- if or (.defaultVals.spec.scaleDownMode) ((.values.spec | default dict).scaleDownMode) }}
  scaleDownMode: {{ (.values.spec | default dict).scaleDownMode | default .defaultVals.spec.scaleDownMode }}
  {{- end }}
  {{- if or (.defaultVals.spec.spotMaxPrice) ((.values.spec | default dict).spotMaxPrice) }}
  spotMaxPrice: {{ (.values.spec | default dict).spotMaxPrice | default .defaultVals.spec.spotMaxPrice }}
  {{- end }}
  maxPods: {{ (.values.spec | default dict).maxPods | default .defaultVals.spec.maxPods }}
  osDiskType: {{ (.values.spec | default dict).osDiskType | default .defaultVals.spec.osDiskType }}
  {{- if or (.defaultVals.spec.scaleSetPriority) ((.values.spec | default dict).scaleSetPriority) }}
  scaleSetPriority: {{ (.values.spec | default dict).scaleSetPriority | default .defaultVals.spec.scaleSetPriority }}
  {{- end }}
  osType: {{ (.values.spec | default dict).osType | default .defaultVals.spec.osType }}
  enableNodePublicIP: {{ (.values.spec | default dict).enableNodePublicIP | default .defaultVals.spec.enableNodePublicIP }}
  nodePublicIPPrefixID: {{ (.values.spec | default dict).nodePublicIPPrefixID | default .defaultVals.spec.nodePublicIPPrefixID }}
  {{- if or (.defaultVals.spec.kubeletConfig) ((.values.spec | default dict).kubeletConfig) }}
  kubeletConfig:
    {{- toYaml ((.values.spec | default dict).kubeletConfig | default .defaultVals.spec.kubeletConfig) | nindent 2 }}
  {{- end }}
  {{- if or (.defaultVals.spec.linuxOSConfig) ((.values.spec | default dict).linuxOSConfig) }}
  linuxOSConfig:
    {{- toYaml ((.values.spec | default dict).linuxOSConfig | default .defaultVals.spec.linuxOSConfig) | nindent 2 }}
  {{- end }}
---
{{- include "workers.machinePool" (dict "ctx" .ctx "name" .name "values" .values "defaultVals" .defaultVals) }}
{{- end }}
