#!/bin/bash

apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    apt-transport-https \
    lsb-release \
    gnupg \
    python3 \
    python3-pip

curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list

apt-get update -y
apt-get install -y azure-cli

export ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID}
export ARM_TENANT_ID=${ARM_TENANT_ID}
export ARM_CLIENT_ID=${ARM_CLIENT_ID}
export ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET}

echo "export ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID}" >> /etc/profile
echo "export ARM_TENANT_ID=${ARM_TENANT_ID}" >> /etc/profile
echo "export ARM_CLIENT_ID=${ARM_CLIENT_ID}" >> /etc/profile
echo "export ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET}" >> /etc/profile

echo "ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID}" >> /etc/environment
echo "ARM_TENANT_ID=${ARM_TENANT_ID}" >> /etc/environment
echo "ARM_CLIENT_ID=${ARM_CLIENT_ID}" >> /etc/environment
echo "ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET}" >> /etc/environment

echo "az login --service-principal -u ${ARM_CLIENT_ID} -p ${ARM_CLIENT_SECRET} --tenant ${ARM_TENANT_ID}" > /usr/local/bin/azlogin.sh
chmod +x /usr/local/bin/azlogin.sh

cd /root
git clone https://github.com/kevincloud/sentinel-data-api.git

pip3 install -r /root/sentinel-data-api/requirements.txt

mkdir -p /opt/data-api
cp /root/sentinel-data-api/api.py /opt/data-api/
mkdir -p /opt/web-app
cp /root/sentinel-data-api/app.py /opt/web-app/
cp -R /root/sentinel-data-api/templates /opt/web-app/

sudo bash -c "cat >>/opt/data-api/app.ini" <<EOT
[App]
Identifier=${IDENTIFIER}
AccountKey=${ACCOUNT_KEY}
EOT

sudo bash -c "cat >>/opt/web-app/app.ini" <<EOT
[App]
Identifier=${IDENTIFIER}
AccountKey=${ACCOUNT_KEY}
EOT
