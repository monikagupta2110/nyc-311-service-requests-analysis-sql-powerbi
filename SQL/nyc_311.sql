create database nyc_311_analytics;
USE nyc_311_analytics;

CREATE TABLE nyc_311_raw (
    unique_key VARCHAR(30),
    created_date VARCHAR(50),
    closed_date VARCHAR(50),
    agency VARCHAR(100),
    agency_name VARCHAR(255),
    complaint_type VARCHAR(255),
    descriptor VARCHAR(255),
    descriptor_2 VARCHAR(255),
    location_type VARCHAR(255),
    incident_zip VARCHAR(20),
    incident_address VARCHAR(255),
    street_name VARCHAR(255),
    cross_street_1 VARCHAR(255),
    cross_street_2 VARCHAR(255),
    intersection_street_1 VARCHAR(255),
    intersection_street_2 VARCHAR(255),
    address_type VARCHAR(100),
    city VARCHAR(100),
    landmark VARCHAR(255),
    facility_type VARCHAR(100),
    status VARCHAR(100),
    due_date VARCHAR(50),
    resolution_description TEXT,
    resolution_action_updated_date VARCHAR(50),
    community_board VARCHAR(100),
    council_district VARCHAR(50),
    police_precinct VARCHAR(100),
    bbl VARCHAR(50),
    borough VARCHAR(100),
    x_coordinate_state_plane VARCHAR(50),
    y_coordinate_state_plane VARCHAR(50),
    open_data_channel_type VARCHAR(50),
    park_facility_name VARCHAR(255),
    park_borough VARCHAR(100),
    vehicle_type VARCHAR(100),
    taxi_company_borough VARCHAR(100),
    taxi_pick_up_location TEXT,
    bridge_highway_name VARCHAR(255),
    bridge_highway_direction VARCHAR(100),
    road_ramp VARCHAR(100),
    bridge_highway_segment VARCHAR(255),
    latitude VARCHAR(50),
    longitude VARCHAR(50),
    location VARCHAR(255)
);
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
LOAD DATA LOCAL INFILE 'C:/Users/gupta/Downloads/erm2-nwe9.csv'
INTO TABLE nyc_311_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SHOW VARIABLES LIKE 'local_infile';
LOAD DATA LOCAL INFILE 'C:/Users/gupta/Downloads/erm2-nwe9.csv'
INTO TABLE nyc_311_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
LOAD DATA LOCAL INFILE 'C:/Users/gupta/Downloads/erm2-nwe9.csv'
INTO TABLE nyc_311_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) AS total_rows
FROM nyc_311_raw;
select * from nyc_311_raw limit 5;
select min(created_date) as min_created,
max(created_date) as max_created,
count(*) as total_rows from nyc_311_raw;
SELECT *
FROM nyc_311_raw
LIMIT 5;
SELECT
    MIN(STR_TO_DATE(created_date, '%d-%m-%Y %H:%i')) AS min_created,
    MAX(STR_TO_DATE(created_date, '%d-%m-%Y %H:%i')) AS max_created,
    COUNT(*) AS total_rows
FROM nyc_311_raw;
SELECT COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'nyc_311_analytics'
  AND table_name = 'nyc_311_raw';
USE nyc_311_analytics;

CREATE TABLE Fact_ServiceRequests AS
SELECT
    CAST(unique_key AS UNSIGNED) AS unique_key,

    STR_TO_DATE(NULLIF(created_date, ''), '%d-%m-%Y %H:%i') AS created_date,

    STR_TO_DATE(NULLIF(closed_date, ''), '%d-%m-%Y %H:%i') AS closed_date,

    CAST(
        DATE_FORMAT(
            STR_TO_DATE(NULLIF(created_date, ''), '%d-%m-%Y %H:%i'),
            '%Y-%m-01'
        ) AS DATE
    ) AS created_month,

    agency,
    agency_name,

    complaint_type,
    descriptor,
    descriptor_2,

    location_type,
    incident_zip,
    city,
    borough,
    community_board,
    council_district,
    police_precinct,

    status,

    CASE
        WHEN NULLIF(closed_date, '') IS NULL THEN 0
        ELSE 1
    END AS is_closed,

    CASE
        WHEN NULLIF(closed_date, '') IS NULL THEN NULL
        WHEN STR_TO_DATE(closed_date, '%d-%m-%Y %H:%i')
             < STR_TO_DATE(created_date, '%d-%m-%Y %H:%i')
        THEN 0
        ELSE
            TIMESTAMPDIFF(
                SECOND,
                STR_TO_DATE(created_date, '%d-%m-%Y %H:%i'),
                STR_TO_DATE(closed_date, '%d-%m-%Y %H:%i')
            ) / 3600
    END AS resolution_time_hours,

    open_data_channel_type AS channel

