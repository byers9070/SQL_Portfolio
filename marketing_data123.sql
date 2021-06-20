SELECT *
FROM
 marketing_data.dbo.store

  ----
  
SELECT *
FROM 
  (
SELECT 
  ID,
  SUM(NumDealsPurchases) + SUM(NumWebPurchases) 
  + SUM(numStorePurchases) as totalPurchases
FROM marketing_data.dbo.store 
GROUP BY ID
 ) a
 JOIN marketing_data.dbo.store b
 ON a.ID = b.ID

 
  ---- add total purchases to TEMP TABLE 
CREATE TABLE #purchases
 (
  ID numeric,
  NumDealsPurchases numeric,
  NumWebPurchases numeric,
  numStorePurchases numeric, 
  totalPurchases numeric
  )
INSERT INTO #purchases    
SELECT 
  ID,
  NumDealsPurchases,
  NumWebPurchases,
  numStorePurchases, 
    SUM(NumDealsPurchases) + SUM(NumWebPurchases) 
    + SUM(numStorePurchases) as totalPurchases
FROM marketing_data.dbo.store 
GROUP BY 
  ID, 
  NumDealsPurchases, 
  NumWebPurchases, 
  numStorePurchases
  
  ----
SELECT 
  ID,
  NumDealsPurchases,
  NumWebPurchases,
  numStorePurchases, 
  totalPurchases
FROM #purchases

  ----

SELECT *
FROM #purchases

---- with kids


CREATE TABLE #purchases_withKids
 (
  ID numeric,
  NumDealsPurchases numeric,
  NumWebPurchases numeric,
  numStorePurchases numeric, 
  kidhome numeric,
  teenhome numeric,
  totalPurchases numeric,
  acceptedcmp1 int,
  acceptedcmp2 int,
  acceptedcmp3 int
  )

   
 DROP TABLE IF EXISTS #purchases_withKids 
  INSERT INTO #purchases_withKids    
SELECT 
  ID,
  NumDealsPurchases,
  NumWebPurchases,
  numStorePurchases,
  kidhome,
  teenhome,
  SUM(NumDealsPurchases) + SUM(NumWebPurchases) 
    + SUM(numStorePurchases) as totalPurchases,
  CAST(acceptedcmp1 AS int),
  CAST(acceptedcmp2 AS int),
  CAST(acceptedcmp3 AS int)
FROM marketing_data.dbo.store 

GROUP BY 
  ID, 
  NumDealsPurchases, 
  NumWebPurchases, 
  numStorePurchases,
  kidhome,
  teenhome,
  acceptedcmp1,
  acceptedcmp2,
  acceptedcmp3
HAVING 
  kidhome > 0 or teenhome > 0 


 -----------PURCHASES WITH KIDS------------------------------
---- Total purchases for homes with kids/
---- 1602 c w/ kids - 638 w/o kids - 2240 total 
---- 12 AVG # purchases for all customers
---- 12 AVG # purchases for c w/ kids
---- with kids and totalPurchases > 12 681 (above avg)
---- 871 <= 12 purchases (below avg)
---- 50 = 12 AKA rep of avg c (avg)

-----------------WITHOUT KIDS---------------------------------
---- 638 customer w/o kids
---- 342 cust w/o kids >12 purchases
---- 13 ACG # PURCHASES NO KIDS

---- statstical outliers 11 c 3 purchases or less
 
 ------------------------------------------------------------
SELECT 
  AVG(totalPurchases)
FROM
  #purchases

  ---- 

SELECT *
FROM
  #purchases_withKids

  ----
SELECT 
  AVG(totalPurchases)
FROM
  #purchases_withKids

----

SELECT *
FROM 
  #purchases
WHERE
  kidhome > 0 or teenhome > 0 


---- with kids and totalPurchases > 12

SELECT *
FROM
  #purchases_withKids
WHERE
  totalPurchases > 12

  ---- statstical outliers 11 c 3 purchases or less

SELECT *
FROM
  #purchases_withKids
WHERE
  totalPurchases <= 3

  ---- 871 < 12 puechases 
SELECT *
FROM
  #purchases_withKids
