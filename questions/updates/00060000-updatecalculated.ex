|QUESTIONNAME|
Update a row based on the contents of another row
|QUESTION|
We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
|QUERY|
update cd.facilities facs
    set
        membercost = (select membercost * 1.1 from cd.facilities where facid = 0),
        guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0)
    where facs.facid = 1;
|ANSWER|
<p>Updating columns based on calculated data is not too intrinsically difficult: we can do so pretty easily using subqueries. You can see this approach in our selected answer.

<p>As the number of columns we want to update increases, standard SQL can start to get pretty awkward: you don't want to be specifying a separate subquery for each of 15 different column updates. Postgres provides a nonstandard extension to SQL called <c>UPDATE...FROM</c> that addresses this: it allows you to supply a <c>FROM</c> clause to generate values for use in the <c>SET</c> clause. Example below:

<sql>
update cd.facilities facs
    set
        membercost = facs2.membercost * 1.1,
        guestcost = facs2.guestcost * 1.1
    from (select * from cd.facilities where facid = 0) facs2
    where facs.facid = 1;
</sql>

|HINT|
Take a look at <c>UPDATE FROM</c> in the PostgreSQL documentation.
|SORTED|
1
|PAGEID|
fabb545a-0c85-4c5d-a713-a156d673ccdb
|WRITEABLE|
1
|RETURNTABLE|
cd.facilities
