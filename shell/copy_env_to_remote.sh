#!/bin/sh
if [ $# -lt 1 ]; then
	echo "Usage: $0 <remote-host-name> <user-name>"
	exit
fi
################### functions #####################
function run_cmd(){
	echo $1
	#$1
	$1
	return $?
}

function package_env(){
	echo "package env..."
	
	if [ -f $ZIP ]; then
		cmd="rm -rf $ZIP"
		run_cmd "$cmd"
	fi
	
	if [ -f $VIMRC ]; then
		cmd="zip -j $ZIP $VIMRC" 
		run_cmd "$cmd"
	fi
	
	if [ -f $SHRC ]; then
		cmd="zip -u -j $ZIP $SHRC" 
		run_cmd "$cmd"
	fi
	echo "package env SUCCEED"
}
################### functions #####################

REMOTE_MACHINE=$1
NAME=$2
if [ -z $NAME ]; then
	NAME=`whoami`
fi
VIMRC=$HOME/.vimrc
SHRC=$HOME/.bash_profile
ZIP="${NAME}.zip"
package_env
cmd="scp $ZIP ${NAME}@${REMOTE_MACHINE}:."
run_cmd "$cmd"
# be careful for this command 
cmd="source /etc/profile; unzip -o $ZIP; rm -rf $ZIP"
HOST="${NAME}@${REMOTE_MACHINE}"
echo "ssh $HOST $cmd"
ssh $HOST $cmd
#ssh ${NAME}@${REMOTE_MACHINE} $cmd
#run_cmd "$cmd"
