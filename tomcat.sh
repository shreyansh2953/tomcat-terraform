#! /bin/bash

sudo apt-get update -y
sudo apt install default-jdk -y
sudo apt install net-tools -y
sudo mkdir /opt/tomcat
sudo curl -O https://downloads.apache.org/tomcat/tomcat-10/v10.0.14/bin/apache-tomcat-10.0.14.tar.gz
sudo tar -xzf apache-tomcat-10.0.14.tar.gz -C /opt/tomcat
sudo chown -R ubuntu:ubuntu /opt/tomcat/
