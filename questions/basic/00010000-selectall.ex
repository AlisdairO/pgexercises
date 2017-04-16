|QUESTIONNAME|
Retrieve everything from a table
|QUESTION|
How can you retrieve all the information from the cd.facilities table?
|QUERY|
select * from cd.facilities;
|ANSWER|
<p>The <c>SELECT</c> statement is the basic starting block for queries that read information out of the database.  A minimal select statement is generally comprised of <c>select [some set of columns] from [some table or group of tables]</c>.
<p>In this case, we want all of the information from the facilities table.  The <c>from</c> section is easy - we just need to specify the <c>cd.facilities</c> table.  'cd' is the table's schema - a term used for a logical grouping of related information in the database.  
<p>Next, we need to specify that we want all the columns.  Conveniently, there's a shorthand for 'all columns' - <c>*</c>.  We can use this instead of laboriously specifying all the column names.
|HINT|
<c>select * </c> can be used to retrieve all columns from a table.
|SORTED|
0
|PAGEID|
15ACAD5C-9A3E-4D1A-9E83-3149C2FCFA4D
|WRITEABLE|
0
