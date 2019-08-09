apt install openvpn
https://github.com/OpenVPN/easy-rsa
cd /home/ca/easy-rsa-master/easyrsa3

#set_var EASYRSA_REQ_COUNTRY    "US"
#set_var EASYRSA_REQ_PROVINCE   "California"
#set_var EASYRSA_REQ_CITY       "San Francisco"
#set_var EASYRSA_REQ_ORG        "Copyleft Certificate Co"
#set_var EASYRSA_REQ_EMAIL      "me@example.net"
#set_var EASYRSA_REQ_OU         "My Organizational Unit"

./easyrsa init-pki
./easyrsa gen-dh
./easyrsa build-ca
./easyrsa gen-req openvpn-server nopass
./easyrsa sign-req server openvpn-server
./easyrsa gen-crl # после генерации клиентов
openvpn --genkey --secret ta.key
copy ca.crt dh.pem openvpn-server.crt openvpn-server.key ta.key     /etc/openvpn/server

./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1

copy ca.crt dh.pem client1.crt client1.key ta.key     /etc/openvpn/client

ip address static
mkdir /var/log/openvpn

/etc/sysctl.conf
net.ipv4.ip_forward=1
sysctl -p

service openvpn start
systemctl start openvpn-server@server
journalctl -xe

reboot!!!
