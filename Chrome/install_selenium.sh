#!/bin/bash
requirements = "libglib2.0-0 libnss3 libgconf-2-4 libfontconfig1 chromium-browser unzip"
function install()
{
 apt-get install $1
}
apt-get update
for requirement in $requirements
do
  install "$requirement"
done
