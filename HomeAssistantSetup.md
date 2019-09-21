# Setup
## Prerequisites
- A device that can run HomeAssistant
  - **JustOneButton** isn't computationally intensive -- a Raspberry Pi will do.
- SSL-secured domain endpoint
  - Let's Encrypt certificates will work. Because the Garmin device will only accept
    HTTPS connections with valid SSL certificates, self-signed local developer sites
    won't work and HTTP-only sites won't work either.

## Installation
1. Install Python dependencies

 ```sudo apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev```
2. Install a supported Python version

 ```
wget https://www.python.org/ftp/python/3.5.7/Python-3.5.7.tgz
sudo tar zxf Python-3.5.7.tgz
cd Python-3.5.7
./configure
make -j 4
make install
```
3. Update Python utilities

 ```
sudo pip3 install -U pip
sudo pip3 install -U setuptools
```
4. Add a user to run Home Assistant under

 ```
useradd -rm homeassistant -G dialout,gpio,i2c
cd /srv
mkdir homeassistant
chown homeassistant:homeassistant homeassistant
```

5. Setup a Python virtual environment

 ```
sudo -u homeassistant -H -s
cd /srv/homeassistant
python3.5 -m venv .
source bin/activate
```

6. Install Home Assistant (slow)

 ```
python3.5 -m pip install wheel
pip3.5 install homeassistant
```

## Switch Setup

1. From within the Python virtual environment, start Home Assistant (slow when first started)

 ```hass```

2. Navigate to the UI once Home Assistant has started
    - http://LOCAL_IP:8123/lovelace/default_view
 
3. Add in the switch using the user interface. 
4. (Optional) Add in an automation setting in the UI to disable the switch after a set period of time.
5. Modify the configuration to add a group for the switch. Replace UPPERCASE_ITEMS with your switch names.

 ```
cd /home/homeassistant/.homeassistant
nano group.yaml
>>
NAME_OF_GROUP:
  view: true
  name: FRIENDLY_NAME_OF_GROUP
  entities:
    - swith.NAME
<<
```
6. Test the switch using the APIs locally. If you stop Home Assistant, you can start it using the following commands

 ```
sudo -u homeassistant -H -s
cd /srv/homeassistant
python3.5 -m venv .
source bin/activate
hass
```
7. Setup HomeAssistant to run as a service with a startup script
 ```
apt-get install supervisor
nano /etc/supervisor/conf.d/hass.conf
>>
[program:hass]
command=/home/homeassistant/start.sh
user=homeassistant
stderr_logfile = /home/homeassistant/stderr.log
stdout_logfile = /home/homeassistant/stdout.log
directory = /srv/homeassistant
<<

nano /home/homeassistant/start.sh
>>
#!/bin/bash
sudo -u homeassistant -H -s
/srv/homeassistant/bin/hass -c "/home/homeassistant/.homeassistant"
<<

chmod +x /home/homeassistant/start.sh
chown homeassistant /home/homeassistant/start.sh

supervisorctl reread
supervisorctl update
supervisorctl start hass
<<
```

8. Using the UI, get a long-lived authorization token. Save this for later for the watch to authenticate with.

## Watchface Setup
1. Setup an [Nginx](http://nginx.org/) proxy to expose the Home Assistant API over SSL
   - If you can use a secured SSL certificate here, do so. Otherwise, use a self-signed developer cert.
   - Replace PORT, CERT_PATH, and CERT_KEY_PATH with your preferred values.
 ```
nano /etc/nginx/sites-enabled/home-assistant
>>
upstream homeassistant {
  server 127.0.0.1:8123;
  keepalive 15;
}

server {
  listen PORT;

  ssl on;
  ssl_certificate /etc/nginx/certs/CERT_PATH.cert;
  ssl_certificate_key /etc/nginx/certs/CERT_KEY_PATH.key;
  ssl_session_timeout 5m;
  ssl_protocols TLSv1.2 TLSv1.1 TLSv1;
  ssl_ciphers HIGH:!aNULL:!eNULL:!LOW:!MD5;
  ssl_prefer_server_ciphers on;

  location / {
    proxy_pass http://homeassistant;
    proxy_http_version 1.1;
    proxy_set_header Connection "Keep-Alive";
    proxy_set_header Proxy-Connection "Keep-Alive";
  }
}
<<
```
2. Setup your router to forward connections from the internet on the HTTPS port to the Home Assistant Device.
   - If you used a secured SSL certificate in Step 1, STOP. Your setup is complete.

At this point, the Home Assistant API is accessible over the internet, but can't be used by the Garmin Device
because it uses a self-signed certificate. We can fix this by forwarding SSL calls from a valid website to the device.

1. Setup a Nginx proxy on your website to forward calls to the automation server.
   - Replace WEBSITE, DEVICE_WEBSITE, PORT, CERT_PATH, and CERT_KEY_PATH with your values.

 ```
nano /etc/nginx/sites-enabled/helium24-homeautomation
>>
upstream homeassistant {
  server DEVICE_WEBSITE:PORT;
  keepalive 15;
}

server {
  listen PORT ssl;

  ssl on;
  ssl_certificate /etc/letsencrypt/live/WEBSITE/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/WEBSITE/privkey.pem;
  include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
  
  location / {
    proxy_pass https://DEVICE_WEBSITE:PORT;
    proxy_http_version 1.1;
    proxy_set_header Connection "Keep-Alive";
    proxy_set_header Proxy-Connection "Keep-Alive";
    proxy_ssl_verify off;
  }
}
<<
```