WHERE
  totalPurchases < 12

  ----

SELECT *
FROM
  #purchases
WHERE
  totalPurchases = 12

-----------------------------------------------------------------
DROP TABLE IF EXISTS #cmp
CREATE TABLE #cmp
 (
  ID int,
  NumDealsPurchases int,
  NumWebPurchases int,
  numStorePurchases int, 
  totalPurchases int,
  kidhome int,
  teenhome int,
  acceptedcmp1 int,
  acceptedcmp2 int,
  acceptedcmp3 int
  )

INSERT INTO #cmp    
SELECT 
  ID,
  NumDealsPurchases,
  NumWebPurchases,
  numStorePurchases, 
  kidhome,
  teenhome,
    SUM(NumDealsPurchases) + SUM(NumWebPurchases) 
    + SUM(numStorePurchases) as totalPurchases,
  CAST(acceptedcmp1 AS int),
  CAST(acceptedcmp2 AS int),
  CAST(acceptedcmp3 AS int)

FROM marketing_data.dbo.store 
GROUP BY 
  ID, 
  NumDealsPurchases, 
  NumWebPurchases, 
  numStorePurchases,
  kidhome,
  teenhome,
  acceptedcmp1,
  acceptedcmp2,
  acceptedcmp3
  
---- 

SELECT *
FROM #cmp

---------------------------------------------------------------

CREATE TABLE #purchases_noKids
 (
  ID numeric,
  NumDealsPurchases numeric,
  NumWebPurchases numeric,
  numStorePurchases numeric, 
  kidhome numeric,
  teenhome numeric,
  totalPurchases numeric,
  acceptedcmp1 int,
  acceptedcmp2 int,
  acceptedcmp3 int
  )

   
 DROP TABLE IF EXISTS #purchases_noKids 
  INSERT INTO #purchases_noKids    
SELECT 
  ID,
  NumDealsPurchases,
  NumWebPurchases,
  numStorePurchases,
  kidhome,
  teenhome,
  SUM(NumDealsPurchases) + SUM(NumWebPurchases) 
    + SUM(numStorePurchases) as totalPurchases,
  CAST(acceptedcmp1 AS int),
  CAST(acceptedcmp2 AS int),
  CAST(acceptedcmp3 AS int)
FROM marketing_data.dbo.store 

GROUP BY 
  ID, 
  NumDealsPurchases, 
  NumWebPurchases, 
  numStorePurchases,
  kidhome,
  teenhome,
  acceptedcmp1,
  acceptedcmp2,
  acceptedcmp3
HAVING 
  kidhome = 0 and teenhome = 0 


------------------------------------------------------------
SELECT *
FROM #purchases_withKids 

 ----
SELECT *
FROM #purchases_noKids 

 ---- 13 AVG # PURCHASES NO KIDS
SELECT 
  AVG(totalPurchases)
FROM
  #purchases_noKids 

  ---- 342 cust w/o kids >12 purchases
----------------------NO KIDS-----------------------------------------
SELECT *
FROM #purchases_noKids 
WHERE totalPurchases > 12 
---- 75 accpetedcmp1
SELECT *
FROM #purchases_noKids 
WHERE totalPurchases > 12 and acceptedcmp1 = 1
 ---- 14 acceptedcmp2
SELECT *
FROM #purchases_noKids 
WHERE totalPurchases > 12 and acceptedcmp2 = 1
---- 24 acceptedcmp3
SELECT *
FROM #purchases_noKids 
WHERE totalPurchases > 12 and acceptedcmp3 = 1

----------------------KIDS----------------------------------

SELECT *
FROM #purchases_withKids 
WHERE totalPurchases > 12 
---- 30 accpetedcmp1
SELECT *
FROM #purchases_withKids 
WHERE totalPurchases > 12 and acceptedcmp1 = 1
 ---- 7 acceptedcmp2
SELECT *
FROM #purchases_withKids 
WHERE totalPurchases > 12 and acceptedcmp2 = 1
---- 47 acceptedcmp3
SELECT *
FROM #purchases_withKids 
WHERE totalPurchases > 12 and acceptedcmp3 = 1

---------------------------------------------------------------

   