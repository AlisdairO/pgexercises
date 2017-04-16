|QUESTIONNAME|
Simple aggregation
|QUESTION|
You'd like to get the signup date of your last member.  How can you retrieve this information?
|QUERY|
select max(joindate) as latest
	from cd.members;
|ANSWER|
<p>This is our first foray into SQL's aggregate functions.  They're used to extract information about whole groups of rows, and allow us to easily ask questions like:</p>

<ul>
<li>What's the most expensive facility to maintain on a monthly basis?
<li>Who has recommended the most new members?
<li>How much time has each member spent at our facilities?
</ul>

<p>The <c>MAX</c> aggregate function here is very simple: it receives all the possible values for joindate, and outputs the one that's biggest.  There's a lot more power to aggregate functions, which you will come across in future exercises.</p>
|HINT|
Look up the SQL aggregate function <c>MAX</c>
|SORTED|
0
|PAGEID|
48B782DB-FAA6-4124-82AF-4E2AFF1044B5
|WRITEABLE|
0
