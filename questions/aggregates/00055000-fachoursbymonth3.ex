|QUESTIONNAME|
List the total slots booked per facility per month, part 2
|QUESTION|
Produce a list of the total number of slots booked per facility per month in the year of 2012.  In this version, include output rows containing totals for all months per facility, and a total for all months for all facilities.  The output table should consist of facility id, month and slots, sorted by the id and month.  When calculating the aggregated values for all months and all facids, return null values in the month and facid columns.
|QUERY|
with bookings as (
	select facid, extract(month from starttime) as month, slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
)
select facid, month, sum(slots) from bookings group by facid, month
union all
select facid, null, sum(slots) from bookings group by facid
union all
select null, null, sum(slots) from bookings
order by facid, month;
|ANSWER|
<p>Despite all its many strengths, one aggregation feature that Postgres is missing is <c>ROLLUP</c>.  <c>ROLLUP</c> is designed to calculate questions like the one in this exercise, where you want to drill down to detail but also retrieve more coarsely aggregated data.  A rollup version of this query is quite simple, and would look something like:</p>
<sql>
select facid, extract(month from starttime) as month, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by rollup(facid, month)
order by facid, month;
</sql>
<p>Rollup can be simulated using the <c>UNION ALL</c> operator.  <c>UNION ALL</c> allows us to combine the output of multiple queries, provided they have the same number of columns, and that those columns have the same type.  All we need to do, then, is produce separate queries that output each level of aggregation we need: grouping by facid and month, facid, and nothing respectively.  A naive version of this will look like the below:</p>
<sql>
select facid, extract(month from starttime) as month, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by facid, month
union all
select facid, null, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by facid
union all
select null, null, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
order by facid, month;
</sql>
<p>In our final answer, we've improved upon this somewhat by factoring out the commonalities into a Common Table Expression.</p>
|HINT|
Consider the use of the SQL <c>UNION ALL</c> operator, noting that Postgres does not support the <c>ROLLUP</c> operator.
|SORTED|
1
|PAGEID|
7737A2D8-5BF5-40E9-8486-9396D8D7B098
