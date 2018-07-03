#!/usr/bin/sh

# Incremental Backups with percona tool
# create by kevin

User=root
Pwd=123456
Inb=/usr/bin/innobackupex
Date=`date +%Y-%m-%d`
Bak_home=/home/mysql_data
F_bak=/home/mysql_data/full_bak/$Date
I_bak=/home/mysql_data/incremental_bak/$Date
#Mem=4G

function usage(){
	printf "Use parameter to restore data . No parameter just for backup\n"
	printf "$0\n or $0 2017-12-06\n"
}

function data_op(){
	#just for centos7
	systemctl stop mysqld
	mv /var/lib/mysql /var/lib/mysql_$Date
	mkdir /var/lib/mysql
}

function mysql_op(){
	chown -R mysql.mysql /var/lib/mysql
	systemctl start mysqld >/dev/null
	printf "mysql pid :`pgrep mysqld`\n"	
}

Login="--user=$User --password=$Pwd"
if [[ $# -eq 0 ]];then
	[[ -x /home/mysql_data/full_bak ]] || mkdir -p /home/mysql_data/full_bak
	[[ -x /home/mysql_data/incremental_bak ]] || mkdir -p /home/mysql_data/incremental_bak

	if [[ -x $F_bak ]];then
		#incremental backup
		c=`ls -dl $I_bak/* | wc -l`
		Nfile_I=`ls -td $I_bak/* | head -1`
		Nfile_F=`ls -td $F_bak/* | head -1`
		if [[ $c -ge 1 ]];then
			#$Inb $Login --use-memory=$Mem --incremental-basedir=$nfile --incremental $I_bak
			$Inb $Login --incremental-basedir=$Nfile_I --incremental $I_bak
		else
			#first time to run incremental bakcup
			#$Inb $Login --use-memory=$Mem --incremental-basedir=$F_bak --incremental $I_bak
			$Inb $Login --incremental-basedir=$Nfile_F --incremental $I_bak
		fi
	else
		#full backup
		$Inb $Login $F_bak
	fi

else	
#restore data
	qdate=$1
	restore_f=/home/mysql_data/full_bak/$qdate
	restore_i=/home/mysql_data/incremental_bak/$qdate
	file=`ls -td $restore_f/* | head -1`
	
	data_op
	sleep 2
	$Inb $Login --apply-log --redo-only $file
	for i in `ls -td $restore_i/* | sort -t '/' -k 4`;do
		$Inb $Login --apply-log --redo-only $file --incremental-dir=$i
	done
	$Inb $Login --copy-back $file
	if [[ $? -eq 0 ]];then
		printf "restore complete"
		mysql_op
	else
		printf "data restore fail,please check"
	fi
fi
