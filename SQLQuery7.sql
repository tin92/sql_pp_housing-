/*

Cleaning data using SQL queries

*/

SELECT *
FROM PortfolioProject3..nashville;

-----------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format 

SELECT SaleDate, [SaleDate]
FROM PortfolioProject3..nashville
WHERE ISDATE([SaleDate]) = 0;

UPDATE PortfolioProject3..nashville
SET SaleDate = LEFT(SaleDate, CHARINDEX('-', SaleDate) - 1)
WHERE CHARINDEX('-', SaleDate) > 0

SELECT SaleDate, CAST(SaleDate AS DATE) AS 'SaleDate1' 
FROM PortfolioProject3..nashville;

ALTER TABLE PortfolioProject3..nashville
ADD SaleDateConverted DATE

UPDATE PortfolioProject3..nashville
SET SaleDateConverted = CAST(SaleDate AS DATE)

--------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT PropertyAddress
FROM PortfolioProject3..nashville
WHERE PropertyAddress = ''


SELECT *
FROM PortfolioProject3..nashville
-- WHERE PropertyAddress = ''
ORDER BY ParcelID;

-- ParcelID corresponds to PropertyAddress

UPDATE PortfolioProject3..nashville
SET PropertyAddress = NULL 
WHERE PropertyAddress = ''

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject3..nashville AS a 
JOIN PortfolioProject3..nashville AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
	WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject3..nashville AS a 
JOIN PortfolioProject3..nashville AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
	WHERE a.PropertyAddress IS NULL
-------------------------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject3..nashville;

SELECT PropertyAddress
FROM PortfolioProject3..nashville
WHERE PropertyAddress NOT LIKE  '%,%'

SELECT *
FROM PortfolioProject3..nashville
WHERE PropertyAddress LIKE '499900' OR
	PropertyAddress LIKE '78000'

UPDATE PortfolioProject3..nashville
SET PropertyAddress = '144 SCENIC VIEW  RD, OLD HICKORY',
	ParcelID = '499900'
WHERE PropertyAddress = '499900'
	

UPDATE PortfolioProject3..nashville
SET PropertyAddress = '0  COUCHVILLE PIKE, HERMITAGE',
	ParcelID = '78000'
WHERE PropertyAddress = '78000'

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS 'Address',
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS 'Address1'
FROM PortfolioProject3..nashville;


ALTER TABLE PortfolioProject3..nashville
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject3..nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject3..nashville
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject3..nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * FROM PortfolioProject3..nashville

-- Look at owner address 

SELECT OwnerAddress
FROM PortfolioProject3..nashville


SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject3..nashville


ALTER TABLE PortfolioProject3..nashville
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject3..nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


ALTER TABLE PortfolioProject3..nashville
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject3..nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE PortfolioProject3..nashville
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject3..nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


SELECT * FROM PortfolioProject3..nashville


-- Create new columns for table



-------------------------------------------------------------------------------------

-- Change Y and N in 'Vacant Field' to Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldasVacant)
FROM PortfolioProject3..nashville
GROUP BY SoldasVacant
ORDER BY 2

SELECT *
FROM PortfolioProject3..nashville
WHERE SoldasVacant = '47,5'

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject3..nashville

UPDATE PortfolioProject3..nashville
	SET SoldAsVacant =
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

DELETE 
FROM PortfolioProject3..nashville
WHERE SoldAsVacant = '5,33'OR 
	SoldAsVacant = '1,28' OR
	SoldAsVacant = '47,5' OR
	SoldAsVacant = '';

---------------------------------------------------------------------------------------------------

-- Remove duplicates 
WITH RowNumCTE AS(	
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID
	) row_num
FROM PortfolioProject3..nashville
--ORDER BY ParcelID
)

/*
SELECT *
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress
*/

DELETE
FROM RowNumCTE 
WHERE row_num > 1

--------------------------------------------------------------------------------------------------------------

-- Delete unused columns 

ALTER TABLE PortfolioProject3..nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM PortfolioProject3..nashville
---------------------------------------------------------------------------------------------------------------

