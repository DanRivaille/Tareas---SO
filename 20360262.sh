#!bin/bash

#Ivan Dan Santos Vila
#20.360.262-6

#Funciones correspondientes a los parametros ingresado al script

#Funcion parametro -ps
function comandPs {
	echo "tecleo -ps"
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
	echo "sin comandos"
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
