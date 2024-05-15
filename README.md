# Kali Linux plus Kalitorify on Docker image (WIP)
This is a somewhat customised set of Docker images of Kali Linux, for both platforms ``amd64`` (Docker Desktop on Windows, cloud, etc.) and ``arm64`` (Raspberry Pi, Apple Silicon Mac, etc.), and two flavors, [``kali-rolling``](https://hub.docker.com/r/amitie10g/kali-rolling) (``kali`` is the same image) and [``kali-bleeding-edge``](https://hub.docker.com/r/amitie10g/kali-bleeding-edge). Out-of-the-box tools for all needs!

## Tags

* ``upstream`` the base image built with the [Phusion's base image](https://github.com/phusion/baseimage-docker) project modifications

* ``base`` Image with basic tools, TOR, and kalitorify (forked from the upstream repo to add Dockerfile and pull requests)
  * ``nano``
  * ``lynx`` 
  * ``tor``
  * ``make``
  * ``iptables``
  * ``kali-linux-wsl``

* ``desktop`` Base desktop (XFCE) without further tools. Includes Firefox
  * [``kali-desktop-xfce``](https://www.kali.org/tools/kali-meta/#kali-desktop-xfce)
  * ``xrdp``
  * ``dbus-x11``

* ``latest`` ``top10`` ``desktop-top10`` Most used set of tools on top of Desktop image
  * [``kali-linux-top10``](https://www.kali.org/tools/kali-meta/#kali-linux-top10)
    * ``maltego`` (not installed by default in ``kali-tools-top10`` but installed by default here)

* ``headless`` Tools that dont require graphical environment (large)
  * [``kali-linux-headless``](https://www.kali.org/tools/kali-meta/#kali-linux-headless)

* ``labs`` ``exploitable`` ``vulnerable`` Intentionally vulnerable web applications: [Damn Vulnerable Web Application](https://github.com/digininja/DVWA) and [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/)
  * [``kali-linux-labs``]((https://www.kali.org/tools/kali-meta/#kali-linux-labs))
    * ``dvwa``
    * ``juice-shop``

* ``nethunter`` The Kali Linux NetHunter system
  * [``kali-linux-nethunter``](https://www.kali.org/tools/kali-meta/#kali-linux-nethunter)

* ``tools`` The ``kali-tools-*`` packages on top of Desktop Top 10 (``latest``) image
  * [``kali-tools-crypto-stego``](https://www.kali.org/tools/kali-meta/#kali-tools-crypto-stego)
  * [``kali-tools-database``](https://www.kali.org/tools/kali-meta/#kali-tools-database)
  * [``kali-tools-detect``](https://www.kali.org/tools/kali-meta/#kali-tools-detect)
  * [``kali-tools-exploitation``](https://www.kali.org/tools/kali-meta/#kali-tools-exploitation)
  * [``kali-tools-forensics``](https://www.kali.org/tools/kali-meta/#kali-tools-forensics)
  * [``kali-tools-fuzzing``](https://www.kali.org/tools/kali-meta/#kali-tools-fuzzing)
  * [``kali-tools-gpu``](https://www.kali.org/tools/kali-meta/#kali-tools-gpu)
  * [``kali-tools-hardware``](https://www.kali.org/tools/kali-meta/#kali-tools-)
  * [``kali-tools-identify``](https://www.kali.org/tools/kali-meta/#kali-tools-identify)
  * [``kali-tools-information-gathering``](https://www.kali.org/tools/kali-meta/#kali-tools-information-gathering)
  * [``kali-tools-passwords``](https://www.kali.org/tools/kali-meta/#kali-tools-passwords)
  * [``kali-tools-post-exploitation``](https://www.kali.org/tools/kali-meta/#kali-tools-post-exploitation)
  * [``kali-tools-protect``](https://www.kali.org/tools/kali-meta/#kali-tools-protect)
  * [``kali-tools-reporting``](https://www.kali.org/tools/kali-meta/#kali-tools-reporting)
  * [``kali-tools-respond``](https://www.kali.org/tools/kali-meta/#kali-tools-respond)
  * [``kali-tools-reverse-engineering``](https://www.kali.org/tools/kali-meta/#kali-tools-reverse-engineering)
  * [``kali-tools-reverse-engineering``](https://www.kali.org/tools/kali-meta/#kali-tools-reverse-engineering)
  * [``kali-tools-sniffing-spoofing``](https://www.kali.org/tools/kali-meta/#kali-tools-sniffing-spoofing)
  * [``kali-tools-social-engineering``](https://www.kali.org/tools/kali-meta/#kali-tools-social-engineering)
  * [``kali-tools-voip``](https://www.kali.org/tools/kali-meta/#kali-tools-voip)
  * [``kali-tools-vulnerability``](https://www.kali.org/tools/kali-meta/#kali-tools-vulnerability)
  * [``kali-tools-web``](https://www.kali.org/tools/kali-meta/#kali-tools-web)
  * [``kali-tools-windows-resources``](https://www.kali.org/tools/kali-meta/#kali-tools-windows-resources)
  * [``kali-tools-wireless``](https://www.kali.org/tools/kali-meta/#kali-tools-wireless)

## Usage

* Just download ``docker-compose.yml``, place at an empty directory, and run ``docker-compose up -d``. This will start the ``latest`` and ``labs`` containers (if you use Windows, be sure to replace the incoming port to 13389 do avoid conflicts with the local Remote Desktop port).

* Access the shell: ``docker exec -it --user kali desktop bash`` (omit ``--user kali`` to acces as root).

* Connect to the desktop environment using your Remote Desktop client. Available users are ``root`` and ``kali`` (password is ``kali`` for both). You may use the ``root`` username when running GUI apps that require root permissions.

* Inside the Desktop environment, browse the vulnerble webapps at the Vulnerable container:
  * http://vulnerable:42000 OWASP Juice Shop.
  * http://vulnerable:42001 Damn Vulnerable Web Application.

  Or use the tools available to attemp to exploit those web apps.

**Note**: Due to limitations related to file permissions on mounted volumes on **rootless Podman**, you need to connect to the instance (via console or RDP) using the ``root`` account.

## Building
The image depends on a Kali Linux base image built using the instructions on the [Phusion's base image](https://github.com/phusion/baseimage-docker) repo.

```
docker build --build-arg KALI_VER=<version> --build-arg TOOL=<tool> --target <target> -t amitie10g/kali-linux:<tag> .
```

Where build arg,
* ``KALI_VER`` The kali edition: ``rolling``, ``bleeding-edge``, ``last-release`` or ``experimental`` (if unsure, choose ``rolling``)
* ``TOOL`` One of the [packages](https://www.kali.org/tools/kali-meta/) starting with ``kali-tools-``
* ``--target`` The desired target:
  * ``base`` Just the base image
  * ``desktop`` The Desktop (XFCE, without tools) image
  * ``desktop-top10`` The desktop experience plus the top 10 tools
  * ``labs`` The vulnerable webapps
  * ``headless`` The cli-only tools
  * ``nethunter`` The Kali Nethunter system
  * ``tool`` The target for build the desired tool
 
Edit the Dockerfile to fit your needs.

## FAQ
* Q: Why you created this project<br>
  A: I'm preparing for diploma in cybersecurity, and as my hobby is create Docker containers, I created this as part of my tasks. As this will be useful for everyone, I'be compromised to maintain this project.

* Q: Why s6-overlay<br>
  A: Because this eases the process of bringing required services for tools (eg. Postgres for Metasploit).

* Q: Why XRDP instead o VNC?<br>
  A: a) most of the users uses Windows, and the Remote Desktop client is integrated, and runs seamlessly; and b) performance.

## Licensing

* Everything in the GitHub repo (excluding submodules like Kalitorify) is released into the Public domain (the Unlicense)
* Kalitorify is licensed under the GNU General Public License v3.0
* The software built into the container images are released under their respective licenses

## Related projects

* [kalitorify](https://github.com/brainfucksec/kalitorify)
