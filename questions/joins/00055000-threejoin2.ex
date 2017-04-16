|QUESTIONNAME|
Produce a list of costly bookings
|QUESTION|
How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30?  Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0.  Include in your output the name of the facility, the name of the member formatted as a single column, and the cost.  Order by descending cost, and do not use any subqueries.
|QUERY|
select mems.firstname || ' ' || mems.surname as member, 
	facs.name as facility, 
	case 
		when mems.memid = 0 then
			bks.slots*facs.guestcost
		else
			bks.slots*facs.membercost
	end as cost
        from
                cd.members mems                
                inner join cd.bookings bks
                        on mems.memid = bks.memid
                inner join cd.facilities facs
                        on bks.facid = facs.facid
        where
		bks.starttime >= '2012-09-14' and 
		bks.starttime < '2012-09-15' and (
			(mems.memid = 0 and bks.slots*facs.guestcost > 30) or
			(mems.memid != 0 and bks.slots*facs.membercost > 30)
		)
order by cost desc;
|ANSWER|
<p>This is a bit of a complicated one!  While its more complex logic than we've used previously, there's not an awful lot to remark upon.  The <c>WHERE</c> clause restricts our output to sufficiently costly rows on 2012-09-14, remembering to distinguish between guests and others.  We then use a <c>CASE</c> statement in the column selections to output the correct cost for the member or guest.</p>
|HINT|
As before, this answer requires multiple joins.  It's more complex <c>WHERE</c> logic than you're used to, and will require a <c>CASE</c> statement in the column selections!
|SORTED|
0
|PAGEID|
0AC4E3E2-A77E-403E-B75E-99273CDBE06B
|WRITEABLE|
0
