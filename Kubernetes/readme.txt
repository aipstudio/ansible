apt install -y atop htop mc net-tools ntpdate lnav cifs-utils zabbix-agent open-vm-tools curl gnupg2
apt install -y apt-transport-https ca-certificates  software-properties-common

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
apt update

apt install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
apt install -y kubeadm kubectl kubelet=1.15.4-00

---DOCKER API ENABLE
/etc/systemd/system/multi-user.target.wants/docker.service
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -H tcp://0.0.0.0:2375

---K8S INIT
swapoff /swap.imp
apt install kubelet=1.15.4-00
kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=10.55.0.140 --apiserver-advertise-address=10.55.0.141 --service-cidr=10.245.0.0/16
mkdir -p $HOME/.kube && cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
kubectl apply -f metallb.yaml

coredns pending --> kubectl edit cm coredns -n kube-system
delete loop

---K8S MULTIMASTER
scp -r /etc/kubernetes/pki/ root@wex-2:/etc/kubernetes/

  kubeadm join 10.55.0.140:6443 --token vu2z2d.1sylk0ct2za7ohu0 \
    --discovery-token-ca-cert-hash sha256:6173315a83ec2a995b6cf2617ee08e0729beccbb2b484ce2d267b5bda00ae718 \
    --control-plane

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.55.0.140:6443 --token vu2z2d.1sylk0ct2za7ohu0 \
    --discovery-token-ca-cert-hash sha256:6173315a83ec2a995b6cf2617ee08e0729beccbb2b484ce2d267b5bda00ae718

watch kubectl get all --all-namespaces -o wide
kubectl get nodes --all-namespaces -o wide
kubectl get pods --all-namespaces -o wide
kubectl get services --all-namespaces -o wide

---K8S DASHBOARD
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
kubectl proxy --address=0.0.0.0 --accept-hosts='.*'
http://0.0.0.0:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login

kubectl edit deployment/kubernetes-dashboard -n kubernetes-dashboard
containers:
     - args:
       - --auto-generate-certificates
       - --enable-skip-login
       - --disable-settings-authorizer
kubectl describe pods kubernetes-dashboard -n kubernetes-dashboard
kubectl describe service kubernetes-dashboard -n kubernetes-dashboard

--K8S nginx
kubectl create -f nginx-deployment.yaml
kubectl create -f nginx-service.yaml
kubectl get deployments
kubectl describe service nginx-service
kubectl describe pods nginx-deployment
kubectl get replicasets
kubectl describe replicasets

--K8S Schedule
kubectl describe node node-master
kubectl taint node node-master node-role.kubernetes.io/master:NoSchedule-
kubectl taint node node-master key=value:NoSchedule
kubectl taint node node-master key=value:NoExecute

kubectl cordon my-node
kubectl drain my-node --ignore-daemonsets
kubectl uncordon my-node

---K8S DASHBOARD REMOVE
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml

---K8S REMOVE
kubeadm reset -f
rm -r $HOME/.kube
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
apt remove -y kubeadm kubectl kubelet
reboot