FROM nyc_311_raw;
SHOW WARNINGS;
SHOW CREATE TABLE Fact_ServiceRequests;
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM information_schema.columns
WHERE table_schema = 'nyc_311_analytics'
  AND table_name = 'Fact_ServiceRequests'
  AND COLUMN_NAME = 'resolution_time_hours';
  DROP TABLE Fact_ServiceRequests;
CREATE TABLE Fact_ServiceRequests AS
SELECT
    CAST(unique_key AS UNSIGNED) AS unique_key,

    STR_TO_DATE(
        NULLIF(created_date, ''),
        '%d-%m-%Y %H:%i'
    ) AS created_date,

    STR_TO_DATE(
        NULLIF(closed_date, ''),
        '%d-%m-%Y %H:%i'
    ) AS closed_date,

    CAST(
        DATE_FORMAT(
            STR_TO_DATE(NULLIF(created_date, ''), '%d-%m-%Y %H:%i'),
            '%Y-%m-01'
        ) AS DATE
    ) AS created_month,

    agency,
    agency_name,

    complaint_type,
    descriptor,
    descriptor_2,

    location_type,
    incident_zip,
    city,
    borough,
    community_board,
    council_district,
    police_precinct,

    status,

    CASE
        WHEN NULLIF(closed_date, '') IS NULL THEN 0
        ELSE 1
    END AS is_closed,

    CASE
        WHEN NULLIF(closed_date, '') IS NULL THEN NULL

        WHEN STR_TO_DATE(closed_date, '%d-%m-%Y %H:%i')
             < STR_TO_DATE(created_date, '%d-%m-%Y %H:%i')
        THEN 0

        ELSE CAST(
            TIMESTAMPDIFF(
                SECOND,
                STR_TO_DATE(created_date, '%d-%m-%Y %H:%i'),
                STR_TO_DATE(closed_date, '%d-%m-%Y %H:%i')
            ) / 3600
            AS DECIMAL(20,6)
        )
    END AS resolution_time_hours,

    open_data_channel_type AS channel

FROM nyc_311_raw;
SELECT COUNT(*) AS fact_rows
FROM Fact_ServiceRequests;
SELECT
    MIN(resolution_time_hours) AS min_hours,
    MAX(resolution_time_hours) AS max_hours,
    AVG(resolution_time_hours) AS avg_hours,
    COUNT(resolution_time_hours) AS non_null_hours
FROM Fact_ServiceRequests;
SELECT
    is_closed,
    COUNT(*) AS request_count
FROM Fact_ServiceRequests
GROUP BY is_closed;
create table Dim_Agency as 
select distinct agency , agency_name from Fact_ServiceRequests
where agency is not null 
and agency <> '';
select count(*) as agency_count from Dim_Agency;
select * from Dim_Agency order by agency;
drop table Dim_Borough;
create table Dim_Borough as
select distinct borough from Fact_ServiceRequests
where borough is not null 
and borough <> '';
select count(*) as Borough_count from Dim_Borough;
select * from Dim_Borough order by borough;
create table Dim_Channel 
as select distinct channel from Fact_ServiceRequests
where channel is not null and channel <> '';
select count(*) as channel_count from Dim_Channel;
select * from Dim_Channel order by channel;
create table Dim_Status 
as select distinct status from Fact_ServiceRequests
where status is not null and status <> '';
select count(*) as status_count from Dim_Status;
select * from Dim_Status order by status;
CREATE TABLE Dim_Problem AS
SELECT DISTINCT
    complaint_type,
    descriptor,
    descriptor_2
