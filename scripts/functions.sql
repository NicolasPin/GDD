CREATE FUNCTION dbo.ExtractSucursal (
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