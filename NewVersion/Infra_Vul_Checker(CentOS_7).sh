#!/bin/sh
rm -rf BackData 2>/dev/null
mkdir BackData
mkdir BackData/Copied_Files
cp /etc/login.defs BackData/Copied_Files/ 2>/dev/null
cp /etc/inetd.conf BackData/Copied_Files/ 2>/dev/null || cp -r /etc/xinetd.d/ BackData/Copied_Files/ 2>/dev/null
cp /etc/mail/sendmail.cf BackData/Copied_Files/ 2>/dev/null
(cp /etc/csh.login BackData/Copied_Files/ 2>/dev/null || cp /etc/csh.cshrc BackData/Copied_Files/ 2>/dev/null) || (cp /etc/profile BackData/Copied_Files 2>/dev/null || cp /etc/.profile BackData/Copied_Files 2>/dev/null)
cp /etc/exports BackData/Copied_Files/ 2>/dev/null
cp /etc/passwd BackData/Copied_Files/ 2>/dev/null
cp /etc/group BackData/Copied_Files/ 2>/dev/null
cp /etc/motd BackData/Copied_Files/ 2>/dev/null
cp /etc/issue.net BackData/Copied_Files/ 2>/dev/null
cp /etc/vsftpd/vsftpd.conf BackData/Copied_Files/ 2>/dev/null || cp /etc/vsftpd.conf BackData/Copied_Files/ 2>/dev/null
cp /etc/named.conf BackData/Copied_Files/ 2>/dev/null
cp /etc/pam.d/system-auth BackData/Copied_Files/ 2>/dev/null
cp /etc/pam.d/password-auth BackData/Copied_Files/ 2>/dev/null
cp /etc/securetty BackData/Copied_Files/ 2>/dev/null
cp /etc/pam.d/login BackData/Copied_Files/ 2>/dev/null
cp /etc/security/pwquality.conf BackData/Copied_Files/ 2>/dev/null 
cp /etc/rsyslog.conf BackData/Copied_Files/ 2>/dev/null
cp /var/log/wtmp BackData/Copied_Files/ 2>/dev/null
cp /var/log/sulog BackData/Copied_Files/ 2>/dev/null
cp /etc/snmp/snmpd.conf BackData/Copied_Files/ 2>/dev/null
cp /etc/pam.d/su BackData/Copied_Files/ 2>/dev/null
cp /usr/bin/su BackData/Copied_Files/ 2>/dev/null

echo $PATH > BackData/5
echo "No User Files" > BackData/6
find / -nouser -exec ls -al {} \; 2>/dev/null >> BackData/6
echo "" >> BackData/6
echo "No Group Files" >> BackData/6
find / -nogroup -exec ls -al {} \; 2>/dev/null >> BackData/6
find / -type f \( -perm -4000 -o -perm 2000 \) -exec ls -al {} \; 2>/dev/null  > BackData/13
find / -type f \( -name ".*rc" -o -name ".*profile" -o -name ".*login" \) -exec ls -l {} \; 2>/dev/null > BackData/14
find / -type f -perm -2 -exec ls -l {} \; 2>/dev/null > BackData/15

ls -l /etc/passwd /etc/shadow /etc/hosts /etc/inetd.conf /etc/xinetd.conf /etc/xinetd.d /etc/syslog.conf /etc/rsyslog.conf /etc/services 
