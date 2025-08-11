# templates/_helpers.tpl
{{/*
Expand the name of the chart.
*/}}
{{- define "nexus-database.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "nexus-database.fullname" -}}
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
{{- define "nexus-database.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nexus-database.labels" -}}
helm.sh/chart: {{ include "nexus-database.chart" . }}
{{ include "nexus-database.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.global.environment }}
component: data
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nexus-database.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nexus-database.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MongoDB labels
*/}}
{{- define "nexus-database.mongodb.labels" -}}
{{ include "nexus-database.labels" . }}
tier: database
database-type: mongodb
{{- end }}

{{/*
PostgreSQL labels
*/}}
{{- define "nexus-database.postgresql.labels" -}}
{{ include "nexus-database.labels" . }}
tier: database
database-type: postgresql
{{- end }}

{{/*
Redis labels
*/}}
{{- define "nexus-database.redis.labels" -}}
{{ include "nexus-database.labels" . }}
tier: cache
database-type: redis
{{- end }}

{{/*
Messaging labels
*/}}
{{- define "nexus-database.messaging.labels" -}}
{{ include "nexus-database.labels" . }}
tier: messaging
{{- end }}

---
# templates/namespace.yaml
{{- if .Values.global.namespace }}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.labels" . | nindent 4 }}
    name: {{ .Values.global.namespace }}
{{- end }}

---
# templates/mongodb/cart-mongodb-statefulset.yaml
{{- if and .Values.mongodb.enabled .Values.mongodb.cart.enabled }}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ .Values.mongodb.cart.name }}
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.mongodb.labels" . | nindent 4 }}
    app: {{ .Values.mongodb.cart.name }}
    service: cart-service
spec:
  serviceName: {{ .Values.mongodb.cart.name }}-headless
  replicas: {{ .Values.mongodb.cart.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.mongodb.cart.name }}
  template:
    metadata:
      labels:
        {{- include "nexus-database.mongodb.labels" . | nindent 8 }}
        app: {{ .Values.mongodb.cart.name }}
        service: cart-service
    spec:
      {{- if .Values.global.nodeSelector }}
      nodeSelector:
        {{- toYaml .Values.global.nodeSelector | nindent 8 }}
      {{- end }}
      containers:
        - name: mongodb
          image: "{{ .Values.mongodb.cart.image.repository }}:{{ .Values.mongodb.cart.image.tag }}"
          imagePullPolicy: {{ .Values.mongodb.cart.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.mongodb.cart.service.port }}
              name: mongodb
          env:
            - name: MONGO_INITDB_ROOT_USERNAME
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.mongodb.cart.name }}-secret
                  key: username
            - name: MONGO_INITDB_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.mongodb.cart.name }}-secret
                  key: password
            - name: MONGO_INITDB_DATABASE
              value: {{ .Values.mongodb.cart.database.name }}
            - name: MONGO_INITDB_ARGS
              value: "--auth"
          volumeMounts:
            - name: mongodb-data
              mountPath: /data/db
            - name: mongodb-config
              mountPath: /data/configdb
          resources:
            {{- toYaml .Values.mongodb.cart.resources | nindent 12 }}
          startupProbe:
            tcpSocket:
              port: {{ .Values.mongodb.cart.service.port }}
            initialDelaySeconds: 60
            periodSeconds: 15
            timeoutSeconds: 10
            failureThreshold: 20
          readinessProbe:
            tcpSocket:
              port: {{ .Values.mongodb.cart.service.port }}
            initialDelaySeconds: 90
            periodSeconds: 15
            timeoutSeconds: 10
            failureThreshold: 5
          livenessProbe:
            tcpSocket:
              port: {{ .Values.mongodb.cart.service.port }}
            initialDelaySeconds: 180
            periodSeconds: 30
            timeoutSeconds: 10
            failureThreshold: 3
  volumeClaimTemplates:
    - metadata:
        name: mongodb-data
        labels:
          {{- include "nexus-database.mongodb.labels" . | nindent 10 }}
          app: {{ .Values.mongodb.cart.name }}
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: {{ .Values.global.storageClass }}
        resources:
          requests:
            storage: {{ .Values.mongodb.cart.storage.data.size }}
    - metadata:
        name: mongodb-config
        labels:
          {{- include "nexus-database.mongodb.labels" . | nindent 10 }}
          app: {{ .Values.mongodb.cart.name }}
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: {{ .Values.global.storageClass }}
        resources:
          requests:
            storage: {{ .Values.mongodb.cart.storage.config.size }}
{{- end }}

