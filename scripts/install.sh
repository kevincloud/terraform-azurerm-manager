#!/bin/bash

apt-get update -y
apt-get install -y nginx python3 python3-pip

service nginx start

pip3 install awscli
