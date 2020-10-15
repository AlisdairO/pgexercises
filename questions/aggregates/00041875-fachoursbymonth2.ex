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
<p>The main piece of new functionality in this question is the <c>EXTRACT</c> function.  <c>EXTRACT</c> allows you to get individual components of a timestamp, like day, month, year, etc.  We group by the output of this function to provide per-month values.  An alternative, if we needed to distinguish between the same month in different years, is to make use of the <c>DATE_TRUNC</c> function, which truncates a date to a given granularity. It's also worth noting that this is the first time we've truly made use of the ability to group by more than one column.</p>
<p>One thing worth considering with this answer: the use of the <c>EXTRACT</c> function in the <c>WHERE</c> clause has the potential to cause severe issues with performance on larger tables. If the timestamp column has a regular index on it, Postgres will not understand that it can use the index to speed up the query and will instead have to scan through the whole table. You've got a couple of options here:</p>
<ul>
<li>Consider creating an <a href="https://www.postgresql.org/docs/current/indexes-expressional.html">expression-based index</a> on the timestamp column. With appropriately specified indexes Postgres can use indexes to speed up <c>WHERE</c> clauses containing function calls.
<li>Alter the query to be a little more verbose, but use more standard comparisons, for example: 
<sql> select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by facid, month
order by facid, month;</sql>
Postgres is able to use an index using these standard comparisons without any additional assistance.
</ul>
|HINT|
Take a look at the <c>EXTRACT</c> function.
|SORTED|
1
|PAGEID|
9D932BE5-29DC-4B4B-A418-00E9E9751CF1
|WRITEABLE|
0