---
# templates/mongodb/cart-mongodb-service.yaml
{{- if and .Values.mongodb.enabled .Values.mongodb.cart.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.mongodb.cart.name }}-headless
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.mongodb.labels" . | nindent 4 }}
    app: {{ .Values.mongodb.cart.name }}
    service: cart-service
spec:
  clusterIP: None
  selector:
    app: {{ .Values.mongodb.cart.name }}
  ports:
    - name: mongodb
      port: {{ .Values.mongodb.cart.service.port }}
      targetPort: {{ .Values.mongodb.cart.service.port }}
      protocol: TCP
{{- end }}

---
# templates/mongodb/cart-mongodb-configmap.yaml
{{- if and .Values.mongodb.enabled .Values.mongodb.cart.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.mongodb.cart.name }}-config
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.mongodb.labels" . | nindent 4 }}
    app: {{ .Values.mongodb.cart.name }}
    service: cart-service
data:
  database-name: {{ .Values.mongodb.cart.database.name | quote }}
  mongodb-url: "mongodb://{{ .Values.mongodb.cart.name }}-headless.{{ .Values.global.namespace }}.svc.cluster.local:{{ .Values.mongodb.cart.service.port }}/{{ .Values.mongodb.cart.database.name }}"
  mongod.conf: |
    storage:
      dbPath: /data/db
      journal:
        enabled: true
      wiredTiger:
        engineConfig:
          cacheSizeGB: 0.5

    systemLog:
      destination: file
      logAppend: true
      path: /var/log/mongodb/mongod.log
      logRotate: reopen

    net:
      port: {{ .Values.mongodb.cart.service.port }}
      bindIp: 0.0.0.0
      maxIncomingConnections: 100

    processManagement:
      timeZoneInfo: /usr/share/zoneinfo

    security:
      authorization: enabled
{{- end }}

---
# templates/mongodb/cart-mongodb-secret.yaml
{{- if and .Values.mongodb.enabled .Values.mongodb.cart.enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Values.mongodb.cart.name }}-secret
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.mongodb.labels" . | nindent 4 }}
    app: {{ .Values.mongodb.cart.name }}
    service: cart-service
type: Opaque
data:
  username: {{ .Values.mongodb.cart.auth.username | b64enc }}
  password: {{ .Values.mongodb.cart.auth.password | b64enc }}
{{- end }}

---
# templates/postgresql/product-postgres-statefulset.yaml
{{- if and .Values.postgresql.enabled .Values.postgresql.product.enabled }}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ .Values.postgresql.product.name }}
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.postgresql.labels" . | nindent 4 }}
    app: {{ .Values.postgresql.product.name }}
    service: product-service
spec:
  serviceName: {{ .Values.postgresql.product.name }}-service
  replicas: {{ .Values.postgresql.product.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.postgresql.product.name }}
  template:
    metadata:
      labels:
        {{- include "nexus-database.postgresql.labels" . | nindent 8 }}
        app: {{ .Values.postgresql.product.name }}
        service: product-service
    spec:
      {{- if .Values.global.nodeSelector }}
      nodeSelector:
        {{- toYaml .Values.global.nodeSelector | nindent 8 }}
      {{- end }}
      containers:
        - name: postgres
          image: "{{ .Values.postgresql.product.image.repository }}:{{ .Values.postgresql.product.image.tag }}"
          imagePullPolicy: {{ .Values.postgresql.product.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.postgresql.product.service.port }}
              name: postgres
          env:
            - name: POSTGRES_DB
              value: {{ .Values.postgresql.product.database.name }}
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.postgresql.product.name }}-secret
                  key: username
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.postgresql.product.name }}-secret
                  key: password
            - name: PGDATA
              value: "/var/lib/postgresql/data/pgdata"
            - name: POSTGRES_INITDB_ARGS
              value: "--auth-local=trust --auth-host=scram-sha-256"
          volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
            - name: postgres-config
              mountPath: /etc/postgresql
              readOnly: true
          resources:
            {{- toYaml .Values.postgresql.product.resources | nindent 12 }}
          livenessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - $(POSTGRES_USER)
                - -d
                - $(POSTGRES_DB)
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - $(POSTGRES_USER)
                - -d
                - $(POSTGRES_DB)
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 3
          startupProbe:
            exec:
              command:
                - pg_isready
                - -U
                - $(POSTGRES_USER)
                - -d
                - $(POSTGRES_DB)
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 12
      volumes:
        - name: postgres-config
          configMap:
            name: {{ .Values.postgresql.product.name }}-config
  volumeClaimTemplates:
    - metadata:
        name: postgres-data
        labels:
          {{- include "nexus-database.postgresql.labels" . | nindent 10 }}
          app: {{ .Values.postgresql.product.name }}
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: {{ .Values.postgresql.product.storage.size }}
        storageClassName: {{ .Values.global.storageClass }}
{{- end }}

