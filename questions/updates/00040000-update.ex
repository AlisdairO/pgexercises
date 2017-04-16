|QUESTIONNAME|
Update some existing data
|QUESTION|
We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.
|QUERY|
update cd.facilities
    set initialoutlay = 10000
    where facid = 1;
|ANSWER|
<p>The <c>UPDATE</c> statement is used to alter existing data. If you're familiar with <c>SELECT</c> queries, it's pretty easy to read: the <c>WHERE</c> clause works in exactly the same fashion, allowing us to filter the set of rows we want to work with. These rows are then modified according to the specifications of the <c>SET</c> clause: in this case, setting the initial outlay.</p>

<p>The <c>WHERE</c> clause is extremely important. It's easy to get it wrong or even omit it, with disastrous results. Consider the following command:</p>

<sql>
update cd.facilities
    set initialoutlay = 10000;
</sql>

<p>There's no <c>WHERE</c> clause to filter for the rows we're interested in. The result of this is that the update runs on every row in the table! This is rarely what we want to happen.</p>
|HINT|
You can alter existing data using the <c>UPDATE</c> statement.
|SORTED|
1
|PAGEID|
badeb19f-3590-4cdc-ad7c-911ae9d4b675
|WRITEABLE|
1
|RETURNTABLE|
cd.facilities
