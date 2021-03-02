-- EXAMPLE: RECURSIVE DATE WITH CTE:
-- Input Parameters:

DECLARE @inpStartDate Date = DATEADD(YY, -2, GETDATE()),			--	Start date of the calendar
	   				 @inpEndDate Date = GETDATE()		-- End date of the calendar
SELECT StartDate = @inpStartDate , EndDate = @inpEndDate

;WITH GetCalendar (DayDate, NameofDay, NameofMonth, Yearof)			-- CTE Definition
AS
(
-- Block1: This block will create the base of table to generate the first record of the calendar
SELECT DayDate = @inpStartDate
			, NameofDay = DATENAME(DW, @inpStartDate)
			, NameofMonth = DATENAME(MM, @inpStartDate)
			, Yearof = YEAR(@inpStartDate)
UNION ALL
-- Block2: This block will use the first block and will add the 1 day in the current of the GetCalendar
-- This will produce a resultset till the end of @inpEndDate
SELECT DayDate = DATEADD(D, 1, DayDate)
			, NameofDay = DATENAME(DW, DATEADD(D, 1, DayDate))
			, NameofMonth = DATENAME(MM, DATEADD(D, 1, DayDate))
			, Yearof = YEAR(DATEADD(D, 1, DayDate))
FROM GetCalendar
WHERE DayDate <= @inpEndDate
)
SELECT * FROM GetCalendar		-- Pull the calendar data
OPTION (MAXRECURSION 0)			-- Set to get all data




------------------------------------------------------------------------------------------------------------------------------
/*
Example - Recursive query to generate numbers between 1 to 10
*/

WITH NumberCTE AS
(
SELECT 1 AS Number
UNION ALL
SELECT Number+1 FROM NumberCTE 
WHERE Number<10
)
SELECT * FROM NumberCTE



-------------------------------------------------------------------------------------------------------------------------------------------
-- A simple self-join works if we only need employee name and manager name but if we need the 
-- hierarchy of employee and manager we need to build a  recursive CTE as shown in the following section

Select E1.EmployeeName As EmployeeName
			 , ISNULL(E2.EmployeeName, 'C.E.O.') As ManagerName
From Employees_ForCTE E1
Left Join Employees_ForCTE E2
	On E1.ManagerID = E2.EmployeeID

-- SQL Query to get organization hierarchy
Use LearnItFirst
GO
Declare @ID int =7;
With EmployeeCTE As
(
		Select EmployeeID, EmployeeName, ManagerID
		From Employees_ForCTE
		Where EmployeeID = @ID
		Union ALL
		Select Employees_ForCTE.EmployeeID, Employees_ForCTE.EmployeeName, Employees_ForCTE.ManagerID
		From Employees_ForCTE
		Join EmployeeCTE
		On Employees_ForCTE.EmployeeID = EmployeeCTE.ManagerID
)
Select E1.EmployeeName, ISNULL (E2.EmployeeName, 'C.E.O.') as ManagerName
From EmployeeCTE E1
Left Join EmployeeCTE E2
On E1.ManagerID = E2.EmployeeID

-- -------------------------------------------------------------------------------------------------------------------------------
/*
SQL Query to Delete duplicate rows using a CTE
*/

Create table Employees_DeleteDuplicates
(
 ID int,
 FirstName nvarchar(50),
 LastName nvarchar(50),
 Gender nvarchar(50),
 Salary int
)
GO

Insert into Employees_DeleteDuplicates values (1, 'Mark', 'Hastings', 'Male', 60000)
Insert into Employees_DeleteDuplicates values (1, 'Mark', 'Hastings', 'Male', 60000)
Insert into Employees_DeleteDuplicates values (1, 'Mark', 'Hastings', 'Male', 60000)
Insert into Employees_DeleteDuplicates values (2, 'Mary', 'Lambeth', 'Female', 30000)
Insert into Employees_DeleteDuplicates values (2, 'Mary', 'Lambeth', 'Female', 30000)
Insert into Employees_DeleteDuplicates values (3, 'Ben', 'Hoskins', 'Male', 70000)
Insert into Employees_DeleteDuplicates values (3, 'Ben', 'Hoskins', 'Male', 70000)
Insert into Employees_DeleteDuplicates values (3, 'Ben', 'Hoskins', 'Male', 70000)
GO

-- The delete query should delete all duplicate rows except one. 
WITH EmployeesCTE AS
(
   SELECT *, ROW_NUMBER()OVER(PARTITION BY ID ORDER BY ID) AS RowNumber
   FROM Employees_DeleteDuplicates
)
DELETE FROM EmployeesCTE WHERE RowNumber > 1
GO
