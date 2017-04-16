|QUESTIONNAME|
Produce a list of all members, along with their recommender, using no joins.
|QUESTION|
How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
|QUERY|
select distinct mems.firstname || ' ' ||  mems.surname as member,
	(select recs.firstname || ' ' || recs.surname as recommender 
		from cd.members recs 
		where recs.memid = mems.recommendedby
	)
	from 
		cd.members mems
order by member;
|ANSWER|
<p>This exercise marks the introduction of subqueries.  Subqueries are, as the name implies, queries within a query.  They're commonly used with aggregates, to answer questions like 'get me all the details of the member who has spent the most hours on Tennis Court 1'.</p>
<p>In this case, we're simply using the subquery to emulate an outer join.  For every value of member, the subquery is run once to find the name of the individual who recommended them (if any).  A subquery that uses information from the outer query in this way (and thus has to be run for each row in the result set) is known as a <i>correlated subquery</i>.</p>
|HINT|
Answering this question correctly requires the use of a <i>subquery</i>
|SORTED|
1
|PAGEID|
699A3656-42C9-40AE-A56D-54DD6905FDEF
|WRITEABLE|
0
