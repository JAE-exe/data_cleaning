/*

Cleaning Data in SQL Queries

*/

SELECT SaleDate,CONVERT(DATE,SaleDate)
FROM NHD;


UPDATE NHD
SET SaleDate=CONVERT(DATE,SaleDate);


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NHD a
JOIN NHD b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>B.[UniqueID]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NHD a
JOIN NHD b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>B.[UniqueID]
WHERE a.PropertyAddress IS NULL;


SELECT PropertyAddress FROM NHD;


SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
FROM NHD;

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM NHD;

ALTER TABLE NHD
ADD PropertyStreetAddress NVARCHAR(255);

UPDATE NHD
SET PropertyStreetAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE NHD
ADD PropertyCityAddress NVARCHAR(255);

UPDATE NHD
SET PropertyCityAddress = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));


--SELECT 
--PARSENAME(REPLACE(OwnerAddress,',','.'),3),
--PARSENAME(REPLACE(OwnerAddress,',','.'),2),
--PARSENAME(REPLACE(OwnerAddress,',','.'),1)
--FROM NHD;


ALTER TABLE NHD
ADD OwnerStreetAddress NVARCHAR(255);

UPDATE NHD
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NHD
ADD OwnerCityAddress NVARCHAR(255);

UPDATE NHD
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NHD
ADD OwnerStateAddress NVARCHAR(255);

UPDATE NHD
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


ALTER TABLE NHD
ALTER COLUMN SoldAsVacant VARCHAR(3); -- Adjust length as needed

SELECT DISTINCT(SoldAsVacant)
FROM NHD;

UPDATE NHD
SET SoldAsVacant = 
	CASE
	WHEN SoldAsVacant = 0 THEN 'NO'
	WHEN SoldAsVacant = 1 THEN 'YES'
	ELSE SoldAsVacant
	END


ALTER TABLE NHD
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict;

SELECT * FROM NHD;
