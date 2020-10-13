|QUESTIONNAME|
Work out the start times of bookings for tennis courts
|QUESTION|
How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'?  Return a list of start time and facility name pairings, ordered by the time.
|QUERY|
select bks.starttime as start, facs.name as name
	from 
		cd.facilities facs
		inner join cd.bookings bks
			on facs.facid = bks.facid
	where 
		facs.name in ('Tennis Court 2','Tennis Court 1') and
		bks.starttime >= '2012-09-21' and
		bks.starttime < '2012-09-22'
order by bks.starttime;
|ANSWER|
<p>This is another <c>INNER JOIN</c> query, although it has a fair bit more complexity in it!  The <c>FROM</c> part of the query is easy - we're simply joining facilities and bookings tables together on the facid.  This produces a table where, for each row in bookings, we've attached detailed information about the facility being booked.</p>
<p>On to the <c>WHERE</c> component of the query.  The checks on starttime are fairly self explanatory - we're making sure that all the bookings start between the specified dates.  Since we're only interested in tennis courts, we're also using the <c>IN</c> operator to tell the database system to only give us back facility IDs 0 or 1 - the IDs of the courts.  There's other ways to express this: We could have used <c>where facs.facid = 0 or facs.facid = 1</c>, or even <c>where facs.name like 'Tennis%'</c>.</p>
<p>The rest is pretty simple: we <c>SELECT</c> the columns we're interested in, and <c>ORDER BY</c> the start time.</p>
|HINT|
This is another <c>INNER JOIN</c>. You may also want to think about using the <c>IN</c> or <c>LIKE</c> operators to limit the results you get back.
|SORTED|
1
|PAGEID|
AB9B1D9D-E13D-461E-9D24-03563CFA350B
|WRITEABLE|
0
