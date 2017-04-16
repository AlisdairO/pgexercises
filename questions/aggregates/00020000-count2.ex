|QUESTIONNAME|
Count the number of expensive facilities
|QUESTION|
Produce a count of the number of facilities that have a cost to guests of 10 or more.
|QUERY|
select count(*) from cd.facilities where guestcost >= 10;
|ANSWER|
<p>This one is only a simple modification to the previous question: we need to weed out the inexpensive facilities.  This is easy to do using a <c>WHERE</c> clause. Our aggregation can now only see the expensive facilities.
</p>
|HINT|
You'll need to add a <c>WHERE</c> clause to the answer of the previous question.
|SORTED|
0
|PAGEID|
0F0BAA3C-9FA0-47DC-8A8F-1FBA363E5DE0
|WRITEABLE|
0
