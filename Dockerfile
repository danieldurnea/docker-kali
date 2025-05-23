# kali or kali-bleeding-edge
ARG KALI_VER=rolling
FROM amitie10g/kali-$KALI_VER:upstream AS base-build

ARG DEBIAN_FRONTEND=noninteractive
# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3.5-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip

# Create shell script
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/kali.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/kali.sh


# Create directory for SSH daemon's runtime files
RUN echo '/usr/sbin/sshd -D' >>/kali.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config # Allow root login via SSH
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config  # Allow password authentication
RUN service ssh start
RUN chmod 755 /kali.sh

# Expose port

# Start the shell script on container startup

COPY /root /
# add local files
# ports and volumes


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
CMD  /kali.sh
