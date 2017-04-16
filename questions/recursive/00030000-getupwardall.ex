|QUESTIONNAME|
Produce a CTE that can return the upward recommendation chain for any member
|QUESTION|
Produce a CTE that can return the upward recommendation chain for any member.  You should be able to <c>select recommender from recommenders where member=x</c>.  Demonstrate it by getting the chains for members 12 and 22.  Results table should have member and recommender, ordered by member ascending, recommender descending.
|QUERY|
with recursive recommenders(recommender, member) as (
	select recommendedby, memid
		from cd.members
	union all
	select mems.recommendedby, recs.member
		from recommenders recs
		inner join cd.members mems
			on mems.memid = recs.recommender
)
select recs.member member, recs.recommender, mems.firstname, mems.surname
	from recommenders recs
	inner join cd.members mems		
		on recs.recommender = mems.memid
	where recs.member = 22 or recs.member = 12
order by recs.member asc, recs.recommender desc
|ANSWER|
<p>This question requires us to produce a CTE that can calculate the upward recommendation chain for any user.  Most of the complexity of working out the answer is in realising that we now need our CTE to produce two columns: one to contain the member we're asking about, and another to contain the members in their recommendation tree.  Essentially what we're doing is producing a table that flattens out the recommendation hierarchy.</p>
<p>Since we're looking to produce the chain for every user, our initial statement needs to select data for each user: their ID and who recommended them.  Subsequently, we want to pass the member field through each iteration without changing it, while getting the next recommender.  You can see that the recursive part of our statement hasn't really changed, except to pass through the 'member' field.</p>
|HINT|
Your initial statement should return all the recommendedby and memid fields in the members table.
|SORTED|
1
|PAGEID|
524202ce-2856-11e3-bbef-0023df7f7ec4
|WRITEABLE|
0
