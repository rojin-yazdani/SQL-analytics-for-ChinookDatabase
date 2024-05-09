-- Query 1 - query used for first insight 
WITH ARTISTS_AMTS AS (
	SELECT 
		STRFTIME('%Y', I.InvoiceDate) YEAR, 
		AR.ArtistId,
		AR.Name ArtistName, 
		SUM(IL.UnitPrice * IL.Quantity) SALE_AMT
	FROM InvoiceLine IL
	JOIN Invoice I ON IL.InvoiceId = I.InvoiceId
	JOIN Track T ON IL.TrackId = T.TrackId
	JOIN Album A ON T.AlbumId = A.AlbumId
	JOIN Artist AR ON A.ArtistId = AR.ArtistId
	GROUP BY STRFTIME('%Y', I.InvoiceDate), AR.ArtistId,AR.Name
)
SELECT 
	AA.YEAR, 
	AA.ArtistId, 
	AA.ArtistName, 
	AA.SALE_AMT
FROM ARTISTS_AMTS AA
JOIN (SELECT YEAR, MAX(SALE_AMT) MAX_SALE_AMT 
	  FROM ARTISTS_AMTS 
	  GROUP BY YEAR) YM 
   ON AA.YEAR = YM.YEAR AND AA.SALE_AMT = YM.MAX_SALE_AMT;

------------------------------------------------------------------------------------
-- Query 2 - query used for second insight 
SELECT 
	STRFTIME('%Y', I.InvoiceDate) YEAR, 
	G.Name GENRE_NAME, 
	SUM(IL.UnitPrice * IL.Quantity) SALE_AMT
FROM InvoiceLine IL
JOIN Invoice I ON IL.InvoiceId = I.InvoiceId
JOIN Track T ON IL.TrackId = T.TrackId
JOIN Genre G ON T.GenreId = G.GenreId
GROUP BY STRFTIME('%Y', I.InvoiceDate), G.Name
HAVING SALE_AMT > 20
ORDER BY 1,3 DESC;

------------------------------------------------------------------------------------
-- Query 3 - query used for third insight 
WITH COUNTRY_STATS AS 
(
	SELECT C.Country, G.GenreId, G.Name, SUM(IL.UnitPrice * IL.Quantity) SUM_PURCHASE, COUNT(I.InvoiceId) COUNT_PURCHASE
	FROM InvoiceLine IL
	JOIN Track T ON IL.TrackId = T.TrackId
	JOIN Genre G ON T.GenreId = G.GenreId
	JOIN Invoice I ON IL.InvoiceId = I.InvoiceId
	JOIN Customer C ON I.CustomerId = C.CustomerId  
	GROUP BY C.Country, G.GenreId, G.Name
)
SELECT CS.Country ||'-'|| CS.Name COUNTRY_GENRE, CS.SUM_PURCHASE, CS.COUNT_PURCHASE
FROM COUNTRY_STATS CS
JOIN (SELECT GI.Country, MAX(SUM_PURCHASE) MAX_SUM_PURCHASE, MAX(COUNT_PURCHASE) MAX_COUNT_PURCHASE
	  FROM  COUNTRY_STATS GI
	  WHERE COUNT_PURCHASE
	  GROUP BY GI.Country) CSM 
    ON CS.Country = CSM.Country AND CS.SUM_PURCHASE = CSM.MAX_SUM_PURCHASE AND CS.COUNT_PURCHASE = CSM.MAX_COUNT_PURCHASE
ORDER BY CS.Country;

------------------------------------------------------------------------------------
-- Query 4 - query used for fourth insight 
WITH CUSTOMER_STATS AS 
(
	SELECT C.Country, C.CustomerId, C.FirstName, C.LastName, SUM(I.TOTAL) SUM_SPENT 
	FROM Customer C
	JOIN Invoice I ON I.CustomerId = C.CustomerId
	GROUP BY C.Country, C.CustomerId, C.FirstName, C.LastName
)
SELECT CS.Country || '-' || CS.FirstName || ' ' || CS.LastName COUNTRY_CUSTOMER, CS.SUM_SPENT
FROM CUSTOMER_STATS CS
JOIN  
	(SELECT CC.Country, MAX(CC.SUM_SPENT) MAX_SUM_SPENT
	 FROM CUSTOMER_STATS CC 
	 GROUP BY CC.Country) CSM 
  ON CS.Country = CSM.Country AND CS.SUM_SPENT = CSM.MAX_SUM_SPENT
ORDER BY 1;
