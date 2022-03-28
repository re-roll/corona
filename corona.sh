#!/bin/sh

#----------------------Initializing of variables------------------------#

filename=()
k=0
flags=0
flagA=0
flagB=0
flagS=0
flagG=0
isInfected=0
isMerge=0
isGender=0
isAge=0
isDaily=0
isMonthly=0
isYearly=0
isCountries=0
isDistricts=0
isRegions=0

#----------------------Help function------------------------------------#

helpF()
{
    echo "Usage: corona [-h] [FILTERS] [COMMAND] [LOG [LOG2 [...]]"
    exit
}

#----------------------Get arguments after filters----------------------#

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

#----------------------Get commands and filename------------------------#

while [ -n "$1" ]
do
    if [[ $1 == *.csv* ]]
    then
        ((k=k+1))
        filename[k]=$1
    fi
    case "$1" in
    infected) isInfected=1;((flags=flags+1));;
    merge) isMerge=1;((flags=flags+1));;
    gender) isGender=1;((flags=flags+1));;
    age) isAge=1;((flags=flags+1));;
    daily) isDaily=1;((flags=flags+1));;
    monthly) isMonthly=1;((flags=flags+1));;
    yearly) isYearly=1;((flags=flags+1));;
    countries) isCountries=1;((flags=flags+1));;
    districts) isDistricts=1;((flags=flags+1));;
    regions) isRegions=1;((flags=flags+1));;
    esac
    shift
done

#----------------------Work with file(s)--------------------------------#

if [[ $k == 0 ]] && [[ $flags == 0 ]]
then
    cat 
elif [[ $k == 1 ]] && [[ $flags == 0 ]]
then
    cat ${filename[1]}
fi      

#----------------------Work with commands-------------------------------#

# [infected]

cntLn=0

if [[ $isInfected == 1 ]] && [[ $k == 1 ]]
then
    cntLn=($(wc -l ${filename[1]}))
    ((cntLn=cntLn-1))
    echo $cntLn
elif [[ $isInfected == 1 ]] && [[ $k == 0 ]]
then
    cntLn=$(wc -l)
    ((cntLn=cntLn-1))
    echo $cntLn
fi

# [gender]

filter1="M"
filter2="Z"

if [[ $isGender == 1 ]]
then
    out=$(awk -F, -v f1="$filter1" -v f2="$filter2"  \
        'BEGIN { count=0 } \
        BEGIN { countm=0 } \
        BEGIN { countz=0 } \
        {
            if ($4 == f1) {
                countm++
            }
            if ($4 == f2) {
                countz++
            }
            if ($3 == ""){
                count++
            }
        }\

        END { print "M:", countm} \
        END { print "Z:", countz} \
        END { if (count > 0) {print "None:", count}} \
        ' ${filename[1]})
    echo "$out"
fi

# [merge]

n=0

if [[ $k > 1 ]] && [[ $isMerge == 1 ]]
then
    while [ $n -le $k ]
    do
        cat ${filename[1]} <(tail +2 ${filename[n]})
        ((n=n+1))
    done < ${filename[1]}
elif [[ $k -le 1 ]] && [[ $isMerge == 1 ]]
then
    echo "WARNING: There is nothing to merge"
    exit 2
fi  

# [age]

if [[ $isAge == 1 ]]
then
    out=$(awk -F, \
        'BEGIN { count=0 } \
        BEGIN { count1=0 } \
        BEGIN { count2=0 } \
        BEGIN { count3=0 } \
        BEGIN { count4=0 } \
        BEGIN { count5=0 } \
        BEGIN { count6=0 } \
        BEGIN { count7=0 } \
        BEGIN { count8=0 } \
        BEGIN { count9=0 } \
        BEGIN { count10=0 } \
        BEGIN { count11=0 } \
        BEGIN { count12=0 } \
        {
            if (($3 >= 0) && ($3 <= 5)) {
                count1++
            }
            else if (($3 >= 6) && ($3 <= 15)) {
                count2++
            }
            else if (($3 >= 16) && ($3 <= 25)) {
                count3++
            }
            else if (($3 >= 26) && ($3 <= 35)) {
                count4++
            }
            else if (($3 >= 36) && ($3 <= 45)) {
                count5++
            }
            else if (($3 >= 46) && ($3 <= 55)) {
                count6++
            }
            else if (($3 >= 56) && ($3 <= 65)) {
                count7++
            }
            else if (($3 >= 66) && ($3 <= 75)) {
                count8++
            }
            else if (($3 >= 76) && ($3 <= 85)) {
                count9++
            }
            else if (($3 >= 86) && ($3 <= 95)) {
                count10++
            }
            else if (($3 >= 96) && ($3 <= 105)) {
                count11++
            }
            else if ($3 > 105) {
                count12++
            }
            if ($3 == ""){
                count++
            }
            else if ( ((!($3 ~ /^[0-9]+$/)) && (!($3 == "vek"))) || ($3 < 0) ){
                print "Invalid age: "
                print
            }
        } \
        END { print "0-5   :", count1} \
        END { print "6-15  :", count2} \
        END { print "16-25 :", count3} \
        END { print "26-35 :", count4} \
        END { print "36-45 :", count5} \
        END { print "46-55 :", count6} \
        END { print "56-65 :", count7} \
        END { print "66-75 :", count8} \
        END { print "76-85 :", count9} \
        END { print "86-95 :", count10} \
        END { print "96-105:", count11} \
        END { print ">105  :", count12} \
        END { if (count > 0) {print "None  :", count}} \
        ' ${filename[1]})
    echo "$out"
fi

# [daily]
    
if [[ $isDaily == 1 ]]
then
        lastday=0
    cnt=0
    while IFS="," read -r a b c
    do
        year=${b:0:4}
        month=${b:5:2}
        day=${b:8:2}
        if [[ $day != $lastday ]]
        then
            datum=("$year-$month-$day")
            out=$(awk -F, -v f1="$datum"\
            '{
                if ($2 == f1) {
                    count++
                }
            }\
            END {print count}' ${filename[1]})
            echo "$year-$month-$day: $out"
        fi
        lastday=$day
    done < <(tail -n +2 ${filename[1]})
fi
