sudo sh <<EOF
adduser --home /home/net-tester --shell /usr/sbin/nologin net-tester
cd /opt
git clone https://github.com/net-tester/net-tester.git
chown -R net-tester:net-tester net-tester
cd net-tester
export HOME=/home/net-tester
sudo -E -u net-tester git config --global url."https://".insteadOf "git://"
sudo -E -u net-tester git checkout feature/api-merge
sudo -E -u net-tester bundle install --path=vendor/bundle
cp /opt/net-tester/utilities/net-tester.sudoers /etc/sudoers.d/net-tester
cp /opt/net-tester/utilities/net-tester.service /etc/systemd/system/net-tester.service
systemctl daemon-reload
systemctl enable net-tester
systemctl start net-tester
EOF
