|QUESTIONNAME|
More aggregation
|QUESTION|
You'd like to get the first and last name of the last member(s) who signed up - not just the date.  How can you do that?
|QUERY|
select firstname, surname, joindate
	from cd.members
	where joindate = 
		(select max(joindate) 
			from cd.members);
|ANSWER|
<p>In the suggested approach above, you use a <i>subquery</i> to find out what the most recent joindate is.  This subquery returns a <i>scalar</i> table - that is, a table with a single column and a single row.  Since we have just a single value, we can substitute the subquery anywhere we might put a single constant value.  In this case, we use it to complete the <c>WHERE</c> clause of a query to find a given member.

<p>You might hope that you'd be able to do something like below:</p>

<sql>select firstname, surname, max(joindate)
        from cd.members</sql>

<p>Unfortunately, this doesn't work.  The <c>MAX</c> function doesn't restrict rows like the <c>WHERE</c> clause does - it simply takes in a bunch of values and returns the biggest one.  The database is then left wondering how to pair up a long list of names with the single join date that's come out of the max function, and fails.  Instead, you're left having to say 'find me the row(s) which have a join date that's the same as the maximum join date'.</p>

<p>As mentioned by the hint, there's other ways to get this job done - one example is below.  In this approach, rather than explicitly finding out what the last joined date is, we simply order our members table in descending order of join date, and pick off the first one.  Note that this approach does not cover the extremely unlikely eventuality of two people joining at the exact same time :-).

<sql>select firstname, surname, joindate
	from cd.members
order by joindate desc
limit 1;</sql>
|HINT|
You may find you need a subquery to get this done - although other methods exist!
|SORTED|
1
|PAGEID|
22B4AFEF-A54A-4080-AC6F-8A9C8E3C7EC6
|WRITEABLE|
0
