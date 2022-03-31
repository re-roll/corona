#!/bin/sh

# Dmitrii Ivanushkin
# xivanu00

#----------------------Initializing of variables------------------------#

filename=()
k=0
n=0
cntLn=0
flags=0
opts=0
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
isA=0
isB=0
isS=0
isG=0

#----------------------Functions---------------------------------------#

helpF()
{
    echo ""
    echo "Usage: corona [-h] [FILTERS] [COMMAND] [LOG [LOG2 [...]]"
    echo ""
    echo "[COMMAND] může být jeden z:"
    echo "infected — spočítá počet nakažených."
    echo "merge — sloučí několik souborů se záznamy do jednoho, zachovávající původní pořadí (hlavička bude ve výstupu jen jednou)."
    echo "gender — vypíše počet nakažených pro jednotlivá pohlaví."
    echo "age — vypíše statistiku počtu nakažených osob dle věku (bližší popis je níže)."
    echo "daily — vypíše statistiku nakažených osob pro jednotlivé dny."
    echo "monthly — vypíše statistiku nakažených osob pro jednotlivé měsíce."
    echo "yearly — vypíše statistiku nakažených osob pro jednotlivé roky."
    echo "countries — vypíše statistiku nakažených osob pro jednotlivé země nákazy (bez ČR, tj. kódu CZ)."
    echo "districts — vypíše statistiku nakažených osob pro jednotlivé okresy."
    echo "regions — vypíše statistiku nakažených osob pro jednotlivé kraje."
    echo ""
    echo "[FILTERS] může být kombinace následujících (každý maximálně jednou):"
    echo "-a DATETIME — after: jsou uvažovány pouze záznamy PO tomto datu (včetně tohoto data). DATETIME je formátu YYYY-MM-DD."
    echo "-b DATETIME — before: jsou uvažovány pouze záznamy PŘED tímto datem (včetně tohoto data)."
    echo "-g GENDER — jsou uvažovány pouze záznamy nakažených osob daného pohlaví. GENDER může být M (muži) nebo Z (ženy)."
    echo "-s [WIDTH] u příkazů gender, age, daily, monthly, yearly, countries, districts a regions vypisuje data ne číselně," 
    echo "  ale graficky v podobě histogramů."
    echo "  Nepovinný parametr WIDTH nastavuje šířku histogramů, tedy délku nejdelšího řádku, na WIDTH." 
    echo "  Tedy, WIDTH musí být kladné celé číslo." 
    echo "  Pokud není parametr WIDTH uveden, řídí se šířky řádků požadavky uvedenými níže."
    echo "-h — vypíše nápovědu s krátkým popisem každého příkazu a přepínače."
    echo ""

    exit
}
#----------------------Get commands, filters and filename--------------#

while [ -n "$1" ]
do
    if [[ $1 == *.csv ]]
    then
        ((k=k+1))
        filename[k]=$1
    elif [[ $1 == *.gz ]]
    then
        gunzip $1
        ((k=k+1))
        filename[k]=${1:0:15}
    elif [[ $1 == *.bz2 ]]
    then
        ((k=k+1))
        filename[k]=${1:0:15}
        bzip2 -dk $1
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
    -a) flagA="$2";isA=1;((opts=opts+1));;
    -b) flagB="$2";isB=1;((opts=opts+1));;
    -g) flagG="$2";isG=1;((opts=opts+1));;
    -s) flagS="$2";isS=1;((opts=opts+1));;
    -h) helpF;;
    esac
    shift
done

#----------------------Work with filters--------------------------------#

# [-g]

if [[ $isG == 1 ]] && [[ $flagG == "M" ]]
then
        outG=$(awk -F, \
            '{
                if ($4 == "M") {
                    print
                }
            }\
            ' ${filename[1]})
elif [[ $isG == 1 ]] && [[ $flagG == "Z" ]]
then
    outG=$(awk -F, \
            '{
                if ($4 == "Z") {
                    print
                }
            }\
            ' ${filename[1]})
