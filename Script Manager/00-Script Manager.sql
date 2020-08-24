
GO
:setvar Transaccional	"SeHablaSQL_Transaccional"
:setvar DataWarehouse	"SeHablaSQL_DW"
:setvar DataMart		"SeHablaSQL_DM"

:setvar Directorio "C:\Users\prica\Documents\MyWork\SQL Server Management Studio\SeHablaSQL\Script Manager"

GO
:on error exit
GO

:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
		RETURN 
    END
GO

BEGIN TRAN
	PRINT 'Iniciando en el Transaccional'
	USE [$(Transaccional)];
	:r $(Directorio)"\01-ALTER Categories y SubCategories.sql"
	GO
	:r $(Directorio)"\02-UPDATES Transaccional.sql"
	PRINT 'Transaccional Finalizado'

	PRINT 'Iniciando en el Data Warehouse'
	USE [$(DataWarehouse)];
	:r $(Directorio)"\01-ALTER Categories y SubCategories.sql"
	GO
	:r $(Directorio)"\21-UPDATES Data Warehouse.sql"
	PRINT 'Transaccional Data Warehouse'

	PRINT 'Iniciando Data Mart'
	USE [$(DataMart)];
	:r $(Directorio)"\30-ALTER DataMart.sql"
	GO
	:r $(Directorio)"\31-UPDATES DataMart.sql"
	PRINT 'Finalizando Data Mart'

SELECT DISTINCT CategoryOrder, SubCategoryOrder
FROM  Production.Products

-- ROLLBACK
-- COMMIT

--USE master;