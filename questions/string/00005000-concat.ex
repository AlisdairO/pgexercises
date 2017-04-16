|QUESTIONNAME|
Format the names of members
|QUESTION|
Output the names of all members, formatted as 'Surname, Firstname'
|QUERY|
select surname || ', ' || firstname as name from cd.members
|ANSWER|
Building strings in sql is similar to other languages, with the exception of the concatenation operator: ||.  Some systems (like SQL Server) use +, but || is the SQL standard.
|HINT|
Use the <c>||</c> operator to concatenate strings
|SORTED|
0
|PAGEID|
1e806c68-1974-11e4-aa6a-efecb22b3579
|WRITEABLE|
0
