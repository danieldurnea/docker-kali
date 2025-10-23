# You can change the base image to any other image you want.
ARG KALI_VER=rolling
FROM amitie10g/kali-$KALI_VER:upstream AS base-build

ARG DEBIAN_FRONTEND=noninteractive

ARG DEBIAN_FRONTEND=noninteractive
COPY init/ /etc/my_init.d/
COPY kalitorify /tmp/kalitorify
COPY excludes /etc/dpkg/dpkg.cfg.d/

# Base system plus nano, lynx, tor and kalitorify
RUN adduser --quiet --add_extra_groups --disabled-password --gecos \"\" kali && \
    adduser kali sudo && \
    echo "kali:kali" | chpasswd && \
    echo "root:kali" | chpasswd && \
    apt-get update && \
    apt-get install --no-install-suggests -y \
        nano \
        lynx \
        tor \
        make \
        kali-linux-wsl \
        iptables \
        inetutils-ping \
        inetutils-traceroute && \
    apt-get clean && \
    cd /tmp/kalitorify && make install

# Desktop
FROM base-build AS desktop-build
RUN apt-get install -y kali-desktop-xfce xrdp dbus-x11 && apt-get clean

# Desktop plus Top 10
FROM desktop-build AS desktop-top10-build
RUN apt-get install -y kali-tools-top10 maltego && dpkg-reconfigure wireshark-common && apt-get clean

# Tools on top of Desktop top 10
FROM desktop-top10-build AS tool-build
ARG TOOL=exploitation
RUN apt-get install -y kali-tools-$TOOL && apt-get clean

# Large metapackage
FROM desktop-top10-build AS large-build
RUN apt-get install -y kali-tools-large && apt-get clean

# Full metapackage
FROM large-build AS full-build
RUN apt-get install -y kali-tools-large && apt-get clean

# Vulnerable webapps
FROM base-build AS labs-build
RUN apt-get install -y kali-linux-labs && apt-get clean && \
    sed -i '/allow 127.0.0.1;/a \\t    allow 172.16.0.0/12;' /etc/dvwa/vhost/dvwa-nginx.conf
COPY init.d/dvwa init.d/juice-shop /etc/init.d/

# Headless
FROM base-build AS headless-build
RUN apt-get install -y kali-linux-headless && apt-get clean

# Nethunter
FROM base-build AS nethunter-build
RUN apt-get install -y kali-linux-nethunter && apt-get clean

# Cleanup
FROM base-build AS base
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM desktop-build AS desktop
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM desktop-top10-build AS desktop-top10
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM labs-build AS labs
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM headless-build AS headless
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM nethunter-build AS nethunter
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM tool-build AS tool
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM large-build AS large
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM full-build AS full
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root


ARG AUTH_TOKEN
ARG PASSWORD=rootuser

# Install packages and set locale
RUN apt-get update \
    && apt-get install -y locales nano ssh sudo python3 curl wget \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH tunnel using ngrok
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.utf8

RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip \
    && unzip ngrok.zip \
    && rm /ngrok.zip \
    && mkdir /run/sshd \
    && echo "/ngrok tcp --authtoken ${AUTH_TOKEN} 22 &" >>/docker.sh \
    && echo "sleep 5" >> /docker.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(\\\"SSH Info:\\\n\\\",\\\"ssh\\\",\\\"root@\\\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '),\\\"\\\nROOT Password:${PASSWORD}\\\")\" || echo \"\nError：AUTH_TOKEN，Reset ngrok token & try\n\"" >> /docker.sh \
    && echo '/usr/sbin/sshd -D' >>/docker.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo root:${PASSWORD}|chpasswd \
    && chmod 755 /docker.sh

EXPOSE 80 8888 8080 443 5130-5135 3306 7860
CMD ["/bin/bash", "/docker.sh"]
