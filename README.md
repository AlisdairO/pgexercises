PostgreSQL Exercises
=========

This is the code for the SQL tutorial site [PostgreSQL Exercises](http://pgexercises.com).  It's made using a simple static site generator and some template html files.

Directories/Files under this project root:
-----

- **database** - contains sample database configuration files, SQL file to create+populate pgexercises database.  
- **nginx** - contains sample nginx configurations files.  
- **questions** - contains the files that define the exercises.  These are used to generate static html files based on the templates under site/website.  
- **scripts** - various scripts to do stuff like generate the html files, upload them to the site, and so on.  
- **site** - web site files and html templates.  
- **SQLForwarder** - simple web application to send queries to and from the DB.  
- **dbdata.xlsx** - just an excel file containing all the db data.  


Instructions to get a dev environment working:
-----

Install nginx, apache tomcat 7, PostgreSQL, ant, perl.  

**Set a password**  

Modify database/clubdata.sql and database/context.xml to set a password of your choosing  

**Set up your database**  

> su - postgres  
> cd $PGEXERCISES\_HOME/database  
> psql -f clubdata.sql  

**Set up nginx**  

- Copy nginx/nginx-dev.conf and nginx/mime.type to your nginx config directory (e.g. /etc/nginx/).  
- Rename nginx-dev.conf to nginx.conf, and change the root location and SQLForwarder blocks to match your setup.  

**Configure SQL Forwarder servlet**  

- Modify the SQLForwarder/build.properties file to tell the build where to get the apache tomcat libraries  
- Run 'ant war' on the SQLForwarder project to get a WAR file in SQLForwarder/build/war  
- Copy war to $TOMCAT\_HOME/webapps 
- Copy the database/context.xml file to $TOMCAT\_HOME/conf, and modify it appropriately to point at the server/port Postgres uses (default is 5432), use the user name and password you've set up, and so on.  
- Copy the SQLForwarder/WebContent/WEB-INF/lib/postgresql-9.3-1100.jdbc4.jar file to $TOMCAT\_HOME/lib 

**Run the pgexercises build**  

The following should build your html files in site/website/questions:
> cd $PGEXERCISES\_HOME/scripts  
> ./processdocs.pl ../ 1  

**Start everything up**

Start postgres, tomcat, and nginx if not already started.  Hopefully you should be able to see a web page at your nginx port (default localhost:80)!
