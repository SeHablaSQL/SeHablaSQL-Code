/*** Objetivo:
	? Simular ambiente empresarial con:		básico de ventas para en el siguiente script generar nuevos requerimientos de negocios
		? un sistema transaccional
		? un Data Warehouse
		? un Data Mart 		
	? Mantener intacta AdventureWorks
	? Crear una tabla de Ventas con posibilidades de ser mejorada

--Nota: algunas partes
*/

IF NOT EXISTS (SELECT * FROM sys.databases where name = 'SeHablaSQL_Transaccional')
	CREATE DATABASE SeHablaSQL_Transaccional
GO
IF NOT EXISTS (SELECT * FROM sys.databases where name = 'SeHablaSQL_DW')
	CREATE DATABASE SeHablaSQL_DW
GO
IF NOT EXISTS (SELECT * FROM sys.databases where name = 'SeHablaSQL_DM')
	CREATE DATABASE SeHablaSQL_DM
GO

/*************************************************************************************************/
/* Copiamos las tablas de AdventureWorks de Productos, para Usar SeHablaSQL_Transaccional como la 
   BD transaccional */
USE SeHablaSQL_Transaccional
GO
	DROP TABLE IF EXISTS Production.Product;
	DROP TABLE IF EXISTS Production.ProductSubCategory;
	DROP TABLE IF EXISTS Production.ProductCategory;
GO
BEGIN	/* Trabajamos el transaccional */

	IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Production')
		EXEC('CREATE SCHEMA Production AUTHORIZATION dbo;')
		
	
	CREATE TABLE Production.ProductCategory(
		  ProductCategoryID INT NOT NULL
		, Name VARCHAR(50) NOT NULL
		, rowguid uniqueidentifier ROWGUIDCOL  NOT NULL
		, ModifiedDate datetime NOT NULL
		, CONSTRAINT PK_ProductCategory_ProductCategoryID 
			PRIMARY KEY CLUSTERED 
			(ProductCategoryID ASC)
	);

	CREATE TABLE Production.ProductSubCategory(
		  ProductSubCategoryID INT NOT NULL
		, ProductCategoryID int NOT NULL
		, Name VARCHAR(50) NOT NULL
		, rowguid uniqueidentifier ROWGUIDCOL  NOT NULL
		, ModifiedDate datetime NOT NULL
		, CONSTRAINT PK_ProductSubCategory_ProductSubCategoryID 
			PRIMARY KEY CLUSTERED (ProductSubCategoryID ASC)
	);

	CREATE TABLE Production.Product(
		  ProductID INT NOT NULL
			CONSTRAINT PK_Product_ProductID 
			PRIMARY KEY CLUSTERED (ProductID ASC)
		, Name VARCHAR(100) NOT NULL
		, ProductNumber VARCHAR(25) NOT NULL
		, Color VARCHAR(15) NULL
		, ListPrice money NOT NULL
			CONSTRAINT CK_Product_ListPrice 
			CHECK ((ListPrice>=(0.00)))
		, ProductSubCategoryID INT NULL
			CONSTRAINT FK_Product_ProductSubCategory
			FOREIGN KEY --(ProductSubCategoryID)
			REFERENCES Production.ProductSubCategory (ProductSubCategoryID)
		, SellStartDate DATETIME NOT NULL
		, SellEndDate DATETIME NULL
		, rowguid UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL
			CONSTRAINT DF_Product_rowguid  
			DEFAULT (NEWID()) 
		, ModifiedDate datetime NOT NULL
			CONSTRAINT DF_Product_ModifiedDate  
			DEFAULT (GETDATE()) 
		, CONSTRAINT CK_Product_SellEndDate 
			CHECK ((SellEndDate >= SellStartDate OR SellEndDate IS NULL))
	);

	/* Ahora llenamos las tablas con los datos desde AdventureWorks */

	INSERT INTO Production.ProductCategory(ProductCategoryID, Name, rowguid, ModifiedDate)
	SELECT ProductCategoryID, Name, rowguid, ModifiedDate
	FROM AdventureWorks2017.Production.ProductCategory;

	INSERT INTO Production.ProductSubCategory(ProductSubCategoryID, ProductCategoryID, Name, rowguid, ModifiedDate)
	SELECT ProductSubCategoryID, ProductCategoryID, Name, rowguid, ModifiedDate
	FROM AdventureWorks2017.Production.ProductSubCategory;

	INSERT INTO Production.Product (ProductID, Name, ProductNumber, Color, ListPrice, ProductSubCategoryID, SellStartDate, SellEndDate, rowguid, ModifiedDate)
	SELECT ProductID, Name, ProductNumber, Color, ListPrice, ProductSubCategoryID, SellStartDate, SellEndDate, rowguid, ModifiedDate
	FROM AdventureWorks2017.Production.Product;
END
GO
/*************************************************************************************************/

USE SeHablaSQL_DW
GO
	DROP TABLE IF EXISTS Production.Product;
	DROP TABLE IF EXISTS Production.ProductSubCategory;
	DROP TABLE IF EXISTS Production.ProductCategory;
