SELECT  
         hd.incident_number as [Incident Number],
         hd.description as Description,
         CASE 
		   WHEN hd.assignee IS NULL then 'No Assignee'
		   ELSE hd.assignee
         END as Assignee,   
	 hd.status,
         CASE 
           when hd.status = 1 then 'Assigned'
           when hd.status = 2 then 'In Progress'
           when hd.status = 3 then 'Pending'
           when hd.status = 4 then 'Resolved'
           when hd.status = 5 then 'Closed'
           when hd.status = 6 then 'Cancelled'
           else 'Unknown Status'
         end as status_str,        

         DATEADD(ss, hd.reported_date - 3600 * 5, CONVERT(DATETIME, '1970-01-01 00:00:00', 102)) as [Reported Date],
         SUBSTRING(hd.detailed_decription, 1,2000) as Notes

  FROM HPD_Help_Desk hd

  WHERE assigned_support_company = 'IT Contract Support' 
  and hd.status not in(4,5,6)
  and DATEADD(ss, hd.reported_date - 3600 * 5, CONVERT(DATETIME, '1970-01-01 00:00:00', 102)) > DATEADD(day,-10,GETDATE())
  ORDER BY [Reported Date] desc