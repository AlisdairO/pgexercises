|QUESTIONNAME|
Return a count of bookings for each month
|QUESTION|
Return a count of bookings for each month, sorted by month
|QUERY|
select date_trunc('month', starttime) as month, count(*)
	from cd.bookings
	group by month
	order by month
|ANSWER|
<p>This one is a fairly simple reuse of concepts we've seen before.  We simply count the number of bookings, and aggregate by the booking's start time, truncated to the month.</p>
|HINT|
You're probably going to want the date_trunc function again.
|SORTED|
1
|PAGEID|
98eed3b2-229a-11e3-ad0b-0023df7f7ec4
|WRITEABLE|
0
