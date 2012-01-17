# couch_orcl
### A CouchDB Client for Oracle PL/SQL
##### Zekeriya KOC <zekzekus@gmail.com>

* what does couch_orcl library have?
    * CDB_CONNECTION (type)
        * a connection object type to hold the information about couchdb server you are about to operate on.
        * it have two static methods to create and delete databases on a couchdb instance.
    * CDB_DOCUMENT (type)
        * a document type that inherits from JSON type of awesome [PL/JSON](http://sourceforge.net/projects/pljson/) library.
        * you can build a JSON document with additional attributes about couchdb. e.g. connection, doc id, doc rev, deleted status etc.
        * the instantiated doc object can save itself to a couchdb database or can delete itself from a couchdb database.
        * it can export itself as string and print out.
    * CDB_UTL (utility package)
        * methods to make various type of HTTP requests. (it can do very large requests and handle vary large responses).
        * it can return couchdb server information as json object.
        * it can return the information about a database as json object.
        * it can create and delete databases.
        * it can generate uuids.
    * CDB_SQL (operations with SQL statements)
        * it can return a collection of CDB_DOCUMENT objects from the results of an SQL query. (a little memory expensive)
        * it can send large result sets to couchdb using bulk document api. ready for really large result sets (tested with 1.5 million docs).
 
### Usage examples

* TODO