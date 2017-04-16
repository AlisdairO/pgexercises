|QUESTIONNAME|
Produce a list of all members who have recommended another member
|QUESTION|
How can you output a list of all members who have recommended another member?  Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
|QUERY|
select distinct recs.firstname as firstname, recs.surname as surname
	from 
		cd.members mems
		inner join cd.members recs
			on recs.memid = mems.recommendedby
order by surname, firstname;
|ANSWER|
<p>Here's a concept that some people find confusing: you can join a table to itself!  This is really useful if you have columns that reference data in the same table, like we do with recommendedby in cd.members.</p>
<p>If you're having trouble visualising this, remember that this works just the same as any other inner join.  Our join takes each row in members that has a recommendedby value, and looks in members again for the row which has a matching member id.  It then generates an output row combining the two members entries.  This looks like the diagram below:</p>
</div></div>
<div class="row"><div class="span12 answerdiv">
<p><img src="../../assets/innerjoin.png"></img></p>
</div></div>
<div class="row"><div class="span8 answerdiv">
<p>Note that while we might have two 'surname' columns in the output set, they can be distinguished by their table aliases.  Once we've selected the columns that we want, we simply use <c>DISTINCT</c> to ensure that there are no duplicates.
|HINT|
This is an <c>INNER JOIN</c>, just like the previous exercises.
|SORTED|
1
|PAGEID|
72632294-4D39-4342-8BE4-162B883F5798
|WRITEABLE|
0
