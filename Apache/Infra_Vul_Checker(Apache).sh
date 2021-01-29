#!/bin/sh

# Make sure only root can run our script
if [ "$EUID" != 0 ]; then
	echo "You have to run this script in root"
	exit
	fi

echo -e "Put httpd.conf directory (ex. /etc/httpd/conf/httpd.conf) : \c";
read conf_dir;

# Make Result Directory
resultdir=`date +%Y%m%d_%H%M%S`
resultdir=Result_$resultdir
mkdir $resultdir
echo "Code","No","SubNo","Result","Reason" > $resultdir/result.csv;
# Script Start
echo "########################################################################";
echo "#                      Infra Vulerability Checker                      #";
echo "#                                               Made By : Tomato       #";
echo "########################################################################";
echo "";
echo "3. 서비스 관리";
echo "------------------------------------------------------------------------";
echo "3.17 Apache 디렉토리 리스팅 제거";
tmp=`grep -ri "Indexes" $conf_dir | grep -v "#"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	result=1;
	reason="-";
else
	echo "취약(Indexes 옵션이 설정되어 있음)";
	result=2;
	reason="(Indexes 옵션이 설정되어 있음)"
fi
tmp=`cat $conf_dir`;
echo "$tmp";
echo "U-35",3,17,$result,$reason >> $resultdir/result.csv;
echo "$tmp" > $resultdir/U-35;
echo 
echo "";
echo "------------------------------------------------------------------------";
echo "3.18 Apache 웹 프로세스 권한 제한";
tmp=`grep -rE "User|Group" $conf_dir | grep -vEi "#|User-Agent" | grep -i root`;
if [ "$tmp" == "" ]; then
	echo "양호";
	result=1;
	reason="-";
else
	echo "취약(Apache 프로세스가 Root로 실행되고 있음)";
	result=2;
	reason="(Apache 프로세스가 Root로 실행되고 있음)"
fi
tmp=`grep -rE "User|Group" $conf_dir | grep -vEi "#|User-Agent"`;
echo "$tmp";
echo "U-36",3,18,$result,$reason >> $resultdir/result.csv;
echo "$tmp" > $resultdir/U-36;
echo "";
echo "------------------------------------------------------------------------";
echo "3.19 Apache 상위 디렉토리 접근 금지";
tmp=`grep -ri "AllowOverride" $conf_dir | grep -v "#" | grep -i "none"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	result=1;
	reason="-";
else
	echo "취약(AllowOverride 옵션이 None으로 설정되어 있음)";
	result=2;
	reason="(AllowOverride 옵션이 None으로 설정되어 있음)"
fi
tmp=`cat $conf_dir`;
echo "$tmp";
echo "U-37",3,19,$result,$reason >> $resultdir/result.csv;
echo "$tmp" > $resultdir/U-37;
echo "";
echo "------------------------------------------------------------------------";
echo "3.20 Apache 불필요한 파일 제거";
tmp=`grep -ri "DocumentRoot" $conf_dir | grep -v "#" | awk '{print $2"/htdocs/manual"}' | sed 's/"//g' | xargs ls -ld 2>/dev/null`;
if [ "$tmp" == "" ]; then
	tmp2=`grep -ri "DocumentRoot" $conf_dir | grep -v "#" | awk '{print $2"/manual"}' | sed 's/"//g' | xargs ls -ld 2>/dev/null`;
	if [ "$tmp2" == "" ]; then
		echo "양호";
		result=1;
		reason="-";
		tmp=`grep -ri "DocumentRoot" $conf_dir | grep -v "#" | awk '{print $2}' | sed 's/"//g' | xargs ls -ld 2>/dev/null`;
		echo "$tmp";
		echo "$tmp" > $resultdir/U-38;
	else
		echo "취약(불필요한 manaul 디렉토리가 존재함)";
		result=2;
		reason="(불필요한 manaul 디렉토리가 존재함)";
		echo "$tmp2";
		echo "$tmp2" > $resultdir/U-38;
	fi
else
	tmp2=`grep -ri "DocumentRoot" $conf_dir | grep -v "#" | awk '{print $2"/manual"}' | sed 's/"//g' | xargs ls -ld 2>/dev/null`;
	if [ "$tmp2" == "" ]; then
		echo "취약(불필요한 htdocs/manual 디렉토리가 존재함)";
		result=2;
		reason="(불필요한 htdocs/manaul 디렉토리가 존재함)";
		echo "$tmp";
		echo "$tmp" > $resultdir/U-38;
	else
		echo "취약(불필요한 manaul 디렉토리와 htdocs/manaul 디렉토리가 존재함)";
		result=2;
		reason="(불필요한 manaul 디렉토리와 htdocs/manaul 디렉토리가 존재함)";
		echo "$tmp";
		echo "$tmp2";
		echo "$tmp" > $resultdir/U-38;
		echo "$tmp2" >> $resultdir/U-38;
	fi
fi
echo "U-38",3,20,$result,$reason >> $resultdir/result.csv;
echo "";
echo "------------------------------------------------------------------------";
echo "3.21 Apache 링크 사용 금지";
tmp=`grep -ri "FollowSymLinks" $conf_dir | grep -v "#"`;
if [ "$tmp" == "" ]; then
	echo "양호";
	result=1;
	reason="-";
else
	echo "취약(FollowSymLinks 옵션이 설정되어 있음)";
	result=2;
	reason="(FollowSymLinks 옵션이 설정되어 있음)"
