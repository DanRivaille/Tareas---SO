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
	cant_lineas=$(wc -l locks | awk '{print $1}')

	for (( i = 1 ; i <= $cant_lineas ; i++ )); do
		pid=$(cat locks | awk -v linea_actual=$i '{if (NR == linea_actual) print $5}')
		bloqueo=$(cat locks | awk -v linea_actual=$i '{if (NR == linea_actual) print $2}')	

		name=$(head $pid/status | grep "Name:" | awk '{print $2}')
		
		printf "%10s %30s %15s\n" "$pid" "$name" "$bloqueo"
	done
}

#Funcion parametro -m
function comandM {
	cd /proc

	printf "%15s %15s\n" "Total" "Available"

	mem_total=$(head meminfo | grep "MemTotal:" | awk '{print $2/1000000}')
	mem_available=$(head meminfo | grep "MemAvailable:" | awk '{print $2/1000000}')

	#mem_total_pr=$(echo "scale=2; $mem_total / 10000000" | bc -l)

	printf "%15s %15s\n" "$mem_total" "$mem_available"
}

#Funcion parametro -tcp
function comandTcp {
	cd /proc

	printf "%20s %20s %15s\n" "Source:Port" "Destination:Port" "Status"
	cant_lineas=$(wc -l net/tcp | awk '{print $1+1}')

	for ((i = 2 ; i <= $cant_lineas ; i++)); do
		ip_origen=$(awk -v linea_actual=$i '{if (NR == linea_actual) print $2}' net/tcp)
		ip_destino=$(awk -v linea_actual=$i '{if (NR == linea_actual) print $3}' net/tcp)
		status=$(awk -v linea_actual=$i '{if (NR == linea_actual) print $4}' net/tcp)

		#primera_parte=$((16#{variable:6:2}))

		printf "%20s %20s " "$ip_origen" "$ip_destino"

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
	echo "tecleo -tcpStatus"
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
