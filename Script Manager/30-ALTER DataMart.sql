/* Agregamos las columnas nuevas en la tabla de Productos*/
ALTER TABLE Production.Products
ADD CategoryOrder INT NULL
  , SubcategoryOrder INT NULL;