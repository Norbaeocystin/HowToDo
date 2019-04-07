#!/bin/bash
function install()
{
 apt-get install $1
}
apt-get update
install "chromium-browser"
