|QUESTIONNAME|
Count the number of facilities
|QUESTION|
For our first foray into aggregates, we're going to stick to something simple.  We want to know how many facilities exist - simply produce a total count.
|QUERY|
select count(*) from cd.facilities;
|ANSWER|
<p>Aggregation starts out pretty simply!  The SQL above selects everything from our facilities table, and then counts the number of rows in the result set.  The count function has a variety of uses: 

<ul>
<li><c>COUNT(*)</c> simply returns the number of rows
<li><c>COUNT(address)</c> counts the number of non-null addresses in the result set.
<li>Finally, <c>COUNT(DISTINCT address)</c> counts the number of <i>different</i> addresses in the facilities table.
</ul>
</p>

<p>The basic idea of an aggregate function is that it takes in a column of data, performs some function upon it, and outputs a <i>scalar</i> (single) value.  There are a bunch more aggregation functions, including <c>MAX</c>, <c>MIN</c>, <c>SUM</c>, and <c>AVG</c>.  These all do pretty much what you'd expect from their names :-).</p>

<p>One aspect of aggregate functions that people often find confusing is in queries like the below:</p>

<sql>
select facid, count(*) from cd.facilities
</sql>

<p>Try it out, and you'll find that it doesn't work.  This is because count(*) wants to collapse the facilities table into a single value - unfortunately, it can't do that, because there's a lot of different facids in cd.facilities - Postgres doesn't know which facid to pair the count with.</p>

<p>Instead, if you wanted a query that returns all the facids along with a count on each row, you can break the aggregation out into a subquery as below:</p>

<sql>
select facid, 
	(select count(*) from cd.facilities)
	from cd.facilities
</sql>

<p>When we have a subquery that returns a scalar value like this, Postgres knows to simply repeat the value for every row in cd.facilities.</p>

|HINT|
Try investigating the SQL <c>COUNT</c> function
|SORTED|
0
|PAGEID|
E7789C0F-CEB2-4D7B-8897-8D8CA5478F7D
|WRITEABLE|
0
