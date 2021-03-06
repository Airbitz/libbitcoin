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
wget https://github.com/libbitcoin/libbitcoin-server/releases/download/v2.1.0/bs-linux-x64-mainnet
wget https://github.com/libbitcoin/libbitcoin-explorer/releases/download/v2.1.0/bx-linux-x64-mainnet
mv bs-linux-x64-mainnet bs
mv bx-linux-x64-mainnet bx
chmod 755 bs
chmod 755 bx

echo "
# Libbitcoin Server configuration file.
[node]
# The number of threads in the database threadpool, defaults to 6.
database_threads = 6
# The number of threads in the network threadpool, defaults to 4.
network_threads = 4
# The number of threads in the memory threadpool, defaults to 4.
memory_threads = 4
# The maximum number of peer hosts in the pool, defaults to 1000.
host_pool_capacity = 1000
# The maximum number of orphan blocks in the pool, defaults to 50.
block_pool_capacity = 50
# The maximum number of transactions in the pool, defaults to 2000.
tx_pool_capacity = 100000
# The minimum height of the history database, defaults to 0.
history_height = 0
# The height of the checkpoint hash, defaults to 0.
checkpoint_height = 300000
# The checkpoint hash, defaults to a null hash (no checkpoint).
checkpoint_hash = 000000000000000082ccf8f1557c5d40b21edabb18d2d691cfbf87118bac7254
# The port for incoming connections, set to 0 to disable, defaults to 8333 (18333 for testnet).
# listen_port = 0
# The maximum number of outgoing P2P network connections, defaults to 8.
outbound_connections = 8
# The peer cache file path, defaults to 'peers'.
hosts_file = peers
# The blockchain directory, defaults to 'blockchain'.
blockchain_path = blockchain

[logging]
# The debug log file path, defaults to 'debug.log'.
debug_file = debug.log
# The error log file path, defaults to 'error.log'.
error_file = error.log
# Write service requests to the log, impacts performance, defaults to false.
log_requests = false

[server]
# The query service endpoint, defaults to 'tcp://*:9091'.
query_endpoint = tcp://*:9091
# The heartbeat service endpoint, defaults to 'tcp://*:9092'.
heartbeat_endpoint = tcp://*:9092
# The block publishing service endpoint, defaults to 'tcp://*:9093'.
block_publish_endpoint = tcp://*:9093
# The transaction publishing service endpoint, defaults to 'tcp://*:9094'.
tx_publish_endpoint = tcp://*:9094
# Enable the publisher, defaults to false.
publisher_enabled = false

[identity]
# The path to the ZPL-encoded server private certificate file.
#cert_file = /home/bitcoin/libbitcoin/server.cert
# The directory for ZPL-encoded client public certificate files, allows anonymous clients if not set.
# client_certs_path =
# Allowed client IP address, all clients allowed if none set, multiple entries allowed.
# client = 127.0.0.1
# client =
# Node to augment peer discovery, formatted as host:port, multiple entries allowed.
# peer = obelisk.airbitz.co:8333
# peer =
# The server name, must be unique if specified.
# unique_name = 
" > bs.cfg

./bx cert-new server.cert

#
# Setup script to restart BS
#
echo "
#!/bin/bash
cd ${userdir}/libbitcoin
touch keep-going
while [ -f keep-going ];
do ./bs ${userdir}/libbitcoin/bs.cfg > ${userdir}/libbitcoin/console.log;
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

rsync blocks@bitcoin-serverhub-phoenix.airbitz.co:blockchain.bak/ ~/libbitcoin/blockchain --progress --append --partial -avz


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
