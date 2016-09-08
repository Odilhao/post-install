#!/bin/bash

declare -a portstcp=("22" "80" "443")
declare -a portsudp=("")


epel-install(){
  sudo yum -t -y -e 0 install epel-release
  sudo yum -t -y -e 0 update
  echo "Epel Installed"
}

firewalld-install(){
  sudo systemctl start firewalld
  sudo systemctl enable firewalld

  for i in "${portstcp[@]}"
  do
    echo "Liberando a porta $i tcp"
  sudo firewall-cmd --permanent --add-port=$i/tcp
  done

  for i in "${portsudp[@]}"
  do
    echo "Liberando a porta $i udp"
  sudo firewall-cmd --permanent --add-port=$i/udp
  done

}

fail2ban-install(){

  echo "Installing fail2ban"
  sudo yum -t -y -e 0 install fail2ban fail2ban-firewalld fail2ban-systemd

cat >/etc/fail2ban/jail.d/sshd.conf <<EOF
[DEFAULT]
bantime = 345600
banaction = firewallcmd-ipset
backend = systemd
action = %(action_mwl)s
maxretry = 4
[sshd]
enabled = true

EOF

  sudo systemctl start fail2ban
  sudo systemctl enable fail2ban

}

ntp-install(){

  echo "Installing ntp"
  sudo yum -t -y -e 0 install ntp
  timedatectl set-timezone America/Sao_Paulo
  systemctl start ntpd
  systemctl enable ntpd

}


firewalld-install
fail2ban-install
ntp-install
