#!/bin/sh

# Make sure only root can run our script
if [ "$EUID" != 0 ]; then
	echo "You have to run this script in root"
	exit
	fi
# Make Result Directory
resultdir=`date +%Y%m%d_%H%M%S`
resultdir=Result_$resultdir
mkdir $resultdir
echo "No","SubNo","Result","Reason" > $resultdir/result.csv;
# Script Start
echo "########################################################################";
echo "#                      Infra Vulerability Checker                      #";
echo "#                                               Made By : Tomato       #";
echo "########################################################################";
echo "";
echo "1. 계정관리";
echo "------------------------------------------------------------------------";
echo "1.1 root 계정 원격 접속 제한";
tmp=`grep -i pts /etc/securetty`;
if [ "$tmp" == "" ]; then
	tmp=`cat /etc/pam.d/login | awk '{if($1=="auth" && $2=="required" && ($3=="pam_securetty.so" || $3=="/lib/security/pam_securetty.so")){print $0}}' | grep -v "#"`;
	if [ "$tmp" != "" ]; then
		echo "양호";
		result=1;
		reason="-";
		echo "$tmp";
	else
		echo "취약(login 파일에 auth required pam_securetty.so가 설정되어 있지 않음)";
		result=2;
		reason="(login 파일에 auth required pam_securetty.so가 설정되어 있지 않
     음)"
		tmp=`cat /etc/pam.d/login`;
		echo "$tmp";
	fi
else
	echo "취약(/etc/securetty 파일에 pts관련 설정이 존재함)";
	result=2;
	reason="(/etc/securetty 파일에 pts관련 설정이 존재함)"
	echo "$tmp";
fi
echo 1,1,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.2 패스워드 복잡성 설정";
tmp_cnt=0;
tmp_array=("lcredit" "dcredit" "ocredit");
for chk in ${tmp_array[@]}; do
	tmp=`grep -i $chk /etc/security/pwquality.conf 2>/dev/null | grep -v "#" | grep "\-1"`;
	if [ "$tmp" != "" ]; then
		tmp_cnt=`expr $tmp_cnt + 1`;
	fi
done
tmp=`grep -i minlen /etc/security/pwquality.conf | grep -v "#"`;
if [ "$tmp" != "" ]; then
	tmp=`grep -i minlen /etc/security/pwquality.conf | grep -c "[0-7]"`;
	if [ $tmp == 0 ]; then
		tmp_cnt=`expr $tmp_cnt + 1`;
	fi
fi
if [ $tmp_cnt == 4 ]; then
	echo "양호";
	result=1;
	reason="-";
else
	echo "취약(패스워드 복잡성이 부적절하게 설정되어 있음 (기준 : minlen=8 다른 속성은 -1))";
	result=2;
	reason="(패스워드 복잡성이 부적절하게 설정되어 있음 (기준 : minlen=8 다른 >     속성은 -1))";
fi
tmp=`cat /etc/security/pwquality.conf | grep -i "lcredit\|dcredit\|ocredit\|minlen"`;
echo "$tmp";
echo 1,2,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.3 계정 잠금 임계값 설정";
tmp=`grep -i tally /etc/pam.d/system-auth 2>/dev/null | grep -v "#" | grep -i "required" | grep -i "auth" | grep -i "deny = [1-5]\|deny= [1-5]\|deny =[1-5]\|deny=[1-5]"`;
if [ "$tmp" != "" ]; then
	echo "양호";
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(system-auth파일에 tally를 통한 deny설정이 부적절하게 설정되었거나 없음)";
	result=2;
	reason="(system-auth파일에 tally를 통한 deny설정이 부적절하게 설정되었거나      없음)";
	tmp=`cat /etc/pam.d/system-auth`;
	echo "$tmp";
fi
echo 1,3,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.4 패스워드 파일 보호";
tmp=`ls -al /etc/shadow 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`cut -f 2 -d : /etc/passwd | grep -v -i "x"`;
	if [ "$tmp" == "" ]; then
		echo "양호";
		result=1;
		reason="-";
		tmp=`cat /etc/passwd`;
		echo "$tmp";
	else
		echo "취약(패스워드 파일이 보호되고 있지 않음)";
		result=2;
		reason="(패스워드 파일이 보호되고 있지 않음)";
		tmp=`cat /etc/passwd`;
		echo "$tmp";
	fi
else
	echo "취약(shadow 파일이 존재하지 않음)";
	result=2;
	reason="(shadow 파일이 존재하지 않음)";
fi
echo 1,4,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2. 파일 및 디렉토리 관리";
echo "------------------------------------------------------------------------";
echo "2.1 root홈, 패스 디렉터리 권한 및 패스 설정 ";
tmp=`echo $PATH | grep "::\|\.:"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	result=1;
	reason="-";
	tmp=`echo $PATH`;
	echo "$tmp";
else
	echo "취약(PATH 환경변수에 . 또는 :: 가 삽입되어 있음)";
	result=2;
	reason="(PATH 환경변수에 . 또는 :: 가 삽입되어 있음)";
	echo "$tmp";
fi
echo 2,1,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.2 파일 및 디렉터리 소유자 설정";
tmp=`find / -nouser -print 2>/dev/null`;
if [ "$tmp" == "" ]; then
	tmp=`find / -nogroup -print 2>/dev/null`;
	if [ "$tmp" == "" ]; then
		echo "양호(소유자 또는 그룹이 없는 파일 및 디렉터리 없음)";
		result=1;
		reason="(소유자 또는 그룹이 없는 파일 및 디렉터리 없음)";
	else
		echo "취약(그룹이 없는 파일 또는 디렉터리 있음)";
		result=2;
		reason="(그룹이 없는 파일 또는 디렉터리 있음)";
		echo "$tmp";
	fi
else
	echo "취약(소유자 또는 그룹이 없는 파일 또는 디렉터리 있음)";
	result=2;
	reason="(소유자 또는 그룹이 없는 파일 또는 디렉터리 있음)";
	echo "$tmp";
fi
echo 2,2,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.3 /etc/passwd 파일 소유자 및 권한 설정";
tmp=`ls -l /etc/passwd 2>/dev/null | awk '{print $1 $3}' | grep -i "root" | grep -i "\-rw\-r\-\-r\-\-\|rw\-r\-\-\-\-\-\|rw\-\-\-\-\-\-\-\|r\-\-r\-\-r\-\-\|r\-\-r\-\-\-\-\-\|r\-\-\-\-\-\-\-\-\|\-\-\-\-\-\-\-\-\-"`;
if [ "$tmp" != "" ]; then
	echo "양호";
	result=1;
	reason="-";
	echo `ls -l /etc/passwd`;
else
	echo "취약(passwd파일의 권한 또는 소유자가 부적절함)";
	result=2;
	reason="(passwd파일의 권한 또는 소유자가 부적절함)";
	tmp=`ls -l /etc/passwd | awk '{print $0}'`;
	echo "$tmp";
fi
echo 2,3,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.4 /etc/shadow 파일 소유자 및 권한 설정";
tmp=`ls -l /etc/shadow 2>/dev/null | awk '{print $1 $3}' | grep -i "root" | grep -i "r\-\-\-\-\-\-\-\-\|\-\-\-\-\-\-\-\-\-"`;
if [ "$tmp" != "" ]; then
	echo "양호";
	result=1;
	reason="-";
else
	echo "취약(shadow파일의 권한 또는 소유자가 부적절함)";
	result=2;
	reason="(shadow파일의 권한 또는 소유자가 부적절함)";
fi	
echo `ls -l /etc/shadow | awk '{print $0}'`;
echo 2,4,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.5 /etc/hosts 파일 소유자 및 권한 설정";
tmp=`ls -l /etc/hosts 2>/dev/null | awk '{print $1 $3}' | grep -i "root" | grep -i "rw\-\-\-\-\-\-\-\|r\-\-\-\-\-\-\-\-\|\-\-\-\-\-\-\-\-\-"`;
if [ "$tmp" != "" ]; then
	echo "양호";
	result=1;
	reason="-";
else
	echo "취약(hosts파일의 권한 또는 소유자가 부적절함)";
	result=2;
	reason="(hosts파일의 권한 또는 소유자가 부적절함)";
