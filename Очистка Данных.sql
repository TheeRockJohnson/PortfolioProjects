SELECT * FROM PortfolioProject.dbo.Housing

------------------------

SELECT SaleDateConverted, Convert(Date, SaleDate)
FROM PortfolioProject.dbo.Housing

Update Housing
Set SaleDate = Convert(Date,SaleDate)

Alter table Housing
Add SaleDateConverted Date;

Update Housing
Set SaleDateConverted = Convert(Date,SaleDate)


------------------------

SELECT *
FROM PortfolioProject.dbo.Housing
-- Where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.Housing a
Join Housing b 
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.Housing a
Join Housing b 
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]

------------------------------

SELECT PropertyAddress
FROM PortfolioProject.dbo.Housing
-- Where PropertyAddress is null
-- order by ParcelID

Select 
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1) as Address
, Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(PropertyAddress)) as Address
FROM PortfolioProject.dbo.Housing

Alter table housing
Add Address Nvarchar(255)

Update Housing
Set Address = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1)


Alter table housing
Add City Nvarchar(255)

Update Housing
Set City = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(PropertyAddress))

Select *
From Housing


------------------------

Select OwnerAddress
From Housing

Select
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From Housing

Alter table housing
Add OwnerStreet Nvarchar(255)
Update Housing
Set OwnerStreet = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter table housing
Add OwnerCity Nvarchar(255)
Update Housing
Set OwnerCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter table housing
Add OwnerState Nvarchar(255)
Update Housing
Set OwnerState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

Select *
From Housing

----------------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
Case 
	when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	End
From Housing

Update Housing
Set SoldAsVacant = Case 
	when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	End


--------------------------------------------
WITH RowNumCTE AS( 
Select *, 
	ROW_NUMBER() Over(
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID) row_num
From Housing
)
DELETE 
From RowNumCTE
Where row_num > 1


--------------------------------------------

Select * 
From Housing

Alter table Housing
Drop Column OwnerAddress, TaxtDistrict, PropertyAddress

Alter table Housing
Drop Column SaleDate





----------------------------         ETL


sp_configure 'show advanced options', 1;
Reconfigure
go 

sp_configure 'Ad Hoc Distributed Queries', 1;
Reconfigure
go

Use PortfolioProject
go

exec master.dbo.MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0' , N'AllowInProcess', 1
go 

exec master.dbo.MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0' , N'DynamicParameters', 1
go


---- bulk insert

Use PortfolioProject;
Go
Bulk insert Housing From 'C:\ ... '
	With (
		Fieldterminator = ',',
		Rowterminator = '\n'
		);
GO

----- Using Openrowset

Use PortfolioProject
Go
Select * into Housing
From openrowset('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0; ...',);
GO
 
