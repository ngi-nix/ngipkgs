#!/usr/bin/env bash
set -xeu

rm -f server.log

DEV=rserver
ETC=$PWD
KEYSDIR=$ETC/keys/server
PEERDIR=$ETC/peers

SERVER_RP_ENDPOINT=localhost:9999
SERVER_WG_PORT=10000
#SERVER_WG_ENDPOINT=localhost:$SERVER_WG_PORT

sudo ip link add dev $DEV type wireguard || true
sudo ip a add fe80::1/64 dev $DEV
sudo ip link set dev $DEV up
trap "sudo ip link del dev $DEV" TERM

sudo wg set $DEV private-key $KEYSDIR/wgsk listen-port $SERVER_WG_PORT
sudo wg set $DEV peer $(cat $PEERDIR/client/wgpk) allowed-ips ::/0

# sudo rosenpass exchange \
# 	secret-key $KEYSDIR/pqsk \
# 	public-key $KEYSDIR/pqpk \
# 	listen $SERVER_RP_ENDPOINT \
# 	verbose \
# 	peer \
# 	    public-key $PEERDIR/client/pqpk \
# 	    wireguard $DEV \
# 		$(cat $PEERDIR/client/wgpk) \
# 	>> server.log 2>&1 &

sudo rosenpass exchange-config server.toml \
	>> server.log 2>&1 &

wait