makecert.exe -n "CN=FERC SharePoint Development Root,O=FERC,OU=Development,L=Washington,S=DC,C=US" -pe -ss Root -sr LocalMachine -sky exchange -m 120 -a sha1 -len 2048 -r
makecert.exe -n "CN=*.dev.spapps.ferc.gov" -pe -ss My -sr LocalMachine -sky exchange -m 120 -in "FERC SharePoint Development Root" -is Root -ir LocalMachine -a sha1 -eku 1.3.6.1.5.5.7.3.1
