DROP TABLE IF EXISTS [MASTER_COOKS].[Promocion_X_Ticket];
DROP TABLE IF EXISTS [MASTER_COOKS].[Item_Ticket];
DROP TABLE IF EXISTS [MASTER_COOKS].[Rebaja_Producto];
DROP TABLE IF EXISTS [MASTER_COOKS].[Producto];
DROP TABLE IF EXISTS [MASTER_COOKS].[Promocion];
DROP TABLE IF EXISTS [MASTER_COOKS].[Regla];
DROP TABLE IF EXISTS [MASTER_COOKS].[Marca];
DROP TABLE IF EXISTS [MASTER_COOKS].[Subcategoria];
DROP TABLE IF EXISTS [MASTER_COOKS].[Categoria];
DROP TABLE IF EXISTS [MASTER_COOKS].[Envio];
DROP TABLE IF EXISTS [MASTER_COOKS].[Estado_Envio];
DROP TABLE IF EXISTS [MASTER_COOKS].[Pago];
DROP TABLE IF EXISTS [MASTER_COOKS].[Ticket];
DROP TABLE IF EXISTS [MASTER_COOKS].[Cliente];
DROP TABLE IF EXISTS [MASTER_COOKS].[Detalle_Pago];
DROP TABLE IF EXISTS [MASTER_COOKS].[Caja];
DROP TABLE IF EXISTS [MASTER_COOKS].[Tipo_Caja];
DROP TABLE IF EXISTS [MASTER_COOKS].[Medio_De_Pago];
DROP TABLE IF EXISTS [MASTER_COOKS].[Descuento_Medio_Pago];
DROP TABLE IF EXISTS [MASTER_COOKS].[Empleado];
DROP TABLE IF EXISTS [MASTER_COOKS].[Supermercado];
DROP TABLE IF EXISTS [MASTER_COOKS].[Sucursal];
DROP TABLE IF EXISTS [MASTER_COOKS].[Localidad];
DROP TABLE IF EXISTS [MASTER_COOKS].[Provincia];

DROP SEQUENCE IF EXISTS [MASTER_COOKS].[seq_empleado_legajo];
DROP SEQUENCE IF EXISTS [MASTER_COOKS].[seq_pago_numero];
DROP SEQUENCE IF EXISTS [MASTER_COOKS].[seq_deta_codigo];
DROP SEQUENCE IF EXISTS [MASTER_COOKS].[seq_envio_codigo];

DROP FUNCTION IF EXISTS [MASTER_COOKS].[ExtractSucursal];
DROP FUNCTION IF EXISTS [MASTER_COOKS].[ExtractIIBB];
DROP FUNCTION IF EXISTS [MASTER_COOKS].[ExtractSubCategoria];
DROP FUNCTION IF EXISTS [MASTER_COOKS].[ExtractProductoNombre];
DROP FUNCTION IF EXISTS [MASTER_COOKS].[ExtractProductoMarca];

DROP SCHEMA IF EXISTS [MASTER_COOKS];
