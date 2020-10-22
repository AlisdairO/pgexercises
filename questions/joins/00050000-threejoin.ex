|QUESTIONNAME|
Produce a list of all members who have used a tennis court
|QUESTION|
How can you produce a list of all members who have used a tennis court?  Include in your output the name of the court, and the name of the member formatted as a single column.  Ensure no duplicate data, and order by the member name followed by the facility name.
|QUERY|
select distinct mems.firstname || ' ' || mems.surname as member, facs.name as facility
	from 
		cd.members mems
		inner join cd.bookings bks
			on mems.memid = bks.memid
		inner join cd.facilities facs
			on bks.facid = facs.facid
	where
		facs.name in ('Tennis Court 2','Tennis Court 1')
order by member, facility
|ANSWER|
<p>This exercise is largely a more complex application of what you've learned in prior questions.  It's also the first time we've used more than one join, which may be a little confusing for some.  When reading join expressions, remember that a join is effectively a function that takes two tables, one labelled the left table, and the other the right.  This is easy to visualise with just one join in the query, but a little more confusing with two.</p>

<p>Our second <c>INNER JOIN</c> in this query has a right hand side of cd.facilities.  That's easy enough to grasp.  The left hand side, however, is the table returned by joining cd.members to cd.bookings.  It's important to emphasise this: the relational model is all about tables.  The output of any join is another table.  The output of a query is a table.  Single columned lists are tables.  Once you grasp that, you've grasped the fundamental beauty of the model.</p>
<p>As a final note, we do introduce one new thing here: the <c>||</c> operator is used to concatenate strings.</p>
|HINT|
This answer requires multiple joins.  To concatenate strings you can use the <c>||</c> operator.
|SORTED|
1
|PAGEID|
1E7B6EED-BDC5-4B46-829C-0E1B10BD8644
|WRITEABLE|
0
