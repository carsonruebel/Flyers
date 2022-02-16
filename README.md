# Flyers
This project's goal is to use real-world super market flyer advertisements to track price trends over time of various items. This project has evolved twice, resulting in three semi-functional versions.
- Version 1: Manual input from paper flyers
- Version 2: Python script executing locally daily to pull from public API
- Version 3: Azure Data Factory to load data from API to SQL using serverless offerings

### Technology Used
This project makes use of the following technology:
- All versions make use of an Azure SQL Database as a sink
- Version 1 uses Excel formulas to build batch SQL queries to input data into the DB
- Version 1 makes use of SQL stored procs to parse out SQL spreadsheet into normalized dim/fact tables
- Version 2 uses Python to pull and append flyer details from a public API to a CSV file
- Version 2 *will use* new SQL stored procs to parse out CSV file into a separate data model of dim/fact tables (due to different details available)
- Version 3 *will use* Azure Data Factory to extract, transform, and load data from a public API directly to the DB
- All versions *will make use of* PowerBI to view the data with slicers to select individual products, families of products, and stores to view price trends over time

### Risks and Assumptions
There are risks and assumptions from both a data quality perspective and with the ETL of all three versions
- Data Quality: Advertisements have no standardization! Some will list a minimum required quantity to get a sale price Some will appear to have a minimum but may not actually be required. Some will combine mix and match of brands and products. Many are broad categories that cover multiple various products without specification. Mitigation for manual entry is to have a specific column specifying if this is for a single product or various, so price trends can be built specifically on individual products.
- Version 1: Data entry takes incredibly long and is not practical. It takes upwards of 5 hours to input a single store's weekly flyer. Due to this, I've largely moved my time investment to Versions 2 and 3.
- Version 2: Python script is set to run daily using Windows Task Scheduler. This currently only works when logged in, meaning if my computer is off or locked it will not receive the day's deteails. This could be mitigated by diving deeper into why it doesn't work when logged out, or by scheduling to run much more frequently.

### Nice to add in future
- Secure connectivity to SQL with better identity practices
- Find and implement method to share PowerBI results without incurring $20/month premium charge

### How to install
*placeholder*

### License
Licensed under [GPLv3](GPLv3.txt)
