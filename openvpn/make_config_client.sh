#!/bin/bash
KEY_DIR=/etc/openvpn/client
KEY_DIR_SERVER=/etc/openvpn/server
OUTPUT_DIR=/etc/openvpn/client
BASE_CONFIG=/etc/openvpn/client/client.conf

cat ${BASE_CONFIG} <(echo -e '<ca>') ${KEY_DIR_SERVER}/ca.crt <(echo -e '</ca>\n<cert>') ${KEY_DIR}/${1}.crt <(echo -e '</cert>\n<key>') ${KEY_DIR}/${1}.key <(echo -e '</key>\n<tls-auth>') ${KEY_DIR_SERVER}/ta.key <(echo -e '</tls-auth>') > ${OUTPUT_DIR}/${1}.ovpn
