/*
    Data Cleaning in SQL
    
    This script performs data cleaning operations on the NHD table, including:
    - Standardizing date formats
    - Filling in missing property addresses
    - Splitting address fields into separate components
    - Standardizing boolean values
    - Removing unnecessary columns
*/

/* 1. Standardize SaleDate Format */
SELECT SaleDate, CONVERT(DATE, SaleDate) AS FormattedSaleDate
FROM NHD;

-- Update SaleDate column to store data in proper DATE format
UPDATE NHD
SET SaleDate = CONVERT(DATE, SaleDate);

/* 2. Fill Missing Property Addresses Using ParcelID */

-- Identify records where PropertyAddress is NULL and can be updated using another record with the same ParcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       ISNULL(a.PropertyAddress, b.PropertyAddress) AS UpdatedAddress
FROM NHD a
JOIN NHD b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

-- Update missing PropertyAddress values
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NHD a
JOIN NHD b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

/* 3. Split PropertyAddress into Street and City */

-- Extract street and city from PropertyAddress
SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS PropertyStreetAddress,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertyCityAddress
FROM NHD;

-- Add new columns for street and city
ALTER TABLE NHD ADD PropertyStreetAddress NVARCHAR(255);
ALTER TABLE NHD ADD PropertyCityAddress NVARCHAR(255);

-- Update new columns with extracted values
UPDATE NHD
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

UPDATE NHD
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

/* 4. Split OwnerAddress into Street, City, and State */

-- Extract street, city, and state using PARSENAME (requires replacing commas with dots)
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreet,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM NHD;

-- Add new columns for owner address components
ALTER TABLE NHD ADD OwnerStreetAddress NVARCHAR(255);
ALTER TABLE NHD ADD OwnerCityAddress NVARCHAR(255);
ALTER TABLE NHD ADD OwnerStateAddress NVARCHAR(255);

-- Update new columns with extracted values
UPDATE NHD
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE NHD
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE NHD
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

/* 5. Standardize SoldAsVacant Values */

-- Change SoldAsVacant column type to store "YES" and "NO" instead of 0 and 1
ALTER TABLE NHD ALTER COLUMN SoldAsVacant VARCHAR(3);

-- Check distinct values before updating
SELECT DISTINCT SoldAsVacant FROM NHD;

-- Convert 0/1 values to "NO"/"YES"
UPDATE NHD
SET SoldAsVacant = 
    CASE 
        WHEN SoldAsVacant = '0' THEN 'NO'
        WHEN SoldAsVacant = '1' THEN 'YES'
        ELSE SoldAsVacant
    END;

/* 6. Remove Unnecessary Columns */

ALTER TABLE NHD DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

/* 7. Final Cleaned Data Output */

SELECT * FROM NHD;
