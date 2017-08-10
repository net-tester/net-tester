sudo sh <<EOF
adduser --shell /usr/sbin/nologin net-tester
cd /opt
git clone https://github.com/net-tester/net-tester.git
chown -R net-tester:net-tester net-tester
cd net-tester
git checkout feature/api-merge
sudo -u net-tester bundle install --path=vendor/bundle
cp utilities/net-tester.sudoers /etc/sudoers.d/
cp utilities/net-tester.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable net-tester
systemctl start net-tester
EOF

