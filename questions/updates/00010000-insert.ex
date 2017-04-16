|QUESTIONNAME|
Insert some data into a table
|QUESTION|
<p>The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:</p>
<ul><li>facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.</ul>
|QUERY|
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    values (9, 'Spa', 20, 30, 100000, 800);
|ANSWER|
<p><c>INSERT INTO ... VALUES</c> is the simplest way to insert data into a table. There's not a whole lot to discuss here: <c>VALUES</c> is used to construct a row of data, which the <c>INSERT</c> statement inserts into the table. It's a simple as that.</p>

<p>You can see that there's two sections in parentheses. The first is part of the <c>INSERT</c> statement, and specifies the columns that we're providing data for. The second is part of <c>VALUES</c>, and specifies the actual data we want to insert into each column.</p>

<p>If we're inserting data into every column of the table, as in this example, explicitly specifying the column names is optional. As long as you fill in data for all columns of the table, in the order they were defined when you created the table, you can do something like the following:</p>

<sql>
insert into cd.facilities values (9, 'Spa', 20, 30, 100000, 800);
</sql>

<p>Generally speaking, for SQL that's going to be reused I tend to prefer being explicit and specifying the column names.</p>
|HINT|
<c>INSERT</c> can be used to insert data into a table.
|SORTED|
1
|PAGEID|
eeb585a7-bdb9-411d-a1ce-057769c30346
|WRITEABLE|
1
|RETURNTABLE|
cd.facilities
