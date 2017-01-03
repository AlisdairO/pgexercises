|QUESTIONNAME|
List the total slots booked per facility per month, part 2
|QUESTION|
Produce a list of the total number of slots booked per facility per month in the year of 2012.  In this version, include output rows containing totals for all months per facility, and a total for all months for all facilities.  The output table should consist of facility id, month and slots, sorted by the id and month.  When calculating the aggregated values for all months and all facids, return null values in the month and facid columns.
|QUERY|
select facid, extract(month from starttime) as month, sum(slots)
from cd.bookings
where extract(year from starttime) = 2012
group by rollup (facid, month)
order by facid, month
|ANSWER|
<p>As of version 9.5, Postgres finally supports grouping sets, rollup and cube. Rollup is just a shorthand for grouping sets, so we could have also written the following query:</p>
<sql>
select facid, extract(month from starttime) as month, sum(slots)
from cd.bookings
where extract(year from starttime) = 2012
group by grouping sets ((facid, month), (facid), ())
order by facid, month
</sql>
<p>Rollup can be simulated using the <c>UNION ALL</c> operator.  <c>UNION ALL</c> allows us to combine the output of multiple queries, provided they have the same number of columns, and that those columns have the same type.  All we need to do, then, is produce separate queries that output each level of aggregation we need: grouping by facid and month, facid, and nothing respectively.  A naive version of this will look like the below:</p>
<sql>
select facid, extract(month from starttime) as month, sum(slots) as slots
	from cd.bookings
	where extract(year from b.starttime) = 2012
	group by facid, month
union all
select facid, null, sum(slots) as slots
	from cd.bookings
	where extract(year from b.starttime) = 2012
	group by facid
union all
select null, null, sum(slots) as slots
	from cd.bookings
	where extract(year from b.starttime) = 2012
order by facid, month;
</sql>
<p>This can be further simplified by using Common Table Expressions, but as of Postgres 9.5, the <c>ROLLUP</c> operator should be preferred.</p>
|HINT|
Consider the use of the SQL <c>ROLLUP</c> operator.
|SORTED|
1
|PAGEID|
7737A2D8-5BF5-40E9-8486-9396D8D7B098