FROM Fact_ServiceRequests
WHERE complaint_type IS NOT NULL
  AND complaint_type <> '';
SELECT COUNT(*) AS problem_count
FROM Dim_Problem;
SELECT *
FROM Dim_Problem
LIMIT 20;
select distinct complaint_type from Dim_Problem;
SELECT DISTINCT
    complaint_type,
    descriptor,
    descriptor_2
FROM Fact_ServiceRequests;
show tables like 'Dim_Date';
DROP TABLE Dim_Date;
CREATE TABLE Dim_Date AS
SELECT DISTINCT
    DATE(created_date) AS 'date',
    YEAR(created_date) AS 'year',
    MONTH(created_date) AS 'month',
    MONTHNAME(created_date) AS 'month_name',
    DATE_FORMAT(created_date, '%Y-%m') AS 'year_month'
FROM Fact_ServiceRequests
WHERE created_date IS NOT NULL;
select count(*) from Dim_Date;
SELECT *
FROM Dim_Date
ORDER BY `date`;
CREATE TABLE Dim_Location AS
SELECT DISTINCT
    CONCAT_WS('|',
        COALESCE(location_type, ''),
        COALESCE(incident_zip, ''),
        COALESCE(city, ''),
        COALESCE(borough, ''),
        COALESCE(community_board, ''),
        COALESCE(council_district, ''),
        COALESCE(police_precinct, '')
    ) AS location_key,

    location_type,
    incident_zip,
    city,
    borough,
    community_board,
    council_district,
    police_precinct

FROM Fact_ServiceRequests;
SELECT COUNT(*) AS location_count
FROM Dim_Location;
select count(*) as total_rows,
count(distinct location_key) as unique_keys
from Dim_Location;
select * from Dim_Location;
ALTER TABLE Fact_ServiceRequests
ADD COLUMN location_key VARCHAR(1000);
UPDATE Fact_ServiceRequests
SET location_key = CONCAT_WS('|',
    COALESCE(location_type, ''),
    COALESCE(incident_zip, ''),
    COALESCE(city, ''),
    COALESCE(borough, ''),
    COALESCE(community_board, ''),
    COALESCE(council_district, ''),
    COALESCE(police_precinct, '')
);
SELECT
    COUNT(*) AS total_rows,
    COUNT(location_key) AS populated_keys,
    COUNT(DISTINCT location_key) AS unique_keys
FROM Fact_ServiceRequests;
SELECT COUNT(*) AS unmatched_locations
FROM Fact_ServiceRequests f
LEFT JOIN Dim_Location d
    ON f.location_key = d.location_key
WHERE d.location_key IS NULL;
SELECT 'Fact_ServiceRequests' AS table_name, COUNT(*) AS row_count
FROM Fact_ServiceRequests

UNION ALL

SELECT 'Dim_Agency', COUNT(*)
FROM Dim_Agency

UNION ALL

SELECT 'Dim_Borough', COUNT(*)
FROM Dim_Borough

UNION ALL

SELECT 'Dim_Channel', COUNT(*)
FROM Dim_Channel

UNION ALL

SELECT 'Dim_Status', COUNT(*)
FROM Dim_Status

UNION ALL

SELECT 'Dim_Problem', COUNT(*)
FROM Dim_Problem

UNION ALL

SELECT 'Dim_Date', COUNT(*)
FROM Dim_Date

UNION ALL

