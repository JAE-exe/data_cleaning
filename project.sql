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
