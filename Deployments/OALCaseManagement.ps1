start-transcript
restore-spsite "http://fdc1s-sp23appt1:83/" -path "\\fdc1s-sp23wfed3\e$\Backups\OALCaseMgmt.bak" -force -Confirm:$false -databasename WSS_OALCaseMgmt_Content 
stop-transcript