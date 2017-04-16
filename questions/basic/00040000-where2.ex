|QUESTIONNAME|
Control which rows are retrieved - part 2
|QUESTION|
How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost?  Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
|QUERY|
select facid, name, membercost, monthlymaintenance 
	from cd.facilities 
	where 
		membercost > 0 and 
		(membercost < monthlymaintenance/50.0);
|ANSWER|
<p>The <c>WHERE</c> clause allows us to filter for the rows we're interested in - in this case, those with a membercost of more than zero, and less than 1/50th of the monthly maintenance cost.  As you can see, the massage rooms are very expensive to run thanks to staffing costs!</p>
<p>When we want to test for two or more conditions, we use <c>AND</c> to combine them.  We can, as you might expect, use <c>OR</c> to test whether either of a pair of conditions is true.
<p>You might have noticed that this is our first query that combines a <c>WHERE</c> clause with selecting specific columns.  You can see in the image below the effect of this: the intersection of the selected columns and the selected rows gives us the data to return.  This may not seem too interesting now, but as we add in more complex operations like joins later, you'll see the simple elegance of this behaviour.</p>
<div class="row answerdiv">
<div class="span12">
<p><img src="../../assets/whereandselect.png", title="Specifying column names to a select statement" /></p>
</div></div>
<div class="row answerdiv">
<div class="span8">
|HINT|
The <c>WHERE</c> clause allows you to filter the rows that you want to retrieve.
|SORTED|
0
|PAGEID|
56E7C8E0-80DE-4CC5-8947-E3C15E347276
|WRITEABLE|
0
