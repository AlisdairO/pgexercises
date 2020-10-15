|QUESTIONNAME|
Delete a member from the cd.members table
|QUESTION|
We want to remove member 37, who has never made a booking, from our database. How can we achieve that?
|QUERY|
delete from cd.members where memid = 37;
|ANSWER|
<p>This exercise is a small increment on our previous one. Instead of deleting all bookings, this time we want to be a bit more targeted, and delete a single member that has never made a booking. To do this, we simply have to add a <c>WHERE</c> clause to our command, specifying the member we want to delete. You can see the parallels with <c>SELECT</c> and <c>UPDATE</c> statements here.

<p>There's one interesting wrinkle here. Try this command out, but substituting in member id 0 instead. This member has made many bookings, and you'll find that the delete fails with an error about a foreign key constraint violation. This is an important concept in relational databases, so let's explore a little further.

<p>Foreign keys are a mechanism for defining relationships between columns of different tables. In our case we use them to specify that the memid column of the bookings table is related to the memid column of the members table. The relationship (or 'constraint') specifies that for a given booking, the member specified in the booking <b>must</b> exist in the members table. It's useful to have this guarantee enforced by the database: it means that code using the database can rely on the presence of the member. It's hard (even impossible) to enforce this at higher levels: concurrent operations can interfere and leave your database in a broken state.

<p>PostgreSQL supports various different kinds of constraints that allow you to enforce structure upon your data. For more information on constraints, check out the PostgreSQL documentation on <a href="https://www.postgresql.org/docs/current/static/ddl-constraints.html">foreign keys</a>
|HINT|
Take a look at the <c>DELETE</c> statement in the PostgreSQL docs.
|SORTED|
1
|PAGEID|
1a596ce6-0839-412b-b00a-5f8a66499cbb
|WRITEABLE|
1
|RETURNTABLE|
cd.members
