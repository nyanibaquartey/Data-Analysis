/*

Data Cleaning

*/


SELECT *
FROM PortfolioProjects..NashvilleHousing


-----------------------STANDARDIZING DATE FORMAT----------------------------

ADD NEW COLUMN FOR NEW DATE FORMAT

ALTER TABLE PortfolioProjects..NashvilleHousing
ADD SaleDateConverted DATE

POPULATE THE NEW COLUMN

UPDATE PortfolioProjects..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

DISPLAY THE ORIGINAL AND NEW DATE COLUMNS

SELECT SaleDate, SaleDateConverted
FROM PortfolioProjects..NashvilleHousing



------------------------------POPULATING ADDRESS COLUMN FOR PROPERTIES WITH MISSING ADDRESSES-------------------------------------


DISPLAY PROPERTIES WITH NO PROPERTY ADDRESS

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--POPULATE PROPERTY ADDRESS DATA WHERE NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



----------------------SPLITTING PROPERTY ADDRESS-------------------------------------


--SPLIT ADDRESS COLUMN INTO ADDRESS NUMBER AND  CITY

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProjects..NashvilleHousing


--ADD NEW COLUMNS FOR ADDRESS NUMBER AND ADDRESS CITY
 
ALTER TABLE PortfolioProjects..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
	PropertySplitCity NVARCHAR(255)


--POPULATE NEW COLUMNS

UPDATE PortfolioProjects..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--VIEW NEWLY CREATED COLUMNS

SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProjects.dbo.NashvilleHousing



-------------------------------SPLITTING OWNER ADDRESS-------------------------------


VIEW OWNER ADDRESS COLUMN

SELECT OwnerAddress
FROM PortfolioProjects.dbo.NashvilleHousing


--SPLIT ADDRESS

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjects.dbo.NashvilleHousing


--ADD NEW COLUMNS FOR ADDRESS NUMBER AND ADDRESS CITY
 
ALTER TABLE PortfolioProjects..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255)


--POPULATE NEW COLUMNS

UPDATE PortfolioProjects..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--VIEW NEWLY CREATED COLUMNS

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProjects.dbo.NashvilleHousing




--------------------CHANGE N & Y TO YES & NO IN SOLD AS VACANT FIELD------------------------------

SELECT DISTINCT SoldAsVacant, COUNT(*)
FROM PortfolioProjects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
		END
FROM PortfolioProjects.dbo.NashvilleHousing



UPDATE PortfolioProjects..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
		END




---------------------------------REMOVE DUPLICATES---------------------------------

--Using row number window function to identify duplicates
--Use CTE to be able to use the row number function result column in the WHERE clause
WITH cte_row_num AS (
SELECT *,
		ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
							ORDER BY UniqueID) AS row_num
FROM PortfolioProjects..NashvilleHousing 
)

--SELECT *
--FROM cte_row_num
--WHERE row_num <> 1

DELETE 
FROM cte_row_num
WHERE row_num <> 1