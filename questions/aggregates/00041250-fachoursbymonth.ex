|QUESTIONNAME|
List the total slots booked per facility in a given month
|QUESTION|
Produce a list of the total number of slots booked per facility in the month of September 2012.  Produce an output table consisting of facility id and slots, sorted by the number of slots.
|QUERY|
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	where
		starttime >= '2012-09-01'
		and starttime < '2012-10-01'
	group by facid
order by sum(slots);
|ANSWER|
<p>This is only a minor alteration of our previous example.  Remember that aggregation happens after the <c>WHERE</c> clause is evaluated: we thus use the <c>WHERE</c> to restrict the data we aggregate over, and our aggregation only sees data from a single month.</p>
|HINT|
You can restrict the data that goes into your aggregate functions using the <c>WHERE</c> clause.
|SORTED|
1
|PAGEID|
C875DDEF-6559-4E2A-979E-AB8EA43E1B3F
|WRITEABLE|
0
