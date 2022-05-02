--Cleaning Data:

SELECT * FROM 
[Portfolio Project]..[Nashville Housing]

--Standardize Date Format:

SELECT SaleDate, CONVERT(date, SaleDate) as Rectified_date FROM 
[Portfolio Project]..[Nashville Housing]

--UPDATE [Portfolio Project]..[Nashville Housing] SET SaleDate = CONVERT(Date, SaleDate); 

ALTER TABLE  [Portfolio Project]..[Nashville Housing] 
Add SaleDateConverted Date

UPDATE [Portfolio Project]..[Nashville Housing]
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, SaleDate FROM 
[Portfolio Project]..[Nashville Housing]


--Populate Property Address Data:

SELECT PropertyAddress FROM
[Portfolio Project]..[Nashville Housing]
WHERE PropertyAddress IS NULL

SELECT * FROM
[Portfolio Project]..[Nashville Housing]
WHERE PropertyAddress IS NULL

SELECT * FROM
[Portfolio Project]..[Nashville Housing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) FROM
[Portfolio Project]..[Nashville Housing] as a
JOIN [Portfolio Project]..[Nashville Housing] as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) FROM
[Portfolio Project]..[Nashville Housing] as a
JOIN [Portfolio Project]..[Nashville Housing] as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

SELECT PropertyAddress FROM [Portfolio Project]..[Nashville Housing]
WHERE PropertyAddress IS NULL

--Dissecting the address into city, state, etc.:

SELECT PropertyAddress FROM
[Portfolio Project]..[Nashville Housing]
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as State
FROM [Portfolio Project]..[Nashville Housing]

ALTER TABLE  [Portfolio Project]..[Nashville Housing] 
Add SplitedAddress nvarchar(255)

UPDATE [Portfolio Project]..[Nashville Housing]
SET SplitedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE  [Portfolio Project]..[Nashville Housing] 
Add SplitedState nvarchar(255)

UPDATE [Portfolio Project]..[Nashville Housing]
SET SplitedState = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT SplitedAddress, SplitedState FROM 
[Portfolio Project]..[Nashville Housing]

SELECT OwnerAddress FROM 
[Portfolio Project]..[Nashville Housing]

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as State
FROM 
[Portfolio Project]..[Nashville Housing]

ALTER TABLE  [Portfolio Project]..[Nashville Housing] 
Add SplitedOwnerAddress nvarchar(255)

UPDATE [Portfolio Project]..[Nashville Housing]
SET SplitedOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE  [Portfolio Project]..[Nashville Housing] 
Add SplitedOwnerCity nvarchar(255)

UPDATE [Portfolio Project]..[Nashville Housing]
SET SplitedOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE  [Portfolio Project]..[Nashville Housing] 
Add SplitedOwnerState nvarchar(255)

UPDATE [Portfolio Project]..[Nashville Housing]
SET SplitedOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT SplitedOwnerAddress, SplitedOwnerCity, SplitedOwnerState
FROM [Portfolio Project]..[Nashville Housing]

SELECT * FROM [Portfolio Project]..[Nashville Housing]

--Change Y and N to YES and NO respectively:

SELECT SoldAsVacant, COUNT(SoldAsVacant) as Counts
FROM [Portfolio Project]..[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY Counts DESC

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
	as ModifiedSAV
FROM [Portfolio Project]..[Nashville Housing]
WHERE SoldAsVacant IN ('Y', 'N')

UPDATE [Portfolio Project]..[Nashville Housing]
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

SELECT SoldAsVacant, COUNT(SoldAsVacant) as Counts
FROM [Portfolio Project]..[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY Counts DESC

--Deleting Duplicates:

WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
				UniqueID
			) row_num
FROM [Portfolio Project]..[Nashville Housing]
--ORDER BY ParcelID
)
DELETE FROM ROWNUMCTE
WHERE row_num>1 
--ORDER BY PropertyAddress

--Verifying the deletion

WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
				UniqueID
			) row_num
FROM [Portfolio Project]..[Nashville Housing]
--ORDER BY ParcelID
)
SELECT * FROM ROWNUMCTE
WHERE row_num>1 
ORDER BY PropertyAddress

--Deleting Unused Columns:

SELECT * FROM 
[Portfolio Project]..[Nashville Housing]

ALTER TABLE [Portfolio Project]..[Nashville Housing]
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE [Portfolio Project]..[Nashville Housing]
DROP COLUMN SaleDate