#!/bin/bash

set -e

# Configure yum to skip unavailable repositories
yum-config-manager --save --setopt=epel.skip_if_unavailable=true
yum-config-manager --save --setopt=rhel-server-rhscl-7-rpms.skip_if_unavailable=true

# Update yum cache
yum makecache -y

# Install required dependencies
yum install -y perl-core zlib-devel

# Download and install OpenSSL
wget https://www.openssl.org/source/openssl-1.1.1t.tar.gz
tar -xf openssl-1.1.1t.tar.gz
cd openssl-1.1.1t
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
make
make install
ldconfig
ln -sf /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -sf /usr/local/ssl/include/openssl /usr/include/openssl
cd ..

# Install Python and development tools
yum install -y centos-release-scl
yum-config-manager --enable rhel-server-rhscl-7-rpms
yum install -y llvm-toolset-7.0 python3 python3-devel

# Upgrade Python packages
python3 -m pip install --upgrade pip
python3 -m pip install --force-reinstall urllib3 requests
python3 -m pip install setuptools wheel twine auditwheel

# Build and publish the package
python3 -m pip wheel . -w dist/ --no-deps
twine upload --verbose --skip-existing dist/*