fi

# [-a]

if [[ $isA == 1 ]]
then
    filter1=$flagA
    outA=$(awk -F, -v f1="$filter1" \
            '{
                if ($2 >= f1) {
                    print
                }
            }\
        ' ${filename[1]})
fi

# [-b]

if [[ $isB == 1 ]]
then
    filter1=$flagB
    outB=$(awk -F, -v f1="$filter1" \
            '{
                if ($2 <= f1) {
                    print
                }
            }\
        ' ${filename[1]})
fi

#----------------------Work with file(s)--------------------------------#

if [[ $k == 0 ]] && [[ $opts == 0 ]] && [[ $flags == 0 ]]
then
    cat <&0
    exit
elif [[ $k == 1 ]] && [[ $opts == 0 ]] && [[ $flags == 0 ]]
then
    cat ${filename[1]}
    exit
fi
if [[ $k == 0 ]] && [[ $opts == 1 ]] && [[ $flags == 0 ]]
then
    if [[ $isG == 1 ]]
    then
    echo "$outG"
    elif [[ $isA == 1 ]]
    then
    echo "$outA"
    elif [[ $isB == 1 ]]
    then
    echo "$outB"
    fi
    exit
elif [[ $k == 1 ]] && [[ $opts == 1 ]] && [[ $flags == 0 ]]
then
    if [[ $isG == 1 ]]
    then
    echo "$outG"
    elif [[ $isA == 1 ]]
    then
    echo "$outA"
    elif [[ $isB == 1 ]]
    then
    echo "$outB"
    fi
    exit
fi

#----------------------Work with commands-------------------------------#

# [infected]

if [[ $isInfected == 1 ]] && [[ $isG == 1 ]]
then
    cntLn=($(wc -l <<< "${outG}"))
    echo $cntLn
elif [[ $isInfected == 1 ]] && [[ $isA == 1 ]]
then
    cntLn=($(wc -l <<< "${outA}"))
    ((cntLn=cntLn-1)) # 'after' means that the last string will be in the $outA and we don't need it
    echo $cntLn
elif [[ $isInfected == 1 ]] && [[ $isB == 1 ]]
then
    cntLn=($(wc -l <<< "${outB}"))
    echo $cntLn
fi

if [[ $isInfected == 1 ]] && [[ $k == 0 ]] && [[ $opts == 0 ]]
then
    cntLn=$(wc -l)
    ((cntLn=cntLn-1))
    echo $cntLn
elif [[ $isInfected == 1 ]] && [[ $k == 1 ]] && [[ $opts == 0 ]]
then
    cntLn=($(wc -l ${filename[1]}))
    ((cntLn=cntLn-1))
    echo $cntLn
fi

# [gender]

filter1="M"
filter2="Z"

if [[ $isGender == 1 ]] && [[ $isG == 1 ]]
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
        ' <<< $outG)
    echo "$out"
elif [[ $isGender == 1 ]] && [[ $isA == 1 ]]
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
        ' <<< $outA)
    echo "$out"
elif [[ $isGender == 1 ]] && [[ $isB == 1 ]]
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
        ' <<< $outB)
    echo "$out"
elif [[ $isGender == 1 ]] && [[ $opts == 0 ]]
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

