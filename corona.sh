#!/bin/sh

isFilename=0
commands=()
flagA=0
flagB=0
flagS=0
flagG=0

helpF()
{
    echo "Usage: corona [-h] [FILTERS] [COMMAND] [LOG [LOG2 [...]]"
    exit 1
}

while getopts ":a:b:g:s:h" flag
do
   case "$flag" in
      a ) flagA="$OPTARG" ;;
      b ) flagB="$OPTARG" ;;
      g ) flagG="$OPTARG" ;;
      s ) flagS="$OPTARG" ;;
      h ) helpF
         exit 0;;
   esac
done

while [ ! -z $1 ]
do
    if [[ $1 == *.txt ]]; 
    then
        filename=$1
        isFilename=1
    elif [[ $1 != -* ]] && [[ $1 != -h ]] && [[ $1 != $flagA ]] && [[ $1 != $flagB ]] && [[ $1 != $flagG ]] && [[ $1 != $flagS ]];
    then
        ((k=k+1))
        commands[k]=$1
    fi
    shift
done

if [[ $isFilename == 1 ]]; then
    echo "Filename is: $filename"
fi

echo "Commands are: ${commands[@]}"
echo "Flag -a is $flagA"
echo "Flag -b is $flagB"
echo "Flag -s is $flagS"
echo "Flag -g is $flagG"