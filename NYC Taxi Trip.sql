/* Create table Calendar */
CREATE Table Calendar (
 [Date] date
 , FiscalYear int
 , FiscalQuarter int
 , FiscalMonthNumber int
 , FiscalMonthOfQuarter int
 , FiscalWeekOfYear int
 , [DayOfWeek] int
 , FiscalMonthName nvarchar(20)
 , FiscalMonthYear nvarchar(20)
 , FiscalQuarterYear  int
 , DayOfMonthNumber int
 , [DayName] nvarchar(20)
)

/* Drop table */
DROP TABLE Taxi_Zones

/* Add csv file to table (change the file location with each file) */
BULK INSERT Calendar
FROM 'C:\Users\Admin\Desktop\Project 2\454_calendar.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n',
  FIRSTROW = 2
);

/* Merge table Taxi trip 2019 and taxi trip 2020 into a view and remove VendorID column and store_and_fwd_flag column and split datetime type into date and time column*/
CREATE VIEW Taxi_Trips_20192020 AS
	SELECT CAST(lpep_pickup_datetime AS date) AS lpep_pickup_date
			, CAST(lpep_pickup_datetime AS time(0)) AS lpep_pickup_time
			, CAST(lpep_dropoff_datetime AS date) AS lpep_dropoff_date
			, CAST(lpep_dropoff_datetime AS time(0)) AS lpep_dropoff_time
			, RatecodeID, PULocationID, DOLocationID
			, passenger_count, trip_distance, fare_amount, extra, mta_tax, tip_amount, tolls_amount
			, improvement_surcharge, total_amount, payment_type, trip_type, congestion_surcharge
	FROM Taxi_Trips_2019 
	UNION ALL
	SELECT CAST(lpep_pickup_datetime AS date) AS lpep_pickup_date
			, CAST(lpep_pickup_datetime AS time(0)) AS lpep_pickup_time
			, CAST(lpep_dropoff_datetime AS date) AS lpep_dropoff_date
			, CAST(lpep_dropoff_datetime AS time(0)) AS lpep_dropoff_time
			, RatecodeID, PULocationID, DOLocationID
			, passenger_count, trip_distance, fare_amount, extra, mta_tax, tip_amount, tolls_amount
			, improvement_surcharge, total_amount, payment_type, trip_type, congestion_surcharge
	FROM Taxi_Trips_2020 

/* Delete view */
DROP VIEW Trip_Type

/* Get distinct value of RateCodeID column and create view rate_code and add new column rate_code_name */
CREATE VIEW Rate_Code AS
	SELECT DISTINCT tx.RatecodeID,
					 CAST(CASE 
						WHEN tx.RatecodeID = 1 THEN 'Standard rate'
						WHEN tx.RatecodeID = 2 THEN 'JFK'
						WHEN tx.RatecodeID = 3 THEN 'Newark'
						WHEN tx.RatecodeID = 4 THEN 'Nassau or Westchester'
						WHEN tx.RatecodeID = 5 THEN 'Negotiated fare'
						WHEN tx.RatecodeID = 6 THEN 'Group ride'
						WHEN tx.RatecodeID = 99 THEN 'Unknown'
						ELSE 'No information'
					END AS nvarchar(20)) AS rate_code_name
	FROM Taxi_Trips_20192020 tx

/*Get distinct value of payment_type column and create new view named Payment_Type (rename column payment_type = PaymenttypeID and add new column payment_type) */
CREATE VIEW Payment_Type AS
	SELECT DISTINCT tx.payment_type AS PaymenttypeID,
					 CAST(CASE 
						WHEN tx.payment_type = 1 THEN 'Credit card'
						WHEN tx.payment_type = 2 THEN 'Cash'
						WHEN tx.payment_type = 3 THEN 'No charge'
						WHEN tx.payment_type = 4 THEN 'Dispute'
						WHEN tx.payment_type = 5 THEN 'Unknown'
						ELSE 'No information'
					END AS nvarchar(20)) AS payment_type
	FROM Taxi_Trips_20192020 tx

	SELECT DISTINCT tx.trip_type
	FROM Taxi_Trips_20192020 tx

/* Create view Trip_Type (rename column trip_type = TriptypeID and add new column trip_type) */
CREATE VIEW Trip_Type AS
	SELECT DISTINCT tx.trip_type AS TriptypeID,
					 CAST(CASE 
						WHEN tx.trip_type = 1 THEN 'Street-hail'
						WHEN tx.trip_type = 2 THEN 'Dispatch'
						ELSE 'No information'
					END AS nvarchar(20)) AS trip_type
	FROM Taxi_Trips_20192020 tx

/* Check distinct value congestion_surcharge column */
SELECT DISTINCT congestion_surcharge, COUNT(congestion_surcharge) AS total_row_value
FROM dbo.Taxi_Trips_20192020
GROUP BY congestion_surcharge
ORDER BY congestion_surcharge ASC

/* Remove rows with condition  */
DELETE FROM Taxi_Trips_2019
WHERE [total_amount] < 0

DELETE FROM Taxi_Trips_2020
WHERE [total_amount] < 0

/* Delete year 2017 and year 2018 from table Calendar */	
DELETE FROM Calendar
WHERE YEAR(Date) = 2017

DELETE FROM Calendar
WHERE YEAR(Date) = 2018


/* Replace null value congestion_surcharge column = 0 */
UPDATE [Taxi_Trips_2019]
SET [congestion_surcharge]= 0
WHERE [congestion_surcharge] IS NULL

UPDATE [Taxi_Trips_2020]
SET [congestion_surcharge]= 0
WHERE [congestion_surcharge] IS NULL

/* Check value < 0 */
SELECT DISTINCT [total_amount]
FROM dbo.Taxi_Trips_20192020
WHERE [total_amount] < 0