---
# templates/postgresql/product-postgres-service.yaml
{{- if and .Values.postgresql.enabled .Values.postgresql.product.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.postgresql.product.name }}-service
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.postgresql.labels" . | nindent 4 }}
    app: {{ .Values.postgresql.product.name }}
    service: product-service
spec:
  clusterIP: None
  selector:
    app: {{ .Values.postgresql.product.name }}
  ports:
    - name: postgres
      port: {{ .Values.postgresql.product.service.port }}
      targetPort: {{ .Values.postgresql.product.service.port }}
      protocol: TCP
{{- end }}

---
# templates/postgresql/product-postgres-configmap.yaml
{{- if and .Values.postgresql.enabled .Values.postgresql.product.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.postgresql.product.name }}-config
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.postgresql.labels" . | nindent 4 }}
    app: {{ .Values.postgresql.product.name }}
    service: product-service
data:
  database-name: {{ .Values.postgresql.product.database.name | quote }}
{{- end }}

---
# templates/postgresql/product-postgres-secret.yaml
{{- if and .Values.postgresql.enabled .Values.postgresql.product.enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Values.postgresql.product.name }}-secret
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.postgresql.labels" . | nindent 4 }}
    app: {{ .Values.postgresql.product.name }}
    service: product-service
type: Opaque
data:
  username: {{ .Values.postgresql.product.auth.username | b64enc }}
  password: {{ .Values.postgresql.product.auth.password | b64enc }}
  database: {{ .Values.postgresql.product.database.name | b64enc }}
  host: {{ printf "%s-service" .Values.postgresql.product.name | b64enc }}
  port: {{ .Values.postgresql.product.service.port | toString | b64enc }}
{{- end }}

---
# templates/redis/redis-deployment.yaml
{{- if .Values.redis.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.redis.name }}
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "nexus-database.redis.labels" . | nindent 4 }}
    app: {{ .Values.redis.name }}
spec:
  replicas: {{ .Values.redis.replicas }}
  selector:
    matchLabels:
      app: {{ .Values.redis.name }}
  template:
    metadata:
      labels:
        {{- include "nexus-database.redis.labels" . | nindent 8 }}
        app: {{ .Values.redis.name }}
    spec:
      {{- if .Values.global.nodeSelector }}
      nodeSelector:
        {{- toYaml .Values.global.nodeSelector | nindent 8 }}
      {{- end }}
      containers:
        - name: redis
          image: "{{ .Values.redis.image.repository }}:{{ .Values.redis.image.tag }}"
          imagePullPolicy: {{ .Values.redis.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.redis.service.port }}
              name: redis-port
          command:
            - redis-server
            - /usr/local/etc/redis/redis.conf
          resources:
            {{- toYaml .Values.redis.resources | nindent 12 }}
          volumeMounts:
            - name: redis-data
              mountPath: /data
            - name: redis-config
              mountPath: /usr/local/etc/redis
              readOnly: true
          env:
            - name: REDIS_PORT
              value: {{ .Values.redis.service.port | quote }}
          livenessProbe:
            tcpSocket:
              port: {{ .Values.redis.service.port }}
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            exec:
              command:
                - redis-cli
                - ping
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 3
          startupProbe:
            tcpSocket:
              port: {{ .Values.redis.service.port }}
            initialDelaySeconds: 10
            periodSeconds: 5
            failureThreshold: 10
      volumes:
        - name: redis-data
          persistentVolumeClaim:
            claimName: {{ .Values.redis.name }}-pvc
        - name: redis-config
          configMap:
            name: {{ .Values.redis.name }}-config
      restartPolicy: Always
{{- end }}