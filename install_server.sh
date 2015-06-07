#!/bin/sh

#
# Libbitcoin Server Install
#

userdir=`pwd`
username=`whoami`
mkdir ~/libbitcoin
#sudo apt-get update
#sudo apt-get install tmux

cd ~/libbitcoin
wget https://github.com/libbitcoin/libbitcoin-server/releases/download/v2.0.0/bs-linux-x64-mainnet
wget https://github.com/libbitcoin/libbitcoin-explorer/releases/download/v2.1.0/bx-linux-x64-mainnet
mv bs-linux-x64-mainnet bs
mv bx-linux-x64-mainnet bx
chmod 755 bs
chmod 755 bx

echo "
# Libbitcoin Server configuration file.
[general]
# The blockchain directory, defaults to 'blockchain'.
blockchain_path = blockchain
# The minimum height of the history database, defaults to 0.
history_height = 0
# The peer cache file path, defaults to 'hosts'.
hosts_file = hosts
# Enable the listening for incoming connections, defaults to true.
listener_enabled = true
# The maximum number of outgoing P2P network connections, defaults to 8.
out_connections = 32
# Enable the publisher, defaults to false.
publisher_enabled = false
# The maximum number of transactions in the pool, defaults to 2000.
tx_pool_capacity = 2000

[logging]
# The debug log file path, defaults to 'debug.log'.
debug_file = debug.log
# The error log file path, defaults to 'error.log'.
error_file = error.log
# Write service requests to the log, impacts performance, defaults to false.
log_requests = false

[endpoints]
# The query service endpoint, defaults to 'tcp://*:9091'.
service = tcp://*:9091
# The heartbeat endpoint, defaults to 'tcp://*:9092'.
heartbeat = tcp://*:9092
# The block publishing service endpoint, defaults to 'tcp://*:9093'.
block_publish = tcp://*:9093
# The transaction publishing service endpoint, defaults to 'tcp://*:9094'.
tx_publish = tcp://*:9094

[identity]
# The path to the ZPL-encoded server private certificate file.
cert_file = ${userdir}/libbitcoin/server.cert
# The directory for ZPL-encoded client public certificate files, allows anonymous clients if not set.
# client_certs_path =
# Allowed client IP address, all clients allowed if none set, multiple entries allowed.
# client = 127.0.0.1
# client =
# Node to augment peer discovery, formatted as host:port, multiple entries allowed.
# peer = obelisk.airbitz.co:8333
# peer =
# The server name, must be unique if specified.
# unique_name = " > bs.cfg

./bx cert-new server.cert

#
# Setup script to restart BS
#
echo "
#!/bin/bash
cd ${userdir}/libbitcoin
touch keep-going
while [ -f keep-going ];
do ./bs ${userdir}/libbitcoin/bs.cfg > ${userdir}/libbitcoin/console.log 2>&1;
sleep 30; done" > loopbs

chmod 755 loopbs

#
# Download part of blockchain from Airbitz backup
#
echo "

***********************************************************
Pulling blockchain from Airbitz backup. May take 2-24 hours
***********************************************************

Enter the following password when prompted: abRsDa1029384756\n\n"

rsync blocks@bitcoin-rs-dallas.airbitz.co:blockchain.bak/ ~/libbitcoin/blockchain --progress --partial -avz


#
# Start the libbitcoin server!
#
echo "
*************************************************
*************************************************
Type the following to start the libbitcoin server

    ~/libbitcoin/loopbs &

Then

    tail -f ~/libbitcoin/console.log

to see it's progress.

To kill server
    rm -rf ~/libbitcoin/keep-going
    killall bs
"
