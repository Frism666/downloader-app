#!/bin/bash
set -e
echo "Updating system..."
sudo apt-get update -y
sudo apt-get install -y python3 python3-venv python3-pip liblzma-dev xz-utils git
echo "Cloning/pulling repo..."
cd /opt
if [ ! -d downloader-app ]; then
  sudo git clone https://github.com/<username>/downloader-app.git downloader-app
else
  cd downloader-app
  sudo git pull
  cd ..
fi
sudo chown -R $USER:$USER downloader-app
echo "Setting up virtualenv..."
cd downloader-app
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo "Creating cookies folder..."
mkdir -p /opt/downloader-app/cookies
echo "Creating service..."
sudo tee /etc/systemd/system/downloader.service > /dev/null << 'EOF'
[Unit]
Description=Downloader Flask App
After=network.target
[Service]
Type=simple
User=$USER
WorkingDirectory=/opt/downloader-app
Environment="FLASK_APP=app.py"
Environment="FLASK_ENV=production"
ExecStart=/opt/downloader-app/venv/bin/python app.py
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable downloader.service
sudo systemctl restart downloader.service
echo "Deployment complete!"
