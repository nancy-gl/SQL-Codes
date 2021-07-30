/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [Covid-Data-Portfolio].[dbo].[NashvilleHousingData] -- 56,477 rows

------------------------------------------------------------------------
 -- Statndardize the date format
 -- Changed the date format from DateTime to Date

 Select [SaleDate], CONVERT(Date, SaleDate, 101)
 FROM [Covid-Data-Portfolio].[dbo].[NashvilleHousingData]

 Update [NashvilleHousingData]
 Set SaleDate = CONVERT(Date, SaleDate, 101)  -- did not update dont know why

 Select *
 FROM [Covid-Data-Portfolio].[dbo].[NashvilleHousingData]

ALTER TABLE NashvilleHousingData
Alter Column SaleDate Date  -- this worked

------------------------------------------------------------------------
-- Populate Property address

 Select PropertyAddress
 FROM [Covid-Data-Portfolio].[dbo].[NashvilleHousingData]
 Where PropertyAddress is null  -- 29 rows has null value

 Select *
 FROM [Covid-Data-Portfolio].[dbo].[NashvilleHousingData]
 Where PropertyAddress is null 

 Select a.ParcelID, a.PropertyAddress,b.ParcelId, b.PropertyAddress
 From [Covid-Data-Portfolio].[dbo].[NashvilleHousingData] a
 Join [Covid-Data-Portfolio].[dbo].[NashvilleHousingData] b
	On a.ParcelID = b.ParcelID   -- 73,795 rows for join on ParcelId only
	And a.UniqueId <> b.UniqueID -- 17,318 rows

 Select a.ParcelID, a.PropertyAddress,b.ParcelId, b.PropertyAddress
		, ISNULL(a.PropertyAddress, b.PropertyAddress)
 From [Covid-Data-Portfolio].[dbo].[NashvilleHousingData] a
 Join [Covid-Data-Portfolio].[dbo].[NashvilleHousingData] b
	On a.ParcelID = b.ParcelID   -- 73,795 rows for join on ParcelId only
	And a.UniqueId <> b.UniqueID 
 Where a.PropertyAddress is null  -- 35 rows are null that is replaced by property address

 Update a
 Set PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
  From [Covid-Data-Portfolio].[dbo].[NashvilleHousingData] a
 Join [Covid-Data-Portfolio].[dbo].[NashvilleHousingData] b
	On a.ParcelID = b.ParcelID   
	And a.UniqueId <> b.UniqueID 
 Where a.PropertyAddress is null --(29 rows affected) no null values in the propertyaddress column

 --------------------------------------------------------------------------------------------------------
 -- Breaking Out Address into Individual Columns (address, city, state)
 Select PropertyAddress
 FROM [Covid-Data-Portfolio].[dbo].[NashvilleHousingData]

 Select PropertyAddress, 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as PropertyStreetAddress,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) as PropertyState
 FROM [Covid-Data-Portfolio].[dbo].[NashvilleHousingData]

 Alter Table NashvilleHousingData
 Add PropertyStreetAddress nvarchar(255)
 Update NashvilleHousingData
 Set PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

 Alter Table NashvilleHousingData
 Add PropertyCity nvarchar(255)
 Update NashvilleHousingData
 Set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) 

 ---------------------------------------------------------------------------------------------------------
 -- Breaking out Owner's Address in a simpler way

 Select OwnerAddress
 From NashvilleHousingData

 -- PARSENAME function can be used to separate the columns but it obly works with periods so Replace , with .
 Select OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerStreetAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerCity,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerState
 From NashvilleHousingData

 Alter Table NashvilleHousingData
 Add OwnerStreetAddress nvarchar(255)
 Update NashvilleHousingData
 Set OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

 Alter Table NashvilleHousingData
 Add OwnerCity nvarchar(255)
 Update NashvilleHousingData
 Set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

 Alter Table NashvilleHousingData
 Add OwnerState nvarchar(255)
 Update NashvilleHousingData
 Set OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 ---------------------------------------------------------------------------------------------------
 --Change Y to YES and N to NO

 Select SoldAsVacant
 From NashvilleHousingData

 Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as Count
 From NashvilleHousingData
 Group by SoldAsVacant
 Order by 2

 Select SoldAsVacant 
		, Case When SoldAsVacant = 'Y' Then 'Yes' 
			   When SoldAsVacant = 'N' Then 'No'
			   Else SoldAsVacant
			   End
 From NashvilleHousingData

 Update NashvilleHousingData
 Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes' 
						 When SoldAsVacant = 'N' Then 'No'
						 Else SoldAsVacant
						 End

--------------------------------------------------------------------------------------------------
-- Remove Duplicates

With RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	Order By UniqueID
	) as row_num
From NashvilleHousingData
-- Order By ParcelID
)
Select * 
From RowNumCTE
Where row_num > 1
Order By [UniqueID ] --104 duplicate rows

-- Replace 'Select' with 'Delete' to delete the duplicates, only doing it in this practice dataset not with real data.
With RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	Order By UniqueID
	) as row_num
From NashvilleHousingData
-- Order By ParcelID
)
Delete  
From RowNumCTE
Where row_num > 1  --104 rows removed


-------------------------------------------------------------------------------------------------------------------------------------
--Delete unused columns (we normally create a view for selecting columns so this step is not realistic)

Select *
From NashvilleHousingData

ALter Table NashvilleHousingData
Drop Column OwnerAddress, TaxDistrict, PropertyAddress