GO
BEGIN	/* Trabajamos el Data Warehouse */

	IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Production')
		EXEC('CREATE SCHEMA Production AUTHORIZATION dbo;')

	CREATE TABLE Production.ProductCategory(
		  ProductCategoryID INT NOT NULL
		, Name VARCHAR(50) NOT NULL
		, rowguid uniqueidentifier ROWGUIDCOL  NOT NULL
		, ModifiedDate datetime NOT NULL
		, CONSTRAINT PK_ProductCategory_ProductCategoryID 
			PRIMARY KEY CLUSTERED 
			(ProductCategoryID ASC)
	);

	CREATE TABLE Production.ProductSubCategory(
		  ProductSubCategoryID INT NOT NULL
		, ProductCategoryID int NOT NULL
		, Name VARCHAR(50) NOT NULL
		, rowguid uniqueidentifier ROWGUIDCOL  NOT NULL
		, ModifiedDate datetime NOT NULL
		, CONSTRAINT PK_ProductSubCategory_ProductSubCategoryID 
			PRIMARY KEY CLUSTERED (ProductSubCategoryID ASC)
	);

	CREATE TABLE Production.Product(
		  ProductID INT NOT NULL
			CONSTRAINT PK_Product_ProductID 
			PRIMARY KEY CLUSTERED (ProductID ASC)
		, Name VARCHAR(100) NOT NULL
		, ProductNumber VARCHAR(25) NOT NULL
		, Color VARCHAR(15) NULL
		, ListPrice money NOT NULL
			CONSTRAINT CK_Product_ListPrice 
			CHECK ((ListPrice>=(0.00)))
		, ProductSubCategoryID INT NULL
			CONSTRAINT FK_Product_ProductSubCategory
			FOREIGN KEY --(ProductSubCategoryID)
			REFERENCES Production.ProductSubCategory (ProductSubCategoryID)
		, SellStartDate DATETIME NOT NULL
		, SellEndDate DATETIME NULL
		, rowguid UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL
			CONSTRAINT DF_Product_rowguid  
			DEFAULT (NEWID()) 
		, ModifiedDate datetime NOT NULL
			CONSTRAINT DF_Product_ModifiedDate  
			DEFAULT (GETDATE()) 
		, CONSTRAINT CK_Product_SellEndDate 
			CHECK ((SellEndDate >= SellStartDate OR SellEndDate IS NULL))
	);

	INSERT INTO Production.ProductCategory
	SELECT *
	FROM SeHablaSQL_Transaccional.Production.ProductCategory;

	INSERT INTO Production.ProductSubCategory
	SELECT *
	FROM SeHablaSQL_Transaccional.Production.ProductSubCategory;

	INSERT INTO Production.Product
	SELECT *
	FROM SeHablaSQL_Transaccional.Production.Product;
END
GO
/*************************************************************************************************/

USE SeHablaSQL_DM
GO
	DROP TABLE IF EXISTS Production.Products;
GO
BEGIN	/* Trabajamos el Data Mart */
	
	IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Production')
		EXEC('CREATE SCHEMA Production AUTHORIZATION dbo;');

	/*** Desnormalizo y creo la punta de la estrella de productos ***/
	CREATE TABLE Production.Products(
		  ProductsID INT IDENTITY(1, 1) NOT NULL	/* Llave en una tabla tipo 2 */
		, RefProductID INT NOT NULL					/* hacemos referencia a ProductID del DW */
		, ProductCode VARCHAR(25) NOT NULL
		, ProductName VARCHAR(100) NOT NULL
		, Product AS CONCAT(ProductCode, ' - ', ProductName)
		, Color VARCHAR(15) NULL
		, ProductCategoryID INT NOT NULL
		, Category VARCHAR(50) NOT NULL
		, ProductSubCategoryID INT NOT NULL
		, SuCategory VARCHAR(50) NOT NULL
		, ListPrice NUMERIC(10, 3) NOT NULL
		, SellStartDate DATETIME NOT NULL
		, SellEndDate DATETIME NULL
	);

	INSERT INTO Production.Products (RefProductID, ProductCode, ProductName, Color, ProductCategoryID, Category, ProductSubCategoryID, SuCategory, ListPrice, SellStartDate, SellEndDate)
	SELECT p.ProductID, p.ProductNumber, p.[Name] AS ProductName, p.Color
		 , COALESCE(c.ProductCategoryID, -1) AS Category
		 , COALESCE(c.[Name], '***') AS SubCategoryName
		 , COALESCE(sc.ProductSubCategoryID, -1) AS ProductCategoryID
		 , COALESCE(sc.[Name], '***') AS SubCategoryName
		 , CAST(p.ListPrice AS NUMERIC(10, 3)), p.SellStartDate, p.SellEndDate
	FROM SeHablaSQL_DW.Production.Product AS p
	LEFT JOIN (SeHablaSQL_DW.Production.ProductSubCategory AS sc
			   LEFT JOIN SeHablaSQL_DW.Production.ProductCategory AS c
				ON sc.ProductCategoryID = c.ProductCategoryID) 
					ON p.ProductSubCategoryID = sc.ProductSubCategoryID
	
END

USE master;
GO