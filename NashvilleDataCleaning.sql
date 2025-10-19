/*
	@author Oluwapamilerin Agbekorode
	Cleaning Data in SQL Queries 
*/
------------------------------------------------------------------
Select * 
from SQL_Project.dbo.NashvilleHousing

-- Standardize Data Format
Select SaleDateConverted, CONVERT(Date, SaleDate) 
from SQL_Project.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) 



------------------------------------------------------------------------------------------
-- Populate Property Address Data 
Select *
from SQL_Project.dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from SQL_Project.dbo.NashvilleHousing a
JOIN SQL_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from SQL_Project.dbo.NashvilleHousing a
JOIN SQL_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from SQL_Project.dbo.NashvilleHousing
-- where PropertyAddress is null
-- order by ParcelID

select 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

from SQL_Project.dbo.NashvilleHousing;

ALTER TABLE SQL_Project.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update SQL_Project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE SQL_Project.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update SQL_Project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
from  SQL_Project.dbo.NashvilleHousing;


Select OwnerAddress
from  SQL_Project.dbo.NashvilleHousing;

SELECT 
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) + ' ' +
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS CityState,
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS ZipCode
FROM SQL_Project.dbo.NashvilleHousing;



ALTER TABLE SQL_Project.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update SQL_Project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE SQL_Project.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update SQL_Project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Select *
from  SQL_Project.dbo.NashvilleHousing;
------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from  SQL_Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
from SQL_Project.dbo.NashvilleHousing;

 Update SQL_Project.dbo.NashvilleHousing
 SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

------------------------------------------------------------------------------------------------------
-- Remove Duplicate

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
)   row_num
from SQL_Project.dbo.NashvilleHousing
-- order by ParcelID;
)
select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress;

------------------------------------------------------------------------------------------------------
--Delete Unused Colomns

Select *
from SQL_Project.dbo.NashvilleHousing;

ALTER TABLE SQL_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE SQL_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate






--------------------------------------------------------------------------------------------------------------