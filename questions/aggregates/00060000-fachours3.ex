|QUESTIONNAME|
List the total hours booked per named facility
|QUESTION|
Produce a list of the total number of <i>hours</i> booked per facility, remembering that a slot lasts half an hour.  The output table should consist of the facility id, name, and hours booked, sorted by facility id.  Try formatting the hours to two decimal places.
|QUERY|
select facs.facid, facs.name,
	trim(to_char(sum(bks.slots)/2.0, '9999999999999999D99')) as "Total Hours"

	from cd.bookings bks
	inner join cd.facilities facs
		on facs.facid = bks.facid
	group by facs.facid, facs.name
order by facs.facid;
|ANSWER|
<p>There's a few little pieces of interest in this question.  Firstly, you can see that our aggregation works just fine when we join to another table on a 1:1 basis.  Also note that we group by both <c>facs.facid</c> and <c>facs.name</c>.  This is might seem odd: after all, since <c>facid</c> is the primary key of the <c>facilities</c> table, each <c>facid</c> has exactly one <c>name</c>, and grouping by both fields is the same as grouping by <c>facid</c> alone.  In fact, you'll find that if you remove <c>facs.name</c> from the <c>GROUP BY</c> clause, the query works just fine: Postgres works out that this 1:1 mapping exists, and doesn't insist that we group by both columns.</p>

<p>Unfortunately, depending on which database system we use, validation might not be so smart, and may not realise that the mapping is strictly 1:1.  That being the case, if there were multiple <c>name</c>s for each <c>facid</c> and we hadn't grouped by <c>name</c>, the DBMS would have to choose between multiple (equally valid) choices for the <c>name</c>.  Since this is invalid, the database system will insist that we group by both fields.  In general, I recommend grouping by all columns you don't have an aggregate function on: this will ensure better cross-platform compatibility.</p>

<p>Next up is the division.  Those of you familiar with MySQL may be aware that integer divisions are automatically cast to floats.  Postgres is a little more traditional in this respect, and expects you to tell it if you want a floating point division.  You can do that easily in this case by dividing by 2.0 rather than 2.</p>

<p>Finally, let's take a look at formatting.  The <c>TO_CHAR</c> function converts values to character strings.  It takes a formatting string, which we specify as (up to) lots of numbers before the decimal place, decimal place, and two numbers after the decimal place.  The output of this function can be prepended with a space, which is why we include the outer <c>TRIM</c> function.</p>
|HINT|
Remember that in Postgres, dividing two integers together causes an integer division.  Here you want a floating point division.  For formatting the hours, take a look at the <c>to_char</c> function, remembering to <c>trim</c> any leftover whitespace
|SORTED|
1
|PAGEID|
3B453BF9-ABD5-4C48-8EB5-3627FF8AAAA5
|WRITEABLE|
0
