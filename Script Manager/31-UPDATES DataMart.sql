/* y finalmente llevamos los cambios al Data Mart */
UPDATE p
	SET CategoryOrder = COALESCE(c.CategoryOrder, -1)
	  , SubcategoryOrder = COALESCE(sc.SubcategoryOrder, -1)
FROM Production.Products AS p
LEFT JOIN (SeHablaSQL_DW.Production.ProductSubCategory AS sc
		   INNER JOIN SeHablaSQL_DW.Production.ProductCategory AS c
			ON sc.ProductCategoryID = c.ProductCategoryID) 
	ON p.ProductSubCategoryID = sc.ProductSubCategoryID
WHERE (p.CategoryOrder + p.SubcategoryOrder) IS NULL;

