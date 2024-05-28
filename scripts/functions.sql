GO
CREATE FUNCTION dbo.ExtractSucursal(
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'Sucursal N°:', '');

    RETURN @output;
END;
GO

CREATE FUNCTION dbo.ExtractIIBB (
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'Ingr. Brut. N°: ', '');

    RETURN @output;
END;
GO

CREATE FUNCTION dbo.ExtractSubCategoria (
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'SubCategoria N°', '');

    RETURN @output;
END;
GO

CREATE FUNCTION dbo.ExtractProductoNombre (
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'Codigo:', '');

    RETURN @output;
END;
GO

CREATE FUNCTION dbo.ExtractProductoMarca (
    @input NVARCHAR(255)
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @output NVARCHAR(255);

    SET @output = REPLACE(@input, 'Marca N°', '');

    RETURN @output;
END;
GO

CREATE FUNCTION dbo.CalcularCantidadProductos(
    @tick_numero DECIMAL(18,0),
    @tick_tipo CHAR(1),
    @tick_sucursal_id DECIMAL(6,0)
)
RETURNS DECIMAL(18,0)
AS
BEGIN
    DECLARE @total_cantidad DECIMAL(18,0);

    SELECT @total_cantidad = SUM(item_cantidad)
    FROM [MASTER_COOKS].[Item_Ticket]
    WHERE item_ticket_numero = @tick_numero
      AND item_tipo_id = @tick_tipo
      AND item_sucursal_id = @tick_sucursal_id;

    RETURN @total_cantidad;
END;
GO