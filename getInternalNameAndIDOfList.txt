$web = Get-SPWeb https://fdc1s-sp23wfed2.ferc.gov/piw
$list = $web.Lists["PIWList"]

$list.Fields | Select Title, InternalName | sort InternalName | out-file c:\users\lnguyen\desktop\temp\listfields.txt

NotePad c:\users\lnguyen\desktop\temp\listfields.txt