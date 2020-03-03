# tkn

[tektoncd/cli](https://github.com/tektoncd/cli) `docker` image build.

## Development

Build the image using `docker`: `docker build --rm -t tkn .`

Run the image using `docker`:
```console
$ docker run --rm -it \
    -v ${HOME}/.kube:/home/tekton/.kube \
    -v ${HOME}/.config/gcloud:/home/tekton/.config/gcloud \
    --network host \
    tkn --help
```

Lint the `Dockerfile`: `docker run --rm -i hadolint/hadolint < Dockerfile`


### Tekton Triggers

The `.tekton` directory contains [Kubernetes](https://kubernetes.io/) specifications for [Tekton Triggers](https://github.com/tektoncd/triggers).

The [`EventListener`](https://github.com/tektoncd/triggers/blob/master/docs/eventlisteners.md) intercepts `push` and `pull_request` events from GitHub then triggers a [`TaskRun`](https://github.com/tektoncd/pipeline/blob/master/docs/taskruns.md) to lint the projects `Dockerfile` using the [`hadolint/hadolint`](https://hub.docker.com/r/hadolint/hadolint) `docker` image.

#### Installation

1. Create the `github-secret`:
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  annotations:
  name: github-secret
type: Opaque
data:
  secret: cmFuZG9t
  token: Y2hzY1k2c2V2MFVpUWRzYXZvY25ZL21RdDhWNEJHTDlEdmdnL0ZNME95OD0K
EOF
```

2. Create the `tekton-triggers` role object: `kubectl apply -f .tekton/role.yaml`

3. Create the `tkn` service account: `kubectl apply -f .tekton/serviceaccount.yaml`

4. Create the service account role binding: `kubectl create rolebinding tkn-tekton-triggers --role tekton-triggers --serviceaccount tkn:tkn`

5. Create the `hadolint` task: `kubectl apply -f .tekton/task.yaml`

6. Create the event listener and triggers: `kubectl apply -f .tekton/triggers.yaml`

7. Create an [`Ingress`](https://kubernetes.io/docs/concepts/services-networking/ingress/) resource to expose the `EventListener`:
```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-resource
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: tekton.example.com
    http:
      paths:
        - path: /
          backend:
            serviceName: _EVENTLISTENER_
            servicePort: 8080
  tls:
  - hosts:
    - tekton.example.com
    secretName: tls-secret
EOF
```