if [[ $isAge == 1 ]] && [[ $opts == 0 ]]
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
            else if (($3 > 105) && (!($3 == "vek"))){
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
elif [[ $isAge == 1 ]] && [[ $isA == 1 ]]
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
            else if (($3 > 105) && (!($3 == "vek"))) {
                count12++
                print
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
        ' <<< $outA)
    echo "$out"
elif [[ $isAge == 1 ]] && [[ $isB == 1 ]]
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
            else if (($3 > 105) && (!($3 == "vek"))) {
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
        ' <<< $outB)
    echo "$out"
elif [[ $isAge == 1 ]] && [[ $isG == 1 ]]
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
            else if (($3 > 105) && (!($3 == "vek"))) {
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
        ' <<< $outG)
    echo "$out"
fi

# [daily]
    
if [[ $isDaily == 1 ]] && [[ $k == 1 ]] && [[ $opts == 0 ]]
then
    out=$(awk -F, '{ if ($2 != "datum") {A[$2]++}}END{for(i in A)print i":",A[i]}' ${filename[1]} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isDaily == 1 ]] && [[ $k == 1 ]] && [[ $isA == 1 ]]
then
    out=$(awk -F, '{ if ($2 != "datum") {A[$2]++}}END{for(i in A)print i":",A[i]}' <<< ${outA} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isDaily == 1 ]] && [[ $k == 1 ]] && [[ $isB == 1 ]]
then
    out=$(awk -F, '{ if ($2 != "datum") {A[$2]++}}END{for(i in A)print i":",A[i]}' <<< ${outB} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isDaily == 1 ]] && [[ $k == 1 ]] && [[ $isG == 1 ]]
then
    out=$(awk -F, '{ if ($2 != "datum") {A[$2]++}}END{for(i in A)print i":",A[i]}' <<< ${outG} | sort -t, -k2,2rn)
    echo "$out"
fi

# [monthly]



# [yearly]

if [[ $isYearly == 1 ]] && [[ $opts == 0 ]]
then
    out=$(awk -F, \
            '{
                if (($2 >= "2020-01-01")  && ($2 <= "2020-12-31")) {
                    count0++
                    is0=1
                }
                if (($2 >= "2021-01-01")  && ($2 <= "2021-12-31")) {
                    count1++
                    is1=1
                }
                if (($2 >= "2022-01-01")  && ($2 <= "2022-12-31")) {
                    count2++
                    is2=1
                }
            }\
            END {if (is0 == 1) {print "2020:" count0}} \
            END {if (is1 == 1) {print "2021:" count1}} \
            END {if (is2 == 1) {print "2022:" count2}}' ${filename[1]})
    echo "$out"
elif [[ $isYearly == 1 ]] && [[ $isA == 1 ]]
then
    out=$(awk -F, \
            '{
                if (($2 >= "2020-01-01")  && ($2 <= "2020-12-31")) {
                    count0++
                    is0=1
                }
                if (($2 >= "2021-01-01")  && ($2 <= "2021-12-31")) {
                    count1++
                    is1=1
                }
                if (($2 >= "2022-01-01")  && ($2 <= "2022-12-31")) {
                    count2++
                    is2=1
                }
            }\
            END {if (is0 == 1) {print "2020:" count0}} \
            END {if (is1 == 1) {print "2021:" count1}} \
            END {if (is2 == 1) {print "2022:" count2}}' <<< $outA)
    echo "$out"
elif [[ $isYearly == 1 ]] && [[ $isB == 1 ]]
then
    out=$(awk -F, \
            '{
                if (($2 >= "2020-01-01")  && ($2 <= "2020-12-31")) {
                    count0++
                    is0=1
                }
                if (($2 >= "2021-01-01")  && ($2 <= "2021-12-31")) {
                    count1++
                    is1=1
                }
                if (($2 >= "2022-01-01")  && ($2 <= "2022-12-31")) {
                    count2++
                    is2=1
                }
            }\
            END {if (is0 == 1) {print "2020:" count0}} \
            END {if (is1 == 1) {print "2021:" count1}} \
            END {if (is2 == 1) {print "2022:" count2}}' <<< $outB)
    echo "$out"
elif [[ $isYearly == 1 ]] && [[ $isG == 1 ]]
then
    out=$(awk -F, \
            '{
                if (($2 >= "2020-01-01")  && ($2 <= "2020-12-31")) {
                    count0++
                    is0=1
                }
                if (($2 >= "2021-01-01")  && ($2 <= "2021-12-31")) {
                    count1++
                    is1=1
                }
                if (($2 >= "2022-01-01")  && ($2 <= "2022-12-31")) {
                    count2++
                    is2=1
                }
            }\
            END {if (is0 == 1) {print "2020:" count0}} \
            END {if (is1 == 1) {print "2021:" count1}} \
            END {if (is2 == 1) {print "2022:" count2}}' <<< $outG)
    echo "$out"
fi

# [countries]

if [[ $isCountries == 1 ]] && [[ $opts == 0 ]]
then
    out=$(awk -F, '{ if (($8 != "") && ($8 != "CZ") && ($8 != "nakaza_zeme_csu_kod")) {A[$8]++}}END{for(i in A)print i":",A[i]}' ${filename[1]} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isCountries == 1 ]] && [[ $isA == 1 ]]
