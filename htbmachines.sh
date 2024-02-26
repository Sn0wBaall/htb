#!/bin/bash

#Colours
#
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Variables globales

mainUrl="https://htbmachines.github.io/bundle.js"

#funciones

function helpPanel(){
echo -e "\n${yellowColour}[+]$endColour${grayColour} Uso:${endColour}"
echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}"
echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por la ip de una maquina${endColour}"
echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de la resolucion de la maquina en Youtube"
echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostar este panel de ayuda\n${endColour}" 
}


function updateFiles(){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${redColour}[!]${endColour}${grayColour} El archivo no existe${endColour}"
    sleep 1
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios${endColour}"
    sleep 2
    curl -s $mainUrl > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${greenColour}[+]${endColour}${grayColour} Listo, archivos descargados ;)${endColour}"
  else
    echo -e "\n${redColour}[!]${endColour}${grayColour} Buscando actualizaciones${endColour}"
    sleep 3
    curl -s $mainUrl > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5tempValue=$(md5sum bundle_temp.js | awk '{print $1}')
    md5originalValue=$(md5sum bundle.js | awk '{print $1}')
    if [ $md5tempValue != $md5originalValue ];then
      echo -e "\n${greenColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Aplicando actualizaciones${endColour}"
      sleep 2
      rm bundle.js
      mv bundle_temp.js bundle.js
      echo -e "\n${greenColour}[+]${endColour}${grayColour} Listo, archivos actualizados${endColour}"
    else
      echo -e "\n${greenColour}[+]${endColour}${grayColour}No se han encontrado actualizaciones, tienes todo al dia ;)${endColour}"
      rm bundle_temp.js
    fi
    tput cnorm
  fi
     
}

function searchMachine(){
  machineName="$1"
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina${endColour}${turquoiseColour} $machineName${endColour}${grayColour}:${endColour}\n"
  
  cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' 
}

function searchIp(){
  ipAdress="$1"
  
  machineName="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la ip${endColour}${turquoiseColour} $ipAdress${endColour}${grayColour} es:${endColour}${redColour} $machineName${endColour}"

}

function searchLink(){
  machineLink="$1"
  
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineLink\"/,/resuelta/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} El link de la maquina${endColour}${turquoiseColour} $machineLink${endColour}${grayColour} es:${endColour}${redColour} $youtubeLink${endColour}"
}

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1

}
trap ctrl_c INT
sleep 1


#Indicadores
declare -i parameter_counter=0 

while getopts "m:i:y:uh" arg; do 
  case $arg in 
    m) machineName=$OPTARG; let parameter_counter=1;;
    u) let parameter_counter=2;;
    i) ipAdress=$OPTARG; let parameter_counter=3;;
    y) machineLink=$OPTARG; let parameter_counter=4;; 
    h) ;;
  esac
done

#Condicionales

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ];then
  updateFiles
elif [ $parameter_counter -eq 3 ];then
  searchIp $ipAdress
elif [ $parameter_counter -eq 4 ]; then
  searchLink $machineLink
else
  helpPanel
fi  







