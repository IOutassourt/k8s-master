curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -
ip -4 addr show en0
sudo cat /var/lib/rancher/k3s/server/node-token
