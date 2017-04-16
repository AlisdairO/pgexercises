|QUESTIONNAME|
Classify results into buckets
|QUESTION|
How can you produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on if their monthly maintenance cost is more than $100?  Return the name and monthly maintenance of the facilities in question.
|QUERY|
select name, 
	case when (monthlymaintenance > 100) then
		'expensive'
	else
		'cheap'
	end as cost
	from cd.facilities;
|ANSWER|
<p>This exercise contains a few new concepts.  The first is the fact that we're doing computation in the area of the query between <c>SELECT</c> and <c>FROM</c>.  Previously we've only used this to select columns that we want to return, but you can put anything in here that will produce a single result per returned row - including subqueries.
<p>The second new concept is the <c>CASE</c> statement itself.  <c>CASE</c> is effectively like if/switch statements in other languages, with a form as shown in the query.  To add a 'middling' option, we would simply insert another <c>when...then</c> section.
<p>Finally, there's the <c>AS</c> operator.  This is simply used to label columns or expressions, to make them display more nicely or to make them easier to reference when used as part of a subquery.
|HINT|
Try looking up the SQL <c>CASE</c> statement.
|SORTED|
0
|PAGEID|
E5607899-7323-4E7A-8D7E-FCC0EA32838B
|WRITEABLE|
0
