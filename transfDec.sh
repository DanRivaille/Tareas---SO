#!bin/bash

#transforma la cadena pasada como argumento en formato dir_ip:port (ej: 3500007F:0035) en hexadecimal a una cadena en formato
#142.31.53.31:80

ip_pt1_hex=$(echo ${1:0:2})
ip_pt2_hex=$(echo ${1:2:2})
ip_pt3_hex=$(echo ${1:4:2})
ip_pt4_hex=$(echo ${1:6:2})

ip_pt1=$(echo "ibase=16; $ip_pt1_hex" | bc)
ip_pt2=$(echo "ibase=16; $ip_pt2_hex" | bc)
ip_pt3=$(echo "ibase=16; $ip_pt3_hex" | bc)
ip_pt4=$(echo "ibase=16; $ip_pt4_hex" | bc)

port_hex=$(echo ${1#*:})

port=$(echo "ibase=16; $port_hex" | bc)

echo "$ip_pt1.$ip_pt2.$ip_pt3.$ip_pt4:$port"

