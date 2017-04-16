|QUESTIONNAME|
Classify facilities by value
|QUESTION|
Classify facilities into equally sized groups of high, average, and low based on their revenue. Order by classification and facility name.
|QUERY|
select name, case when class=1 then 'high'
		when class=2 then 'average'
		else 'low'
		end revenue
	from (
		select facs.name as name, ntile(3) over (order by sum(case
				when memid = 0 then slots * facs.guestcost
				else slots * membercost
			end) desc) as class
		from cd.bookings bks
		inner join cd.facilities facs
			on bks.facid = facs.facid
		group by facs.name
	) as subq
order by class, name;
|ANSWER|
<p>This exercise should mostly use familiar concepts, although we do introduce the <c>NTILE</c> window function. <c>NTILE</c> groups values into a passed-in number of groups, as evenly as possible.  It outputs a number from 1-&gt;number of groups.  We then use a <c>CASE</c> statement to turn that number into a label!</p>
|HINT|
Investigate the <c>NTILE</c> window function.
|SORTED|
1
|PAGEID|
AAD28EA4-D02C-49AB-B065-7A229D5BBE09
|WRITEABLE|
0
