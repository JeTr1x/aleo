#!/bin/bash
echo -e "\033[1;36m"
echo " ::::::'##:'########:'########:'########::'####:'##::::'## ";
echo " :::::: ##: ##.....::... ##..:: ##.... ##:. ##::. ##::'## ";
echo " :::::: ##: ##:::::::::: ##:::: ##:::: ##:: ##:::. ##'## ";
echo " :::::: ##: ######:::::: ##:::: ########::: ##::::. ### ";
echo " '##::: ##: ##...::::::: ##:::: ##.. ##:::: ##:::: ## ## ";
echo "  ##::: ##: ##:::::::::: ##:::: ##::. ##::: ##::: ##:. ## ";
echo " . ######:: ########:::: ##:::: ##:::. ##:'####: ##:::. ## ";
echo " :......:::........:::::..:::::..:::::..::....::..:::::..::";
echo -e "\e[0m"



sleep 2


echo -e 'Installing dependencies...\n' && sleep 1
sudo apt update && sudo apt upgrade -y
apt install make clang pkg-config libssl-dev build-essential gcc xz-utils git curl vim tmux ntp jq llvm ufw -y < "/dev/null"
echo "=================================================="
echo -e 'Installing Rust (stable toolchain)...\n' && sleep 1
# curl https://sh.rustup.rs -sSf | sh -s -- -y
#source $HOME/.cargo/env
# rustup toolchain install nightly-2021-03-10-x86_64-unknown-linux-gnu
# toolchain=`rustup toolchain list | grep -m 1 nightly`
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
cargo clean
rustup default stable
rustup update stable --force
echo "=================================================="

#Downloading binaries
echo -e 'Cloning snarkOS...\n' && sleep 1
rm -rf $HOME/snarkOS
cd $HOME
git clone https://github.com/AleoHQ/snarkOS.git --depth 1
cd snarkOS
echo "=================================================="
echo -e 'Installing snarkos v2.0.2 ...\n' && sleep 1
#cargo install --path .
cargo build --release
rm -rf /usr/bin/snarkos
cp $HOME/snarkOS/target/release/snarkos /usr/bin

#create Service
echo -e 'Creating a service for Aleo Node...\n' && sleep 1
echo "[Unit]
Description=Aleo Client Node
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/snarkos --verbosity 2
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleod.service
 mv $HOME/aleod.service /etc/systemd/system
 tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

# Starting Services
systemctl restart systemd-journald
systemctl daemon-reload
echo -e 'Enabling Aleo Node services\n' && sleep 1
systemctl enable aleod
systemctl restart aleod

# Update Aleo
echo -e "Installing Aleo Updater\n"
cd $HOME
#wget -q -O $HOME/aleo_updater_WIP.sh https://raw.githubusercontent.com/elangrr/testnet_manuals/main/aleo/aleo_update_WIP.sh && chmod +x $HOME/aleo_updater_WIP.sh
echo "[Unit]
Description=Aleo Updater
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/snarkOS
ExecStart=/bin/bash $HOME/aleo_updater_WIP.sh
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
" > $HOME/aleo-updater.service
mv $HOME/aleo-updater.service /etc/systemd/system
systemctl daemon-reload
echo -e 'Enabling Aleo Updater services\n' && sleep 1
#systemctl enable aleo-updater
#systemctl restart aleo-updater

# Open ports on system
. $HOME/.bashrc
echo "=================================================="
echo " Attention - Please ensure ports 4130 and 4180"
echo "             are enabled on your local network."
echo ""
echo " Cloud Providers - Enable ports 4130 and 4180"
echo "                   in your network firewall"
echo ""
echo " Home Users - Enable port forwarding or NAT rules"
echo "              for 4130 and 4180 on your router."
echo "==
