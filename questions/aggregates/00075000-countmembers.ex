|QUESTIONNAME|
Produce a list of member names, with each row containing the total member count
|QUESTION|
Produce a list of member names, with each row containing the total member count.  Order by join date, and include guest members.
|QUERY|
select count(*) over(), firstname, surname
	from cd.members
order by joindate
|ANSWER|
<p>Using the knowledge we've built up so far, the most obvious answer to this is below.  We use a subquery because otherwise SQL will require us to group by firstname and surname, producing a different result to what we're looking for.</p>

<sql>
select (select count(*) from cd.members) as count, firstname, surname
	from cd.members
order by joindate
</sql>

<p>There's nothing at all wrong with this answer, but we've chosen a different approach to introduce a new concept called window functions.  Window functions provide enormously powerful capabilities, in a form often more convenient than the standard aggregation functions. While this exercise is only a toy, we'll be working on more complicated examples in the near future.</p>

<p>Window functions operate on the result set of your (sub-)query, after the <c>WHERE</c> clause and all standard aggregation.  They operate on a <i>window</i> of data.  By default this is unrestricted: the entire result set, but it can be restricted to provide more useful results.  For example, suppose instead of wanting the count of all members, we want the count of all members who joined in the same month as that member:</p>

<sql>
select count(*) over(partition by date_trunc('month',joindate)),
	firstname, surname
	from cd.members
order by joindate
</sql>

<p>In this example, we partition the data by month.  For each row the window function operates over, the window is any rows that have a joindate in the same month.  The window function thus produces a count of the number of members who joined in that month.</p>

<p>You can go further.  Imagine if, instead of the total number of members who joined that month, you want to know what number joinee they were that month.  You can do this by adding in an <c>ORDER BY</c> to the window function:</p>

<sql>
select count(*) over(partition by date_trunc('month',joindate) order by joindate),
	firstname, surname
	from cd.members
order by joindate
</sql>

<p>The <c>ORDER BY</c> changes the window again.  Instead of the window for each row being the entire partition, the window goes from the start of the partition to the current row, and not beyond.  Thus, for the first member who joins in a given month, the count is 1.  For the second, the count is 2, and so on.</p>

<p>One final thing that's worth mentioning about window functions: you can have multiple unrelated ones in the same query.  Try out the query below for an example - you'll see the numbers for the members going in opposite directions!  This flexibility can lead to more concise, readable, and maintainable queries.</p>

<sql>
select count(*) over(partition by date_trunc('month',joindate) order by joindate asc), 
	count(*) over(partition by date_trunc('month',joindate) order by joindate desc), 
	firstname, surname
	from cd.members
order by joindate
</sql>

<p>Window functions are extraordinarily powerful, and they will change the way you write and think about SQL.  Make good use of them!</p>

|HINT|
Read up on the <c>COUNT</c> window function.
|SORTED|
1
|PAGEID|
1DAA4B87-48BB-49A3-AC62-EB2EC1A11FB2
|WRITEABLE|
0
