#!bin/bash

#Ivan Dan Santos Vila
#20.360.262-6

#Funciones correspondientes a los parametros ingresado al script

#Funcion script sin parametros
function noComand {
	cd /proc

	model_name=$(head cpuinfo | grep "model name" | awk '{print $4,$5,$6,$7,$9}')	#se extrae el modelo del procesador
	kernel_version=$(cat version | awk '{print $3}')				#se extrae la version del kernel
	memory=$(head meminfo | grep "MemTotal:" | awk '{print $2}')			#se extrae la cantidad de memoria
	uptime=$(cat uptime | awk '{print $1/84600}')					#se extrae el tiempo que ha estado prendido el equipo

	echo "ModelName:     $model_name"
	echo "KernelVersion: $kernel_version"
	echo "Memory (kb):   $memory kb"
	echo "Uptime (dias): $uptime"
}

#Funcion parametro -ps
function comandPs {
	cd /proc

	printf "%10s %8s %8s %15s %60s\n" "UID" "PID" "PPID" "STATUS" "CMD"		#se imprime el encabezado

	for directory in *; do							#para cada elemento dentro de /proc
		if [[ $directory =~ [0-9] ]]; then				#se pregunta si contiene almenos 1 numero el nombre del elemento
			uid=$(head $directory/stat | awk '{print $5}')			#se extrae el uid, (identificador del usuario)
			pid=$(head $directory/stat | awk '{print $1}')			#se extrae el pid, (idenificador del proceso)
			ppid=$(head $directory/stat | awk '{print $4}')			#se extrae el ppid, (pid del padre del proceso)
			status=$(head $directory/stat | awk '{print $3}')		#se extrae el status del proceso
			cant_words=$(wc -w $directory/cmdline | awk '{print $1}')	#se cuentan las lines de cmdline, si son 0, se lee comm

			printf "%10s %8s %8s " "$uid" "$pid" "$ppid"

			if [ $status == "S" ]; then				#dependiendo del caracter representante del estado del proceso
				printf "%15s " "Sleeping"				#se imprime la cadena que corresponde
			elif [ $status == "I" ]; then
				printf "%15s " "Idle"
			elif [ $status == "R" ]; then
				printf "%15s " "Running"
			elif [ $status == "D" ]; then
				printf "%15s " "Disk Sleep"
			elif [ $status == "T" ]; then
				printf "%15s " "Stopped"
			elif [ $status == "Z" ]; then
				printf "%15s " "Zombie"
			elif [ $status == "X" ]; then
				printf "%15s " "Death"
			else
				printf "%15s " "$status"
			fi

			if [ $cant_words -ne 0 ]; then					#se valida si el archivo cmdline contiene alguna palabra
				cmd=$(cat $directory/cmdline | awk '{print $1}')
			else
				cmd=$(cat $directory/comm | awk '{print $1}')		#si no es asi, se saca el cmd del archivo comm
			fi

			printf "%60s\n" "$cmd"
		fi
	done
}

#Funcion parametro -psBloked
function comandPsBlocked {
	cd /proc

	printf "%10s %30s %15s\n" "PID" "NOMBRE PROCESO" "TIPO"			#se imprime e encabezado

	IFS=$'\n' # nuevo separador de campo, el caracter fin de línea
	for line in $(sort -k 2 locks)						#se recorren las lineas ordenadas del archivo locks
	do
		pid=$(echo $line | awk '{print $5}')				#se extrae el pid del proceso
		bloqueo=$(echo $line | awk '{print $2}')			#se extrae el tipo de bloqueo

		name=$(head $pid/status | grep "Name:" | awk '{print $2}')	#se extrae el nombre der proceso

		printf "%10s %30s %15s\n" "$pid" "$name" "$bloqueo"		#se muestra la info
	done
}

#Funcion parametro -m
function comandM {
	cd /proc

	printf "%15s %15s\n" "Total" "Available"					#se imprime el encabezado

	total=$(head meminfo | grep "MemTotal:" | awk '{print $2/1000000}')		#se extrae la cantidad total de memoria
	mem_total=$(echo ${total:0:3})							#se trunca la cantidad a 1 decimal despues de la coma

	available=$(head meminfo | grep "MemAvailable:" | awk '{print $2/1000000}')	#se extrae la cantidad disponile de memoria
	mem_available=$(echo ${available:0:3})						#se trunca la cantidad a 1 decimal despues de la coma

	printf "%15s %15s\n" "$mem_total" "$mem_available"				#se muestra la info
}

