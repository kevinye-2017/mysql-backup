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

Login="--user=$User --password=$Pwd"
[[ -x /home/mysql_data/full_bak ]] || mkdir -p /home/mysql_data/full_bak
[[ -x /home/mysql_data/incremental_bak ]] || mkdir -p /home/mysql_data/incremental_bak
#[[ -x /home/mysql_data/log ]] || mkdir -p /home/mysql_data/log

if [[ -x $F_bak ]];then
	#incremental backup
	c=`ls -dl  /home/mysql_data/incremental_bak/* |wc -l`
	nfile=`ls -td /home/mysql_data/incremental_bak/*|head -1`

	if [[ $c -ge 1 ]];then
		#$Inb $Login --use-memory=$Mem  --incremental $I_bak --incremental-dir $nfile
		$Inb $Login --incremental $I_bak --incremental-dir $nfile
	else
		#first time to run incremental bakcup
		#$Inb $Login --use-memory=$Mem  --incremental $I_bak --incremental-dir $F_bak
		$Inb $Login --incremental $I_bak --incremental-dir $F_bak
	fi
else
	#full backup
	$Inb $Login $F_bak
fi
