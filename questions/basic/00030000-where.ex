|QUESTIONNAME|
Control which rows are retrieved
|QUESTION|
How can you produce a list of facilities that charge a fee to members?
|QUERY|
select * from cd.facilities where membercost > 0;
|ANSWER|
<p>The <c>FROM</c> clause is used to build up a set of candidate rows to read results from.  In our examples so far, this set of rows has simply been the contents of a table.  In future we will explore joining, which allows us to create much more interesting candidates.
<p>Once we've built up our set of candidate rows, the <c>WHERE</c> clause allows us to filter for the rows we're interested in - in this case, those with a membercost of more than zero.  As you will see in later exercises, <c>WHERE</c> clauses can have multiple components combined with boolean logic - it's possible to, for instance, search for facilities with a cost greater than 0 and less than 10.  The filtering action of the <c>WHERE</c> clause on the facilities table is illustrated below:
<div class="row answerdiv">
<div class="span12">
<p><img src="../../assets/whereclause.png", title="Action of a WHERE clause on a set of candidate rows" /></p>
</div></div>
<div class="row answerdiv">
<div class="span8">
|HINT|
The <c>WHERE</c> clause allows you to filter the rows that you want to retrieve.
|SORTED|
0
|PAGEID|
91465B99-7B5A-4970-B582-79913E41D421
|WRITEABLE|
0
