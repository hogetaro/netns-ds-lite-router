
set -ex

UNIQ=$(date +%H%M%S)
NS=myrouter-$UNIQ
BRIDGE=br0
TNAME=guestun0
VETHH=veth-h$UNIQ
VETHG=veth-g$UNIQ
V4ADDR=192.168.0.40
V4ADDR=10.0.0.4
NX="ip netns exec $NS "

sudo ip netns del $NS || true
sleep 3
sudo cp -r /etc/netns/myrouter /etc/netns/$NS
sudo ip netns add $NS
sudo $NX ip link set lo up
sudo $NX brctl addbr $BRIDGE
sudo $NX ip link set $BRIDGE up
sudo ip link add name $VETHH type veth peer name $VETHG
sudo ip link set $VETHG netns $NS
sudo     brctl addif $BRIDGE $VETHH
sudo $NX brctl addif $BRIDGE $VETHG
sudo     ip link set $VETHH up
sudo $NX ip link set $VETHG up
sudo $NX ip addr add $V4ADDR/24 brd + dev $BRIDGE

TMP=""
while [ X$TMP = X ]
do
  sleep 3
  declare -a TMP=($(sudo $NX ip address show dev br0|grep inet6|grep dynamic))
done
echo "IPV6 line:" ${TMP[@]}
V6LOCAL=${TMP[1]%/*}
sudo $NX ip -6 tunnel add $TNAME mode ipip6 local $V6LOCAL remote 2404:8e00::feed:100
sudo $NX ip link set $TNAME up
sudo $NX ip route add default dev $TNAME

sudo $NX curl https://www.ugtop.com/spill.shtml|grep blue
sudo $NX su owner

