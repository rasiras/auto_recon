#!/bin/bash

go get github.com/ffuf/ffuf
go get -u github.com/tomnomnom/assetfinder
GO111MODULE=auto go get -u -v github.com/projectdiscovery/subfinder/cmd/subfinder
go get github.com/tomnomnom/waybackurls
GO111MODULE=on go get -u -v github.com/lc/gau
GO111MODULE=on go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei


cd /root/go/bin
cp ffuf assetfinder subfinder waybackurls gau nuclei /usr/bin

git clone https://github.com/projectdiscovery/nuclei-templates
