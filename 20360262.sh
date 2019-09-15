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

	printf "%10s %8s %8s %15s %30s\n" "UID" "PID" "PPID" "STATUS" "CMD"

	for directory in *; do
		if [[ $directory =~ [0-9] ]]; then
			uid=$(head $directory/stat | awk '{print $5}')
			pid=$(head $directory/stat | awk '{print $1}')
			ppid=$(head $directory/stat | awk '{print $4}')
			status=$(head $directory/stat | awk '{print $3}')
			cmd=$(head $directory/stat | awk '{print $2}')

			printf "%10s %8s %8s " "$uid" "$pid" "$ppid"

			if [ $status == "S" ]; then
				printf "%15s " "Sleeping"
			else
				printf "%15s " "$status"
			fi
			printf "%30s\n" "$cmd"
		fi
	done
}

#Funcion parametro -psBloked
function comandPsBlocked {
	echo "tecleo -psBlocked"
}

#Funcion parametro -m
function comandM {
	echo "tecleo -m"
}

#Funcion parametro -tcp
function comandTcp {
	echo "tecleo -tcp"
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
