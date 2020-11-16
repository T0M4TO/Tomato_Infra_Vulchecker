#!/bin/sh
rm -rf Copied_Files
mkdir Copied_Files
cp /etc/login.defs Copied_Files/ 2>/dev/null
cp /etc/inetd.conf Copied_Files/ 2>/dev/null || cp -r /etc/xinetd.d/ Copied_Files/ 2>/dev/null
cp /etc/mail/sendmail.cf Copied_Files/ 2>/dev/null
(cp /etc/csh.login Copied_Files/ 2>/dev/null || cp /etc/csh.cshrc Copied_Files/ 2>/dev/null) || (cp /etc/profile 2>/dev/null || cp /etc/.profile 2>/dev/null)
cp /etc/exports Copied_Files/ 2>/dev/null
cp /etc/passwd Copied_Files/ 2>/dev/null
cp /etc/group Copied_Files/ 2>/dev/null
cp /etc/motd Copied_Files/ 2>/dev/null
cp /etc/issue.net Copied_Files/ 2>/dev/null
cp /etc/vsftpd/vsftpd.conf Copied_Files/ 2>/dev/null || cp /etc/vsftpd.conf Copied_Files/ 2>/dev/null
cp /etc/named.conf Copied_Files/ 2>/dev/null
cp /etc/pam.d/system-auth Copied_Files/ 2>/dev/null
cp /etc/pam.d/password-auth Copied_Files/ 2>/dev/null
cp /etc/securetty Copied_Files/ 2>/dev/null
cp /etc/pam.d/login Copied_Files/ 2>/dev/null
cp /etc/security/pwquality.conf Copied_Files/ 2>/dev/null 
cp /etc/rsyslog.conf Copied_Files/ 2>/dev/null
cp /var/log/wtmp Copied_Files/ 2>/dev/null
cp /var/log/sulog Copied_Files/ 2>/dev/null
cp /etc/snmp/snmpd.conf Copied_Files/ 2>/dev/null
cp /etc/pam.d/su Copied_Files/ 2>/dev/null
cp /usr/bin/su Copied_Files/ 2>/dev/null

mkdir collect_files
echo $PATH > collect_files/5
find / -nouser 2>/dev/null > result_files/6
find / -nogroup 2>/dev/null >> result_files/6

