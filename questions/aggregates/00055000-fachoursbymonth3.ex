|QUESTIONNAME|
List the total slots booked per facility per month, part 2
|QUESTION|
Produce a list of the total number of slots booked per facility per month in the year of 2012.  In this version, include output rows containing totals for all months per facility, and a total for all months for all facilities.  The output table should consist of facility id, month and slots, sorted by the id and month.  When calculating the aggregated values for all months and all facids, return null values in the month and facid columns.
|QUERY|
select facid, extract(month from starttime) as month, sum(slots) as slots
	from cd.bookings
	where
		starttime >= '2012-01-01'
		and starttime < '2013-01-01'
	group by rollup(facid, month)
order by facid, month;
|ANSWER|
<p>When we are doing data analysis, we sometimes want to perform multiple levels of aggregation to allow ourselves to 'zoom' in and out to different depths. In this case, we might be looking at each facility's overall usage, but then want to dive in to see how they've performed on a per-month basis. Using the SQL we know so far, it's quite cumbersome to produce a single query that does what we want - we effectively have to resort to concatenating multiple queries using UNION ALL:</p>

<sql>select facid, extract(month from starttime) as month, sum(slots) as slots
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
order by facid, month;</sql>

<p>As you can see, each subquery performs a different level of aggregation, and we just combine the results. We can clean this up a lot by factoring out commonalities using a CTE:</p>

<sql>
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
</sql>

<p>This version is not excessively hard on the eyes, but it becomes cumbersome as the number of aggregation columns increases. Fortunately, PostgreSQL 9.5 introduced support for the <c>ROLLUP</c> operator, which we've used to simplify our accepted answer.</p>

<p><c>ROLLUP</c> produces a hierarchy of aggregations in the order passed into it: for example, <c>ROLLUP(facid, month)</c> outputs aggregations on (facid, month), (facid), and (). If we wanted an aggregation of all facilities for a month (instead of all months for a facility) we'd have to reverse the order, using <c>ROLLUP(month, facid)</c>. Alternatively, if we instead want all possible permutations of the columns we pass in, we can use <c>CUBE</c> rather than <c>ROLLUP</c>. This will produce (facid, month), (month), (facid), and ().</p>

<p><c>ROLLUP</c> and <c>CUBE</c> are special cases of <c>GROUPING SETS</c>. <c>GROUPING SETS</c> allow you to specify the exact aggregation permutations you want: you could, for example, ask for just (facid, month) and (facid), skipping the top-level aggregation.</p>
|HINT|
Look up Postgres' <c>ROLLUP</c> operator.
|SORTED|
1
|PAGEID|
7737A2D8-5BF5-40E9-8486-9396D8D7B098
|WRITEABLE|
0
