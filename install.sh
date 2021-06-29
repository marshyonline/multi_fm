#DietPi setup script for RTL-SDR/Multimon-ng/Pagermon for decoding pager messages(FLEX/POCSAG etc.)

read -p 'Site Number: ' sitename

cat <<EOF >no-rtl.conf
blacklist dvb_usb_rtl28xxu
blacklist rtl2832
blacklist rtl2830
EOF

mv no-rtl.conf /etc/modprobe.d/

apt install -y git-core git wget curl cmake libusb-1.0-0-dev build-essential libpulse-dev libx11-dev librtlsdr-dev libjansson-dev

#requred for pyenv python 2.7 building
apt install -y make build-essential libssl1.0-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev 

cd ~

mkdir SDR
cd SDR/

git clone https://github.com/EliasOenal/multimon-ng.git
cd multimon-ng/
mkdir build
cd build/
cmake ..
make
make install

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.3/install.sh | bash

source ~/.bashrc

nvm install 8.9.3
nvm use 8.9.3
nvm alias default 8.9.3

npm install pm2 -g
export NODE_ENV=production

pm2 install pm2-logrotate
pm2 logrotate -u user

cd ~

#Python version management system
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

source ~/.bashrc

#rm -fr ~/.pyenv # removes pyenv

#locate openssl lib to prevent build errors
CFLAGS=-I/usr/include/openssl LDFLAGS=-L/usr/lib pyenv install -v 2.7.0

pyenv global 2.7.0

cd ~/SDR

git clone https://github.com/DanrwAU/eas-receiver.git
cd eas-receiver
npm install

mkdir /tmp/ckit
cd /tmp/ckit
git clone https://github.com/concurrencykit/ck.git
cd ck
./configure && make && sudo make install

cd ~/SDR
git clone https://github.com/pvachon/tsl.git
cd tsl
git checkout 73634bd4d07da43c93e394f66e298094ffc0a8b7
./waf configure && ./waf build install

cd ~/SDR
git clone https://github.com/pvachon/tsl-sdr.git
cd tsl-sdr
git checkout 3d2e3b18f627d544ca0972616c5038b23d0dce65
./waf configure && ./waf build

cd /usr/bin 
ln -s /root/SDR/tsl-sdr/build/release/bin/multifm multifm

sed -i "s/Site-X/Site-$hostnumber/g" "/root/SDR/eas-receiver/config/config-easch1.json"
sed -i "s/Site-X/Site-$hostnumber/g" "/root/SDR/eas-receiver/config/config-easch2.json"
sed -i "s/Site-X/Site-$hostnumber/g" "/root/SDR/eas-receiver/config/config-voda.json"
sed -i "s/Site-X/Site-$hostnumber/g" "/root/SDR/eas-receiver/reader.sh"

#pm2 start reader.sh
#pm2 save
#pm2 startup

exit 0
