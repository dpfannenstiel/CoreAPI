#!/bin/bash -x

if ! grep "# VAGRANT" /lib/systemd/system/mongod.service; then

# https://www.howtoforge.com/tutorial/install-mongodb-on-ubuntu-16.04/
# Setup for Mongodb
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# Update apt-get
apt-get update

# Install Node
# https://github.com/nodesource/distributions#debinstall
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Mongodb
# https://www.howtoforge.com/tutorial/install-mongodb-on-ubuntu-16.04/
apt-get install -y mongodb-org

rm /lib/systemd/system/mongod.service
cat <<EOF >> /lib/systemd/system/mongod.service
# VAGRANT SETUP
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target

[Service]
User=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

[Install]
WantedBy=multi-user.target
EOF
systemctl start mongod
systemctl enable mongod
sed "s/--quiet/--quiet --auth/g" /lib/systemd/system/mongod.service
systemd daemon-reload
sudo service mongod restart
# import CSV file to seed database
# mongoimport -d <database> -c <table> --type csv --file /vagrant/<path to file>.csv --headerline
sudo service mongod restart

# set up npm global packages
npm install -g nodemon
npm install -g mocha@4.0.1

# install api components
cd /vagrant/api
npm install
else
  echo "mongod.service already setup"
fi

node --version
nodejs --version
npm --version

# setup nginx
# nginx
sudo apt-get -y install nginx
sudo service nginx start

# set up nginx server
sudo cp /vagrant/provision/sample.conf /etc/nginx/sites-available/site.conf
sudo chmod 644 /etc/nginx/sites-available/site.conf
sudo ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf
sudo service nginx restart

# clean /var/www
sudo rm -Rf /var/www

# symlink /var/www => /vagrant
ln -s /vagrant/web_app /var/www