SELECT 'Dim_Location', COUNT(*)
FROM Dim_Location;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT agency) AS unique_agencies
FROM Dim_Agency;
ALTER TABLE Dim_Agency
ADD PRIMARY KEY (agency);
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT borough) AS unique_boroughs
FROM Dim_Borough;
ALTER TABLE Dim_Borough
ADD PRIMARY KEY (borough);
select count(*) as total_rows,
count(distinct channel) as unique_channels
from Dim_Channel;
alter table Dim_Channel
add primary key (channel);
select count(*) as total_rows, 
count(distinct status) as unique_status
from Dim_Status;
alter table Dim_Status
add primary key (status);
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT `date`) AS unique_dates
FROM Dim_Date;
alter table Dim_Date
add primary key (`date`);
ALTER TABLE Dim_Location
ADD PRIMARY KEY (location_key);
ALTER TABLE Dim_Location
MODIFY COLUMN location_key VARCHAR(1000) NOT NULL;
ALTER TABLE Dim_Location
ADD PRIMARY KEY (location_key);
SELECT
    MAX(CHAR_LENGTH(location_key)) AS max_key_length
FROM Dim_Location;
ALTER TABLE Dim_Location
MODIFY COLUMN location_key VARCHAR(150) NOT NULL;
ALTER TABLE Dim_Location
ADD PRIMARY KEY (location_key);
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CONCAT_WS('|',
        COALESCE(complaint_type, ''),
        COALESCE(descriptor, ''),
        COALESCE(descriptor_2, '')
    )) AS unique_problem_keys
FROM Dim_Problem;
SELECT
    COUNT(*) AS total_rows,
    COUNT(problem_key) AS populated_keys,
    COUNT(DISTINCT problem_key) AS unique_keys
FROM Dim_Problem;
ALTER TABLE Dim_Problem
ADD COLUMN problem_key VARCHAR(500);
UPDATE Dim_Problem
SET problem_key = CONCAT_WS('|',
    COALESCE(complaint_type, ''),
    COALESCE(descriptor, ''),
    COALESCE(descriptor_2, '')
);
SELECT
    COUNT(*) AS total_rows,
    COUNT(problem_key) AS populated_keys,
    COUNT(DISTINCT problem_key) AS unique_keys
FROM Dim_Problem;
ALTER TABLE Dim_Problem
MODIFY COLUMN problem_key VARCHAR(500) NOT NULL;
ALTER TABLE Dim_Problem
ADD PRIMARY KEY (problem_key);
ALTER TABLE Fact_ServiceRequests
ADD COLUMN problem_key VARCHAR(500);
UPDATE Fact_ServiceRequests
SET problem_key = CONCAT_WS('|',
    COALESCE(complaint_type, ''),
    COALESCE(descriptor, ''),
    COALESCE(descriptor_2, '')
);
SELECT
    COUNT(*) AS total_rows,
    COUNT(problem_key) AS populated_keys,
    COUNT(DISTINCT problem_key) AS unique_keys
FROM Fact_ServiceRequests;
SELECT COUNT(*) AS unmatched_problems
FROM Fact_ServiceRequests f
LEFT JOIN Dim_Problem d
    ON f.problem_key = d.problem_key
WHERE d.problem_key IS NULL;
SELECT COUNT(*) AS unmatched_agencies
FROM Fact_ServiceRequests f
LEFT JOIN Dim_Agency d
    ON f.agency = d.agency
WHERE d.agency IS NULL;
SELECT COUNT(*) AS unmatched_boroughs
FROM Fact_ServiceRequests f
LEFT JOIN Dim_Borough d
    ON f.borough = d.borough
WHERE d.borough IS NULL;
SELECT COUNT(*) AS unmatched_channels
FROM Fact_ServiceRequests f
LEFT JOIN Dim_Channel d
    ON f.channel = d.channel
WHERE d.channel IS NULL;
SELECT COUNT(*) AS unmatched_statuses
FROM Fact_ServiceRequests f
LEFT JOIN Dim_Status d
    ON f.status = d.status
WHERE d.status IS NULL;
SELECT COUNT(*) AS unmatched_dates
FROM Fact_ServiceRequests f
LEFT JOIN Dim_Date d
    ON DATE(f.created_date) = d.`date`
