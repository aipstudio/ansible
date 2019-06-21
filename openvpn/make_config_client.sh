#!/bin/bash
KEY_DIR=/etc/openvpn/client
OUTPUT_DIR=/etc/openvpn/client
BASE_CONFIG=/etc/openvpn/client.conf

cat ${BASE_CONFIG} <(echo -e '<ca>') ${KEY_DIR}/ca.crt <(echo -e '</ca>\n<cert>') ${KEY_DIR}/${1}.crt <(echo -e '</cert>\n<key>') ${KEY_DIR}/${1}.key <(echo -e '</key>\n<tls-auth>') ${KEY_DIR}/ta.key <(echo -e '</tls-auth>') > ${OUTPUT_DIR}/${1}.ovpn
