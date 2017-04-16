|QUESTIONNAME|
Insert multiple rows of data into a table
|QUESTION|
<p>In the previous exercise, you learned how to add a facility. Now you're going to add multiple facilities in one command. Use the following values:</p>
<ul><li>facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
<li>facid: 10, Name: 'Squash Court 2', membercost: 3.5, guestcost: 17.5, initialoutlay: 5000, monthlymaintenance: 80.</ul>
|QUERY|
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    values
        (9, 'Spa', 20, 30, 100000, 800),
        (10, 'Squash Court 2', 3.5, 17.5, 5000, 80);
|ANSWER|
<p><c>VALUES</c> can be used to generate more than one row to insert into a table, as seen in this example. Hopefully it's clear what's going on here: the output of <c>VALUES</c> is a table, and that table is copied into cd.facilities, the table specified in the <c>INSERT</c> command.</p>

<p>While you'll most commonly see <c>VALUES</c> when inserting data, Postgres allows you to use <c>VALUES</c> wherever you might use a <c>SELECT</c>. This makes sense: the output of both commands is a table, it's just that <c>VALUES</c> is a bit more ergonomic when working with constant data.</p>

<p>Similarly, it's possible to use <c>SELECT</c> wherever you see a <c>VALUES</c>. This means that you can <c>INSERT</c> the results of a <c>SELECT</c>. For example:</p>

<sql>
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    SELECT 9, 'Spa', 20, 30, 100000, 800
    UNION ALL
        SELECT 10, 'Squash Court 2', 3.5, 17.5, 5000, 80;
</sql>

<p>In later exercises you'll see us using <c>INSERT ... SELECT</c> to generate data to insert based on the information already in the database.</p>
|HINT|
<c>VALUES</c> can be used to generate more than one row.
|SORTED|
1
|PAGEID|
cf4a345f-93a6-4920-a87c-e3957f6c3d18
|WRITEABLE|
1
|RETURNTABLE|
cd.facilities
