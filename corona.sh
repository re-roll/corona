#!/bin/sh

#----------------------Initializing of variables----------------------

isFilename=0
filename=()
k=0
flagA=0
flagB=0
flagS=0
flagG=0

#----------------------Help function----------------------

helpF()
{
    echo "Usage: corona [-h] [FILTERS] [COMMAND] [LOG [LOG2 [...]]"
    exit 1
}

#----------------------Get arguments after filters----------------------

while getopts "a:b:g:s:h" flag
do
   case "$flag" in
      a ) flagA="$OPTARG" ;;
      b ) flagB="$OPTARG" ;;
      g ) flagG="$OPTARG" ;;
      s ) flagS="$OPTARG" ;;
      h ) helpF;;
   esac
done

#----------------------Get commands and filename----------------------

while [ -n "$1" ]
do
    if [[ $1 == *.csv ]]; 
    then
        ((k=k+1))
        filename[k]=$1
        isFilename=1
    fi
    case "$1" in
    infected) isInfected=1;;
    merge) isMerge=1;;
    gender) isGender=1;;
    age) isAge=1;;
    daily) isDaily=1;;
    monthly) isMonthly=1;;
    yearly) isYearly=1;;
    countries) isCountries=1;;
    districts) isDistricts=1;;
    regions) isRegions=1;;
    esac
    shift
done

# Delete it later

if [[ $isFilename == 1 ]]
then
    echo "${filename[@]}"
fi
