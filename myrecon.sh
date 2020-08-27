#!/bin/bash

#bash script to automate recon with populor available tools
#install and place assetfinder,ffuf, gau, httprobe,subfinder in /bin folder
#set path varaible to desired path
#files are saved to assigned path go through files after recon is done!

echo "    / \  _   _| |_ ___    |  _ \ ___  ___ ___  _ __"
echo "   / _ \| | | | __/ _ \   | |_) / _ \/ __/ _ \| '_ \ "
echo "  / ___ \ |_| | || (_) |  |  _ <  __/ (_| (_) | | | |"
echo " /_/   \_\__,_|\__\___/___|_| \_\___|\___\___/|_| |_|"
echo "                     |_____|                         "


echo " 						auto recon script by Rasi Aeef"



tput bold

printf "\n\n\n"
echo " ENTER THE DOMAIN TO RECON"
read domain
mkdir /home/sniper/Desktop/domain/$domain
mypath=/home/sniper/Desktop/domain/$domain

printf "\n enumerating subdomains\n\n"

	assetfinder --subs-only $domain > $mypath/$domain.txt
	subfinder -d $domain --silent >> $mypath/$domain.txt

sort -u $mypath/$domain.txt > $mypath/subdomains.txt
rm $mypath/$domain.txt

printf "\n subdomain enumeration done and files are saved!! \n\n"

printf "\n extracting endpoints from js \n\n"

	cat $mypath/subdomains.txt | waybackurls | grep -i ".*\.js$" > $mypath/jsfiles.txt
	cat $mypath/subdomains.txt | gau | grep -i  ".*\.js$" >> $mypath/jsfiles.txt
	sort -u $mypath/jsfiles.txt > $mypath/jsurls.txt
	rm $mypath/jsfiles.txt
	mkdir $mypath/jsfiles

	for url in $(cat $mypath/jsurls.txt);do
	wget -q  $url -P $mypath/jsfiles
done

	for file in $mypath/jsfiles/*; do
	cat $file | grep -aoP "(?<=(\"|\'|\`))\/[a-zA-Z0-9_?&=\/\-\#\.]*(?=(\"|\'|\`))"  >> $mypath/paths.txt
	done
cat $mypath/paths.txt | sort -u > $mypath/endpoints.txt
rm $mypath/paths.txt
printf "\n paths are extracted and saved! \n\n"

printf "\n doing favicon hash enumeration\n\n"

	cat $mypath/subdomains.txt | httprobe  | sort -u > $mypath/httprobed.txt

	cat $mypath/httprobed.txt | favfreak.py > $mypath/hashanalysis.txt

echo "hash enumeration done"

rm $mypath/httprobed.txt
rm -r $mypath/jsfiles

printf "\n running nuclei\n\n\n"

nuclei -t /home/sniper/Desktop/tools/nuclei-templates/all -l $mypath/subdomains.txt -silent

printf "\n nuclei done \n\n"

printf  "\n doing nmap\n\n"

nmap -iL $mypath/subdomains.txt >> $mypath/nmap

echo "nmap done"

printf "\n\n"

read -p "DO YOU WAN TO RUN FFUF ON DISCOVERED ENDPOINTS? " -n 1 -r
echo    # (optional) move to a new line	
if [[ $REPLY =~ ^[Yy]$ ]]
then
    ffuf -w $mypath/endpoints.txt -u https://$domain/FUZZ -mc 200
fi
