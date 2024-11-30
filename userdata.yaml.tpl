#cloud-config

hostname: "oci-arm"
timezone: Asia/Ho_Chi_Minh

groups:
  - docker

users:
  - name: ${github_user}
    ssh_import_id:
      - gh:${github_user}
    shell: /usr/bin/zsh
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups:
      - sudo
      - users
      - docker

ssh_pwauth: false

apt:
  sources:
    tailscale.list:
      source: deb https://pkgs.tailscale.com/stable/ubuntu $RELEASE main
      keyid: 2596A99EAAB33821893C0A79458CA832957F5868
    docker.list:
      source: deb https://download.docker.com/linux/ubuntu $RELEASE stable
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

package_update: true
package_upgrade: true
package_reboot_if_required: true

packages:
  - tailscale

  - docker-ce
  - docker-ce-cli
  - containerd.io
  - docker-buildx-plugin
  - docker-compose-plugin

  - zsh
  - git

runcmd:
  - tailscale up -authkey ${tailscale_auth_key}

  - iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
  - iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
  - netfilter-persistent save

  - wget -qO- https://github.com/MoeClub/Note/raw/master/Oracle/eat.service > /etc/systemd/system/eat.service
  - systemctl daemon-reload
  - systemctl enable eat
  - systemctl start eat

final_message: "The system is finally up, after $UPTIME seconds"
