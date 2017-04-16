|QUESTIONNAME|
Produce a list of costly bookings, using a subquery
|QUESTION|
The <a href="./threejoin2.html">Produce a list of costly bookings</a> exercise contained some messy logic: we had to calculate the booking cost in both the <c>WHERE</c> clause and the <c>CASE</c> statement.  Try to simplify this calculation using subqueries.  For reference, the question was:</p>
<p><i>How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30?  Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0.  Include in your output the name of the facility, the name of the member formatted as a single column, and the cost.  Order by descending cost.</i>
|QUERY|
select member, facility, cost from (
	select 
		mems.firstname || ' ' || mems.surname as member,
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
			bks.starttime < '2012-09-15'
	) as bookings
	where cost > 30
order by cost desc;
|ANSWER|
<p>This answer provides a mild simplification to the previous iteration: in the no-subquery version, we had to calculate the member or guest's cost in both the <c>WHERE</c> clause and the <c>CASE</c> statement.  In our new version, we produce an inline query that calculates the total booking cost for us, allowing the outer query to simply select the bookings it's looking for.  For reference, you may also see subqueries in the <c>FROM</c> clause referred to as <i>inline views</i>.</p>
|HINT|
Your answer will be similar to the referenced exercise.  Use a subquery in the <c>FROM</c> clause to generate a result set that calculates the total cost of each booking.  The outer query can then select the bookings it's interested in.
|SORTED|
0
|PAGEID|
4C85AC8E-6F45-457C-B9C9-41C07C57A39D
|WRITEABLE|
0
