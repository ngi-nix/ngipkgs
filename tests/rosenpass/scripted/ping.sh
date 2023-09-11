#! /usr/bin/env bash
set -xeuo pipefail

rm -rf keys peers
mkdir -p {keys,peers}/{client,server}

if pgrep rosenpass; then
  echo "Rosenpass appears to be running; exiting..."
  exit 1
fi

for NODE in server client; do
  KEYSDIR=$PWD/keys/$NODE
  rosenpass gen-keys --force \
    --public-key $KEYSDIR/pqpk \
    --secret-key $KEYSDIR/pqsk

  wg genkey | tee $KEYSDIR/wgsk | wg pubkey >$KEYSDIR/wgpk

  cp $KEYSDIR/*pk peers/$NODE/
done

for NODE in server client; do
  if [ "$NODE" = "server" ]; then
    OTHER=client
  else
    OTHER=server
  fi
  sed "s|xxx|$(cat keys/$OTHER/wgpk)|" <${NODE}-template.toml >${NODE}.toml
done

./server.sh &
SERVER_PID=$!
sleep 1

./client.sh &
CLIENT_PID=$!
sleep 1

function cleanup {
  echo "Cleaning up..."
  kill -TERM $SERVER_PID || true
  kill -TERM $CLIENT_PID || true
  sudo pkill rosenpass || true
}
trap cleanup EXIT TERM

ping fe80::1%rclient >ping.log 2>&1 &

watch -n 1 sudo wg show all preshared-keys
