#!/bin/sh
# Install ansible on VM to run playbook

echo "Installing Ansible via pip..."
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py

sudo apt-get update
sudo apt-get install python-dev

sudo pip install ansible

echo "Cleaning up apt..."
sudo apt-get clean
sudo apt-get autoclean

echo "Setting postgres password"
sudo su - postgres psql -c "ALTER USER postgres PASSWORD 'secretpassword';"

echo "Running Ansible Playbook"
ansible-playbook /vagrant/provisioning/playbook.yml --connection=local

echo "Creating uselessapp database"
sudo su - postgres psql -c "CREATE DATABASE uselessapp;"

echo "Installing PostGIS extension in uselessapp db"
sudo su - postgres psql -d uselessapp -c "CREATE EXTENSION postgis;"
sudo su - postgres psql -d uselessapp -c "CREATE EXTENSION postgis_topology;"
sudo su - postgres psql -d uselessapp -c "CREATE EXTENSION postgis_tiger_geocoder;"

echo "Loading GIS data in uselessapp db"
sudo su - postgres psql -d uselessapp -f /vagrant/gis-data/ne_10m_admin_0_countries/ne_10m_admin_0_countries.sql
sudo su - postgres psql -d uselessapp -f /vagrant/gis-data/ne_10m_admin_0_sovereignty/ne_10m_admin_0_sovereignty.sql

echo "Done!"
