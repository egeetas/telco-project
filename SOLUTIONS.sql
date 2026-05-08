-- 1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.
-- Approach:
-- To find the customers subscribed to a specific tariff, we must join the CUSTOMERS table with the TARIFFS table on their common column, TARIFF_ID. 
-- By performing an INNER JOIN, we ensure that we only get records where a customer is linked to a valid tariff. 
-- Finally, we apply a WHERE clause to filter the results specifically for the tariff named 'Kobiye Destek'.
SELECT c.CUSTOMER_ID, c.NAME, c.CITY, c.SIGNUP_DATE 
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';

/* Sample Output:
CUSTOMER_ID NAME                 CITY                 SIGNUP_DATE
----------- -------------------- -------------------- -----------
       9720 Yasemin              MARDİN               17-FEB-26
       9726 Sevim                DÜZCE                21-APR-25
       9735 Fatih                SAMSUN               08-FEB-26
       9742 Özlem                HAKKARİ              04-AUG-25
       9744 İbrahim              KIRKLARELİ           23-FEB-26
*/

-- 1.2 Find the newest customer who subscribed to this tariff.
-- Approach:
-- This query builds upon the previous one by joining CUSTOMERS and TARIFFS and filtering for the 'Kobiye Destek' tariff. 
-- To determine the most recent subscriber, we use the ORDER BY clause to sort the records in descending order based on the SIGNUP_DATE column. 
-- Finally, we utilize the FETCH FIRST 1 ROWS WITH TIES clause to limit the output to the newest customer, while accommodating potential ties if multiple users signed up on the same latest date.
SELECT c.CUSTOMER_ID, c.NAME, c.CITY, c.SIGNUP_DATE 
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROWS WITH TIES;

/* Sample Output:
CUSTOMER_ID NAME                 CITY                 SIGNUP_DATE
----------- -------------------- -------------------- -----------
       2098 Mustafa              EDİRNE               11-APR-26
*/

-- 2.1 Find the distribution of tariffs among the customers.
-- Approach:
-- We need to calculate how many customers belong to each distinct tariff plan. 
-- To achieve this, we join the TARIFFS table with the CUSTOMERS table and then use the GROUP BY clause on the tariff name. 
-- For each group, we apply the COUNT() aggregate function on the customer ID to produce the total distribution numbers.
SELECT t.NAME AS TARIFF_NAME, COUNT(c.CUSTOMER_ID) AS CUSTOMER_COUNT
FROM TARIFFS t
LEFT JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY t.NAME
ORDER BY CUSTOMER_COUNT DESC;

/* Sample Output:
TARIFF_NAME                              CUSTOMER_COUNT
---------------------------------------- --------------
Kurumsal SMS                                       2567
Genç Dinamik                                       2516
Kobiye Destek                                      2471
Çalışan GB                                         2396
*/

-- 3.1 Identify the earliest customers to sign up.
-- Approach:
-- The earliest signup date can be identified by using the MIN() aggregate function on the SIGNUP_DATE column. 
-- We implement this within a subquery to first determine the absolute minimum date in the entire CUSTOMERS table. 
-- The outer query then retrieves all customer records where the signup date is exactly equal to that minimum date, accommodating ties.
SELECT CUSTOMER_ID, NAME, CITY, SIGNUP_DATE
FROM CUSTOMERS
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS);

/* Sample Output:
CUSTOMER_ID NAME                 CITY                 SIGNUP_DATE
----------- -------------------- -------------------- -----------
       9761 Ömer                 ANTALYA              09-APR-25
       9845 Burak                GÜMÜŞHANE            27-APR-25
*/

-- 3.2 Find the distribution of these earliest customers across different cities, including the total count for each city.
-- Approach:
-- We start by applying the same WHERE clause using a subquery to isolate only those customers who signed up on the earliest possible date. 
-- Next, we add a GROUP BY clause targeting the CITY column to organize these early adopters by their geographic location. 
-- Finally, we use the COUNT() function to count the occurrences within each city group and display the geographical distribution.
SELECT CITY, COUNT(CUSTOMER_ID) AS CUSTOMER_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS)
GROUP BY CITY
ORDER BY CUSTOMER_COUNT DESC;

/* Sample Output:
CITY                 CUSTOMER_COUNT
-------------------- --------------
ANTALYA                          15
GÜMÜŞHANE                        12
ERZİNCAN                         10
TRABZON                           8
*/

-- 4.1 Identify the IDs of missing customers in monthly records.
-- Approach:
-- We need to find customers who exist in the parent table but are missing in the child MONTHLY_STATS table. 
-- The NOT EXISTS operator is highly efficient in Oracle for this type of anti-join query. 
-- We use a correlated subquery inside NOT EXISTS to check each customer ID against the MONTHLY_STATS table and return only those without a match.
SELECT c.CUSTOMER_ID, c.NAME
FROM CUSTOMERS c
WHERE NOT EXISTS (
    SELECT 1 
    FROM MONTHLY_STATS m 
    WHERE m.CUSTOMER_ID = c.CUSTOMER_ID
);

/* Sample Output:
CUSTOMER_ID NAME
----------- --------------------
       9711 Süleyman
       9712 Merve
       9713 Hacer
       9714 Özlem
       9715 Özlem
*/

