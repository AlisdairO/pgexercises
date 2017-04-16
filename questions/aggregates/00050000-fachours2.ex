|QUESTIONNAME|
Output the facility id that has the highest number of slots booked
|QUESTION|
Output the facility id that has the highest number of slots booked. For bonus points, try a version without a <c>LIMIT</c> clause.  This version will probably look messy!
|QUERY|
select facid, sum(slots) as "Total Slots"
	from cd.bookings
	group by facid
order by sum(slots) desc
LIMIT 1;
|ANSWER|
<p>Let's start off with what's arguably the simplest way to do this: produce a list of facility IDs and the total number of slots used, order by the total number of slots used, and pick only the top result.</p>

<p>It's worth realising, though, that this method has a significant weakness.  In the event of a tie, we will still only get one result!  To get all the relevant results, we might try using the <c>MAX</c> aggregate function, something like below:</p>

<sql>select facid, max(totalslots) from (
	select facid, sum(slots) as totalslots    
		from cd.bookings    
		group by facid
	) as sub group by facid
</sql>

<p>The intent of this query is to get the highest totalslots value and its associated facid(s).  Unfortunately, this just won't work!  In the event of multiple facids having the same number of slots booked, it would be ambiguous which facid should be paired up with the single (or <i>scalar</i>) value coming out of the <c>MAX</c> function.  This means that Postgres will tell you that facid ought to be in a <c>GROUP BY</c> section, which won't produce the results we're looking for.</p>

<p>Let's take a first stab at a working query:</p>

<sql>
select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
	having sum(slots) = (select max(sum2.totalslots) from
		(select sum(slots) as totalslots
		from cd.bookings
		group by facid
		) as sum2);
</sql>

<p>The query produces a list of facility IDs and number of slots used, and then uses a <c>HAVING</c> clause that works out the maximum totalslots value.  We're essentially saying: 'produce a list of facids and their number of slots booked, and filter out all the ones that doen't have a number of slots booked equal to the maximum.'</p>

<p>Useful as <c>HAVING</c> is, however, our query is pretty ugly.  To improve on that, let's introduce another new concept: <a href="http://www.postgresql.org/docs/current/static/queries-with.html">Common Table Expressions</a> (CTEs).  CTEs can be thought of as allowing you to define a database view inline in your query.  It's really helpful in situations like this, where you're having to repeat yourself a lot. </p>

<p>CTEs are declared in the form <c>WITH CTEName as (SQL-Expression)</c>.  You can see our query redefined to use a CTE below:</p>

<sql>
with sum as (select facid, sum(slots) as totalslots
	from cd.bookings
	group by facid
)
select facid, totalslots 
	from sum
	where totalslots = (select max(totalslots) from sum);
</sql>

<p>You can see that we've factored out our repeated selections from cd.bookings into a single CTE, and made the query a lot simpler to read in the process!</p>

<p>BUT WAIT.  There's more.  It's also possible to complete this problem using Window Functions.  We'll leave these until later, but even better solutions to problems like these are available.</p>

<p>That's a lot of information for a single exercise.  Don't worry too much if you don't get it all right now - we'll reuse these concepts in later exercises.</p>

|HINT|
Consider the use of the <c>LIMIT</c> keyword combined with <c>ORDER BY</c>.  For the <c>LIMIT</c>-less version, you'll probably want to investigate the <c>HAVING</c> keyword.  Be aware that the latter version is difficult!
|SORTED|
1
|PAGEID|
D9CE3ED7-8B51-4B36-8E05-298C8205EFB4
|WRITEABLE|
0
