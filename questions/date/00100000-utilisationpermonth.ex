|QUESTIONNAME|
Work out the utilisation percentage for each facility by month
|QUESTION|
Work out the utilisation percentage for each facility by month, sorted by name and month, rounded to 1 decimal place.  Opening time is 8am, closing time is 8.30pm.  You can treat every month as a full month, regardless of if there were some dates the club was not open.
|QUERY|
select name, month, 
	round((100*slots)/
		cast(
			25*(cast((month + interval '1 month') as date)
			- cast (month as date)) as numeric),1) as utilisation
	from  (
		select facs.name as name, date_trunc('month', starttime) as month, sum(slots) as slots
			from cd.bookings bks
			inner join cd.facilities facs
				on bks.facid = facs.facid
			group by facs.facid, month
	) as inn
order by name, month
|ANSWER|
<p>The meat of this query (the inner subquery) is really quite simple: an aggregation to work out the total number of slots used per facility per month.  If you've covered the rest of this section and the category on aggregates, you likely didn't find this bit too challenging.</p>
<p>This query does, unfortunately, have some other complexity in it: working out the number of days in each month.  We can calculate the number of days between two months by subtracting two timestamps with a month between them.  This, unfortunately, gives us back on interval datatype, which we can't use to do mathematics.  In this case we've worked around that limitation by converting our timestamps into <i>dates</i> before subtracting.  Subtracting date types gives us an integer number of days.</p>
<p>A alternative to this workaround is to convert the interval into an <i>epoch</i> value: that is, a number of seconds.  To do this use <c>EXTRACT(EPOCH FROM month)/(24*60*60)</c>.  This is arguably a much nicer way to do things, but is much less portable to other database systems.</p>
|HINT|
Remember different months have different lengths - you'll need to calculate the number of available slots in each month.  You need to find a way to retrieve an <i>integer</i> (rather than interval) number of days for the length of the month.
|SORTED|
1
|PAGEID|
0bd6fea0-2844-11e3-8dea-0023df7f7ec4
|WRITEABLE|
0
