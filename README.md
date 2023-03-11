**THIS DOES NOT WORK FOR MAC OS v10.13+**

*Just format your drive in exFat.*


# MacOS NTFS Mounter
Simple script to enable R/W mount for an NTFS device in MacOS using FSTAB, only when it's needed. 
This Script also perform a chkdsk in case the NTFS partition is "damaged", when diskutil fails to mount it as R/W because the device was previously removed from a Windows PC without safe-remove.

**IMPORTANT:** NTFS partition Fix is made using ntfsfix. This tool is a part of NTFS-3G package and it's already included in this package. You **don't need to** install NTFS-3G in order to use this script. During script-execution it halts if the partition cannot be mounted, and asks you for the fix permission. 

**Proceed at your own risk, I am not responsible in case the partition gets damaged, or you lose your data.** If you prefer you can fix the partition using Windows (a popup will show up when you connect the device), then safe-remove it, and use it on MacOS. Script will mount it R/W without need to fix the partition.

## Usage

Download and Extract. Set -x permissions to the script with: 

`sudo chmod +x ntfsmount.sh`


Connect the disk and then from Terminal:

`sudo ./ntfsmount.sh labelname`

**Note:** labelname is the name of the disk as you can see it from Finder. Label can have spaces in it. You can write it with quotes or without, it will be automatically recognized. 

## How it works

Script needs sudo permissions to edit `/etc/fstab` file. Everytime the scipt ends, after the device has been mounted in R/W mode, the `/etc/fstab` file get's erased, so next time you will connect the device it will be mounted as Read-Only again, unless you exec the script again.

Once the partition is mounted in R/W mode you can't see it from Finder. If you need to open again the partition (without connecting-disconnecting the device), simply go to Finder and then, on Menu Bar, `Go -> Go to folder` and write `/Volumes/label name`. A window will show up. 

## How to install

If you want you can install the script so you can call it using Terminal without having to Change Directory first. 

cd to Script Directory, then: 

`sudo ./ntfsmount.sh --install`

Then usage is:

`sudo ntfsmount.sh labelname`


## Changelog
2017-10-25
* Added --install option
* Tested on MacOS High Sierra 10.13

2017-09-09
* Initial Release
* Tested on MacOS Sierra 10.12.6
* No pre-requisites. 
