# Linux 驗證日誌分析器 (Linux Auth Log Analyzer)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-lightgrey.svg)]()

這是一個通用、輕量且萬用的 Linux 驗證日誌（`auth.log`）快速分析工具。

本程式自動掃描系統中的 `auth.log` 歷史紀錄，協助管理員快速找出暴力破解攻擊的源頭，以及排查帳號有沒有被越權執行 `sudo` 命令。


## 📊 核心分析模組與輸出說明

本工具執行後，會依序在畫面上輸出以下 8 大安全數據看板：

1. **Failed password - Top Target Accounts**：統計黑客最常嘗試破解的「現有系統帳號」排行（例如 root、peter）。
2. **Invalid user - Top Target Accounts**：統計黑客嘗試用系統中「不存在的字典帳號」進行盲猜爆破的排行。
3. **Failed password - Top Source IPs**：精準列出發動攻擊的黑客來源 IP 排行（Top 100），方便您直接丟進防火牆封鎖。
4. **Hourly Distribution of Attacks**：分析 24 小時（00:00 - 23:59）的攻擊次數分佈，讓您知道黑客最常在哪些時段發起爆破。
5. **Daily Distribution of Attacks**：提供近期的每日攻擊總數趨勢，方便評估最近是否遭到針對性的連續攻擊。
6. **Successful Logins Audit**：拉出所有「成功登入」的紀錄，包含精確時間、使用者與來源 IP，直接排查有沒有可疑人士成功潛入。
7. **Sudo Privilege Escalation Audit**：完整列出所有透過 `sudo` 執行的命令紀錄。
8. **Current Fail2ban Defense Status**：偵測系統中的 Fail2ban 防禦狀態，確認 SSH 防護牆是否有在正常抓人。

## 🚀 使用方法

> [!NOTE]
> 由於需要讀取敏感的系統安全日誌 `/var/log/auth.log*`，**本腳本必須使用 root (`sudo`) 權限執行**。

```bash
chmod +x auth-log-analyzer.sh
sudo ./auth-log-analyzer.sh
```

## 📊 執行範例

