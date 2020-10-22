#!/bin/bash
echo "Patching du proxy pour APT"
source config.cfg
echo "APT::Get::AllowUnauthenticated 1;
Acquire::http::proxy \"http://$scribeuseraptdom:$scribepass@$proxy_def_ip:$proxy_def_port/\";
Acquire::ftp::proxy \"ftp://$scribeuseraptdom:$scribepass@$proxy_def_ip:$proxy_def_port/\";
Acquire::https::proxy \"https://$scribeuseraptdom:$scribepass@$proxy_def_ip:$proxy_def_port/\";" > /etc/apt/apt.conf.d/20proxy
