|QUESTIONNAME|
Produce a list of all members, along with their recommender
|QUESTION|
How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).  
|QUERY|
select mems.firstname as memfname, mems.surname as memsname, recs.firstname as recfname, recs.surname as recsname
	from 
		cd.members mems
		left outer join cd.members recs
			on recs.memid = mems.recommendedby
order by memsname, memfname;
|ANSWER|
<p>Let's introduce another new concept: the <c>LEFT OUTER JOIN</c>.  These are best explained by the way in which they differ from inner joins.  Inner joins take a left and a right table, and look for matching rows based on a join condition (<c>ON</c>).  When the condition is satisfied, a joined row is produced.  A <c>LEFT OUTER JOIN</c> operates similarly, except that if a given row on the left hand table doesn't match anything, it still produces an output row.  That output row consists of the left hand table row, and a bunch of <c>NULLS</c> in place of the right hand table row.</p>
<p>This is useful in situations like this question, where we want to produce output with optional data.  We want the names of all members, and the name of their recommender <i>if that person exists</i>.  You can't express that properly with an inner join.</p>
<p>As you may have guessed, there's other outer joins too.  The <c>RIGHT OUTER JOIN</c> is much like the <c>LEFT OUTER JOIN</c>, except that the left hand side of the expression is the one that contains the optional data.  The rarely-used <c>FULL OUTER JOIN</c> treats both sides of the expression as optional.
|HINT|
Try investigating the <c>LEFT OUTER JOIN</c>.
|SORTED|
1
|PAGEID|
FD2FCC4E-391D-4C3A-B066-B61F86A6A14D
|WRITEABLE|
0