-- 4.2 Find the distribution of these missing customers across different cities.
-- Approach:
-- This query leverages the same anti-join logic from the previous step to filter out customers who have proper monthly records. 
-- Once we have the isolated dataset of missing customers, we apply the GROUP BY clause on the CITY column. 
-- Applying the COUNT() function then aggregates the total number of missing records for each specific city.
SELECT c.CITY, COUNT(c.CUSTOMER_ID) AS MISSING_CUSTOMER_COUNT
FROM CUSTOMERS c
WHERE NOT EXISTS (
    SELECT 1 
    FROM MONTHLY_STATS m 
    WHERE m.CUSTOMER_ID = c.CUSTOMER_ID
)
GROUP BY c.CITY
ORDER BY MISSING_CUSTOMER_COUNT DESC;

/* Sample Output:
CITY                 MISSING_CUSTOMER_COUNT
-------------------- ----------------------
KARABÜK                                   2
ADIYAMAN                                  1
TRABZON                                   1
KOCAELİ                                   1
KIRŞEHİR                                  1
*/

-- 5.1 Find the customers who have used at least 75% of their data limit.
-- Approach:
-- This query requires information from all three tables, so we perform INNER JOINs across CUSTOMERS, MONTHLY_STATS, and TARIFFS. 
-- In the WHERE clause, we calculate the threshold by multiplying the tariff's DATA_LIMIT by 0.75. 
-- We then compare the customer's actual DATA_USAGE against this calculated threshold, returning only those who meet or exceed it.
SELECT c.CUSTOMER_ID, c.NAME, m.DATA_USAGE, t.DATA_LIMIT
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.DATA_USAGE >= (t.DATA_LIMIT * 0.75);

/* Sample Output:
CUSTOMER_ID NAME                 DATA_USAGE DATA_LIMIT
----------- -------------------- ---------- ----------
       2469 Yağmur                 17427.34      20480
       2481 Mustafa                18895.63      20480
       2489 Burak                  19272.67      20480
       2499 Metin                  15644.52      20480
       2206 Özlem                  15865.09      20480
*/

-- 5.2 Identify the customers who have completely exhausted all of their package limits.
-- Approach:
-- We construct a comprehensive query by joining the CUSTOMERS, MONTHLY_STATS, and TARIFFS tables together. 
-- To check for total package exhaustion, the WHERE clause must evaluate three separate conditions simultaneously. 
-- We use the AND logical operator to ensure the query only returns customers whose data, minute, and SMS usages all meet or exceed their respective tariff limits.
SELECT c.CUSTOMER_ID, c.NAME
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.DATA_USAGE >= t.DATA_LIMIT 
  AND m.MINUTE_USAGE >= t.MINUTE_LIMIT 
  AND m.SMS_USAGE >= t.SMS_LIMIT;

/* Sample Output:
CUSTOMER_ID NAME
----------- --------------------
       1089 Yağmur
       1093 Metin
        807 Ali
        857 Ali
        860 Furkan
*/

-- 6.1 Find the customers who have unpaid fees.
-- Approach:
-- We start by joining the CUSTOMERS table with the MONTHLY_STATS table on the CUSTOMER_ID column. 
-- This connection allows us to access the payment status for each individual customer's monthly record. 
-- We then apply a strict filter in the WHERE clause to selectively return rows where the PAYMENT_STATUS indicates the fee is completely unpaid.
SELECT c.CUSTOMER_ID, c.NAME, m.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.PAYMENT_STATUS = 'UNPAID';

/* Sample Output:
CUSTOMER_ID NAME                 PAYMENT_STATUS
----------- -------------------- --------------------
         19 Veli                 UNPAID
         20 Ayşe                 UNPAID
         22 Fatma                UNPAID
         25 Mehmet               UNPAID
*/

-- 6.2 Find the distribution of all payment statuses across the different tariffs.
-- Approach:
-- To examine this distribution, we need to bring together data from the TARIFFS, CUSTOMERS, and MONTHLY_STATS tables using INNER JOINs. 
-- We then utilize a multi-column GROUP BY clause, grouping the results by both the tariff name and the payment status. 
-- Using the COUNT() aggregate function on these groups provides the frequency of each payment status within every specific tariff plan.
SELECT t.NAME AS TARIFF_NAME, m.PAYMENT_STATUS, COUNT(m.ID) AS STATUS_COUNT
FROM TARIFFS t
JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
GROUP BY t.NAME, m.PAYMENT_STATUS
ORDER BY t.NAME, STATUS_COUNT DESC;

/* Sample Output:
TARIFF_NAME                              PAYMENT_STATUS       STATUS_COUNT
---------------------------------------- -------------------- ------------
Genç Dinamik                             PAID                         1792
Genç Dinamik                             LATE                          372
Genç Dinamik                             UNPAID                        352
Kobiye Destek                            PAID                         1719
Kobiye Destek                            LATE                          392
Kobiye Destek                            UNPAID                        360
Kurumsal SMS                             PAID                         1796
Kurumsal SMS                             UNPAID                        403
Kurumsal SMS                             LATE                          368
Çalışan GB                               PAID                         1692
Çalışan GB                               LATE                          365
Çalışan GB                               UNPAID                        339
*/
