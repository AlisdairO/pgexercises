|QUESTIONNAME|
Retrieve specific columns from a table
|QUESTION|
You want to print out a list of all of the facilities and their cost to members.  How would you retrieve a list of only facility names and costs? 
|QUERY|
select name, membercost from cd.facilities;
|ANSWER|
<p>For this question, we need to specify the columns that we want.  We can do that with a simple comma-delimited list of column names specified to the select statement.  All the database does is look at the columns available in the <c>FROM</c> clause, and return the ones we asked for, as illustrated below</p>
<div class="row answerdiv">
<div class="span12">
<p><img src="../../assets/select.png", title="Specifying column names to a select statement" /></p>
</div></div>
<div class="row answerdiv">
<div class="span8">
<p>Generally speaking, for non-throwaway queries it's considered desirable to specify the names of the columns you want in your queries rather than using *.  This is because your application might not be able to cope if more columns get added into the table.</p>
|HINT|
The select statement allows you to specify column names to retrieve.
|SORTED|
0
|PAGEID|
E57B52A5-0749-4E25-A64F-04CE0007A897
|WRITEABLE|
0
