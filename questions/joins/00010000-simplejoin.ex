|QUESTIONNAME|
Retrieve the start times of members' bookings
|QUESTION|
How can you produce a list of the start times for bookings by members named 'David Farrell'?
|QUERY|
select bks.starttime 
	from 
		cd.bookings bks
		inner join cd.members mems
			on mems.memid = bks.memid
	where 
		mems.firstname='David' 
		and mems.surname='Farrell';
|ANSWER|
<p>The most commonly used kind of join is the <c>INNER JOIN</c>.  What this does is combine two tables based on a join expression - in this case, for each member id in the members table, we're looking for matching values in the bookings table.  Where we find a match, a row combining the values for each table is returned.  Note that we've given each table an <i>alias</i> (bks and mems).  This is used for two reasons: firstly, it's convenient, and secondly we might join to the same table several times, requiring us to distinguish between columns from each different time the table was joined in.</p>
<p>Let's ignore our select and where clauses for now, and focus on what the <c>FROM</c> statement produces.  In all our previous examples, FROM has just been a simple table.  What is it now?  Another table!  This time, it's produced as a composite of bookings and members.  You can see a subset of the output of the join below:</p>
</div></div>
<div class="row answerdiv">
<div class="span12">
<p><img src="../../assets/joinbefore.gif", title="Output of a from clause of a join" /></p>
</div></div>
<div class="row answerdiv">
<div class="span8">
<p>For each member in the members table, the join has found all the matching member ids in the bookings table.  For each match, it's then produced a row combining the row from the members table, and the row from the bookings table.</p>
<p>Obviously, this is too much information on its own, and any useful question will want to filter it down.  In our query, we use the start of the <c>SELECT</c> clause to pick columns, and the WHERE clause to pick rows, as illustrated below:</p>
</div></div>
<div class="row answerdiv">
<div class="span12">
<p><img src="../../assets/join1.png"></img></p>
</div></div>
<div class="row answerdiv">
<div class="span8">
<p>That's all we need to find David's bookings!  In general, I encourage you to remember that the output of the FROM clause is essentially one big table that you then filter information out of.  This may sound inefficient - but don't worry, under the covers the DB will be behaving much more intelligently :-).</p>

<p>One final note: there's two different syntaxes for inner joins.  I've shown you the one I prefer, that I find more consistent with other join types.  You'll commonly see a different syntax, shown below:</p>
<sql>
select bks.starttime
        from
                cd.bookings bks,
                cd.members mems
        where
                mems.firstname='David'
                and mems.surname='Farrell'
                and mems.memid = bks.memid;
</sql>
<p>This is functionally exactly the same as the approved answer.  If you feel more comfortable with this syntax, feel free to use it!</p>
|HINT|
Take a look at the documentation for <c>INNER JOIN</c>.
|SORTED|
0
|PAGEID|
E3C88AF9-53BC-460D-9D06-ED66630FACBC
|WRITEABLE|
0