WHERE d.`date` IS NULL;
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT unique_key) AS unique_keys
FROM Fact_ServiceRequests;
ALTER TABLE Fact_ServiceRequests
ADD PRIMARY KEY (unique_key);
alter table Fact_ServiceRequests
add constraint fk_fact_agency
foreign key (agency)
references Dim_Agency(agency);
ALTER TABLE Fact_ServiceRequests
ADD CONSTRAINT fk_fact_agency
FOREIGN KEY (agency)
REFERENCES Dim_Agency(agency);
ALTER TABLE Fact_ServiceRequests
ADD CONSTRAINT fk_fact_borough
FOREIGN KEY (borough)
REFERENCES Dim_Borough(borough);
ALTER TABLE Fact_ServiceRequests
ADD CONSTRAINT fk_fact_channel
FOREIGN KEY (channel)
REFERENCES Dim_Channel(channel);
ALTER TABLE Fact_ServiceRequests
ADD CONSTRAINT fk_fact_status
FOREIGN KEY (status)
REFERENCES Dim_Status(status);
ALTER TABLE Fact_ServiceRequests
ADD COLUMN created_date_only DATE;
UPDATE Fact_ServiceRequests
SET created_date_only = DATE(created_date);
SELECT
    COUNT(*) AS total_rows,
    COUNT(created_date_only) AS populated_dates,
    COUNT(DISTINCT created_date_only) AS unique_dates
FROM Fact_ServiceRequests;
ALTER TABLE Fact_ServiceRequests
ADD CONSTRAINT fk_fact_date
FOREIGN KEY (created_date_only)
REFERENCES Dim_Date(`date`);
ALTER TABLE Fact_ServiceRequests
ADD CONSTRAINT fk_fact_problem
FOREIGN KEY (problem_key)
REFERENCES Dim_Problem(problem_key);
ALTER TABLE Fact_ServiceRequests
ADD CONSTRAINT fk_fact_location
FOREIGN KEY (location_key)
REFERENCES Dim_Location(location_key);
ALTER TABLE Fact_ServiceRequests
MODIFY COLUMN location_key VARCHAR(150) NOT NULL;
ALTER TABLE Fact_ServiceRequests
ADD CONSTRAINT fk_fact_location
FOREIGN KEY (location_key)
REFERENCES Dim_Location(location_key);
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'nyc_311_analytics'
  AND TABLE_NAME = 'Fact_ServiceRequests'
  AND CONSTRAINT_NAME = 'fk_fact_location';
  # how many requests each month?
  select created_month , count(*) as total_requests from Fact_ServiceRequests
  group by created_month
  order by created_month;
  # which agencies handling higher requests
  select agency, agency_name , count(*) as total_requests
  from Fact_ServiceRequests
  group by agency , agency_name
  order by total_requests desc;
  # how many requests are closed vs not closed ?
  select is_closed , count(*) as request_count
  from Fact_ServiceRequests
  group by is_closed;
  # what % of the services has been closed ?
  select
  count(*) as total_requests,
  sum(is_closed) as closed_requests,
  round(sum(is_closed)* 100.0 / count(*),2) as closer_rate
  from Fact_ServiceRequests;
  # how long does it take to close a service request
  select 
  count(resolution_time_hours) as closed_requests,
  round(avg(resolution_time_hours),2) as avg_resolution_hour,
    round(min(resolution_time_hours),2) as min_resolution_hour,
    round(max(resolution_time_hours),2) as max_resolution_hour
from Fact_ServiceRequests where resolution_time_hours is not null;
# which agencies have longer and shorter closing time?
select agency, agency_name ,
count(resolution_time_hours) as closed_requests,
round(avg(resolution_time_hours),2) as avg_resolution_hour
from Fact_ServiceRequests
where resolution_time_hours is not null
group by agency , agency_name 
order by closed_requests desc;
select
created_month , count(resolution_time_hours) as closed_requests,
round(avg(resolution_time_hours),2) as avg_resolution_hour 
from Fact_ServiceRequests where resolution_time_hours is not null 
group by created_month
order by created_month;
# what type of problems generate the most 311 request
select complaint_type,
count(*) as total_requests
from Fact_ServiceRequests
group by complaint_type
order by total_requests desc limit 15;
select borough,
count(*) as total_requests
from Fact_ServiceRequests
group by borough
order by total_requests desc;





  

