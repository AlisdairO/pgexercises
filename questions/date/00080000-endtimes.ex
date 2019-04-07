|QUESTIONNAME|
Work out the end time of bookings
|QUESTION|
Return a list of the start and end time of the last 10 bookings (ordered by the time at which they end, followed by the time at which they start) in the system.
|QUERY|
select starttime, starttime + slots*(interval '30 minutes') endtime
	from cd.bookings
	order by endtime desc, starttime desc
	limit 10
|ANSWER|
<p>This question simply returns the start time for a booking, and a calculated end time which is equal to <c>start time + (30 minutes * slots)</c>.  Note that it's perfectly okay to multiply intervals.</p>
<p>The other thing you'll notice is the use of order by and limit to get the last ten bookings.  All this does is order the bookings by the (descending) time at which they end, and pick off the top ten.</p>
|HINT|
You can multiply an interval by the number of slots in a booking.
|SORTED|
1
|PAGEID|
7d327298-223e-11e3-b1bb-0023df7f7ec4
|WRITEABLE|
0
