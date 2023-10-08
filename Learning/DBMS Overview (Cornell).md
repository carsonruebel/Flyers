https://www.youtube.com/watch?v=4cWkVbC2bNE

* Overview (0:00 - 9:50)
	* SQL is supported by most relational database systems
	* Resources at 7:45
* SQL Intro (9:50 - 59:20)
	* DDL Data Definition Language (schema definition)
	* DML Data Manipulation Language (change/retrieve data)
	* TCL Transaction Control Language (TBD, grouping commands)
	* DCL Data Control Language (Assign data access rights)
	* DDL
		* Define the content you can insert in the DB (columns, data types, relation constraints)
			* eg CREATE TABLE Students(Sid int, Sname text, Gpa real);
		* Integrity constraints limit the content you can put in the DB
			* This can be added with ALTER Table or within CREATE TABLE
			* eg ALTER TABLE Students ADD PRIMARY KEY(Sid);
		* There can be two primary keys, it just means the combo of the two needs to be unique
		* Foreign keys link to primary keys in a different table
			* eg ALTER TABLE Enrollment ADD FOREIGN KEY(Sid) REFERENCES Students(Sid)
	* Inserting Data is done with INSERT INTO <table> VALUES (<value-list>)
			* This can also be done with partial data by calling out specific columns
			* Data can be loaded from a file via COPY command
		* Deleting data is done with DELETE FROM <table> WHERE <condition>
		* Updating data is done with UPDATE command
	* SQL (59:20 - 1:46:30)
		* How to use SELECT, FROM, JOIN, WHERE clauses
		* How to use aliases (Select S.Sname From Students S...)
		* <> Not equal to, In, Like, * and _ for multi and single char wildcards
		* AND OR and NOT keywords
		* Select * to select all columns
		* Can use math in SELECT statement eg. SELECT 3 * (Column + Column)
		* can assign new names to columns in SELECT statement
		* JOIN alternatives are USING (specify columns to join on that are same name)
			* NATURAL JOIN will join on all columns that have the same name
			* You can put the join condition in a WHERE statement instead of ON
		* Aggregation Queries
			* COUNT, SUM, AVG, MIN, MAX in SELECT statements
				* COUNT(*) vs COUNT(column) vs COUNT(DISTINCT column)
				* GROUP BY column-list - calculate aggregation by the specified column
					* eg. SELECT Count(*), Cname GROUP BY Cname
				* HAVING further filters the groups in GROUP BY
					* eg. HAVING count > 100
	* Advanced SQL (1:46:30 - 3:05:00)
		* ORDER BY & LIMIT statements
		* SQL uses Ternary (true, false, or unknown)
			* expression = true, false, or IS NULL (not = null)
		* JOINs
			* OUTER JOINs fill missing fields with NULL values
			* UNION combines two query results together (duplicates eliminated unless UNION ALL)
				* INTERSECT and EXCEPT returns the overlap or differences between two queries respectively
				* Note that UNIONs need to be union-compatible, meaning same columns and types
				* Queries can be used as part of another query, eg. a query in the FROM clause
					* These are called sub-queries
					* Correlated vs uncorrelated means sub-query is dependent on parent query (cannot run on it's own) vs uncorrelated it is a proper standalone query
				* Sub-Queries in Conditions
					* EXISTS(sq)
					* x IN (sq)
					* x >= ALL(sq)
					* x >= ANY(sq)
				* ==Correlated queries allow you to iterate the inner loop for each iteration of outer loop. Understand this part more==
					* Allows you to evaluate sub-query for a fixed row in the outer query
					* Decide whether outer row belongs in the result
	* Data Storage (3:05:00 - 3:54:18)
		* Due to costs and physical constraints, try to design algorithms to minimize data movement, and keep related data close together
		* Metadata of a db is stored in the database catalog
		* Content of a db is stored as collection of pages, each typically a few KB (not enough for an entire table)
		* Combination of pages storing one table is called a file
			* Could be stored as a linked list (pages pointing to one another)
			* Could use a directory with pointers to pages
		* Pages contain slots, which each store one table row (record)
			* Records can be referred via pageID & slotID
			* Slots can be fixed-length or variable-length
				* variable-length used for text and other variable-length attribute types
				* Packed representation means no unused slots allowed, upacked allows gaps
					* Unpacked needs bitmap to keep track of used slots, while packed just needs a count of used slots
				* Variable-length records need the page to maintain a directory of used slots, storing the first byte and the length of the slot
					* Records can be moved around freely, meaning regular compaction is allowed
			* Slots are further divided into fields to represent attributes/columns
		* Some newer systems can store data column-wise instead of row-wise
			* Beneficial if queries access only a few columns
	* Tree Indexes (3:54:18 - 5:03:32)
		* One table may have multiple indexes based on nature of common queries
			* Essentially creates a set of pages sorted on a specific attribute with pointers to page/slotID
			* Tree index adds additional pages for ranges that then point to the actual index page that points to the record slot
		* ==Leaf Pages dont make a lot of sense to me, what is the value add of linking index pages together over tree indexing?==
		* Composite keys are indexes consisting of multiple columns
			* Need priority of which attribute to use first (must match first before looking for second)
		* CREATE INDEX <index-name> on <table> (<columns>)
			* columns is a comma-separated column list
		* B+ Trees are popular for dynamic data sets to keep balance after insert/delete operations
	* Hash Indexes (5:03:32 - 5:52:45)
		* Evaluate hash function to find buckets (looking for a specific key)
		* Only useful for equality conditions (exact match)
		* Static vs Extendible vs Linear hashing - how the hashing works back-end (don't really care)
	* Query Processing Overview (5:52:45 - 10:40:35)
		* Buffer Manager is responsible for moving data between HDD and RAM
			* Needs to determine which pages are most valuable
			* Buffer Pool is managed by Buffer Manager - main memory reserved for DBMS broken into 'slots' that are the size of pages
				* Replacement Policy refers to the buffer pool determining which frames to keep
					* LRU = Least Recently Used - drop the page that hasn't been required for the longest period of time
		* Skipped until end because I don't care about this stuff
	* Transactions (10:40:35 - 12:16:04)
		* A transaction is a set of queries or changes that are connected
		* Define a transaction with BEGIN at the start and COMMIT at the end (in PostgreSQL)
		* ACID guarantees:
			* Atomicity (execute all or none)
			* Consistency (all constraints will be satisified eg. uniqueness of PK)
			* Isolation (changes by one user won't affect other users)
				* Simulates sequential execution
				* Interleaving is the process of ordering operations within a transaction to maintain isolation
				* There are different levels of isolation depending on your needs, as isolation can be expensive
			* Durability (changes are durable even in case of interruption)
				* Once the system says it is complete, the results are persistent
		* Concurrency Control is the way the DBMS allows multiple users to operate at the same time without causing data anomalies
			* This operates on a schedule of ordered steps depending on the needs of the system (cheap vs 'goodness')
			* SKIP SECTION ON SCHEDULES
	* Two-Phase Locking (12:16:04 - END)
		* SKIPPED REMAINDER BECAUSE I DONT CARE
	* Database Design (https://www.youtube.com/watch?v=lxEdaElkQhQ&t=0s - 3:07:28)
		* Requirements Analysis
			* Get info on use cases, business processes
		* Conceptual Design
			* Model of data to store in DB
			* Entity Relationship (ER) diagrams
		* Schema Normalization
			* Remove redundancy that was introduced in conceptual design
		* Physical Tuning
			* Performance tuning eg. creating indexes
		* ER Diagrams
			* Entities are things, people, etc.
				* Typically represented as a rectangle
			* Properties are connected to an entity
				* Typically represented as an oval
				* Underlined attributes are primary keys
				* Attributes have simple data types, eg int
			* Relationships connect entities
				* Typically represented as diamonds
				* Participation constraints require both entities must relate to each other at least once, and is represented by a a thick line
				* At-most-once constraints mean there can be a maximum of one relationship between the two entities and is represented by an arrow
			* Sub-classes
				* Weak entities can only be uniquely identified by combining with PK of owning entity
				* Weak entities must belong to another entity (eg homework belonging to a course)
				* Aggregation is represented by a dashed line surrounding the relationship
					* The entire relationship is then connected to other entities with a regular relationship line (the relationship is connected rather than an entity)
			* ER Diagrams help to determine which tables to create when forming the DB schema
		* Turning ED Diagrams into Relations
			* Each entity becomes one row in a relation
			* Properties are columns
			* Underlined attributes are the PK
			* Relationships (diamonds) become tables that stores PK of each connected entity (sounds like a fact table)
				* Additional properties also become columns
			* ![[Cornell_ED_Diagram.png]]
			* Weak entities translate to needing foreign keys in the owning entity
		* Functional dependencies should be separated in different tables to prevent needing to update multiple columns at once
			* This is called decomposing tables
			* Functional dependencies can be found via domain knowledge and inferring dependencies from existing dependencies
			* BCNF is more normalized than 3NF
	* Graph Databases (3:07:28 - 4:44:39)
		* Graph DBs consist of nodes (entities) and edges (relationships)
			* Both nodes and edges can be associated with labels and properties
				* Graph data can be stored and queried using relational solutions, but is not efficient
				* neo4j is one of the most common graph db solutions
			* eg creation of node: CREATE (:Student{name : 'Marc'})
			* eg search for node: MATCH (m:Student{name : 'Marc'}) assigns the result to variable 'm'
			* ![[Cornell_GraphDB_Query.png]]
			* SET command is used to change labels and properties
			* MATCH can also be used to find edges
			* DELETE used with a match will delete the matched record(s)
			* ==neo4jsandbox.com can be used to try these commands==
			* Google uses PageRank algorithm
				* Higher pagerank values are preferable
				* nodes are webpages
				* More times a random surfer lands on a given page, the higher the pagerank score
				* Incoming links from high value websites carry a lot more weight
				* Pregel is a system for distributed graph processing
	* Data Streams (4:44:39 - 6:38:26)
		* Continuous queries differ from relational databases in that the queries remain running and constant while the data changes
		* Skip a bunch of stuff that's deeper than I need
		* ksqlDB uses Apache Kafka Cluster
			* Kafka is a java-based stream processing engine
				* Producers add records. consumes subscribe to topics
				* Kafka topics represent a log of ordered records, each of which is a key-value pair
				* Producers can append to this log (no updates or deletes)
				* Consumers can receive updates for topics subscribed to
				* Topics are divided into partitions
					* Partitions are replicated across servers for fault tolerance
				* Kafka streams use RocksDB for insertions
			* ksqlDB is an API on top of Kafka Streams
			* Translates SQL-like queries to Kafka operators
			* Pull queries gets executed once on current data
			* Push queries is a constant query that generates new data as stream evolves
			* ![[Cornell_StreamDB_Query.png]]
			* Push queries only react and notify you if the data changes
		* Spatial Data (6:38:26 - 7:39:30)
			* Google Maps is an example of 2D spatial data
			* Can be a point or a region with a boundary
			* Z-Ordering places close points spatially close together in indexing as well
			* Region Quad Tree decomposes regions into quarters ,and you can traverse from root node (full region) to the leaf node (region you arrived at after decomposition)
			* Grid Files decompose more fine grained where more data is stored
				* Adapt space partitioning to data
			* R Trees are an adaption of B+ trees to handle spatial data
				* R Trees decompose into flexible sized leafs that can overlap
			* NoSQL and NewSQL (7:39:30 - End)
				* NoSQL does not require consistency, it favors availability over consistency
				* Apache Cassandra uses CQL (no joins) and is a wide-column store
					* Wide-column stores allow rows to have different columns from one another, but otherwise is similar to a table
				* NoSQL does not guarantee ACID transactions
				* H-Store is a form of NewSQL
					* It is feasible to fit databases in RAM in recent times

test update git


https://www.youtube.com/watch?v=miEFm1CyjfM
https://www.youtube.com/watch?v=U0MdznoiCGY

db normalization: https://www.youtube.com/watch?v=GFQaEYEc8_8
IBM DA Course: https://www.youtube.com/watch?v=1PAy6d16ADQ
40:37 is where I stopped in the Cornell Course: https://www.youtube.com/watch?v=4cWkVbC2bNE