```text
$ sudo ./auth-log-analyzer.sh
[+] Advanced environment: zgrep detected. Auditing both live and compressed historical archives (*.gz).

================================================================================
  Failed password - Top Target Accounts (Top 100)
================================================================================
  78269 root
   7331 admin
   4063 user
   3056 ubuntu
   2508 test
   1215 postgres
   1027 ftpuser
   1003 oracle
    878 user1
    799 deploy
    650 guest
    623 demo
    610 pi
    576 git
    526 debian
    462 ftp
    424 nobody
    413 username
    407 nvidia
    388 ubnt
    385 mysql
    384 student
    363 test1
    358 server
    345 1234
    342 cirros
    325 vagrant
    323 orangepi
    319 user2
    311 odoo
    298 prueba
    292 hadoop
    280 public
    275 test2
    273 system
    272 huawei
    272 a
    253 samba
    250 tomcat
    236 zabbix
    236 jenkins
    235 www
    233 steam
    230 web
    229 dev
    228 vpn
    211 teste
    211 support
    209 linaro
    206 kali
    204 squid
    198 1
    197 app
    190 dell
    189 usuario
    188 www-data
    186 apache
    179 testuser
    177 nagios
    170 sshadmin
    169 centos
    165 Admin
    164 backup
    162 weblogic
    160 docker
    152 administrator
    150 AdminGPON
    149 es
    147 nginx
    146 sshd
    142 webmaster
    142 teamspeak
    142 kafka
    141 grid
    139 redis
    134 gpadmin
    131 nexus
    128 developer
    123 lenovo
    121 vnc
    116 abc
    113 informix
    110 webadmin
    110 temp
    110 client
    110 admin1
    106 work
    106 elasticsearch
    105 user3
    105 default
    105 adm
    104 install
    101 node
    100 ansible
     99 bin
     98 upload
     98 minecraft
     98 max
     98 elastic
     96 project

================================================================================
  Invalid user - Top Target Accounts (Top 100)
================================================================================
   2899 admin
   2511 user
   2312 ubuntu
   1372 test
    691 postgres
    683 oracle
    631 deploy
    591 demo
    590 user1
    424 git
    403 ftpuser
    375 nvidia
    368 student
    346 guest
    321 mysql
    292 hadoop
    240 huawei
    234 tomcat
    230 web
    222 server
    220 zabbix
    220 jenkins
    219 www
    213 dev
    206 debian
    202 pi
    199 user2
    197 app
    195 test1
    190 ftp
    190 dell
    186 apache
    177 nagios
    175 odoo
    173 vagrant
    169 centos
    163 support
    162 weblogic
    157 username
    152 administrator
    149 es
    147 testuser
    144 docker
    142 webmaster
    141 grid
    139 test2
    139 redis
    134 gpadmin
    131 nginx
    131 nexus
    130 samba
    130 prueba
    128 public
    126 teamspeak
    126 kafka
    123 lenovo
    121 vnc
    121 system
    120 a
    112 developer
    110 webadmin
    106 work
    106 elasticsearch
    105 user3
    101 Admin
     98 max
     98 elastic
     97 informix
     96 project
     96 inspur
     94 temp
     94 spark
     94 client
     93 devuser
     92 vpn
     92 ubnt
     91 debug
     90 rabbitmq
     89 adm
     88 worker
     88 linux
     88 infra
     87 tom
     87 share
     87 sftp
     86 openlava
     85 node
     85 ai
     84 ansible
     84 adminuser
     84 abc
     82 upload
     82 minecraft
     82 elk
     81 steam
     80 hbase
     80 cassandra
     79 ts3
     78 admin1
     77 test3

================================================================================
  Failed password - Top Source IPs (Top 100)
================================================================================
 211710 192.168.1.12
 108446 172.16.1.1
      4 192.168.1.110
      2 192.168.1.128

================================================================================
  Target Accounts Attacked by Top Aggressive IPs
================================================================================
[+] Investigating Targeted Accounts from IP: [192.168.1.12]
--------------------------------------------------
  16415   Account: [root]
   1371   Account: [user] (Invalid/Non-existent)
    997   Account: [admin] (Invalid/Non-existent)
    882   Account: [ubuntu] (Invalid/Non-existent)
    735   Account: [test] (Invalid/Non-existent)
    495   Account: [demo] (Invalid/Non-existent)
    480   Account: [deploy] (Invalid/Non-existent)
    403   Account: [user1] (Invalid/Non-existent)
    375   Account: [oracle] (Invalid/Non-existent)
    342   Account: [student] (Invalid/Non-existent)

[+] Investigating Targeted Accounts from IP: [172.16.1.1]
--------------------------------------------------
  61854   Account: [root]
   6334   Account: [admin] (Invalid/Non-existent)
   2692   Account: [user] (Invalid/Non-existent)
   2174   Account: [ubuntu] (Invalid/Non-existent)
   1773   Account: [test] (Invalid/Non-existent)
    888   Account: [ftpuser] (Invalid/Non-existent)
    887   Account: [postgres] (Invalid/Non-existent)
    628   Account: [oracle] (Invalid/Non-existent)
    561   Account: [pi] (Invalid/Non-existent)
    475   Account: [user1] (Invalid/Non-existent)

================================================================================
  Hourly Distribution of Attacks (00:00 - 23:59)
================================================================================
  19549 20
  19587 18
  20121 15
  20204 19
  20518 08
  20662 23
  20789 21
  20933 00
  20976 09
  21235 03
  21643 06
  21702 01
  21862 14
  22061 17
  22535 07
  22733 05
  22985 02
  23166 22
  23367 04
  23631 10
  24666 16
  27509 11
  29727 12
  30238 13

================================================================================
  Daily Distribution of Attacks (Top Timeline)
================================================================================
 224888 /var/log/auth.log.3.gz:May 21
 191226 /var/log/auth.log.3.gz:May 20
  17732 /var/log/auth.log.4.gz:May 15
  16840 /var/log/auth.log.3.gz:May 17
  16257 /var/log/auth.log.4.gz:May 16
  10245 /var/log/auth.log.3.gz:May 18
   8879 /var/log/auth.log.1:Jun 1
   6617 /var/log/auth.log.1:May 31
   6471 /var/log/auth.log.4.gz:May 14
   4870 /var/log/auth.log.3.gz:May 19
   4721 /var/log/auth.log.1:Jun 4
   3338 /var/log/auth.log.4.gz:May 13
   3011 /var/log/auth.log.4.gz:May 10
   2952 /var/log/auth.log.2.gz:May 27
   2854 /var/log/auth.log.1:Jun 3
   2838 /var/log/auth.log.2.gz:May 25
   2814 /var/log/auth.log.4.gz:May 11
   2658 /var/log/auth.log.4.gz:May 12
   2281 /var/log/auth.log.2.gz:May 24
   2253 /var/log/auth.log.1:Jun 2
   2252 /var/log/auth.log.3.gz:May 23
   2248 /var/log/auth.log.2.gz:May 30
   2192 /var/log/auth.log.2.gz:May 29
   1786 /var/log/auth.log.3.gz:May 22
    159 /var/log/auth.log.2.gz:May 28
     11 /var/log/auth.log.2.gz:May 26
      4 /var/log/auth.log:Jun 10
      2 /var/log/auth.log.1:Jun 5

================================================================================
  Successful Logins Audit (Accepted Connections Timeline)
================================================================================
/var/log/auth.log:Jun 11 11:49:12 - User: [rudy] | From IP: [192.168.1.46]
/var/log/auth.log:Jun 11 11:44:27 - User: [rudy] | From IP: [192.168.1.46]
/var/log/auth.log:Jun 11 11:33:58 - User: [rudy] | From IP: [10.6.1.180]
/var/log/auth.log:Jun 11 10:24:52 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 11 07:22:36 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 11 06:52:58 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 11 03:09:53 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 17:14:52 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 17:13:59 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 17:05:56 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 13:03:26 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 12:33:44 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 12:27:14 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 12:18:58 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 12:16:53 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 09:41:27 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 09:39:46 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 07:56:03 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 06:23:32 - User: [rudy] | From IP: [192.168.1.110]
/var/log/auth.log:Jun 10 06:18:58 - User: [rudy] | From IP: [10.6.1.133]
/var/log/auth.log:Jun 10 06:18:58 - User: [rudy] | From IP: [10.6.1.133]
/var/log/auth.log.4.gz:May 12 14:04:43 - User: [peter] | From IP: [172.16.1.1]
/var/log/auth.log.4.gz:May 12 13:32:35 - User: [peter] | From IP: [172.16.1.1]
/var/log/auth.log.4.gz:May 12 13:31:57 - User: [peter] | From IP: [172.16.1.1]
/var/log/auth.log.4.gz:May 10 10:40:49 - User: [peter] | From IP: [172.16.1.1]
/var/log/auth.log.3.gz:May 20 18:32:20 - User: [tony] | From IP: [192.168.1.12]
/var/log/auth.log.3.gz:May 20 12:21:00 - User: [peter] | From IP: [172.16.1.1]
/var/log/auth.log.3.gz:May 20 12:19:51 - User: [peter] | From IP: [172.16.1.1]
/var/log/auth.log.3.gz:May 19 21:03:14 - User: [peter] | From IP: [172.16.1.1]
/var/log/auth.log.1:Jun 5 06:04:17 - User: [rudy] | From IP: [10.6.1.133]
/var/log/auth.log.1:Jun 5 06:04:16 - User: [rudy] | From IP: [10.6.1.133]
/var/log/auth.log.1:Jun 5 06:03:22 - User: [rudy] | From IP: [192.168.1.128]
/var/log/auth.log.1:Jun 5 06:03:21 - User: [rudy] | From IP: [192.168.1.128]

================================================================================
  Sudo Privilege Escalation Audit (Activity Log)
================================================================================
/var/log/auth.log:Jun 9 08:44:58 - rudy : TTY=tty1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/sbin/ufw status
/var/log/auth.log:Jun 9 08:44:58 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 9 08:25:37 - rudy : TTY=tty1 ; PWD=/home/rudy ; USER=root ; COMMAND=/bin/bash
/var/log/auth.log:Jun 9 08:25:37 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 10:25:24 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 11 10:25:24 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 08:08:35 - rudy : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 11 08:08:35 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 06:53:22 - root : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/find /home/peter/.ssh/rc /var/tmp/.font-cache-11d9e9/ /tmp/.mozilla-94aa59/ /tmp/tmpgexexufh/ /tmp/.libc.so.6 /tmp/.report-starting.lock /dev/shm/.gconf-985c40/ /dev/shm/.libpthread.so.0 /home/peter/.gstreamer-d80bac/ /home/peter/.mesa-673f8d/ /home/peter/.config/.gtk-bookmarks /home/peter/.cache/.libglib-2.0.so.0 /home/peter/.cache/.libsystem /home/peter/.config/.javago /home/peter/.config/.libdbus-1.so.3 /home/peter/.config/.libsystem /home/tony/.javago -maxdepth 0 -printf %T+ \\tMtime\\t%p\\n%C+ \\tCtime\\t%p\\n
/var/log/auth.log:Jun 11 06:53:22 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 06:53:13 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 11 06:53:13 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 03:16:31 - root : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/tail -f /var/log/syslog
/var/log/auth.log:Jun 11 03:16:31 - root : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/tail -f /var/log/auth.log /dev/fd/63
/var/log/auth.log:Jun 11 03:16:31 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 03:16:31 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 03:16:10 - root : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/tail -f /var/log/syslog
/var/log/auth.log:Jun 11 03:16:10 - root : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/tail -f /var/log/auth.log /dev/fd/63
/var/log/auth.log:Jun 11 03:16:10 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 03:16:10 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 03:10:35 - rudy : TTY=pts/3 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 11 03:10:35 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 03:10:27 - rudy : TTY=pts/2 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 11 03:10:27 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 03:10:20 - rudy : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 11 03:10:20 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 11 03:10:13 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 11 03:10:13 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 16:40:24 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 10 16:40:24 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 15:57:44 - rudy : TTY=pts/2 ; PWD=/home/tony/bin ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 10 15:57:44 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 13:03:42 - rudy : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 10 13:03:42 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 12:20:52 - root : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/dpkg -P binutils
/var/log/auth.log:Jun 10 12:20:52 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 12:19:13 - rudy : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 10 12:19:13 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 12:18:13 - root : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/dpkg -i --force-depends ./binutils_2.34-6ubuntu1.11_amd64.deb
/var/log/auth.log:Jun 10 12:18:13 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 09:41:35 - rudy : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 10 09:41:35 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 07:56:55 - rudy : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 10 07:56:55 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:50:38 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/cat /home/peter/.bash_history
/var/log/auth.log:Jun 10 06:50:38 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:50:22 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/grep Accepted /var/log/auth.log
/var/log/auth.log:Jun 10 06:50:22 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:45:11 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/od -An -c /var/tmp/.font-cache-11d9e9/.javago
/var/log/auth.log:Jun 10 06:45:11 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:44:48 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:44:47 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/od -An -c /var/tmp/.font-cache-11d9e9/.javago
/var/log/auth.log:Jun 10 06:43:02 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/od -An -c /var/tmp/.font-cache-11d9e9/.javago
/var/log/auth.log:Jun 10 06:43:02 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:41:37 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/ls -la /var/tmp/.font-cache-11d9e9/
/var/log/auth.log:Jun 10 06:41:37 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:39:25 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/crontab -u peter -l
/var/log/auth.log:Jun 10 06:39:25 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:38:43 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/grep -i connect /var/log/auth.log
/var/log/auth.log:Jun 10 06:38:43 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:38:31 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/grep -i connect /var/log/auth.log
/var/log/auth.log:Jun 10 06:38:31 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:35:14 - rudy : TTY=pts/0 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/ss -tupan
/var/log/auth.log:Jun 10 06:35:14 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:23:41 - rudy : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/bash
/var/log/auth.log:Jun 10 06:23:41 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:18:35 - rudy : TTY=tty1 ; PWD=/etc/netplan ; USER=root ; COMMAND=/usr/sbin/netplan try
/var/log/auth.log:Jun 10 06:18:35 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log:Jun 10 06:17:19 - rudy : TTY=tty1 ; PWD=/etc/netplan ; USER=root ; COMMAND=/usr/bin/vim 00-installer-config.yaml
/var/log/auth.log:Jun 10 06:17:19 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log.1:Jun 5 06:45:56 - peter : user NOT in sudoers ; TTY=unknown ; PWD=/home/peter ; USER=root ; COMMAND=/usr/sbin/chpasswd
/var/log/auth.log.1:Jun 5 06:43:34 - rudy : TTY=pts/4 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/crontab -u peter -l
/var/log/auth.log.1:Jun 5 06:43:34 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)
/var/log/auth.log.1:Jun 5 06:03:41 - rudy : TTY=pts/1 ; PWD=/home/rudy ; USER=root ; COMMAND=/usr/bin/su
/var/log/auth.log.1:Jun 5 06:03:41 - pam_unix(sudo:session): session opened for user root by rudy(uid=0)

================================================================================
  Current Fail2ban Defense Status
================================================================================
Fail2ban command not found or not running.
```
