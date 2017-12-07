|QUESTIONNAME|
List the total slots booked per facility per month
|QUESTION|
Produce a list of the total number of slots booked per facility per month in the year of 2012.  Produce an output table consisting of facility id and slots, sorted by the id and month.
|QUERY|
select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	from cd.bookings
	where extract(year from starttime) = 2012
	group by facid, month
order by facid, month;
|ANSWER|
<p>The main piece of new functionality in this question is the <c>EXTRACT</c> function.  <c>EXTRACT</c> allows you to get individual components of a timestamp, like day, month, year, etc.  We group by the output of this function to provide per-month values.  An alternative, if we needed to distinguish between the same month in different years, is to make use of the <c>DATE_TRUNC</c> function, which truncates a date to a given granularity.</p>
<p>It's also worth noting that this is the first time we've truly made use of the ability to group by more than one column.</p>
|HINT|
Take a look at the <c>EXTRACT</c> function.
|SORTED|
1
|PAGEID|
9D932BE5-29DC-4B4B-A418-00E9E9751CF1
|WRITEABLE|
0
