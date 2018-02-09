sudo sh <<EOF
systemctl stop net-tester
cd /opt/net-tester
sudo -E -u net-tester git pull
export HOME=/opt/net-tester/log
sudo -E -u net-tester bundle install --path=vendor/bundle
cp /opt/net-tester/script/net-tester.sudoers /etc/sudoers.d/net-tester
cp /opt/net-tester/script/net-tester.service /lib/systemd/system/net-tester.service
systemctl daemon-reload
systemctl enable net-tester
systemctl start net-tester
EOF

