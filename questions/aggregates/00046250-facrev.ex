|QUESTIONNAME|
Find the total revenue of each facility
|QUESTION|
Produce a list of facilities along with their total revenue.  The output table should consist of facility name and revenue, sorted by revenue.  Remember that there's a different cost for guests and members!
|QUERY|
select facs.name, sum(slots * case
			when memid = 0 then facs.guestcost
			else facs.membercost
		end) as revenue
	from cd.bookings bks
	inner join cd.facilities facs
		on bks.facid = facs.facid
	group by facs.name
order by revenue;
|ANSWER|
The only real complexity in this query is that guests (member ID 0) have a different cost to everyone else.  We use a case statement to produce the cost for each session, and then sum each of those sessions, grouped by facility.
|HINT|
Remember the <c>CASE</c> statement!
|SORTED|
1
|PAGEID|
43D1F46E-9701-439A-8982-617C7410FE89
|WRITEABLE|
0
