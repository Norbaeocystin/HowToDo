#!/bin/bash
requirements="libglib2.0-0 libnss3 libgconf-2-4 libfontconfig1 chromium-browser unzip"
function install()
{
 yes | apt-get install $1
}
apt-get update
for requirement in $requirements
do
  install "$requirement"
done
wget https://chromedriver.storage.googleapis.com/77.0.3865.40/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
mv -f ~/chromedriver /usr/local/bin/chromedriver
chown root:root /usr/local/bin/chromedriver
chmod 0755 /usr/local/bin/chromedriver
