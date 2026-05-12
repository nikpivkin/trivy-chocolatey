#!/usr/bin/env bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

file="trivy.nuspec"
powershell="tools/chocolateyinstall.ps1"
version="$1"

sed_binary="sed" 
awk_binary="awk" 

echo -e "${GREEN}Extracting version and id from $file...${NC}"
existingVersion=$($awk_binary -F'[><]' '/<version>/ {print $3}' "$file")
id=$($awk_binary -F'[><]' '/<id>/ {print $3}' "$file")
url64=https://github.com/aquasecurity/"$id"/releases/download/v"$version"/"$id"_"$version"_windows-64bit.zip
# checksum64_file=https://github.com/aquasecurity/"$id"/releases/download/v"$version"/"$id"_"$version"_checksums.txt
# checksum64=$(curl -sL "$checksum64_file" | grep windows-64bit.zip | awk '{print $1}')

printf "%-30s %s\n" "Version:" "${version}"
printf "%-30s %s\n" "ID:" "${id}"
printf "%-30s %s\n" "URL64:" "${url64}"
printf "%-30s %s\n" "Checksum64:" "${checksum64}"

# # Check if the file under the URL exists
# echo -e "${GREEN}Checking if the file under the URL exists...${NC}"
# if curl --output /dev/null --silent --head --fail "$url64"; then
# 	echo "File exists."
# else
# 	echo -e "${RED}File does not exist. Exiting.${NC}"
# 	exit 1
# fi

# # Check if the file under the URL has the same checksum
# echo -e "${GREEN}Checking if the file under the URL has the same checksum...${NC}"
# remote_checksum=$(curl -sL "$url64" | sha256sum | cut -d ' ' -f 1)
# if [ "$remote_checksum" == "$checksum64" ]; then
# 	echo "Checksums match."
# else
# 	echo -e "${RED}Checksums do not match. Exiting.${NC}"
# 	exit 1
# fi

if [ -n "$version" ]; then
	echo -e "${GREEN}Version and checksum are not empty. Updating $powershell...${NC}"
	"$sed_binary" -i "s|^\$version.*|\$version            = '$version'|g" "$powershell"
	# "$sed_binary" -i "s|^\$checksum64.*|\$checksum64         = '$checksum64'|g" "$powershell"
	echo "Updated $powershell with new version and checksum."
	echo -e "${GREEN}Updating $file...${NC}"
	"$sed_binary" -i "s|<version>.*</version>|<version>$version</version>|g" "$file"
	echo "Updated $file with new version."

else
	echo -e "${RED}Error: version or checksum is/are empty.${NC}"
	printf "%-30s %s\n" "Version:" "${version}"
	# printf "%-30s %s\n" "Checksum:" "${checksum64}"
	exit 1
fi
