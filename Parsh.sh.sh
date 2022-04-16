#!/bin/bash

# Modificiado: Bl4dsc4n

echo "dominio"
read dominio
mkdir $dominio
cd $dominio

wget -q -c $dominio -O $dominio

# Filtrando links
#echo "Quebranco as linhas para melhorar a seleÃ§Ã£o dos links, onde se encontram as palavras 'href' e 'action'."
sed -i "s/ /\n/g" $dominio
grep -E "(href=|action=|src=|srcset=)" $dominio > .tmp1-$dominio

#echo "Capturando o conteudo entre aspas e apostrofos."
grep -oh '"[^"]*"' .tmp1-$dominio > .tmp2-$dominio
grep -oh "'[^']*'" .tmp1-$dominio >> .tmp2-$dominio

#echo "Removendo as aspas e apostrofos."
sed -i 's/"//g' .tmp2-$dominio
sed -i "s/'//g" .tmp2-$dominio
cat .tmp2-$dominio | sort -u > achados


for h in $(cat achados | grep -v "http" | sort -u);
do
    a=$(echo $h | cut -c 1,2)
    b=$(echo $h | wc -m)
    if [[ $a =~ // ]]; then
       c=$(echo $h | cut -d"/" -f 2-$b)  >> links
       echo $dominio$c | cut -d " " -f 1
    elif [[ $a =~ /.* ]]; then
       echo $dominio$h | cut -d " " -f 1 >> links
    else
       echo $dominio/$h | cut -d " " -f 1 >> links
    fi
done

echo -e e "\e[1;32mLinks externos\e[0m"
cat achados | grep -Ei "http|https" | grep -v $dominio | sort -u | tee -a links-ext-$dominio

echo -e "\e[1;32mSomente links do dominio\e[0m"
cat achados | grep $dominio > links1
cat links >> links1
cat links1 | sort -u | tee -a links-dominio
