#!/usr/bin/env bash
set -xeu

rm -f client.log

DEV=rclient
ETC=$PWD
KEYSDIR=$ETC/keys/client
PEERDIR=$ETC/peers

SERVER_RP_ENDPOINT=localhost:9999
SERVER_WG_ENDPOINT=localhost:10000

sudo ip link add dev $DEV type wireguard || true
sudo ip a add fe80::2/64 dev $DEV
sudo ip link set dev $DEV up
trap "sudo ip link del dev $DEV" TERM

sudo wg set $DEV private-key $KEYSDIR/wgsk
sudo wg set $DEV peer $(cat $PEERDIR/server/wgpk) allowed-ips ::/0 endpoint $SERVER_WG_ENDPOINT

# sudo rosenpass exchange \
# 	secret-key $KEYSDIR/pqsk \
# 	public-key $KEYSDIR/pqpk \
# 	verbose \
# 	peer \
# 	    public-key $PEERDIR/server/pqpk endpoint $SERVER_RP_ENDPOINT \
# 	    wireguard $DEV \
# 		$(cat $PEERDIR/server/wgpk) \
# 	>> client.log 2>&1 &

sudo rosenpass exchange-config client.toml \
	>> client.log 2>&1 &

wait