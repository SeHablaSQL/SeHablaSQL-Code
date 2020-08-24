/*** En el transaccional Asignamos un orden especifico a las Categorias ***/
UPDATE p
	SET CategoryOrder = o.CategoryOrder
FROM (
	VALUES (1, 2)
		 , (2, 3)
		 , (3, 1)
		 , (4, 4)
)AS o(ProductCategoryID, CategoryOrder)
INNER JOIN Production.ProductCategory AS p
	ON o.ProductCategoryID = p.ProductCategoryID
WHERE p.CategoryOrder IS NULL;

/*** Ahora ordenamos los productos de alfabeticamente descendente ***/
;WITH Origen AS (
	SELECT c.ProductCategoryID
		 , ROW_NUMBER()OVER(PARTITION BY sc.ProductCategoryID
							ORDER BY sc.[Name] DESC) 
			+ c.CategoryOrder * 100 AS NewSubCategoryOrder
		 , sc.SubCategoryOrder
	FROM Production.ProductSubcategory AS sc
	INNER JOIN Production.ProductCategory AS c
		ON sc.ProductCategoryID = c.ProductCategoryID
	WHERE sc.SubcategoryOrder IS NULL
)UPDATE o	/* Actulizamos el CTE que va a ir a actulizar el transaccional */
	SET SubCategoryOrder = NewSubCategoryOrder
FROM Origen AS o;
