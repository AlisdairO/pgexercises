|QUESTIONNAME|
Find the upward recommendation chain for member ID 27
|QUESTION|
Find the upward recommendation chain for member ID 27: that is, the member who recommended them, and the member who recommended that member, and so on.  Return member ID, first name, and surname.  Order by descending member id.
|QUERY|
with recursive recommenders(recommender) as (
	select recommendedby from cd.members where memid = 27
	union all
	select mems.recommendedby
		from recommenders recs
		inner join cd.members mems
			on mems.memid = recs.recommender
)
select recs.recommender, mems.firstname, mems.surname
	from recommenders recs
	inner join cd.members mems
		on recs.recommender = mems.memid
order by memid desc
|ANSWER|
<p><c>WITH RECURSIVE</c> is a fantastically useful piece of functionality that many developers are unaware of.  It allows you to perform queries over hierarchies of data, which is very difficult by other means in SQL.  Such scenarios often leave developers resorting to multiple round trips to the database system.</p>
<p>You've seen <c>WITH</c> before.  The Common Table Expressions (CTEs) defined by <c>WITH</c> give you the ability to produce inline views over your data.  This is normally just a syntactic convenience, but the <c>RECURSIVE</c> modifier adds the ability to join against results already produced to produce even more.  A recursive <c>WITH</c> takes the basic form of:</p>

<sql>WITH RECURSIVE NAME(columns) as (
	&lt;initial statement&gt;
	UNION ALL 
	&lt;recursive statement&gt;
)</sql>
<p>The initial statement populates the initial data, and then the recursive statement runs repeatedly to produce more.  Each step of the recursion can access the CTE, but it sees within it only the data produced by the previous iteration.  It repeats until an iteration produces no additional data.</c>
<p>The most simple example of a recursive <c>WITH</c> might look something like this:</p>
<sql>
with recursive increment(num) as (
	select 1
	union all
	select increment.num + 1 from increment where increment.num < 5
)
select * from increment;
</sql>
<p>The initial statement produces '1'.  The first iteration of the recursive statement sees this as the content of <c>increment</c>, and produces '2'.  The next iteration sees the content of <c>increment</c> as '2', and so on.  Execution terminates when the recursive statement produces no additional data.</p>

<p>With the basics out of the way, it's fairly easy to explain our answer here.  The initial statement gets the ID of the person who recommended the member we're interested in.  The recursive statement takes the results of the initial statement, and finds the ID of the person who recommended them.  This value gets forwarded on to the next iteration, and so on.</p>

<p>Now that we've constructed the recommenders CTE, all our main <c>SELECT</c> statement has to do is get the member IDs from recommenders, and join to them members table to find out their names.</p>
|HINT|
Read up on <c><a href="http://www.postgresql.org/docs/current/static/queries-with.html">WITH RECURSIVE</a></c>.
|SORTED|
1
|PAGEID|
de08311c-2846-11e3-8be6-0023df7f7ec4
|WRITEABLE|
0
