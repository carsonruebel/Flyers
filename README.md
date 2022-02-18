# Flyers
This project's goal is to use real-world super market flyer advertisements to track price trends over time of various items. This project has evolved twice, resulting in three functional versions.
- Version 1: Manual input from paper flyers
- Version 2: Python script executing locally daily to pull from public API
- Version 3: Azure Data Factory to load data from API to SQL using serverless offerings

### Technology Used
This project makes use of the following technology:
- All versions make use of an Azure SQL Database as a sink
- Version 1 uses Excel formulas to build batch SQL queries to input data into the DB
- Version 1 makes use of SQL stored procs to parse out SQL spreadsheet into normalized dim/fact tables
- Version 2 uses Python to pull and append flyer details from a public API to a CSV file
- Version 2 uses SQL stored procs to parse out CSV file into a v2 data model of dim/fact tables (due to different details available)
- Version 3 uses Azure Data Factory to extract, transform, and load data from a public API into a v3 data model of dim/fact tables (due to inclusion of daily loaddate attribute)
- All versions make use of PowerBI to view the data with slicers to select individual products, families of products, and stores to view price trends over time

### Risks and Assumptions
There are risks and assumptions from both a data quality perspective and with the ETL of all three versions
- Data Quality: Advertisements have no standardization! Some will list a minimum required quantity to get a sale price Some will appear to have a minimum but may not actually be required. Some will combine mix and match of brands and products. Many are broad categories that cover multiple various products without specification. Mitigation for manual entry is to have a specific column specifying if this is for a single product or various, so price trends can be built specifically on individual products.
- Version 1: Data entry takes incredibly long and is not practical. It takes upwards of 5 hours to input a single store's weekly flyer.
- Version 1: Risk of human error is very high.
- Version 2: Python script is set to run hourly using Windows Task Scheduler, meaning there is a dependency on my machine being online and logged in frequently enough to capture data.
- Version 2: Manual work needs to be done periodically to build stored proc calls and execute them to upload data to SQL.

### Credit Due
Versions 2 and 3 both utilize Flipp API endpoints
```
request_url = 'https://backflipp.wishabi.com/flipp/items/search?locale=en-us&postal_code=98125&q=' + storename)
```

### Nice to add in future
- Secure connectivity to SQL with better identity practices
- Find and implement method to share PowerBI results without incurring $20/month premium charge

### How to install
*tbd*

### License
Licensed under [GPLv3](GPLv3.txt)
