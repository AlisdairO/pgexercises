|QUESTIONNAME|
Insert calculated data into a table
|QUESTION|
<p>Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else:</p>
<ul><li>Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.</ul>
|QUERY|
insert into cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
    select (select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;
|ANSWER|
<p>In the previous exercises we used <c>VALUES</c> to insert constant data into the facilities table. Here, though, we have a new requirement: a dynamically generated ID. This gives us a real quality of life improvement, as we don't have to manually work out what the current largest ID is: the SQL command does it for us.</p>

<p>Since the <c>VALUES</c> clause is only used to supply constant data, we need to replace it with a query instead. The <c>SELECT</c> statement is fairly simple: there's an inner subquery that works out the next facid based on the largest current id, and the rest is just constant data. The output of the statement is a row that we insert into the facilities table.</p>

<p>While this works fine in our simple example, it's not how you would generally implement an incrementing ID in the real world. Postgres provides <c>SERIAL</c> types that are auto-filled with the next ID when you insert a row. As well as saving us effort, these types are also safer: unlike the answer given in this exercise, there's no need to worry about concurrent operations generating the same ID.</p>
|HINT|
You can calculate data to insert using subqueries.
|SORTED|
1
|PAGEID|
4363ffe4-3c61-4445-a3bd-d8fcbd313d4c
|WRITEABLE|
1
|RETURNTABLE|
cd.facilities
