#!/bin/bash
#check root permissions
echo > /etc/fstab
if ! test -w /etc/fstab
then
	echo 'ERROR: No Root Access.'
	exit 1
fi
if ! test -w /usr/local/lib/libntfs.9.dylib
then
	echo 'Installing Library...'
	sudo mkdir /usr/local/lib
	sudo cp libntfs.9.dylib /usr/local/lib/libntfs.9.dylib
fi
if test $# -eq 0
then
	echo 'Edits /etc/fstab to make the drive writable and then mounts it.'
	echo
	echo 'Usage: ntfsmount.sh label'
	echo 'Install the Script: ntfsmount.sh --install'
	exit 1
fi
labelName="$@"
if [ "$labelName" == "--install" ];
then
	echo 'Installing the Script in /usr/bin'
	sudo cp ntfsmount.sh /usr/bin/ntfsmount.sh
	echo 'Script installed. Please Re-Launch it.'
	exit 0
fi
valid=`diskutil info "$labelName" | wc -l`
if test $valid -eq 1
then
	echo 'ERROR: Invalid Label.'
	echo 'If your label has a space in it try writing it using single quotes!'
	echo
	echo 'Example: ntfs_mount.sh '\''label with spaces'\'
	exit 1
fi
valid2=`diskutil list | grep "$labelName" | wc -l`
if test $valid2 -gt 1
then
	echo 'ERROR: More than one device has this label.'
	echo 'Please disconnect all other devices with the same name.'
	exit 1
fi

#inject patch
valid3=`diskutil info "$labelName" | grep UUID | wc -l`
if test $valid3 -eq 0
then
  valid5=`cat /etc/fstab | grep "$labelName" | wc -l`
    if test $valid5 -eq 0
    then
		echo 'WARNING: Device has no UUID. Using Label...'
		echo 'Injecting LABEL...'
	  	echo >> /etc/fstab
		echo LABEL="$labelName" none ntfs rw,auto,nobrowse >> /etc/fstab
    fi
  else
  	uuid=`diskutil info "$labelName" | grep UUID | cut -d: -f2| cut -d' ' -f15`
  	valid4=`cat /etc/fstab | grep $uuid | wc -l`
  	if test $valid4 -eq 0
  	then
  		echo 'Injecting UUID...'
  		echo >> /etc/fstab
		echo UUID=$uuid none ntfs rw,auto,nobrowse >> /etc/fstab
	fi
fi

#mount-unmount device
echo 'Unmount Disk Partition'
diskutil unmount "$labelName"
echo 'Mount Disk Partition'
diskutil mount "$labelName"

if ! test $? -eq 0
then
	echo
	echo
	echo '!! NTFS PARTITION NEEDS TO BE CHECKED AND REPAIRED !!'
	echo
	echo 'This happens when you disconnect the drive from Windows without do a safe-remove first. MacoS cannot mount a disk in this state.'
	echo 'You can either repair the drive from Windows, or let this script repair it for you.'
	echo
    echo 'WARNING: POTENTIAL DATA LOSS / PARTITION DAMAGE. Proceed at your own risk.'
	read -p "Press Y if you want to continue: " -n 1 -r
	echo    # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		echo
		echo 'Aborting... Reverting changes.'
		echo > /etc/fstab
		echo 'Done. Please reconnect the device to mount it Read-Only again.'
	    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
	fi
	echo 'Do not interrupt the process.'
	address=`diskutil info "$labelName" | grep 'Device Node' | cut -d: -f2 | cut -d' ' -f15`
	echo 'Unmounting all Disk Partitions...'
	diskutil unmountDisk $address
	echo 'Fixing partition errors...'
	sudo ./ntfsfix $address
	echo 'Done!'
	diskutil mount "$labelName"
fi


#open device in /Volumes
echo 'Opening Device...'
open /Volumes/"$labelName"
echo 'Cleaning FSTAB Config...'
echo > /etc/fstab
echo 'DONE!'
echo
echo 'Device will not show up in Finder.'
echo 'If you need to open it again: Go->Go to Folder and then write /Volumes/devicelabel'
exit 0