fi
tmp=`cat $conf_dir`;
echo "$tmp";
echo "U-39",3,21,$result,$reason >> $resultdir/result.csv;
echo "$tmp" > $resultdir/U-39;
echo "";
echo "------------------------------------------------------------------------";
echo "3.22 Apache 파일 업로드 및 다운로드 제한";
tmp=`grep -ri "LimitRequestBody" $conf_dir | grep -v "#" | awk '{print $2}'`;
if [ "$tmp" == "" ]; then
	echo "취약(업로드, 다운로드 파일 사이즈 용량 제한이 설정되어 있지 않음)";
	result=2;
	reason="(업로드, 다운로드 파일 사이즈 용량 제한이 설정되어 있지 않음)";
else
	if [ $tmp > 5000000 ]; then
		echo "취약(소유자 또는 그룹이 없는 파일 또는 디렉터리 있음)";
		result=2;
		reason="(소유자 또는 그룹이 없는 파일 또는 디렉터리 있음)";
	else
		echo "양호";
		result=1;
		reason="-";
	fi
fi
tmp=`cat $conf_dir`;
echo "$tmp";
echo "U-40",3,22,$result,$reason >> $resultdir/result.csv;
echo "$tmp" > $resultdir/U-40;
echo "";
echo "------------------------------------------------------------------------";
echo "3.23 Apache 웹 서비스 영역의 분리";
tmp=`grep -ri "DocumentRoot" $conf_dir | grep -v "#" | awk '{print $2}' | sed 's/"//g' | awk '{if($1=="/usr/local/apache/htdocs" || $1=="/usr/local/apache2/htdocs" || $1=="/var/www/html"){print $0}'`
if [ "$tmp" == "" ]; then
	echo "양호";
	result=1;
	reason="-";
	tmp=`cat $conf_dir`;
else
	echo "취약(DocumentRoot가 기본 디렉토리로 지정되어 있음)";
	result=2;
	reason="(DocumentRoot가 기본 디렉토리로 지정되어 있음)"
fi
echo "$tmp";
echo "U-41",3,23,$result,$reason >> $resultdir/result.csv;
echo "$tmp" > $resultdir/U-41;
echo "";
echo "------------------------------------------------------------------------";
echo "3.35 Apache 웹 서비스 정보 숨김";
tmp=`grep -ri "ServerTokens" $conf_dir | grep -v "#"`;
if [ "$tmp" == "" ]; then
	tmp=`grep -ri "ServerSignature" $conf_dir | grep -v "#"`;
	if [ "$tmp" == "" ]; then
		echo "취약(ServerTokens와 ServerSignature가 설정되어 있지 않음)";
		result=2;
		reason="(ServerTokens와 ServerSignature가 설정되어 있지 않음)";
	else
		tmp=`grep -ri "ServerSignature" $conf_dir | grep -v "#" | awk '{if(tolower($2)!="off"){print $0}}'`;
		if [ "$tmp" == "" ]; then
			echo "취약(ServerTokens가 설정되어 있지 않음)";
			result=2;
			reason="(ServerTokens가 설정되어 있지 않음)";
		else
			echo "취약(ServerTokens가 설정되어 있지 않으며, ServerSignature가 Off로 설정되어 있지 않음)";
			result=2;
			reason="(ServerTokens가 설정되어 있지 않으며, ServerSignature가 Off로 설정되어 있지 않음)";
		fi
	fi
else
	tmp=`grep -ri "ServerSignature" $conf_dir | grep -v "#"`;
	if [ "$tmp" == "" ]; then
		tmp=`grep -ri "ServerTokens" $conf_dir | grep -v "#" | awk '{if(tolower($2)!="prod"){print $0}}'`;
		if [ "$tmp" == "" ]; then
			echo "취약(ServerSignature가 설정되어 있지 않음)";
			result=2;
			reason="(ServerSignature가 설정되어 있지 않음)";
		else
			echo "취약(ServerSignature가 설정되어 있지 않으며, ServerTokens가 Prod로 설정되어 있지 않음)";
			result=2;
			reason="(ServerSignature가 설정되어 있지 않으며, ServerTokens가 Prod로 설정되어 있지 않음)";
		fi	
	else
		tmp=`grep -ri "ServerSignature" $conf_dir | grep -v "#" | awk '{if(tolower($2)!="off"){print $0}}'`;
		if [ "$tmp" == "" ]; then
			tmp=`grep -ri "ServerTokens" $conf_dir | grep -v "#" | awk '{if(tolower($2)!="prod"){print $0}}'`;
			if [ "$tmp" == "" ]; then
				echo "양호";
				result=1;
				reason="-";
			else
				echo "취약(ServerTokens가 Prod로 설정되어 있지 않음)";
				result=2;
				reason="(ServerTokens가 Prod로 설정되어 있지 않음)";
			fi
		else
			tmp=`grep -ri "ServerTokens" $conf_dir | grep -v "#" | awk '{if(tolower($2)!="prod"){print $0}}'`;
			if [ "$tmp" == "" ]; then
				echo "취약(ServerSignature가 Off로 설정되어 있지 않음)";
				result=2;
				reason="(ServerSignature가 Off로 설정되어 있지 않음)";
			else
				echo "취약(ServerSignature가 Off로 설정되어 있지 않으며, ServerTokens가 Prod로 설정되어 있지 않음)";
				result=2;
				reason="(ServerSignature가 Off로 설정되어 있지 않으며, ServerTokens가 Prod로 설정되어 있지 않음)";
			fi
		fi
	fi
fi
tmp=`cat $conf_dir`;
echo "$tmp";
echo "U-72",3,35,$result,$reason >> $resultdir/result.csv;
echo "$tmp" > $resultdir/U-72;
echo "";

tar -cvf $resultdir.tar $resultdir;
rm -r $resultdir;
