#!/bin/bash

sudo apt-get update	 
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:obsproject/obs-studio
sudo add-apt-repository ppa:nextcloud-devs/client
sudo apt-get update
yes | sudo DEBIAN_FRONTEND=noninteractive apt-get install -y lightdm
echo '/usr/sbin/lightdm' | sudo tee /etc/X11/default-display-manager > /dev/null

sudo apt-get install -y ubuntu-drivers-common nvidia-driver-510 ocl-icd-libopencl1 opencl-headers clinfo obs-studio ffmpeg ubuntu-desktop x11vnc net-tools qt5-image-formats-plugins libmng2 nextcloud-client nextcloud-desktop
sudo nvidia-xconfig

sudo sh -c "cat <<EOF > /etc/systemd/system/x11vnc.service
[Unit]
Description=x11vnc (Remote access)
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -display :0 -rfbauth /etc/.vncpasswd -rfbport 5900 -forever -loop -noxdamage -repeat -shared
ExecStop=/bin/kill -TERM $MAINPID
ExecReload=/bin/kill -HUP $MAINPID
KillMode=control-group
Restart=on-failure

[Install]
WantedBy=graphical.target
EOF"

cd /tmp
wget https://github.com/obsproject/obs-websocket/releases/download/5.0.0/obs-websocket-5.0.0-Ubuntu64.zip
unzip obs-websocket-5.0.0-Ubuntu64.zip
sudo dpkg -i obs-websocket-5.0.0-Ubuntu64.deb

sudo systemctl daemon-reload
sudo systemctl enable x11vnc
sudo systemctl start x11vnc
