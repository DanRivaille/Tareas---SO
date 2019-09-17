#!bin/bash

#Ivan Dan Santos Vila
#20.360.262-6

#Funciones correspondientes a los parametros ingresado al script

#Funcion script sin parametros
function noComand {
	cd /proc

	model_name=$(head cpuinfo | grep "model name" | awk '{print $4,$5,$6,$7,$9}')
	kernel_version=$(cat version | awk '{print $3}')
	memory=$(head meminfo | grep "MemTotal:" | awk '{print $2}')
	uptime=$(cat uptime | awk '{print $1/84600}')

	echo "ModelName:     $model_name"
	echo "KernelVersion: $kernel_version"
	echo "Memory (kb):   $memory kb"
	echo "Uptime (dias): $uptime"
}

#Funcion parametro -ps
function comandPs {
	cd /proc

	printf "%10s %8s %8s %15s %60s\n" "UID" "PID" "PPID" "STATUS" "CMD"

	for directory in *; do
		if [[ $directory =~ [0-9] ]]; then
			uid=$(head $directory/stat | awk '{print $5}')
			pid=$(head $directory/stat | awk '{print $1}')
			ppid=$(head $directory/stat | awk '{print $4}')
			status=$(head $directory/stat | awk '{print $3}')
			cant_words=$(wc -w $directory/cmdline | awk '{print $1}')				#se cuentan las lines de cmdline, si son 0, se lee comm

			printf "%10s %8s %8s " "$uid" "$pid" "$ppid"

			if [ $status == "S" ]; then
				printf "%15s " "Sleeping"
			elif [ $status == "I" ]; then
				printf "%15s " "Idle"
			elif [ $status == "R" ]; then
				printf "%15s " "Running"
			else
				printf "%15s " "$status"
			fi

			if [ $cant_words -ne 0 ]; then						#se valida si el archivo cmdline contiene alguna palabra
				cmd=$(cat $directory/cmdline | awk '{print $1}')
			else
				cmd=$(cat $directory/comm | awk '{print $1}')
			fi

			printf "%60s\n" "$cmd"
		fi
	done
}

#Funcion parametro -psBloked
function comandPsBlocked {
	cd /proc

	printf "%10s %30s %15s\n" "PID" "NOMBRE PROCESO" "TIPO"

	IFS=$'\n' # nuevo separador de campo, el caracter fin de línea
	for line in $(sort -k 2 locks)
	do
		pid=$(echo $line | awk '{print $5}')
		bloqueo=$(echo $line | awk '{print $2}')

		name=$(head $pid/status | grep "Name:" | awk '{print $2}')

		printf "%10s %30s %15s\n" "$pid" "$name" "$bloqueo"
	done
}

#Funcion parametro -m
function comandM {
	cd /proc

	printf "%15s %15s\n" "Total" "Available"

	total=$(head meminfo | grep "MemTotal:" | awk '{print $2/1000000}')
	mem_total=$(echo ${total:0:3})

	available=$(head meminfo | grep "MemAvailable:" | awk '{print $2/1000000}')
	mem_available=$(echo ${available:0:3})

	printf "%15s %15s\n" "$mem_total" "$mem_available"
}

#Funcion para tranformar a notacion decimal
function transfDec {
	echo "hola"	
}

#Funcion parametro -tcp
function comandTcp {
	cd /proc

	printf "%20s %20s %15s\n" "Source:Port" "Destination:Port" "Status"
	cant_lineas=$(wc -l net/tcp | awk '{print $1+1}')

	for ((i = 2 ; i <= $cant_lineas ; i++)); do
		ip_port_origen=$(awk -v linea_actual=$i '{if (NR == linea_actual) print $2}' net/tcp)
		ip_port_destino=$(awk -v linea_actual=$i '{if (NR == linea_actual) print $3}' net/tcp)
		status=$(awk -v linea_actual=$i '{if (NR == linea_actual) print $4}' net/tcp)

		ip_origen_hex=$(echo ${ip_port_origen:0:8})
		ip_destino_hex=$(echo ${ip_port_destino:0:8})

		ip_origen=$(echo "ibase=16; $ip_origen_hex" | bc)
		ip_destino=$(echo "ibase=16; $ip_destino_hex" | bc)

		port_origen_hex=$(echo ${ip_port_origen#*:})
		port_destino_hex=$(echo ${ip_port_destino#*:})

		port_origen=$(echo "ibase=16; $port_origen_hex" | bc)
		port_destino=$(echo "ibase=16; $port_destino_hex" | bc)

		printf "     %010d:%s \t  %010d:%s " "$ip_origen" "$port_origen" "$ip_destino" "$port_destino"

		if [ "$status" == "0A" ]; then
			printf "%15s\n" "LISTEN"
		elif [ "$status" == "06" ]; then
			printf "%15s\n" "TIME WAIT"
		elif [ "$status" == "01" ]; then
			printf "%15s\n" "ESTABLISHED"
		fi

	done
}

#Funcion parametro -tcpSatus
function comandTcpStatus {
	cd /proc

	printf "%20s %20s %15s\n" "Source:Port" "Destination:Port" "Status"


	IFS=$'\n' # nuevo separador de campo, el caracter fin de línea
	for line in $(sort -k 4 net/tcp)
	do
		ip_port_origen=$(echo $line | awk '{if ($1 != "sl") print $2}')
		ip_port_destino=$(echo $line | awk '{if ($1 != "sl") print $3}')
		status=$(echo $line | awk '{if ($1 != "sl") print $4}')

		printf "%20s %20s " "$ip_port_origen" "$ip_port_destino"

		if [ "$status" == "0A" ]; then
			printf "%15s\n" "LISTEN"
		elif [ "$status" == "06" ]; then
			printf "%15s\n" "TIME WAIT"
		elif [ "$status" == "01" ]; then
			printf "%15s\n" "ESTABLISHED"
		fi

	done
}

#Funcion parametro -help
function comandoHelp {
	echo "tecleo -help"
}

#Programa Principal

if [ $# -eq 0 ]; then
	noComand
else
	case $1 in
	"-ps")
		comandPs
	;;

	"-psBlocked")
		comandPsBlocked
	;;

	"-m")
		comandM
	;;

	"-tcp")
		comandTcp
	;;

	"-tcpStatus")
		comandTcpStatus
	;;

	"-help")
		comandTcpStatus
	;;

	*)
		echo "comando no valido"
	;;
	esac
fi
