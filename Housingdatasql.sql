--Cleaning Data In SQL

select *
from Housingdata

-- Standardize Date Format

SELECT SaleDate
from housingdata

alter table housingdata
add SaleDatConverted date

update housingdata
set SaleDatConverted=convert(date,SaleDate)

-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from housingdata a
JOIN Housingdata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from housingdata a
JOIN Housingdata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
--- Using Substring
Select PropertyAddress
From housingdata

select 
substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1 ) as address,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as Address
from housingdata

alter table housingdata
add PropertySplitAddress Nvarchar(255);

update housingdata
set PropertySplitAddress=substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1 ) 

alter table housingdata
add PropertySplitCity  Nvarchar(255);

update housingdata
set PropertySplitCity=substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))

---Using PARSENAME
Select OwnerAddress
From housingdata

select
parsename(replace(OwnerAddress, ',', '.'),3),
parsename(replace(OwnerAddress, ',', '.'),2),
parsename(replace(OwnerAddress, ',', '.'),1)
From housingdata


alter table housingdata
Add OwnerSplitAddress Nvarchar(255);

update housingdata
set OwnerSplitAddress=parsename(replace(OwnerAddress, ',', '.'),3)

alter table housingdata
add OwnerSplitCity Nvarchar(255);

update housingdata
set OwnerSplitCity=parsename(replace(OwnerAddress, ',', '.'),2)

alter table housingdata
add OwnerSpliState Nvarchar(255);

update housingdata
set OwnerSpliState=parsename(replace(OwnerAddress, ',', '.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from housingdata
group by SoldAsVacant
order by 2

select
case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end
from housingdata

update housingdata
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Housingdata
---order by ParcelID
)
select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


---deleting duplicate rows
delete
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns
alter table housingdata
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select *
from Housingdata



