./helm install stable/prometheus-operator
./helm delete erstwhile-wolverine

kubectl get secret erstwhile-wolverine-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
