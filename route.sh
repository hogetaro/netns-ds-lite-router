sudo ip route delete default 
sudo ip route add default scope global \
  nexthop via 192.168.0.11 weight 1 \
  nexthop via 192.168.0.12 weight 1 \
  nexthop via 192.168.0.13 weight 1 \
  nexthop via 192.168.0.14 weight 1 \
  nexthop via 192.168.0.15 weight 1 \
  nexthop via 192.168.0.16 weight 1 \
  nexthop via 192.168.0.17 weight 1 \
  nexthop via 192.168.0.18 weight 1 \
  nexthop via 192.168.0.19 weight 1 \
  nexthop via 192.168.0.20 weight 1
