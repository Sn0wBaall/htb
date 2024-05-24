#!/bin/bash

## COLOURS

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

## VARIABLES GLOBALES

mainUrl="https://htbmachines.github.io/bundle.js"

## FUNCIONES

function helpPanel(){
echo -e "\n${yellowColour}[+]$endColour${grayColour} Uso:${endColour}"
echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por nombre de maquina${endColour}"
echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por IP de maquina${endColour}"
echo -e "\t${purpleColour}y)${endColour}${grayColour} Mostar el link de youtube de la maquina${endColour}"
echo -e "\t${purpleColour}d)${endColour}${grayColour} Filtrar maquinas por dificultad${endColour}"
echo -e "\t${purpleColour}o)${endColour}${grayColour} Filtrar maquinas por sistema operativo${endColour}"
echo -e "\t${purpleColour}s)${endColour}${grayColour} Filtar las maquinas por sus skills${endColour}"
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
    tput cnorm 
  else
    echo -e "\n${redColour}[!]${endColour}${grayColour} Buscando actualizaciones${endColour}"
    sleep 3
    curl -s $mainUrl > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5tempValue=$(md5sum bundle_temp.js | awk '{print $1}')
    md5originalValue=$(md5sum bundle.js | awk '{print $1}')
    if [ $md5tempValue != $md5originalValue ];then
      tput civis
      echo -e "\n${greenColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Aplicando actualizaciones${endColour}"
      sleep 2
      rm bundle.js
      mv bundle_temp.js bundle.js
      echo -e "\n${greenColour}[+]${endColour}${grayColour} Listo, archivos actualizados${endColour}"
    else
      fcho -e "\n${greenColour}[+]${endColour}${grayColour}No se han encontrado actualizaciones, tienes todo al dia ;)${endColour}"
      rm bundle_temp.js
    fi
    tput cnorm
  fi     
}

function searchMachine(){
  machineName="$1"

  machinenameChecker="$( cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

  if [ $machinenameChecker ]; then
  

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"

  cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed "s/^ *//" | sed "s/: / -> /" 
  
  else 

    echo -e "\n${redColour}[!] La maquina indicada no existe${endColour}\n"

  fi 
}

function searchIp(){
  ipAdress="$1"
  
  machineName="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ $machineName ]; then
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la IP${endColour}${greenColour} -->${endColour}${purpleColour} $ipAdress${endColour}${grayColour} es${endColour}${turquoiseColour} $machineName${endColour}\n"
  else
    echo -e "\n${redColour}[!] La IP proporcionada no coincide con ninguna maquina${endColour}"
  fi
} 

function searchLink(){
  machineLink="$1"

  youtubeLink="$(cat bundle.js | awk "/name: \"$machineLink\"/,/youtube/" | grep youtube | tr -d '"' | tr -d ',' | awk 'NF{print $NF}')"
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} El link para la maquina${endColour}${greenColour} -->${endColour}${purpleColour} $machineLink${endColour}${grayColour} es${endColour}${turquoiseColour} $youtubeLink${endColour}\n"

}

function getMachinesDifficulty(){
  difficulty="$1"
  
  echo -e "\n${greenColour}[+]${endColour}${grayColour} Recuerda que solo puedes filtrar por cuatro difficultades:${endColour}${greenColour} Facil${endColour}${yellowColour} Media${endColour}${redColour} Dificil${endColour}${purpleColour} Insane${endColour}"

  machine="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5| grep name | awk '$2{print $2}' | tr -d '"' | tr -d ',' | column)"

  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas son las maquinas de dificultad${endColour}${turquoiseColour} $difficulty${endColour}:\n\n${grayColour}$machine${endColour}"

}

function MachineOS(){
  os=$1
  
  echo -e "${greenColour}[+]${endColour}${grayColour} Recuerda que solo puedes filtrar por dos OS:${endColour}${redColour} Wi${endColour}${greenColour}nd${endColour}${blueColour}ow${endColour}${yellowColour}s${endColour}${purpleColour} Linux${endColour}\n"

  machineOs="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep name | awk '$2{print $2}' | tr -d '"' | tr -d ',' | column )"
  
  echo -e "${yellowColour}[+]${endColour}${grayColour} Estas son las maquinas con el OS${endColour}${turquoiseColour} $os${endColour}${grayColour}:\n\n$machineOs${endColour}"
}

function getSkill(){
  skill="$1"

  machineSkill="$(cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  echo -e "${yellowColour}[+]${endColour}${grayColour} Estas son las maquinas donde se toca la skill${endColour}${turquoiseColour} $skill${endColour}${grayColour}:\n\n$machineSkill${endColour}"

}

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}
trap ctrl_c INT
sleep 1


## INDICADORES
declare -i parameter_counter=0 

while getopts "m:ui:y:d:o:s:h" arg; do 
  case $arg in 
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAdress="$OPTARG"; let parameter_counter+=3;;
    y) machineLink="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; let parameter_counter+=5;;
    o) os="$OPTARG"; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done

## CONDICIONALES

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ];then
  searchIp $ipAdress
elif [ $parameter_counter -eq 4 ]; then
  searchLink $machineLink
elif [ $parameter_counter -eq 5 ]; then
 getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then 
  MachineOS $os
elif [ $parameter_counter -eq 7 ]; then 
  getSkill "$skill"
else
  helpPanel
fi  








