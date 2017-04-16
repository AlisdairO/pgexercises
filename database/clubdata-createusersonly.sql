CREATE USER pgexercises with password '' VALID UNTIL 'infinity';
CREATE USER pgeadmin with password '' VALID UNTIL 'infinity';
ALTER USER pgexercises SET statement_timeout = 750;
ALTER USER pgeadmin SET statement_timeout = 60000;
