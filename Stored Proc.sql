/*
WORKING WITH STORED PROCEDURES
*/


CREATE PROCEDURE Production.msp_Category_Insert
		@Name varchar (50)
AS
INSERT INTO Production.ProductCategory(Name)
VALUES (@Name)

SELECT SCOPE_IDENTITY();

GO;

---------------------------------------------------------------------------

CREATE PROC Purchasing.MyTestVendorAllInfo 
	(
	@Product varchar(25)
	)
AS
	SELECT LEFT(v.Name, 25) as Vendor
			, LEFT(p.Name, 25) as ProductName
			, 'Rating' = CASE v.CreditRating 
							WHEN 1 THEN 'Superior'
							WHEN 2 THEN 'Excellent'
							WHEN 3 THEN 'Above Average'
							WHEN 4 THEN 'Average'
							WHEN 5 THEN 'Below Average'
							ELSE 'No Rating'
						 END
			, 'Availability' = CASE v.ActiveFlag
							WHEN 1 THEN 'Yes'
							Else 'No'
						END
	FROM Purchasing.Vendor v
	JOIN Purchasing.ProductVendor pv
		ON v.[BusinessEntityID]=pv.[BusinessEntityID]
	JOIN Production.Product p
		ON p.ProductID = pv.ProductID
	WHERE p.Name LIKE @Product
	ORDER BY v.Name
GO

EXEC Purchasing.MyTestVendorAllInfo N'Thin-Jam Lock Nut 12';
GO


-- =============================================
-- Author:		Manya
-- Create date: 2/16/2016
-- Description:	Returns Employee Data
-- =============================================
CREATE PROCEDURE HumanResources.MyTestspGetEmplyees 
	-- Add the parameters for the stored procedure here
	@LastName nvarchar(50) = NULL, 
	@FirstName nvarchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT FirstName, LastName, Department
	FROM HumanResources.vEmployeeDepartmentHistory
	WHERE FirstName = @FirstName AND LastName = @LastName
		AND EndDate IS NULL;END
GO
EXECUTE @RC = [HumanResources].[MyTestspGetEmplyees] 
   Margheim 
  ,Diane 
GO




-- =============================================
-- Author: <Manya Gautam Bhandari>
-- Create date: <20200702>
-- Description:	<Stored Proc to create template working table for Raw data table>
-- =============================================
ALTER PROC [dbo].[__TMPL__BLD_WRK_TABLENAME]

AS
BEGIN
-- =============================================
-- Drop table if it exists
-- =============================================
IF OBJECT_ID('WRK_TABLENAME') IS NOT NULL
DROP TABLE [WRK_TABLENAME]

-- =============================================
-- Create WRKing table
-- =============================================
CREATE TABLE [WRK_TABLENAME]
(
	[Rownumber]			INT IDENTITY(1,1)
	,[AAA]				VARCHAR(100)
	,[DDD]				DATE
	,[BBB]				VARCHAR(1000)
	,[CCC]				VARCHAR(1)
	,[EEE]				INT	
	,[FFF]				FLOAT
)

-- =============================================
-- Truncate table to remove duplicate data addition
-- =============================================
TRUNCATE TABLE [WRK_TABLENAME]

-- =============================================
-- Insert into WRK table
-- =============================================
INSERT INTO [WRK_TABLENAME]
(
	[AAA]				
	,[DDD]				
	,[BBB]				
	,[CCC]				
	,[EEE]			
	,[FFF]				
)
SELECT 
	[AAA]				
	,[DDD]				
	,[BBB]				
	,[CCC]				
	,[EEE]			
	,[FFF]	
FROM [dbo].[TABLENAME]
-- (x rows affected)


END

/*
	SELECT *
	FROM [WRK_TABLENAME]

	SELECT *
	FROM [dbo].[TABLENAME]


*/
GO