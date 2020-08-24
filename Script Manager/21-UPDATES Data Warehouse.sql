/*** Simulamos un el proceso de actualización
 y Ahora traemos los valores establecidos en la BD de la aplicación ***/
UPDATE c
	SET CategoryOrder = Origen.CategoryOrder
FROM SeHablaSQL_Transaccional.Production.ProductCategory AS Origen
INNER JOIN Production.ProductCategory AS c				/* <- Actualizar */
	ON Origen.ProductCategoryID = c.ProductCategoryID
WHERE c.CategoryOrder IS NULL;

UPDATE sc
	SET SubCategoryOrder = Origen.SubCategoryOrder
FROM SeHablaSQL_Transaccional.Production.ProductSubcategory AS Origen
INNER JOIN Production.ProductSubcategory AS sc			/* <- Actualizar */
	ON Origen.ProductSubCategoryID = sc.ProductSubCategoryID
WHERE sc.SubCategoryOrder IS NULL;