fi
echo `ls -l /etc/hosts | awk '{print $0}'`;
echo 2,5,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.6 /etc/(x)inetd.conf 파일 소유자 및 권한 설정";
tmp=`ls /etc/inetd.conf 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`ls -l /etc/inetd.conf | awk '{if($3!="root" || $1!="rw-------." || $1!="r--------." || $1!="---------"){print $0}}'`;
	if [ "$tmp" == "" ]; then
		echo "양호";
		result=1;
		reason="-";
		echo `ls /etc/inetd.conf 2>/dev/null`;
	else
		echo "취약(inetd.conf 파일의 권한 또는 소유자가 부적절함)";
		result=2;
		reason="(inetd.conf 파일의 권한 또는 소유자가 부적절함)";
		echo "$tmp";
	fi
else
	tmp=`ls -al /etc/xinetd.conf 2>/dev/null /etc/xinetd.d/* 2>/dev/null`;
	if [ "$tmp" == "" ];then
		echo "N/A";
		result=3;
		echo "점검에 필요한 파일이 서버 내 존재하지 않음";
		reason="점검에 필요한 파일이 서버 내 존재하지 않음";
	else
		tmp=`ls -al /etc/xinetd.conf /etc/xinetd.d/* 2>/dev/null | awk '{if($3!="root" || $1!="rw-------." || $1!="r--------." || $1!="---------"){print $0}}'`;
		if [ "$tmp" == "" ]; then
			echo "양호";
			result=1;
			reason="-";
			echo `ls -al /etc/xinetd.conf /etc/xinetd.d/* 2>/dev/null`;
		else
			echo "취약(xinetd.conf, xinetd.d 밑 하위 파일들의 권한 또는 소유자가 부적절함)";
			result=2;
			reason="(xinetd.conf\/xinetd.d 밑 하위 파일들의 권한 또는 소유자가      부적절함)";
			echo "$tmp";
		fi
	fi
fi
echo 2,6,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.7 /etc/syslog.conf 파일 소유자 및 권한 설정";
tmp=`ls /etc/syslog.conf 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`ls -l /etc/syslog.conf | awk '{print $1 $3}' | grep -i "root\|bin\|sys" | grep -i "\-rw\-r\-\-r\-\-\|rw\-r\-\-\-\-\-\|rw\-\-\-\-\-\-\-\|r\-\-r\-\-r\-\-\|r\-\-r\-\-\-\-\-\|r\-\-\-\-\-\-\-\-\|\-\-\-\-\-\-\-\-\-"`;
	if [ "$tmp" != "" ]; then
		echo "양호";
		result=1;
		reason="-";
	else
		echo "취약(syslog.conf파일의 권한 또는 소유자가 부적절함)";
		result=2;
		reason="(syslog.conf파일의 권한 또는 소유자가 부적절함)";
	fi
	echo `ls -l /etc/syslog.conf | awk '{print $0}'`;
else
	tmp=`ls -al /etc/rsyslog.conf 2>/dev/null`;
	if [ "$tmp" == "" ];then
		echo "N/A";
		result=3;
		echo "점검이 필요한 파일이 서버 내 존재하지 않음";
		reason="점검이 필요한 파일이 서버 내 존재하지 않음";
	else
		tmp=`ls -l /etc/rsyslog.conf | awk '{print $1 $3}' | grep -i "root\|bin\|sys" | grep -i "\-rw\-r\-\-r\-\-\|rw\-r\-\-\-\-\-\|rw\-\-\-\-\-\-\-\|r\-\-r\-\-r\-\-\|r\-\-r\-\-\-\-\-\|r\-\-\-\-\-\-\-\-\|\-\-\-\-\-\-\-\-\-"`;
		if [ "$tmp" != "" ]; then
			echo "양호";
			result=1;
			reason="-";
		else
			echo "취약(rsyslog.conf파일의 권한 또는 소유자가 부적절함)";
			result=2;
			reason="(rsyslog.conf파일의 권한 또는 소유자가 부적절함)";
		fi
		echo `ls -l /etc/rsyslog.conf | awk '{print $0}'`;
	fi
fi
echo 2,7,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.8 /etc/services 파일 소유자 및 권한 설정";
tmp=`ls /etc/services 2>/dev/null`;
if [ "$tmp" == "" ];then
	echo "N/A";
	result=3;
	echo "점검이 필요한 파일이 서버 내 존재하지 않음";
	reason="점검이 필요한 파일이 서버 내 존재하지 않음";
else
	tmp=`ls -l /etc/services | awk '{print $1 $3}' | grep -i "root\|bin\|sys" | grep -i "\-rw\-r\-\-r\-\-\|rw\-r\-\-\-\-\-\|rw\-\-\-\-\-\-\-\|r\-\-r\-\-r\-\-\|r\-\-r\-\-\-\-\-\|r\-\-\-\-\-\-\-\-\|\-\-\-\-\-\-\-\-\-"`;
	if [ "$tmp" != "" ]; then
		echo "양호";
		result=1;
		reason="-";
	else
		echo "취약(services파일의 권한 또는 소유자가 부적절함)";
		result=2;
		reason="(services파일의 권한 또는 소유자가 부적절함)";
	fi
	echo `ls -l /etc/services | awk '{print $0}'`;
fi
echo 2,8,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.9 SUID, SGID, Sticky bit 설정 및 권한 설정";
echo "수동진단 필요(OS 기본파일을 확인해서 제외해야함)";
echo "";
echo "SUID가 설정되어있는 파일들";
tmp=`find / -perm -4000 2>/dev/null -exec ls -l {} \;`;
echo "$tmp";
echo ""
echo "SGID가 설정되어 있는 파일들";
tmp=`find / -perm -2000 2>/dev/null -exec ls -l {} \;`;
echo "$tmp";
result=4;
reason="수동진단 필요(OS 기본파일을 확인해서 제외해야함)";
echo 2,9,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.10 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정";
echo "수동진단 필요(passwd파일 내 홈 디렉터리 확인, 소유자가 본인 또는 root/쓰기는 소유자만인지 확인)"
tmp=`find / -name "*.*sh*profile" 2>/dev/null -exec ls -l {} \; -o -name "*.*sh*rc" 2>/dev/null -exec ls -l {} \; | awk '{print $0}'; echo ""; cat /etc/passwd`;
echo "$tmp";
result=4;
reason="(passwd파일 내 홈 디렉터리 확인 후 소유자가 본인 또는 root\/쓰기는 소유자만인지 확인)";
echo 2,10,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.11 world writable 파일 점검";
tmp=`find / -type f -perm -2 -not -path "/proc/*" -not -path "/sys/*" 2>/dev/null -exec ls -l {} \;`;
if [ "$tmp" == "" ]; then
	echo "양호(World writable 파일이 존재하지 않음)";
	result=1;
	reason="(World writable 파일이 존재하지 않음)";
else
	echo "취약(World writable 파일이 존재함)";
	result=2;
	reason="(World writable 파일이 존재함)";
	echo "$tmp";
fi
echo 2,11,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.12 /dev에 존재하지 않는 device 파일 점검";
tmp=`ls -l /dev | awk 'NR-1' | awk '{if($10==""){print $0}}'`;
safe_device_array=($(cat OS_Default_Data/centos7/centos7_default_devicefile));
for safe_device in ${safe_device_array[@]}; do
	tmp=`echo "$tmp" | awk '{if($9!="'$safe_device'"){print $0}}'`;
done
if [ "$tmp" == "" ]; then
	echo "양호(major minor 번호가 없는 device 없음)";
	result=1;
	reason="(major minor 번호가 없는 device 없음)";
	tmp=`ls -l /dev 2>/dev/null`;
	echo "$tmp";
else
	echo "취약(Device  파일이 맞는지 확인 필요, OS 기본은 양호)";
	result=2;
	reason="(Device  파일이 맞는지 확인 필요\/ OS 기본은 양호)";
	echo "$tmp";
fi
echo 2,12,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.13 $HOME/.rhosts, hosts.equiv 사용 금지";
tmp=`rpm -qa | grep -i rsh`;
if [ "$tmp" != "" ]; then
	echo "양호(해당 서비스를 사용하고 있지 않음)";
	result=1
	reason="(해당 서비스를 사용하고 있지 않음)";
else
	result=1
	tmp=`ls -l /etc/hosts.equiv 2>/dev/null`;
	if [ "$tmp" != "" ]; then
		tmp=`ls -l /etc/hosts.equiv 2>/dev/null | awk '{if($3=="root"){print $1}}' | grep -i "rw\-\-\-\-\-\-\-\|r\-\-\-\-\-\-\-\-\|\-\-\-\-\-\-\-\-\-"`;
		if [ "$tmp" == "" ]; then
			echo "hosts.equiv : 취약(권한 또는 소유자 설정이 취약함)";
			result=2
			reason="hosts.equiv : 취약(권한 또는 소유자 설정이 취약함)"
			tmp=`ls -al /etc/hosts.equiv 2>/dev/null`;
			echo "$tmp";
		fi
		tmp=`grep + /etc/hosts.equiv 2>/dev/null`;
		if [ "$tmp" == "" ]; then
			echo "hosts.equiv : 양호"
			tmp=`cat /etc/hosts.equiv 2>/dev/null`;
			echo `$tmp`;
		else
			echo "hosts.equiv : 취약(파일 내 + 가 존재함)";
			result=2
			reason=$reason"\/hosts.equiv : 취약(파일 내 + 가 존재함)";
			tmp=`ls -al /etc/hosts.equiv 2>/dev/null`;
			echo "$tmp";
		fi
	else
		echo "hosts.equiv : 양호(파일이 존재하지 않습니다)";
		result=1;
	fi
	echo "";
	tmp=`find / -name ".rhosts" 2>/dev/null`;
	if [ "$tmp" == "" ]; then
		echo ".rhosts : 양호(파일이 존재하지 않습니다)";
	else
		tmp=`find / -type f -name ".rhosts" 2>/dev/null -exec ls -l {} \; | awk '{if($3=="root"){print $1}}' | grep -i "rw\-\-\-\-\-\-\-\|r\-\-\-\-\-\-\-\-\|\-\-\-\-\-\-\-\-\-"`;
		if [ "$tmp" == "" ]; then
			echo ".rhosts : 취약(권한 또는 소유자 설정이 취약함)";
			result=2
			reason=$reason"\/.rhosts : 취약(권한 또는 소유자 설정이 취약함)";
			tmp=`find / -type f -name ".rhosts" 2>/dev/null -exec ls -l {} \;`;
			echo "$tmp";
		fi
		tmp=`find / -type f -name ".rhosts" | xargs grep +`;
		if [ "$tmp" == "" ]; then
			echo ".rhosts : 양호"
			tmp=`find / -type f -name ".rhosts" -exec ls -l {} \;`;
			echo "$tmp";
			echo "";
			tmp=`find / -type f -name ".rhosts" -exec cat {} \;`;
			echo "$tmp"; 
		else
			echo ".rhosts : 취약(파일 내 + 가 존재함)";
			result=2
			reason=$reason"\/.rhosts : 취약(파일 내 + 가 존재함)";
			tmp=`find / -type f -name ".rhosts" 2>/dev/null -exec ls -l {} \;`;
			echo "$tmp";
		fi
	fi
fi
echo 2,13,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.14 접속 IP 및 포트 제한";			
echo "수동 진단 필요(인터뷰 필요)";
result=4;
reason="(인터뷰 필요)";
echo 2,14,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3. 서비스 관리";
echo "------------------------------------------------------------------------";
echo "3.1 Finger 서비스 비활성화";
tmp=`ls -l /etc/inetd.conf 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`grep -i finger /etc/inetd.conf | grep "#"`
	if [ "$tmp" != "" ]; then
		echo "양호(서비스가 주석처리 되어 있음)";
		result=1;
		reason="(서비스가 주석처리 되어 있음)";
		echo "$tmp";
	else
		echo "취약(서비스가 실행되고 있음)";
		result=2;
		reason="(서비스가 실행되고 있음)";
		tmp=`grep -i finger  /etc/inetd.conf`;
		echo "$tmp";
	fi
else
	tmp=`ls -l /etc/xinetd.d/finger 2>/dev/null`;
	if [ "$tmp" != "" ]; then
		tmp=`grep -i disable /etc/xinetd.d/finger | grep -i yes`;
		if [ "$tmp" != "" ]; then
			echo "양호";
			result=1;
			reason="-";
		else
			echo "취약(disable yes설정되어 서비스가 실행되고 있음)";
			result=2;
			reason="(disable yes설정되어 서비스가 실행되고 있음)";
			tmp=`grep -i disable /etc/xinetd.d/finger`;
			echo "$tmp";
		fi
	else
		echo "양호(서비스 설치되어 있지 않음)";
		result=1;
		reason="(서비스 설치되어 있지 않음)";
	fi
fi
echo 3,1,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.2 Anonymous FTP 비활성화";			
echo "수동 진단 필요(정확히ftp로 된 계정과, Anonymous로 된 계정 없는지 확인)";
tmp=`cat /etc/passwd | grep -i -E "ftp:|anonymous"`;
echo "$tmp";
result=4;
reason="(정확히ftp로 된 계정과 Anonymous로 된 계정 없는지 확인)";
echo 3,2,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.3 r 계열 서비스 비활성화";
tmp=`ls -l /etc/inetd.conf 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`cat /etc/inetd.conf | grep -i "rlogin\|rsh\|rexec" | grep -v "#"`;
	if [ "$tmp" != "" ]; then
		echo "취약(r 계열 서비스 실행중)";
		result=2;
		reason="(r 계열 서비스 실행중)";
		echo "$tmp";
	else
		echo "양호(r 계열 서비스 실행되고 있지 않음)";
		result=1;
		reason="(r 계열 서비스 실행되고 있지 않음)";
		tmp=`cat /etc/inetd.conf`;
		echo "$tmp";
	fi
else
	tmp=`find /etc/xinetd.d -name "r*" 2>/dev/null`;
	if [ "$tmp" != "" ]; then
		tmp=`find /etc/xinetd.d -name "r*" 2>/dev/null | xargs grep -i disable | grep -v -i yes`;
		if [ "$tmp" == "" ]; then
			echo "양호(r 계열 서비스 모두 비활성화 됨)";
			result=1;
			reason="(r 계열 서비스 모두 비활성화 됨)";
		else
			echo "취약(r 계열 서비스 활성화 됨)";
			result=2;
			reason="(r 계열 서비스 활성화 됨)";
			echo "$tmp";
		fi
	else
		echo "양호(검사할 파일이 존재하지 않음)";
		result=1;
		reason="(검사할 파일이 존재하지 않음)";
	fi
fi
echo 3,3,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.4 cron 파일 소유자 및 권한 설정";			
tmp=`find / -name cron.allow 2>/dev/null -exec ls -l {} \; -o -name cron.deny -exec ls -l {} \; 2>/dev/null | awk '{print $1"\t"$3"\t"$9}' | grep -v -E "rw\-r\-\-\-\-\-.*root|rw\-\-\-\-\-\-\-.*root|r\-\-r\-\-\-\-\-.*root|r\-\-\-\-\-\-\-\-.*root|\-\-\-\-\-\-\-\-\-"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	tmp=`find / -name cron.allow 2>/dev/null -exec ls -l {} \; -o -name cron.deny -exec ls -l {} \; 2>/dev/null`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(cron 파일 소유자 또는 권한이 부적절함)";
	result=2;
	reason="(cron 파일 소유자 또는 권한이 부적절함)";
	echo "$tmp";
fi
echo 3,4,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.5 DoS 공격에 취약한 서비스 비활성화";
tmp=`ls /etc/inetd.conf 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`cat /etc/inetd.conf | grep -i "echo\|discard\|daytime\|chargen" | grep -v "#"`;
	if [ "$tmp" == "" ]; then
		echo "양호";
		tmp=`cat /etc/inetd.conf`;
		result=1;
		reason="-";
		echo "$tmp";
	else
		echo "취약(실제 사용하고 있다면 어디에 사용하는지 확인 필요)";
		result=2;
		reason="(실제 사용하고 있다면 어디에 사용하는지 확인 필요)";
		echo "$tmp";
	fi
else
	tmp=`find /etc/xinetd.d -name "echo" -o -name "discard" -o -name "daytime" -o -name "chargen"`;
	if [ "$tmp" == "" ]; then
		echo "양호(서비스 설치되어 있지 않음)";
		result=1;
		reason="(서비스 설치되어 있지 않음)";
	else
		tmp=`find /etc/xinetd.d -name "echo" -o -name "discard" -o -name "daytime" -o -name "chargen" | xargs grep -i disable | grep -v -i yes`;
		if [ "$tmp" == "" ]; then
			echo "양호";
			tmp=`find /etc/xinetd.d -name "echo" -exec cat {} \; -o -name "discard" -exec cat {} \; -o -name "daytime" -exec cat {} \; -o -name "chargen" -exec cat {} \;`;
			result=1;
			reason="-";
			echo "$tmp";  
		else
			echo "취약(실제 사용하고 있다면 어디에 사용하는지 확인 필요)";
			result=2;
			reason="(실제 사용하고 있다면 어디에 사용하는지 확인 필요)";
			echo "$tmp";
		fi
	fi
fi
echo 3,5,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.6 NFS 서비스 비활성화";
tmp=`ps -ef | grep -i "nfs\|statd\|lockd" | grep -v -i -E "grep|\[.*\]"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	tmp=`ps -ef | grep -v -i -E "grep|\[.*\]"`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(nfs 서비스 실행중으로 불필요한지 확인)";
	result=2;
	reason="(nfs 서비스 실행중으로 불필요한지 확인)";
	echo "$tmp";
fi
echo 3,6,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.7 NFS 접근 통제";
tmp=`ps -ef | grep -i "nfs\|statd\|lockd" | grep -v -i -E "grep|\[.*\]"`;
if [ "$tmp" == "" ]; then
	echo "양호(NFS 서비스 없음)";
	tmp=`ps -ef | grep -v -i -E "grep|\[.*\]"`;
	result=1;
	reason="(NFS 서비스 없음)";
	echo "$tmp";
else
	tmp=`grep \* /etc/exports 2>/dev/null`;
	if [ "$tmp" == "" ]; then
		echo "양호";
		tmp=`cat /etc/exports`;
		result=1;
		reason="-";
		echo "$tmp";
	else
		echo "취약(nfs 접근을 everyone으로 설정함)";
		result=2;
		reason="(nfs 접근을 everyone으로 설정함)";
		echo "$tmp";
	fi
fi
echo 3,7,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.8 automountd 제거";
tmp=`ps -ef | grep -i "automount\|autofs" | grep -v -i -E "grep|\[.*\]"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	tmp=`ps -ef | grep -viE "grep|\[.*\]"`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(automountd 실행중)";
	result=2;
	reason="(automountd 실행중)";
	echo "$tmp";
fi
echo 3,8,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.9 RPC 서비스 확인";
tmp=`ls /etc/inetd.conf 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`cat /etc/inetd.conf | grep -i -E "rpc\..*|sadmind|rusersd|walld|sprayd|rstatd|rexd|kcms_server|cachefsd" | grep -v "#"`;
	if [ "$tmp" == "" ]; then
		echo "양호";
		tmp=`cat /etc/inetd.conf`;
		result=1;
		reason="-";
		echo "$tmp";
	else
		echo "취약(RPC 서비스 비활성화 됨)";
		result=2;
		reason="(RPC 서비스 비활성화 됨)";
		echo "$tmp";
	fi
else
	tmp=`find /etc/xinetd.d -name "rpc.*" -o -name sadmind -o -name rusersd -o -name walld -o -name sprayd -o -name rstatd -o -name rexd -o -name kcms_server -o -name cachefsd 2>/dev/null`;
	if [ "$tmp" == "" ]; then
		echo "양호(서비스 설치되어 있지 않음)";
		result=1;
		reason="(서비스 설치되어 있지 않음)";
	else
		tmp=`find /etc/xinetd.d -name "rpc.*" -o -name sadmind -o -name rusersd -o -name walld -o -name sprayd -o -name rstatd -o -name rexd -o -name kcms_server -o -name cachefsd | xargs grep -i disable | grep -v -i yes`;
		if [ "$tmp" == "" ]; then
			echo "양호";
			tmp=`ls -l /etc/xinetd.d/`;
			result=1;
			reason="-";
			echo "$tmp";
		else
			echo "취약(RPC 서비스 동작중)";
			result=2;
			reason="(RPC 서비스 동작중)";
			echo "$tmp";
		fi
	fi
fi
echo 3,9,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.10 NIS, NIS+ 점검";
tmp=`ps -ef | egrep "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" | grep -v -i -E "grep|\[.*\]"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	tmp=`ps -ef | grep -v -i -E "grep|\[.*\]"`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(NIS+를 쓰는지 확인 필요)";
	result=2;
	reason="(NIS+를 쓰는지 확인 필요)";
	echo "$tmp";
fi
echo 3,10,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.11 tftp, talk 서비스 비활성화";
tmp=`ls -l /etc/inetd.conf 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`cat /etc/inetd.conf | grep "tftp\|talk\|ntalk" | grep -v "#"`
	if [ "$tmp" == "" ]; then
		echo "양호";
		tmp=`cat /etc/inetd.conf`;
		result=1;
		reason="-";
		echo "$tmp";
	else
		echo "취약(tftp 또는 talk서비스가 활성화됨)";
		result=2;
		reason="(tftp 또는 talk서비스가 활성화됨)";
		echo "$tmp";
	fi
else
	tmp=`find /etc/xinetd.d/ -name tftp -o -name talk -o -name ntalk 2>/dev/null`;
	if [ "$tmp" == "" ]; then
		echo "양호(서비스 설치되어 있지 않음)";
		result=1;
		reason="(서비스 설치되어 있지 않음)";
	else
		tmp=`find /etc/xinetd.d/ -name tftp -o -name talk -o -name ntalk 2>/dev/null | xargs grep disable | grep -v -i yes`;
		if [ "$tmp" == "" ]; then
			echo "양호";
			tmp=`find /etc/xinetd.d/ -name tftp -exec cat {} \; -o -name talk -exec cat {} \; -o -name ntalk -exec cat {} \;`;
			result=1;
			reason="-";
			echo "$tmp";
		else
			echo "취약(tftp talk 서비스 활성화 됨)";
			result=2;
			reason="(tftp talk 서비스 활성화 됨)";
			echo "$tmp";
		fi
	fi
fi
echo 3,11,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.12 Sendmail 버전 점검";
tmp=`rpm -qa sendmail* 2>/dev/null`;
if [ "$tmp" == "" ]; then
	echo "양호(서비스 설치되어 있지 않음)";
	result=1;
	reason="(서비스 설치되어 있지 않음)";
else
	echo "수동진단 필요(http://www.sendmail.org에서 최신 버전 확인 후 진단)";
	result=4;
	reason="(http://www.sendmail.org에서 최신 버전 확인 후 진단)";
	echo "$tmp";
fi
echo 3,12,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.13 스팸 메일 릴레이 제한";
tmp=`rpm -qa sendmail* 2>/dev/null`;
if [ "$tmp" == "" ]; then
	echo "양호(서비스 설치되어 있지 않음)";
	result=1
	reason="(서비스 설치되어 있지 않음)";
else
	tmp=`cat /etc/mail/sendmail.cf | grep "R$\*" | grep "Relaying denied"`;
	if [ "$tmp" != "" ]; then
		tmp=`ls -l /etc/mail/access 2>/dev/null`;
		if [ "$tmp" != "" ]; then
			echo "수동진단 필요(access 파일 내 정보를 보고 제한되어있는지 확인)";
			tmp=`cat /etc/mail/access`;
			result=4;
			reason="(access 파일 내 정보를 보고 제한되어있는지 확인)";
			echo "$tmp";
		else
			echo "취약(access 파일이 없어 릴레이가 제한되지 않음)";
			result=2;
			reason="(access 파일이 없어 릴레이가 제한되지 않음)";
		fi
	else
		echo "취약(Relaying denied 설정이 없음)";
		result=2;
		reason="(Relaying denied 설정이 없음)";
	fi
fi
echo 3,13,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.14 일반사용자의 Sendmail 실행 방지";
tmp=`rpm -qa sendmail* 2>/dev/null`;
if [ "$tmp" == "" ]; then
	echo "양호(서비스 설치되어 있지 않음)";
	result=1;
	reason="(서비스 설치되어 있지 않음)";
else
	tmp=`grep PrivacyOptions /etc/mail/sendmail.cf | grep -v "#" | grep restrictqrun`;
	if [ "$tmp" != "" ]; then
		echo "양호";
		result=1;
		reason="-";
		echo "$tmp";
	else
		echo "취약(restrictqrun 설정이 되어있지 않음)";
		tmp=`grep PrivacyOptions /etc/mail/sendmail.cf`;
		result=2;
		reason="(restrictqrun 설정이 되어있지 않음)";
		echo "$tmp";
	fi
fi
echo 3,14,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.15 DNS 보안 버전 패치";
tmp=`ps -ef | grep named | grep -v "grep"`;
if [ "$tmp" == "" ]; then
	echo "양호(서비스가 비활성화 됨)";
	tmp=`ps -ef | grep -v -i -E "grep|\[.*\]"`;
	result=1;
	reason="(서비스가 비활성화 됨)";
	echo "$tmp";
else
	tmp=`named -v`;
	echo "수동진단 필요(bind version이 보안 패치된 버전인지 확인 필요)";
	result=4;
	reason="(bind version이 보안 패치된 버전인지 확인 필요)";
	echo "$tmp";
fi
echo 3,15,$result,$reason >> $resultdir/result.csv;
echo"";
echo "------------------------------------------------------------------------";
echo "3.16 DNS Zone Transfer 설정";
tmp=`ps -ef | grep named | grep -v -i -E "grep|\[.*\]"`;
if [ "$tmp" == "" ]; then
	echo "양호(서비스가 비활성화 됨)";
	tmp=`ps -ef | grep -v -i -E "grep|\[.*\]"`;
	result=1;
	reason="(서비스가 비활성화 됨)";
	echo "$tmp";
else
	tmp=`find /etc -name named.conf -exec grep allow-transfer {} \; -o -name named.boot -exec grep xfrnets {} \;`;
	if [ "$tmp" != "" ]; then
		echo "양호";
		result=1;
		reason="-";
		echo "$tmp";
	else
		echo "취약(Zone Transfer 설정이 되어있지 않음)";
		tmp=`find /etc/ -name named.conf -exec cat {} \; -o -name named.conf -exec cat {} \;`;
		result=2;
		reason="(Zone Transfer 설정이 되어있지 않음)";
		echo "$tmp";
	fi
fi
echo 3,16,$result,$reason >> $resultdir/result.csv;
echo"";
echo "------------------------------------------------------------------------";
echo "4. 패치 관리";
echo "------------------------------------------------------------------------";
echo "4.1 최신 보안패치 및 벤더 권고사항 적용";
echo "수동진단 필요(인터뷰 필요)";
tmp=`grep . /etc/*-release | awk '!x[$0]++ {print $0}'`;
echo "$tmp";
result=4;
reason="(인터뷰 필요)";
echo 4,1,$result,$reason >> $resultdir/result.csv;
echo"";
echo "------------------------------------------------------------------------";
echo "5. 패치 관리";
echo "------------------------------------------------------------------------";
echo "5.1 로그의 정기적 검토 및 보고";
echo "수동진단 필요(인터뷰 필요)";
result=4;
reason="(인터뷰 필요)";
echo 5,1,$result,$reason >> $resultdir/result.csv;
echo"";
echo "------------------------------------------------------------------------";
echo "1. 계정관리";
echo "------------------------------------------------------------------------";
echo "1.5 root 이외의 UID가 '0' 금지";
tmp=`grep -v -i root /etc/passwd | cut -f 3 -d : | grep -x "0"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	tmp=`cat /etc/passwd`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(UID가 0인 일반계정이 있음)";
	tmp=`cat /etc/passwd`;
	result=2;
	reason="(UID가 0인 일반계정이 있음)";
	echo "$tmp";
fi
echo 1,5,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.6 root 계정 su 제한";
tmp=`ls -l /usr/bin/su | awk '{if($4!="root"){print $0}}'`;
if [ "$tmp" != "" ]; then
	tmp=`ls -l /usr/bin/su | awk '{print $1"\t"$9}' | grep -E "........x"`;
	if [ "$tmp" == "" ]; then
		echo "양호(other에게 실행권한을 주지않고 특정 그룹만 사용하도록 관리하고 있음)";
		tmp=`ls -l /usr/bin/su`;
		result=1;
		reason="(other에게 실행권한을 주지않고 특정 그룹만 사용하도록 관리하고 있음)";
		echo "$tmp";
	else
		echo "취약(other도 su를 실행할 권한을 가지고 있음)";
		tmp=`ls -l /usr/bin/su`;
		result=2;
		reason="(other도 su를 실행할 권한을 가지고 있음)";
		echo "$tmp";
	fi
else
	tmp=`cat /etc/pam.d/su 2>/dev/null | grep -E "auth.*required.*pam_wheel.so.*debug.*group=|auth.*required.*pam_wheel.so.*use_uid" | grep -v "#"`;
	if [ "$tmp" != "" ]; then
		echo "양호(pam 설정을 통해 관리하고 있음)";
		result=1;
		reason="(pam 설정을 통해 관리하고 있음)";
		echo "$tmp";
	else
		echo "취약(pam 설정이 되어있지 않음)";
		tmp=`cat /etc/pam.d/su`;
		result=2;
		reason="(pam 설정이 되어있지 않음)";
		echo "$tmp";
	fi
fi
echo 1,6,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.7 패스워드 최소 길이 설정";
tmp=`grep -i "PASS_MIN_LEN" /etc/login.defs | grep -v "#" | awk '{if($2<8){print $2}}'`;
if [ "$tmp" == "" ]; then
	echo "양호";
	tmp=`grep -i "PASS_MIN_LEN" /etc/login.defs | grep -v "#"`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(패스워드 최소길이가 설정되지 않음)";
	tmp=`grep -i "PASS_MIN_LEN" /etc/login.defs | grep -v "#"`;
	result=2;
	reason="(패스워드 최소길이가 설정되지 않음)";
	echo "$tmp";
fi
echo 1,7,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.8 패스워드 최대 사용기간 설정";
tmp=`grep -i "PASS_MAX_DAYS" /etc/login.defs | grep -v "#" | awk '{if($2<=90){print $2}}'`;
if [ "$tmp" != "" ]; then
	echo "양호";
	tmp=`grep -i "PASS_MAX_DAYS" /etc/login.defs | grep -v "#"`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(패스워드 최대 사용기간이 설정되지 않음)";
	tmp=`grep -i "PASS_MAX_DAYS" /etc/login.defs | grep -v "#"`;
	result=2;
	reason="(패스워드 최대 사용기간이 설정되지 않음)";
	echo "$tmp";
fi
echo 1,8,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.9 패스워드 최소 사용기간 설정";
tmp=`grep -i "PASS_MIN_DAYS" /etc/login.defs | grep -v "#" | awk '{if($2>0){print $2}}'`;
if [ "$tmp" != "" ]; then
	echo "양호";
	tmp=`grep -i "PASS_MIN_DAYS" /etc/login.defs | grep -v "#"`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(패스워드 최소 사용기간이 설정되지 않음)";
	tmp=`grep -i "PASS_MIN_DAYS" /etc/login.defs | grep -v "#"`;
	result=2;
	reason="(패스워드 최소 사용기간이 설정되지 않음)";
	echo "$tmp";
fi
echo 1,9,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.10 불필요한 계정 제거";
echo "수동진단 필요(계정 리스팅해서 엑셀로 계정별 사용목적 회신받기)";
tmp=`cat /etc/passwd | cut -f 1 -d :`;
result=4;
reason="(계정 리스팅해서 엑셀로 계정별 사용목적 회신받기)";
echo "$tmp";
echo 1,10,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.11 관리자 그룹에 최소한의 계정 포함";
echo "수동진단 필요(root 그룹 내 계정 리스팅 해서 루트권한 사용목적 회신받기)";
tmp=`cat /etc/group | grep root:x:0`;
result=4;
reason="(root 그룹 내 계정 리스팅 해서 루트권한 사용목적 회신받기)";
echo "$tmp";
echo 1,11,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.12 계정이 존재하지 않는 GID 금지";
tmp=`cat /etc/group | grep -v root:x:0 | cut -f 4 -d : | grep -c -v -e "^$"`;
if [ "$tmp" == `cat /etc/group | grep -c -v root:x:0` ]; then
	echo "양호";
	tmp=`cat /etc/group`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(계정이 존재하지 않는 그룹 존재함)";
	tmp=`cat /etc/group | grep -v root:x:0 | awk -F: '{if($4==""){print $0}}'`;
	result=2;
	reason="(계정이 존재하지 않는 그룹 존재함)";
	echo "$tmp";
fi
echo 1,12,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.13 동일한 UID 금지";
tmp=`cat /etc/passwd | grep -c ""`;
if [ "$tmp" == `cat /etc/passwd | awk -F: '!x[$3]++ {print $0}' | grep -c ""` ]; then
	echo "양호";
	tmp=`cat /etc/passwd`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(동일한 UID를 가진 계정이 존재함)";
	tmp=`cat /etc/passwd | awk -F: 'x[$3]++ {print$0}'`;
	result=2;
	reason="(동일한 UID를 가진 계정이 존재함)";
	echo "$tmp";
fi
echo 1,13,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.14 사용자 shell  점검";
tmp=`cat /etc/passwd | awk -F: '{if($7!="/bin/nologin" && $7!="/sbin/nologin"){print $0}}' | grep -iE "/bin/.*sh"`;
echo "수동진단 필요(로그인이 필요한 사유 회신받기)";
result=4;
reason="(로그인이 필요한 사유 회신받기)";
echo "$tmp";
echo 1,14,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "1.15 Session Timeout 설정";
tmp=`echo $SHELL`;
if [ "$tmp" == "/bin/csh" ]; then
	tmp=`ls -l /etc/csh.login 2>/dev/null`;
	if [ "$tmp" != "" ]; then
		tmp=`grep -i autologout /etc/csh.login | awk -F= '{print $2}' | sed "s/ //g"`;
		if [ "$tmp" == "" ]; then
			echo "취약(autologout 관련 설정되어 있지 않음)";
			result=2;
			reason="(autologout 관련 설정되어 있지 않음)";
		elif [ $tmp -gt 10 ]; then
			echo "취약(설정된 값이 10분보다 큼)";
			tmp=`grep -i autologout /etc/csh.login`;
			result=2;
			reason="(설정된 값이 10분보다 큼)";
			echo "$tmp";
		else
			echo "양호";
			tmp=`grep -i autologout /etc/csh.login`;
			result=1;
			reason="-";
			echo "$tmp";
		fi
	else
		tmp=`ls -l /etc/csh.cshrc 2>/dev/null`;
		if [ "$tmp" == "" ]; then
			echo "취약(설정파일이 존재하지 않음)";
			result=2;
			reason="(설정파일이 존재하지 않음)";
		else
			tmp=`grep -i autologout /etc/csh.cshrc | awk -F= '{print $2}' | sed "s/ //g"`;
			if [ "$tmp" == "" ]; then
				echo "취약(autologout 관련 설정되어있지 않음)";
				result=2;
				reason="(autologout 관련 설정되어있지 않음)";
			elif [ $tmp -gt 10 ]; then	
				echo "취약(설정된 값이 10분보다 큼)"
				tmp=`grep -i autologout /etc/csh.cshrc`;
				result=2;
				reason="(설정된 값이 10분보다 큼)"
				echo "$tmp";		
			else
				echo "양호";
				tmp=`grep -i autologout /etc/csh.cshrc`;
				result=1;
				reason="-";
				echo "$tmp";
			fi
		fi
	fi
else
	tmp=`find /etc -maxdepth 1 -name "*profile" 2>/dev/null`;
	if [ "$tmp" != "" ]; then
		tmp=`find /etc -maxdepth 1 -name "*profile" 2>/dev/null | xargs grep "TMOUT" | awk -F= '{if($2<=600){print $2}}'`;
		if [ "$tmp" != "" ]; then
			echo "양호";
			tmp=`find /etc -maxdepth 1 -name "*profile" 2>/dev/null | xargs grep "TMOUT"`;
			result=1;
			reason="-";
			echo "$tmp";
		else
			tmp=`find /etc -maxdepth 1 -name "*profile" 2>/dev/null | xargs grep "TMOUT"`;
			if [ "$tmp" == "" ]; then
				echo "취약(설정이 되어 있지 않음)";
				result=2;
				reason="(설정이 되어 있지 않음)";
			else
				echo "취약(설정이 부적절하게 되어있음)";
				result=2;
				reason="(설정이 부적절하게 되어있음)";
				echo "$tmp";
			fi
		fi
	else
		echo "취약(설정파일이 존재하지 않음)";
		result=2;
		reason="(설정파일이 존재하지 않음)";
	fi
fi
echo 1,15,$result,$reason >> $resultdir/result.csv;
echo"";
echo "------------------------------------------------------------------------";
echo "2. 파일 및 디렉토리 관리";
echo "------------------------------------------------------------------------";
echo "2.15 hosts.lpd 파일 소유자 및 권한 설정";
tmp=`ls -l /etc/hosts.lpd 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`ls -l /etc/hosts.lpd 2>/dev/null | awk '{if($3=="root"){if($1=="-rw-------." || $1=="-r--------." || $1=="----------."){print $1"\t"$3}}}'`;
	if [ "$tmp" != "" ]; then
		echo "양호";
		result=1;
		reason="-";
	else
		echo "취약(설정이 부적절하게 되어있음)";
		result=2;
		reason="(설정이 부적절하게 되어있음)";
	fi
	tmp=`ls -l /etc/hosts.lpd 2>/dev/null`;
	echo "$tmp";
else
	echo "N/A(파일이 존재하지 않음)";
	result=3;
	reason="(파일이 존재하지 않음)";
fi
echo 2,15,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.16 NIS 서비스 비활성화";
tmp=`ps -ef | egrep "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" | grep -v -i -E "grep|\[.*\]"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	tmp=`ps -ef | grep -v -i -E "grep|\[.*\]"`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(불필요한것이 맞는지 확인 필요)";
	result=2;
	reason="(불필요한것이 맞는지 확인 필요)";
	echo "$tmp";
fi
echo 2,16,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.17 UMASK 설정 관리";
tmp=`cat /etc/profile | grep -i umask | grep -v "#" | awk '{if( $2 != "022" ){print $0}}'`;
if [ "$tmp" == "" ]; then
	echo "양호(UMASK가 정상적으로 설정됨)";
	tmp=`cat /etc/profile | grep -i umask | grep -v "#"`;
	result=1;
	reason="(UMASK가 정상적으로 설정됨)";
	echo "$tmp";
else
	echo "취약(UMASK가 잘못 설정됨)";
	result=2;
	reason="(UMASK가 잘못 설정됨)";
	echo "$tmp";
fi
echo 2,17,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.18 홈디렉토리 소유자 및 권한 설정";
dir_array=($(cat /etc/passwd | grep -v -E "/bin/nologin|/sbin/nologin" | awk -F: '{print $6}' | sed "s/ //g"));
own_array=($(cat /etc/passwd | grep -v -E "/bin/nologin|/sbin/nologin" | awk -F: '{print $1}' | sed "s/ //g"));
num=0;
chk=0;
dir="";
for i in ${dir_array[@]}; do
	tmp=`ls -Hdl "$i" 2>/dev/null | awk '{print $3}' | sed "s/ //g"`;
	if [ "${own_array[$num]}" == "$tmp" ] || [ "$tmp" == "root" ]; then
		tmp=`ls -Hdl "$i" 2>/dev/null | awk '{print $1}' | sed "s/ //g" | rev | cut -c 1-3 | rev | awk '{if($1=="---" || $1=="r--" || $1=="--x" || $1=="r-x"){print $1}}'`;
		if [ "$tmp" != "" ]; then
			chk=`expr $chk + 1`;
		else
			tmp=`ls -Hdl "$i" 2>/dev/null | awk '{print $3}' | sed "s/ //g"`;
			dir="$dir$i\t\t${own_array[$num]}\t\t$tmp\t\t";
			tmp=`ls -Hdl "$i" 2>/dev/null | awk '{print $1}'`;
			dir="$dir$tmp\n";
		fi
	else
		dir="$dir$i\t\t${own_array[$num]}\t\t$tmp\t\t";
		tmp=`ls -Hdl "$i" 2>/dev/null | awk '{print $1}'`;
		dir="$dir$tmp\n";
	fi
	num=`expr $num + 1`;
done
if [ $chk -eq ${#dir_array[@]} ]; then
	echo "양호";
	tmp=`cat /etc/passwd`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(소유자 또는 권한이 부적절하게 설정됨)";
	echo -e "홈디렉토리\t실제사용자\t설정된소유자\t권한";
	echo -e "$dir";
	result=2;
	reason="(소유자 또는 권한이 부적절하게 설정됨)";
fi
echo 2,18,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.19 홈디렉토리로 지정한 디렉토리의 존재 관리";
tmp=`cat /etc/passwd | grep -v -E "/bin/nologin|/sbin/nologin" | awk -F: '{if($6=="/"){print $0}}'`;
if [ "$tmp" == "" ]; then
	echo "양호";
	tmp=`cat /etc/passwd`;
	result=1;
	reason="-";
	echo "$tmp";
else
	echo "취약(홈디렉토리가 없는 계정이 존재함)";
	result=2;
	reason="(홈디렉토리가 없는 계정이 존재함)";
	echo "$tmp";
fi
echo 2,19,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "2.20 숨겨진 파일 및 디렉토리 검색 및 제거";
tmp=`find / -name ".*" 2>/dev/null`;
safe_file_array=($(cat OS_Default_Data/centos7/centos7_default_hiddenfile));
safe_dir_array=($(cat OS_Default_Data/centos7/centos7_default_hiddendir));
for safe_file in ${safe_file_array[@]}; do
	tmp=`echo "$tmp" | grep -v -i "$safe_file"`;
done
for safe_file in ${safe_dir_array[@]}; do
	tmp=`echo "$tmp" | grep -v -i "$safe_file"`;
done
if [ "$tmp" == "" ]; then
	echo "양호(시스템 기본 숨김파일들만 존재함)";
	result=1;
	reason="(시스템 기본 숨김파일들만 존재함)";
else
	echo "취약(불필요한 숨김파일이 존재함 -> 담당자 확인 필요)";
	result=2;
	reason="(불필요한 숨김파일이 존재함 -> 담당자 확인 필요)";
	echo "$tmp";
fi
echo 2,20,$result,$reason >> $resultdir/result.csv;
echo"";
echo "------------------------------------------------------------------------";
echo "3. 서비스 관리";
echo "------------------------------------------------------------------------";
echo "3.24 ssh 원격접속 허용";
tmp=`systemctl status telnet.socket 2>/dev/null | grep dead`;
if [ "$tmp" != "" ]; then
	tmp=`ps -ef | grep ftp | grep -v -i -E "grep|\[.*\]"`;
	if [ "$tmp" == "" ]; then
		echo "양호(telnet 및 ftp 서비스를 비활성화 시켜둠)";
		tmp=`systemctl status telnet.socket`;
		result=1;
		reason="(telnet 및 ftp 서비스를 비활성화 시켜둠)";
		echo "$tmp";
		echo "";
		tmp=`ps -ef | grep -v -E -i "grep|\[.*\]"`;
		echo "$tmp";
	else
		echo "취약(telnet은 양호하나, ftp가 사용중에 있음)";
		result=2;
		reason="(telnet은 양호하나 ftp가 사용중에 있음)";
		echo "$tmp";
	fi
else
	tmp=`systemctl status telnet.socket 2>/dev/null | grep listening`;
	if [ "$tmp" == "" ]; then
		tmp=`ps -ef | grep ftp | grep -v -i -E "grep|\[.*\]"`;
		if [ "$tmp" == "" ]; then
			echo "양호(telnet은 설치되어 있지 않으며 ftp 서비스를 비활성화 시켜둠)";
			tmp=`ps -ef | grep -v -E -i "grep|\[.*\]"`;
			result=1;
			reason="(telnet은 설치되어 있지 않으며 ftp 서비스를 비활성화 시켜둠)";
			echo "$tmp";
		else
			echo "취약(telnet은 설치되어 있지 않으나, ftp가 사용중에 있음)";
			result=2;
			reason="(telnet은 설치되어 있지 않으나 ftp가 사용중에 있음)";
			echo "$tmp";
		fi
		tmp=`systemctl status telnet.socket 2>/dev/null`;
		echo "$tmp";
	else
		tmp=`ps -ef | grep ftp | grep -v -i -E "grep|\[.*\]"`;
		if [ "$tmp" == "" ]; then
			echo "취약(ftp는 비활성화 되어있으나, telnet가 사용중에 있음)";
			result=2;
			reason="(ftp는 비활성화 되어있으나 telnet가 사용중에 있음)";
			tmp=`systemctl status telnet.socket 2>/dev/null`;
			echo "$tmp";
			echo "";
			tmp=`ps -ef | grep -v -E -i "grep|\[.*\]"`;
			echo "$tmp";
		else
			echo "취약(telnet, ftp가 모두 사용중에 있음)";
			result=2;
			reason="(telnet과 ftp 모두 사용중에 있음)";
			echo "$tmp";
			echo "";
			tmp=`systemctl status telnet.socket 2>/dev/null`;
			echo "$tmp";
		fi
	fi
fi
echo 3,24,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.25 ftp 서비스 확인";
tmp=`ps -ef | grep ftp | grep -v -i -E "grep|\[.*\]"`;
if [ "$tmp" == "" ]; then
	echo "양호(ftp 서비스를 비활성화 시켜둠)";
	tmp=`ps -ef | grep -v -E -i "grep|\[.*\]"`;
	result=1;
	reason="(ftp 서비스를 비활성화 시켜둠)";
	echo "$tmp";
else
	echo "취약(ftp가 사용중에 있음)";
	result=2;
	reason="(ftp가 사용중에 있음)";
	echo "$tmp";
fi
echo 3,25,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.26 ftp 계정 shell 제한(ftp 서비스를 사용하지 않을 경우 양호)";
tmp=`cat /etc/passwd | awk -F: '{if($1=="ftp"){print $0}}'`;
if [ "$tmp" == "" ]; then
	echo "양호(기본 ftp계정이 존재하지 않음)";
	tmp=`cat /etc/passwd`;
	result=1;
	reason="(기본 ftp계정이 존재하지 않음)";
	echo "$tmp";
else
	tmp=`echo "$tmp" | awk -F: '{if($7=="/bin/nologin" || $7=="/sbin/nologin" || $7=="/bin/false" || $7=="/sbin/false"){print $0}}'`;
	if [ "$tmp" != "" ]; then
		echo "양호(쉘을 사용할 수 없게 설정되어 있음)";
		result=1;
		reason="(쉘을 사용할 수 없게 설정되어 있음)";
		echo "$tmp";
	else
		echo "취약(로그인 및 쉘 사용 가능함)";
		tmp=`cat /etc/passwd | awk -F: '{if($1=="ftp"){print $0}}'`;
		result=2;
		reason="(로그인 및 쉘 사용 가능함)";
		echo "$tmp";
	fi
fi
echo 3,26,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.27 ftpusers 파일 소유자 및 권한 설정(ftp 서비스를 사용하지 않을 경우 양호)";
tmp=`find / -name ftpusers -exec ls -l {} \; -o -name user_list -exec ls -l {} \; 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`find / -name ftpusers -exec ls -l {} \; -o -name user_list -exec ls -l {} \; 2>/dev/null | awk '{if($1!="-rw-r-----." && $1!="-rw-------." && $1!="-r--------." && $1!="----------."){print $0}}'`;
	if [ "$tmp" != "" ]; then
		echo "취약(권한 설정이 부적절히 이루어져 있음)";
		result=2;
		reason="(권한 설정이 부적절히 이루어져 있음)";
		echo "$tmp";
	else
		echo "양호(권한 설정이 잘 이루어져 있음)";
		tmp=`find / -name ftpusers -exec ls -l {} \; -o -name user_list -exec ls -l {} \;`;
		result=1;
		reason="(권한 설정이 잘 이루어져 있음)";
		echo "$tmp";
	fi
	echo "";
	tmp=`find / -name ftpusers -exec ls -l {} \; -o -name user_list -exec ls -l {} \; 2>/dev/null | awk '{if($3!="root"){print $0}}'`;
	if [ "$tmp" != "" ]; then
		echo "취약(소유자 설정이 부적절히 이루어져 있음)";
		result=2;
		reason="(소유자 설정이 부적절히 이루어져 있음)";
		echo "$tmp";
	else
		echo "양호(소유자 설정이 잘 이루어져 있음)";
		tmp=`find / -name ftpusers -exec ls -l {} \; -o -name user_list -exec ls -l {} \;`;
		result=1;
		reason="(소유자 설정이 잘 이루어져 있음)";
		echo "$tmp";
	fi
else
	echo "양호(해당 설정 파일이 존재하지 않음)";
	result=1;
	reason="(해당 설정 파일이 존재하지 않음)";
fi
echo 3,27,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.28 ftpusers 파일 설정(ftp 서비스를 사용하지 않을 경우 양호)";
tmp=`find / -name ftpusers -exec ls -l {} \; -o -name user_list -exec ls -l {} \; 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`find / -name ftpusers -exec grep -HEi "root" {} \; -o -name user_list -exec grep -HEi "root" {} \; -o -name proftpd.conf -exec grep -HEi "RootLogin" {} \; 2>/dev/null | awk -F: '{if($2=="root" || $2=="RootLogin on"){print $0}}'`;
	if [ "$tmp" != "" ]; then
		echo "취약(root 계정 접속이 활성화 되어 있음)";
		result=2;
		reason="(root 계정 접속이 활성화 되어 있음)";
		echo "$tmp";
	else
		echo "양호(root 계정 접속이 비활성화 되어 있음)";
		tmp=`find / -name ftpusers -exec grep -HEi "" {} \; -o -name user_list -exec grep -HEi "" {} \; -o -name proftpd.conf -exec grep -HEi "" {} \; 2>/dev/null`;
		result=1;
		reason="(root 계정 접속이 비활성화 되어 있음)";
		echo "$tmp";
	fi
else
	echo "양호(해당 설정 파일이 존재하지 않음)";
	result=1;
	reason="(해당 설정 파일이 존재하지 않음)";
fi
echo 3,28,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.29 at 파일 소유자 및 권한 설정";
tmp=`ls -l /etc/cron.d/at.allow /etc/cron.d/at.deny 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`echo "$tmp" | awk '{if($1!="-rw-r-----." && $1!="-rw-------." && $1!="-r--------." && $1!="----------."){print $0}}'`;
	if [ "$tmp" != "" ]; then
		echo "취약(권한 설정이 부적절히 이루어져 있음)";
		result=2;
		reason="(권한 설정이 부적절히 이루어져 있음)";
		echo "$tmp";
	else
		echo "양호(권한 설정이 잘 이루어져 있음)";
		tmp=`ls -l /etc/cron.d/at.allow /etc/cron.d/at.deny 2>/dev/null`;
		result=1;
		reason="(권한 설정이 잘 이루어져 있음)";
		echo "$tmp";
	fi
	echo "";
	tmp=`ls -l /etc/cron.d/at.allow /etc/cron.d/at.deny | awk '{if($3!="root"){print $0}}'`;
	if [ "$tmp" != "" ]; then
		echo "취약(소유자 설정이 부적절히 이루어져 있음)";
		result=2;
		reason="(소유자 설정이 부적절히 이루어져 있음)";
		echo "$tmp";
	else
		echo "양호(소유자 설정이 잘 이루어져 있음)";
		tmp=`ls -l /etc/cron.d/at.allow /etc/cron.d/at.deny 2>/dev/null`;
		result=1;
		reason="(소유자 설정이 잘 이루어져 있음)";
		echo "$tmp";
	fi
else
	echo "양호(해당 설정 파일이 존재하지 않음)";
	result=1;
	reason="(해당 설정 파일이 존재하지 않음)";
fi
echo 3,29,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.30 SNMP 서비스 구동 점검";
tmp=`ps -ef | grep snmp | grep -iEv "grep|\[.*\]"`;
if [ "$tmp" == "" ]; then
	echo "양호(snmp서비스 미작동 중)";
	tmp=`ps -ef | grep -iEv "grep|\[.*\]"`;
	result=1;
	reason="(snmp서비스 미작동 중)";
	echo "$tmp";
else
	echo "취약(snmp 구동중, 사용 사유 확인 필요)";
	result=2;
	reason="(snmp 구동중이며 사용 사유 확인 필요)";
	echo "$tmp";
fi
echo 3,30,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.31 SNMP 서비스 Community String의 복잡성 설정(SNMP 비활성화 시 양호)";
tmp=`ps -ef | grep snmp | grep -iEv "grep|\[.*\]"`;
if [ "$tmp" == "" ]; then
	echo "양호(snmp서비스 미작동 중)";
	tmp=`ps -ef | grep -iEv "grep|\[.*\]"`;
	result=1;
	reason="(snmp서비스 미작동 중)";
	echo "$tmp";
else
	tmp=`grep -i com2sec /etc/snmp/snmpd.conf 2>/dev/null | grep -v "#" | awk '{if($4=="public" || $4=="private"){print $0}}'`;
	if [ "$tmp" == "" ]; then
		echo "양호(community string이 Default값이 아님)";
		tmp=`grep -i com2sec /etc/snmp/snmpd.conf | grep -v "#"`;
		result=1;
		reason="(community string이 Default값이 아님)";
		echo "$tmp";
	else
		echo "취약(community string이 Default값임)";
		result=2;
		reason="(community string이 Default값임)";
		echo "$tmp";
	fi
fi
echo 3,31,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.32 로그온 시 경고 메시지 제공";
tmp=`ls -l /etc/motd 2>/dev/null`;
result=4
reason="";
if [ "$tmp" != "" ]; then
	tmp=`grep "" /etc/motd`;
	if [ "$tmp" != "" ]; then
		echo "수동진단(서버 로그온 메시지 설정되어 수동진단 필요)";
		reason=$reason"\/(서버 로그온 메시지 설정되어 수동진단 필요)";
		echo "$tmp";
	else
		echo "취약(서버 로그온 메시지 미설정됨)";
		result=2;
		reason=$reason"\/(서버 로그온 메시지 미설정됨)";
	fi
else
	echo "취약(서버 로그온 파일 존재하지 않음)";
	result=2;
	reason=$reason"\/(서버 로그온 파일 존재하지 않음)";
fi
echo "";
tmp=`systemctl status telnet.socket 2>/dev/null | grep -Ei "listening|dead"`;
if [ "$tmp" == "" ]; then
	echo "양호(telnet설치되어 있지 않음)";
else
	tmp=`cat /etc/issue.net`;
	if [ "$tmp" != "" ]; then
		echo "수동진단(telnet 로그온 메시지 설정되어 수동진단 필요)";
		reason=$reason"\/(telnet 로그온 메시지 설정되어 수동진단 필요)";
		echo "$tmp";
	else
		echo "취약(telnet 로그온 메시지 미설정됨)";
		result=2;
		reason=$reason"\/(telnet 로그온 메시지 미설정됨)";
	fi
fi
echo "";
tmp=`systemctl status vsftpd 2>/dev/null | grep -Ei "running|dead"`;
if [ "$tmp" == "" ]; then
	echo "양호(vsftp설치되어 있지 않음)";
else
	tmp=`cat /etc/vsftpd/vsftpd.conf | grep -v "#" | grep "ftpd_banner"`;
	if [ "$tmp" != "" ]; then
		echo "수동진단(vsftpd 로그온 메시지 설정되어 수동진단 필요)";
		reason=$reason"\/(vsftpd 로그온 메시지 설정되어 수동진단 필요)";
		echo "$tmp";
	else
		echo "취약(vsftpd 로그온 메시지 미설정됨)";
		result=2;
		reason=$reason"\/(vsftpd 로그온 메시지 미설정됨)";
	fi
fi
echo "";
tmp=`ls -l /etc/mail/sendmail.cf 2>/dev/null`;
if [ "$tmp" == "" ]; then
	echo "양호(sendmail 설치되어 있지 않음)";
else
	tmp=`cat /etc/mail/sendmail.cf | grep -v "#" | grep -i "GreetingMessage"`;
	if [ "$tmp" != "" ]; then
		echo "수동진단(sendmail 로그온 메시지 설정되어 수동진단 필요)";
		reason=$reason"\/(sendmail 로그온 메시지 설정되어 수동진단 필요)"; 
		echo "$tmp";
	else
		echo "취약(sendmail 로그온 메시지 미설정됨)";
		result=2;
		reason=$reason"\/(sendmail 로그온 메시지 미설정됨)";
	fi
fi
echo "";
tmp=`systemctl status named 2>/dev/null | grep -Ei "running|dead"`;
if [ "$tmp" == "" ]; then
	echo "양호(DNS 서버 설치되어 있지 않음)";
else
	tmp=`cat /etc/named.conf | grep -v "//" | grep -i "version"`;
	if [ "$tmp" != "" ]; then
		echo "수동진단(DNS 서버 로그온 메시지 설정되어 수동진단 필요)";
		reason=$reason"\/(DNS 서버 로그온 메시지 설정되어 수동진단 필요)";
		echo "$tmp";
	else
		echo "취약(telnet 로그온 메시지 미설정됨)";
		result=2;
		reason=$reason"\/(telnet 로그온 메시지 미설정됨)";
	fi
fi
echo 3,32,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.33 NFS 설정파일 접근권한";
result=1;
reason="";
tmp=`ls -l /etc/exports 2>/dev/null`;
if [ "$tmp" != "" ]; then
	tmp=`echo "$tmp" | awk '{if($1=="-rw-r--r--." || $1=="-rw-r-----." || $1=="-rw-------." || $1=="-r--------." || $1=="----------." || $1=="-rw-r--r--" || $1=="-rw-r-----" || $1=="-rw-------" || $1=="-r--------" || $1=="----------"){print $0}}'`;
	if [ "$tmp" != "" ]; then
		echo "양호(권한이 적절히 설정되어있음)";
	else
		echo "취약(권한이 부적절하게 설정되어 있음)";
		result=2;
		reason=$reason"\/(권한이 부적절하게 설정되어 있음)";
	fi
	tmp=`ls -l /etc/exports | awk '{if($3=="root"){print $0}}'`;
	if [ "$tmp" != "" ]; then
		echo "양호(소유자가 적절히 설정되어있음)";
	else
		echo "취약(소유자가 부적절하게 설정되어 있음)";
		result=2;
		reason=$reason"\/(소유자가 부적절하게 설정되어 있음)";
	fi
	tmp=`ls -l /etc/exports`;
	echo "$tmp";
else
	echo "N/A(파일이 존재하지 않음)";
	result=3;
	reason="(파일이 존재하지 않음)";
fi
echo 3,33,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.34 expn, vrfy 명령어 제한";
tmp=`ls -l /etc/mail/sendmail.cf 2>/dev/null`;
if [ "$tmp" == "" ]; then
	echo "양호(sendmail 설치되어 있지 않음)";
	result=1;
	reason="(sendmail 설치되어 있지 않음)";
else
	tmp=`cat /etc/mail/sendmail.cf | grep -v "#" | grep -i "PrivacyOptions" | grep -iE "noexpn|novrfy"`;
	if [ "$tmp" != "" ]; then
		echo "양호(expn, vrfy 명령어 제한 설정됨)";
		result=1;
		reason="(expn\/vrfy 명령어 제한 설정됨)";
		echo "$tmp";
	else
		echo "취약(명령어 제한 미설정됨)";
		tmp=`cat /etc/mail/sendmail.cf`;
		result=2;
		reason="(명령어 제한 미설정됨)";
		echo "$tmp";
	fi
fi
echo 3,34,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "5. 로그 관리";
echo "------------------------------------------------------------------------";
echo "5.2 정책에 따른 시스템 로깅 설정";
result=1;
reason="";
tmp=`ls -l /etc/syslog.conf 2>/dev/null`;
filenm="/etc/syslog.conf";
if [ "$tmp" == "" ]; then
	filenm="/etc/rsyslog.conf";
fi
tmp=`cat "$filenm" | grep -v "#" | grep -i "\*.info;mail.none;authpriv.none;cron.none"`;
if [ "$tmp" != "" ]; then
	echo "양호(\*.info설정 되어있음)";
else
	echo "취약(\*.info 미설정 되어있음)";
	result=2;
	reason=$reason"\/(\*.info 미설정 되어있음)";
fi
tmp=`cat "$filenm" | grep -v "#" | grep -i "authpriv\.\*"`;
if [ "$tmp" != "" ]; then
	echo "양호(authpriv.\* 설정 되어있음)";
else
	echo "취약(.authpriv.\* 미설정 되어있음)";
	result=2;
	reason=$reason"\/(.authpriv.\* 미설정 되어있음)";
fi
tmp=`cat "$filenm" | grep -v "#" | grep -i "mail.\*"`;
if [ "$tmp" != "" ]; then
	echo "양호(mail.\* 설정 되어있음)";
else
	echo "취약(mail.\*  미설정 되어있음)";
	result=2;
	reason=$reason"\/(mail.\*  미설정 되어있음)";
fi   
tmp=`cat "$filenm" | grep -v "#" | grep -i "cron.\*"`;
if [ "$tmp" != "" ]; then
	echo "양호(cron.\*설정 되어있음)";
else
	echo "취약(cron.\* 미설정 되어있음)";
	result=2;
	reason=$reason"\/(cron.\* 미설정 되어있음)";
fi   
tmp=`cat "$filenm" | grep -v "#" | grep -i "\*.alert"`;
if [ "$tmp" != "" ]; then
	echo "양호(\*.alert설정 되어있음)";
else
	echo "취약(\*.alert 미설정 되어있음)";
	result=2;
	reason=$reason"\/(\*.alert 미설정 되어있음)";
fi   
tmp=`cat "$filenm" | grep -v "#" | grep -i "\*.emerg"`;
if [ "$tmp" != "" ]; then
	echo "양호(\*.emerg 설정 되어있음)";
else
	echo "취약(\*.emerg 미설정 되어있음)";
	result=2;
	reason=$reason"\/(\*.emerg 미설정 되어있음)";
fi
echo "$filenm";
tmp=`cat "$filenm" | grep -v "#" | grep -iE "\*.info;mail.none;authpriv.none;cron.none|authpriv.\*|mail.\*|cron.\*|\*.alert|\*.emerg"`;
echo "$tmp";
echo 5,2,$result,$reason >> $resultdir/result.csv;
