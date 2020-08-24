/*** Agregamos la columna del requerimiento del negocio ***/
ALTER TABLE Production.ProductCategory
ADD CategoryOrder TINYINT NULL;

ALTER TABLE Production.ProductSubcategory
ADD SubcategoryOrder TINYINT NULL;