then
    out=$(awk -F, '{ if (($8 != "") && ($8 != "CZ") && ($8 != "nakaza_zeme_csu_kod")) {A[$8]++}}END{for(i in A)print i":",A[i]}' <<< ${outA} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isCountries == 1 ]] && [[ $isB == 1 ]]
then
    out=$(awk -F, '{ if (($8 != "") && ($8 != "CZ") && ($8 != "nakaza_zeme_csu_kod")) {A[$8]++}}END{for(i in A)print i":",A[i]}' <<< ${outB} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isCountries == 1 ]] && [[ $isG == 1 ]]
then
    out=$(awk -F, '{ if (($8 != "") && ($8 != "CZ") && ($8 != "nakaza_zeme_csu_kod")) {A[$8]++}}END{for(i in A)print i":",A[i]}' <<< ${outG} | sort -t, -k2,2rn)
    echo "$out"
fi

# [districts]

if [[ $isDistricts == 1 ]] && [[ $opts == 0 ]]
then
    out=$(awk -F, '{ if (($5 != "kraj_nuts_kod") && ($5 != "")) {A[$5]++}}END{for(i in A)print i":",A[i]}' ${filename[1]} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isDistricts == 1 ]] && [[ $isA == 1 ]]
then
    out=$(awk -F, '{ if (($5 != "kraj_nuts_kod") && ($5 != "")) {A[$5]++}}END{for(i in A)print i":",A[i]}' <<< ${outA} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isDistricts == 1 ]] && [[ $isB == 1 ]]
then
    out=$(awk -F, '{ if (($5 != "kraj_nuts_kod") && ($5 != "")) {A[$5]++}}END{for(i in A)print i":",A[i]}' <<< ${outB} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isDistricts == 1 ]] && [[ $isG == 1 ]]
then
    out=$(awk -F, '{ if (($5 != "kraj_nuts_kod") && ($5 != "")) {A[$5]++}}END{for(i in A)print i":",A[i]}' <<< ${outG} | sort -t, -k2,2rn)
    echo "$out"
fi

# [regions]

if [[ $isRegions == 1 ]] && [[ $opts == 0 ]]
then
    out=$(awk -F, '{ if (($6 != "okres_lau_kod") && ($6 != "")) {A[$6]++}}END{for(i in A)print i":",A[i]}' ${filename[1]} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isRegions == 1 ]] && [[ $isA == 1 ]]
then
    out=$(awk -F, '{ if (($6 != "okres_lau_kod") && ($6 != "")) {A[$6]++}}END{for(i in A)print i":",A[i]}' <<< ${outA} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isRegions == 1 ]] && [[ $isB == 1 ]]
then
    out=$(awk -F, '{ if (($6 != "okres_lau_kod") && ($6 != "")) {A[$6]++}}END{for(i in A)print i":",A[i]}' <<< ${outB} | sort -t, -k2,2rn)
    echo "$out"
elif [[ $isRegions == 1 ]] && [[ $isG == 1 ]]
then
    out=$(awk -F, '{ if (($6 != "okres_lau_kod") && ($6 != "")) {A[$6]++}}END{for(i in A)print i":",A[i]}' <<< ${outG} | sort -t, -k2,2rn)
    echo "$out"
fi
