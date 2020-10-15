|QUESTIONNAME|
Delete all bookings
|QUESTION|
As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?
|QUERY|
delete from cd.bookings;
|ANSWER|
<p>The <c>DELETE</c> statement does what it says on the tin: deletes rows from the table. Here, we show the command in its simplest form, with no qualifiers. In this case, it deletes everything from the table. Obviously, you should be careful with your deletes and make sure they're always limited - we'll see how to do that in the next exercise.

<p>An alternative to unqualified <c>DELETEs</c> is the following:

<sql>
truncate cd.bookings;
</sql>

<p><c>TRUNCATE</c> also deletes everything in the table, but does so using a quicker underlying mechanism. It's not <a href="https://www.postgresql.org/docs/current/static/mvcc-caveats.html">perfectly safe in all circumstances</a>, though, so use judiciously. When in doubt, use <c>DELETE</c>.

|HINT|
Take a look at the <c>DELETE</c> statement in the PostgreSQL docs.
|SORTED|
1
|PAGEID|
a281e531-33d4-4672-93d9-428982bdb75a
|WRITEABLE|
1
|RETURNTABLE|
cd.bookings
