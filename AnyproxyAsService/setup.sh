# run as sudo
yes | apt-get update
yes | apt-get install nodejs npm
npm install -g anyproxy
yes | anyproxy-ca
cat > /etc/systemd/system/anyproxy.service <<EOF
[Service]
ExecStartPre=/bin/mkdir -p /tmp/anyproxy/cache
ExecStart=/usr/local/bin/anyproxy --intercept --port 3128
StandardOutput=syslog
User=root
Group=root
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

systemctl --system daemon-reload
systemctl enable anyproxy.service
systemctl start anyproxy.service
