apt install -y atop htop mc net-tools ntpdate lnav cifs-utils zabbix-agent open-vm-tools curl gnupg2
apt install -y apt-transport-https ca-certificates  software-properties-common

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt update

apt install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
apt install -y kubeadm kubectl kubelet

DOCKER API ENABLE-----------------
/etc/systemd/system/multi-user.target.wants/docker.service
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -H tcp://0.0.0.0:2375

K8S INIT-----------------
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
update-alternatives --set arptables /usr/sbin/arptables-legacy
update-alternatives --set ebtables /usr/sbin/ebtables-legacy

swapoff /swap.imp
kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=10.55.0.140 --apiserver-advertise-address=10.55.0.140 --service-cidr=10.245.0.0/16
mkdir -p $HOME/.kube && cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

K8S INGRESS CONTROLLER----------------
https://kubernetes.github.io/ingress-nginx/deploy/
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

K8S LOAD BALANCER BARE METALL ------------------------
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml

K8S PROMETHEUS + GRAFANA -----------------------------
https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md
https://github.com/coreos/prometheus-operator

K8S DOCKER-REGISTRY ---------------------------
kubectl create secret docker-registry docker-registry-credentials --docker-server=DOCKER_REGISTRY_SERVER --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD --docker-email=fuck

K8S MULTIMASTER-------------
scp -r /etc/kubernetes/pki/ root@k8s-master-2:/etc/kubernetes/

kubeadm join 10.55.0.140:6443 --token vyoo0b.dlr1bw86filn9b4w \
  --discovery-token-ca-cert-hash sha256:fdd9fad71733e55ea1955275b5c3f544bc4d84a88997d55adc78fed0a63cdbc5 \
  --control-plane

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.55.0.140:6443 --token vyoo0b.dlr1bw86filn9b4w \
  --discovery-token-ca-cert-hash sha256:fdd9fad71733e55ea1955275b5c3f544bc4d84a88997d55adc78fed0a63cdbc5

watch kubectl get all --all-namespaces -o wide
kubectl get nodes --all-namespaces -o wide
kubectl get pods --all-namespaces -o wide
kubectl get services --all-namespaces -o wide
kubectl edit cm coredns -n kube-system
kubectl exec -it pod/nginx-deployment-1-5d8ffdf944-tcn4z -- /bin/bash

K8S DASHBOARD--------------------
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
kubectl proxy --address=0.0.0.0 --accept-hosts='.*'
http://10.55.0.140:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

kubectl edit deployment/kubernetes-dashboard --namespace=kubernetes-dashboard
containers:
     - args:
       - --auto-generate-certificates
       - --enable-skip-login
       - --disable-settings-authorizer
kubectl describe pods kubernetes-dashboard -n kubernetes-dashboard
kubectl describe service kubernetes-dashboard -n kubernetes-dashboard

K8S nginx-------------------
kubectl create -f nginx-deployment.yaml
kubectl create -f nginx-service.yaml
kubectl get deployments
kubectl describe service nginx-service
kubectl describe pods nginx-deployment
kubectl get replicasets
kubectl describe replicasets

K8S Schedule--------------------
kubectl describe node node-master
kubectl taint node node-master node-role.kubernetes.io/master:NoSchedule-
kubectl taint node node-master key=value:NoSchedule
kubectl taint node node-master key=value:NoExecute

kubectl cordon my-node
kubectl drain my-node --ignore-daemonsets
kubectl uncordon my-node

K8S REMOVE----------------------
kubeadm reset -f
rm -r $HOME/.kube
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
apt remove -y kubeadm kubectl kubelet
reboot
