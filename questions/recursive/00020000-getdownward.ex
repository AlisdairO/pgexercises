|QUESTIONNAME|
Find the downward recommendation chain for member ID 1
|QUESTION|
Find the downward recommendation chain for member ID 1: that is, the members they recommended, the members those members recommended, and so on.  Return member ID and name, and order by ascending member id.
|QUERY|
with recursive recommendeds(memid) as (
	select memid from cd.members where recommendedby = 1
	union all
	select mems.memid
		from recommendeds recs
		inner join cd.members mems
			on mems.recommendedby = recs.memid
)
select recs.memid, mems.firstname, mems.surname
	from recommendeds recs
	inner join cd.members mems
		on recs.memid = mems.memid
order by memid
|ANSWER|
<p>This is a pretty minor variation on the previous question.  The essential difference is that we're now heading in the opposite direction.  One interesting point to note is that unlike the previous example, this CTE produces multiple rows per iteration, by virtue of the fact that we're heading down the recommendation tree (following all branches) rather than up it.</p>
|HINT|
Read up on <c><a href="http://www.postgresql.org/docs/current/static/queries-with.html">WITH RECURSIVE</a></c>.
|SORTED|
1
|PAGEID|
4a1e6e0c-2856-11e3-8bd1-0023df7f7ec4
|WRITEABLE|
0
