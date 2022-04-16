#!/bin/bash
# Parsh web : Livre uso e modificação
# Creditos: Bl4dSc4n
# modo de uso: bash parsh.sh www.vulnweb.com

if [[ $1 == "" ]]; then
    echo "modo de uso: bash parsh.sh www.vulnweb.com"
    exit
else
    #dominio=$1
    mkdir $1
    cd $1
    wget -q -c $1 -O $1
    sed -i "s/ /\n/g" $1
    cat $1 | grep -E "(href=|action=|src=)" | grep -oh '"[^"]*"' | awk -F \" '{print $2}' | sort -u > .tmp-$1
    cat $1 | grep -E "(href=|action=|src=)" | grep -oh "'[^']*'" | awk -F "'" '{print $2}' | sort -u >> .tmp-$1
    cat .tmp-$1 | sort -u > achados

    for h in $(cat achados | grep -v "http" | sort -u);
    do
        a=$(echo $h | cut -c 1,2)
        b=$(echo $h | wc -m)
        if [[ $a =~ // ]]; then
           c=$(echo $h | cut -d"/" -f 2-$b)  >> links
           echo $1$c | cut -d " " -f 1
        elif [[ $a =~ /.* ]]; then
           echo $1$h | cut -d " " -f 1 >> links
        else
           echo $1/$h | cut -d " " -f 1 >> links
        fi
    done

    echo -e e "\e[1;32mLinks externos\e[0m"
    cat achados | grep -Ei "http|https" | grep -v $1 | sort -u | tee -a links-ext-$1

    echo -e "\e[1;32mSomente links do dominio\e[0m"
    cat achados | grep $1 > links1
    cat links >> links1
    cat links1 | sort -u | tee -a links-dominio
fi
