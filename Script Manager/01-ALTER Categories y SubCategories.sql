/* Este va al Transaccional y como se importa igual al DW lo podemos reutilizar

El nuevo requerimiento consiste en agregar:
	una columna extra en las Categorias y SubCategorias 
	esta nueva columna se va a utilizar para cambiar el orden de presentacion 
*/

ALTER TABLE Production.ProductCategory
ADD CategoryOrder INT NULL;

ALTER TABLE Production.ProductSubcategory
ADD SubcategoryOrder INT NULL;