#Funcion que recibe una cadena en formato ip:port en notacion hexadecimal(ej: 3500007F:0031) y retorna la misma cadena, convertidad en notacion
#decimal, y con formato (ej: 142.00.10.21:80)
function transfDec {
	ip_pt1_hex=$(echo ${1:0:2})				#se extraen los digitos 1 y 2 de la ip
	ip_pt2_hex=$(echo ${1:2:2})				#se extraen los digitos 3 y 4 de la ip
	ip_pt3_hex=$(echo ${1:4:2})				#se extraen los digitos 5 y 6 de la ip
	ip_pt4_hex=$(echo ${1:6:2})				#se extraen los digitos 7 y 8 de la ip

	ip_pt1=$(echo "ibase=16; $ip_pt1_hex" | bc)		#se transforman a notacion decimal cada par de digitos anteriormente extraidos
	ip_pt2=$(echo "ibase=16; $ip_pt2_hex" | bc)
	ip_pt3=$(echo "ibase=16; $ip_pt3_hex" | bc)
	ip_pt4=$(echo "ibase=16; $ip_pt4_hex" | bc)

	port_hex=$(echo ${1#*:})				#se extrae el puerto

	port=$(echo "ibase=16; $port_hex" | bc)			#se transforma el puerto a notacion decimal

	echo "$ip_pt1.$ip_pt2.$ip_pt3.$ip_pt4:$port"		#se retorna la cadena, agregandole el formato correspondiente
}

#Funcion parametro -tcp
function comandTcp {
	cd /proc

	printf "%20s %20s %15s\n" "Source:Port" "Destination:Port" "Status"	#se imprime el encabezado
	cant_lineas=$(wc -l net/tcp | awk '{print $1+1}')			#se cuentan la cantidad de lineas que tiene el archivo con la info

	for ((i = 2 ; i <= $cant_lineas ; i++)); do				#se recorren cada linea, partiendo de la 2, para no leer el encabezado
		ip_port_origen_hex=$(awk -v linea_actual=$i '{if (NR == linea_actual) print $2}' net/tcp)	#se estrae la ip:port origen en hexa
		ip_port_destino_hex=$(awk -v linea_actual=$i '{if (NR == linea_actual) print $3}' net/tcp)	#se extrae la ip_port destino en hexa
		status=$(awk -v linea_actual=$i '{if (NR == linea_actual) print $4}' net/tcp)			#se extrae el estatus

		if [ "$ip_port_origen_hex" == "" ]; then #Se valida si la cadena actual no es una cadena vacia, en caso que lo sea, termina la funcion
			return
		fi

		ip_port_origen=$(transfDec $ip_port_origen_hex)			#se tranforman las cadenas con el formato indicado
		ip_port_destino=$(transfDec $ip_port_destino_hex)

		printf "%20s %20s " "$ip_port_origen" "$ip_port_destino"	#se muestran las direcciones ip con su puerto correspondiente

		if [ "$status" == "0A" ]; then					#dependiendo del caracter representante del estado
			printf "%15s\n" "LISTEN"				#se imprime la cadena correspondiente
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

	printf "%20s %20s %15s\n" "Source:Port" "Destination:Port" "Status"		#se imprime el encabezado


	IFS=$'\n' # nuevo separador de campo, el caracter fin de línea
	for line in $(sort -k 4 net/tcp)						#se recorren cada linea del archivo ordenado
	do
		ip_port_origen_hex=$(echo $line | awk '{if ($1 != "sl") print $2}')	#se extraen la ip:port origen en hexadecimal
		ip_port_destino_hex=$(echo $line | awk '{if ($1 != "sl") print $3}')	#se extraen la ip:port destino en haxadecimal
		status=$(echo $line | awk '{if ($1 != "sl") print $4}')			#se extrae el estado de la conexion

		if [ "$ip_port_origen_hex" == "" ]; then	#Se valida si la cadena actual no es una cadena vacia, si lo es, termina la funcion
			exit
		fi

		ip_port_origen=$(transfDec $ip_port_origen_hex)				#se transforman las cadenas en el formado correspondiente
		ip_port_destino=$(transfDec $ip_port_destino_hex)

		printf "%20s %20s " "$ip_port_origen" "$ip_port_destino"		#se imprimen las direcciones ip con su puerto correspondiente

		if [ "$status" == "0A" ]; then						#dependiendo del caracter representante del estado
			printf "%15s\n" "LISTEN"					#se imprimen las cadenas correspondientes
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

if [ $# -eq 0 ]; then			#si no se introdujo ningun parametro
	noComand
else
	case $1 in			#si se introdujo -ps
	"-ps")
		comandPs
	;;

	"-psBlocked")			#si se introdujo -psBlocked
		comandPsBlocked
	;;

	"-m")				#si se introdujo -m
		comandM
	;;

	"-tcp")				#si se introdujo -tcp
		comandTcp
	;;

	"-tcpStatus")			#si se introdujo -tcpStatus
		comandTcpStatus
	;;

	"-help")			#si se introdujo -hep
		comandTcpStatus
	;;

	*)				#si el argumento ingresado no corresponde con ninguno de los anteriores
		echo "comando no valido"
	;;
	esac
fi
