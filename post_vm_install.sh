#!/bin/sh
# Install ansible on VM to run playbook

echo "Installing Ansible via pip..."
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py

sudo apt-get update
sudo apt-get install -y python-dev

sudo pip install ansible

echo "Cleaning up apt..."
sudo apt-get clean
sudo apt-get autoclean

echo "Running Ansible Playbook"
ansible-playbook /vagrant/provisioning/playbook.yml -i /vagrant/provisioning/hosts-vagrant --connection=local

echo "Setting postgres password"
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'secretpassword';"

echo "Creating uselessapp database"
sudo -u postgres psql -c "CREATE DATABASE uselessapp;"

echo "Installing PostGIS extension in uselessapp db"
sudo -u postgres psql -d uselessapp -c "CREATE EXTENSION postgis;"
sudo -u postgres psql -d uselessapp -c "CREATE EXTENSION postgis_topology;"
sudo -u postgres psql -d uselessapp -c "CREATE EXTENSION postgis_tiger_geocoder;"

echo "Loading GIS data in uselessapp db"
#sudo -u postgres psql -d uselessapp -f /vagrant/gis-data/ne_10m_admin_0_countries/ne_10m_admin_0_countries.sql
#sudo -u postgres psql -d uselessapp -f /vagrant/gis-data/ne_10m_admin_0_sovereignty/ne_10m_admin_0_sovereignty.sql
sudo -u postgres shp2pgsql -I -s 2249 /vagrant/gis-data/ne_10m_admin_0_countries/ne_10m_admin_0_countries.shp public.geo_countries | sudo -u postgres psql -d uselessapp 
sudo -u postgres shp2pgsql -I -s 2249 /vagrant/gis-data/ne_10m_admin_0_sovereignty/ne_10m_admin_0_sovereignty.shp public.geo_sovereignty | sudo -u postgres psql -d uselessapp 

echo "Done!"
