#!/bin/bash
#myfslinstaller.sh

set -e
set -u

#myfslinstaller function takes the parameters (OS and Version) and downloads the corresponding file of fsl installer from the server.
if [[ $# -ne 0 && $# -ne 4 ]] ;then
 echo -e "Please pass four valid parameters:(Version,OS,Installation Directory,Download Directory)\nUsage: myFslInstallerScript.sh 5.0.6 CentOS6 /usr/local/etc /usr/local/download/"
  exit 1
fi

if [[ $# -eq 0 ]] ;then
 echo "Warning:No parameters passed.Taking default values"
fi

version=${1:-5.0.6}
os=${2:-CentOS6}
installDir=${3:-/usr/local/src}
downloadDir=${4:-/usr/local/etc/}

function myFslInstaller {
 echo "###----FSL INSTALLER---###"
 echo "Version of FSL:$version"
 echo "OS:$os"
 echo "Installation Directory:$installDir"
 echo "Download Directory:$downloadDir"

 if [[ ! ("$version" =~ ^[0-9].+$) ]]; then 
   echo 'This does not look like a valid version number'
   exit 1
 fi

 url=$(getDownloadURL "$version" "$os")

 downloadFileName=$(echo "$url"|sed 's#.*/##')
 echo "$downloadFileName"

 fslDownloadAbsoluteFileName=$downloadDir"$downloadFileName"
 echo "$fslDownloadAbsoluteFileName"

 valid=$(validURL "$url")
 echo "Valid: $valid"
 if [[ "$valid" != "true" ]]; then
   echo "File doesn't exist in server"
   exit 1
 fi

 mkdir -p "$downloadDir"
 if [ ! -f "$fslDownloadAbsoluteFileName" ]; then
   download "$url" "$fslDownloadAbsoluteFileName"
 fi

 md5Url=$(getMD5Url "$version" "$os")
 echo "$md5Url"

 md5DownloadAbsoluteFileName=$downloadDir"$version"".txt"

 download "$md5Url" "$md5DownloadAbsoluteFileName"

 validateMD5 "$md5DownloadAbsoluteFileName" "$fslDownloadAbsoluteFileName"

 untar "$fslDownloadAbsoluteFileName"

}

function getMD5Url {
 version="$1"
 os="$2"
 os=`echo ${os} | tr '[:upper:]' '[:lower:]'`
 main_url='http://fsl.fmrib.ox.ac.uk/fsldownloads/md5sums/'
 echo "$main_url""fsl-""$version-""$os""_64.tar.gz.md5"
}

#Parameters: Version and OS
#Function getDownloadURL will return the url for downloading the requested version.
function getDownloadURL {
 version="$1"
 os="$2"
 os=`echo ${os} | tr '[:upper:]' '[:lower:]'`
 #echo "$os"
 main_url='http://fsl.fmrib.ox.ac.uk/fsldownloads/oldversions/'
 echo "$main_url""fsl-""$version""-""$os""_64.tar.gz"
}

#Parameter:Download URL
#Function validURL will return true or false according to the status of the url
function validURL {
 if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then 
   echo "true";
 fi
}

# Download function downloads the file in corresponding directory which we pass as the second parameter.
function download {
 downloadUrl="$1"
 fileName="$2"
 #echo "Downloading.."
 wget $downloadUrl -O $fileName
}

#validateMD5 function is used for vaidating the md5 checksum value of the downloaded file with the value obtained from the server.
function validateMD5 {
 echo "Validating MD5 values ..."
 md5FileName="$1"
 fslFileName="$2"
 value=$(awk '{print $1}' "$md5FileName")
 #value=$(<"$md5FileName")
 #echo "MD5"
 #echo "$value"
 localmd5=$(md5sum < "$fslFileName" | awk '{print $1}')
 #echo "$localmd5"
 rm "$md5FileName"
 if [[ "$value" != "$localmd5" ]];then
   echo "MD5 sums don't match"
   exit 1
 fi
}

# unpack in install dir
function untar {
 echo "Unpacking installation files ..."
 fslFileName="$1"
 mkdir -p "$installDir" && tar xf "$fslFileName" -C "$installDir"
}


#Function call
 myFslInstaller
