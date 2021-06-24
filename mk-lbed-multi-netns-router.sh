
set -ex

NS=myrouter
VETHH=veth-host
VETHG=veth-guest
BRIDGE=br0
TNAME=guestun0
V4ADDR=192.168.0.40
NX="ip netns exec $NS "


for n in $(seq  -w 11 20)
do
  NS=vr$n
  VETHH=veth-h$n
  VETHG=veth-g$n
  BRIDGEH=br0
  BRIDGEG=br-vr$n
  TNAME=guestun$n
  V4ADDR=192.168.0.$n
  NX="ip netns exec $NS "

  sudo ip netns del $NS || true
  sleep 3

  sudo mkdir /etc/netns/$NS || true
  echo nameserver 8.8.8.8 |sudo tee /etc/netns/$NS/resolv.conf
  sudo ip netns add $NS
  sudo $NX ip link set lo up
  sudo $NX brctl addbr $BRIDGEG
  sudo $NX ip link set $BRIDGEG up
  sudo ip link add name $VETHH type veth peer name $VETHG
  sudo ip link set $VETHG netns $NS
  sudo     brctl addif $BRIDGEH $VETHH
  sudo $NX brctl addif $BRIDGEG $VETHG
  sudo     ip link set $VETHH up
  sudo $NX ip link set $VETHG up
  sudo $NX ip addr add $V4ADDR/24 brd + dev $BRIDGEG
  
  TMP=""
  while [ X$TMP = X ]
  do
    sleep 3
    declare -a TMP=($(sudo $NX ip address show dev $BRIDGEG|grep inet6|grep dynamic))
  done
  echo "IPV6 line:" ${TMP[@]}
  V6LOCAL=${TMP[1]%/*}
  sudo $NX ip -6 tunnel add $TNAME mode ipip6 local $V6LOCAL remote 2404:8e00::feed:100
  sudo $NX ip link set $TNAME up
  sudo $NX ip route add default dev $TNAME
done

