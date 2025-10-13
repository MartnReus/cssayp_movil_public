# Documentación Tabla CD_BOLETA_GENERADA

## Descripción General

Tabla principal que almacena las boletas generadas en el sistema CGA (Consulta y Gestión de Afiliados) de la Caja de Seguridad Social de Abogados y Procuradores de Santa Fe.

## Esquema

**Schema**: `CJ_CGA`  
**Nombre**: `CD_BOLETA_GENERADA`

## Estructura de Columnas

| Columna | Tipo | Descripción | Observaciones |
|---------|------|-------------|---------------|
| `ID_BOLETA_GENERADA` | NUMBER | Clave Primaria de la Tabla | |
| `SISTEMA` | NUMBER | 1- SIE, 2- CGA | |
| `FECHA_IMPRESION` | DATE | Fecha en que se genera la Boleta | |
| `CODIGO_TRANSACCION` | NUMBER | Nro de transacción generado en el día, se resetea todos los días | |
| `NRO_AFILIADO` | NUMBER | Número de Afiliado que genera la boleta | Indexado |
| `DIGITO_AFILIADO` | NUMBER | Dígito verificador del número de afiliado | |
| `MATRICULA` | NUMBER | Número de matrícula del profesional | |
| `CODIGO_ENTE` | VARCHAR2(10) | Ente utilizado por el Banco. Asociado a la tabla CD_CODIGO_ENTE | |
| `DIAS_VENCIMIENTO` | NUMBER | Sumar a la fecha de impresión para obtener la fecha de vencimiento de la boleta | |
| `FECHA_VENCIMIENTO_CUOTA` | DATE | Fecha de vencimiento de la cuota | |
| `ID_TIPO_TRANSACCION` | NUMBER | ID en la tabla CD_TIPO_TRANSACCION, permite encontrar si es de inicio o finalización | **Campo clave para conocer el tipo de operación** |
| `MONTO_ENTERO` | NUMBER | Parte entera del monto de la Boleta | |
| `MONTO_DECIMAL` | NUMBER | Parte decimal del monto de la Boleta | |
| `HONORARIOS` | NUMBER | Monto de honorarios | |
| `CARATULA` | VARCHAR2(150) | Caratula que describe a la Boleta | **Campo clave para identificar juicios** |
| `TIPO_JUICIO` | NUMBER | Tipo de juicio | |
| `JUZGADO` | VARCHAR2(50) | Juzgado del Juicio | |
| `SECRETARIA` | VARCHAR2(50) | Secretaria del Juicio | |
| `ID_TIPO_CONVENIO` | NUMBER | Describe el tipo de Convenio | |
| `ANIO_CONVENIO` | NUMBER | Año en que se realizo el convenio | |
| `DELEGACION_CONVENIO` | NUMBER | Delegacion del Convenio | |
| `NRO_CONVENIO` | NUMBER | Numero de Convenio | |
| `CUOTA_CONVENIO` | NUMBER | Numero de cuota del convenio | |
| `CANTIDAD_CUOTAS_CONVENIO` | NUMBER | Total de cuotas del convenio | |
| `MONTO_CONVENIO` | NUMBER | Monto total del convenio | |
| `RESERVADO_VARIOS` | NUMBER | Reservado dependiendo del tipo de boleta | |
| `ID_BOLETA_ASOCIADA` | NUMBER | **Se usa para una finalizacion de Juicio, va la boleta asociada a la iniciacion correspondiente** | **Campo clave para relación inicio-fin** |
| `SISTEMA_BOLETA_ASOCIADA` | NUMBER | Se usa para una finalizacion de Juicio, va el sistema desde el que se genero la boleta asociada a la iniciacion correspondiente. Es para mantener consistencia entre interno y externo | |
| `ID_BOLETA_COLEGIO` | NUMBER | En las boletas de Iniciación de Juicio del Banco de Santa Fe, va el Id de Boleta correspondiente al colegio | |
| `SISTEMA_BOLETA_COLEGIO` | NUMBER | En las boletas de Iniciación de Juicio del Banco de Santa Fe, va el sistema de donde se genero la Boleta correspondiente al colegio. Teoricamente debería ser el mismo sistema que la boleta para la caja | |
| `ID_ESTADO_BOLETA` | NUMBER | Estado actual de la boleta | |
| `LOTE_PRUEBA` | NUMBER | Lote de prueba | Default: 3 |
| `MATRICULA1` | VARCHAR2(6) | Matrícula alternativa | |
| `LOTE_BANCO` | NUMBER | Lote bancario para procesamiento | |
| `FECHA_PAGO` | DATE | Fecha en que se realizó el pago | |
| `COD_BARRA` | VARCHAR2(100) | Código de barras para pagos | |
| `IMPORTE_PAGO` | NUMBER | Importe efectivamente pagado | |
| `ID_BOLETA_FORENSE` | NUMBER | ID de boleta forense | |
| `SISTEMA_BOLETA_FORENSE` | NUMBER | Sistema de boleta forense | |
| `NRO_BOLETA_FORENSE` | NUMBER | Número de boleta forense | |
| `FECHA_REGULACION` | DATE | Fecha de regulación | |
| `AUTOREGULATORIO` | VARCHAR2(20) | Campo autoregulatorio | |
| `NRO_EXPEDIENTE` | NUMBER | Número de expediente | |
| `ANIO_EXPEDIENTE` | NUMBER | Año del expediente | |
| `CANTIDAD_JUS` | NUMBER | Cantidad de JUS (unidad monetaria) | |
| `MONTO_REGULACION` | NUMBER | Monto de la regulación | |
| `CUIJ` | NUMBER | Código Único de Identificación Judicial | |
| `VALOR_JUS` | NUMBER | Valor del JUS | |
| `CODIGO_IDENTIFICACION` | NUMBER | Código de identificación | |
| `CARATULA_PRINCIPAL` | VARCHAR2(200) | Carátula principal extendida | |
| `CODIGO_IDENTIFICACION_ASOCIADO` | NUMBER | Código de identificación asociado | |
| `ID_COMPANIA_SEGUROS` | NUMBER | ID de compañía de seguros | |
| `SINIESTRO` | VARCHAR2(20) | Número de siniestro | |
| `ID_TIPO_PAGO` | NUMBER | Tipo de pago utilizado | Indexado |
| `ID_CONCEPTO` | NUMBER | Concepto del pago | |
| `MONTO_INCREMENTO` | NUMBER | Monto de incremento | |
| `IDENTIFICADOR_DEUDA` | NUMBER | Identificador de deuda | |
| `GASTOS_ADMINISTRATIVOS` | NUMBER | Gastos administrativos | |
| `ID_TIPO_BOLETA` | NUMBER | **ID en la tabla CD_TIPO_BOLETA, permite conocer el tipo de boleta (inicio/fin)** | **FK a CD_TIPO_BOLETA, indexado** |
| `CANTIDAD_CAUSANTES_OPS` | NUMBER | Cantidad de causantes OPS | |
| `CIRCUNSCRIPCION` | NUMBER | Circunscripción judicial | |
| `ID_TIPO_GASTO` | NUMBER | Tipo de gasto | |

## Restricciones y Claves

### Clave Primaria

- **Constraint**: `UK_BOLETA_GENERADA`
- **Columnas**: `SISTEMA`, `ID_BOLETA_GENERADA`

### Claves Foráneas

- **FK_BOLETAGEN_TIPOBOLETA**: `ID_TIPO_BOLETA` → `CD_TIPO_BOLETA.ID_TIPO_BOLETA`

## Índices

| Índice | Columnas | Descripción |
|--------|----------|-------------|
| `IDX_BOLETAGENERADA_ANIOFECIMP` | Campo calculado año de fecha impresión | Para consultas por año |
| `IDX_BOLETAGENERADA_NROAF` | `NRO_AFILIADO` | Búsquedas por afiliado |
| `IDX_BOLETAGEN_FECHAIMPR` | Campo calculado fecha impresión | Consultas por fecha |
| `IDX_BOLETAGEN_IDTIPOBOLETA` | `ID_TIPO_BOLETA` | Filtros por tipo |
| `IDX_BOLETAGEN_IDTIPOPAGO` | `ID_TIPO_PAGO` | Filtros por tipo de pago |
| `UK_BOLETA_GENERADA` | `SISTEMA`, `ID_BOLETA_GENERADA` | Índice único |

## Relación entre Boletas de Inicio y Fin

### Lógica de Asociación

- **Boleta de Inicio**: `ID_BOLETA_ASOCIADA` = `NULL`
- **Boleta de Fin**: `ID_BOLETA_ASOCIADA` = `ID_BOLETA_GENERADA` de la boleta de inicio

### Ejemplo de Relación

```sql
-- Boleta de Inicio
ID_BOLETA_GENERADA: 123
ID_TIPO_BOLETA: 1  -- Tipo "Inicio"
ID_BOLETA_ASOCIADA: NULL
CARATULA: "Pérez Juan C/ González Raúl S/ Cuota alimentaria"

-- Boleta de Fin (asociada)
ID_BOLETA_GENERADA: 456
ID_TIPO_BOLETA: 2  -- Tipo "Fin"
ID_BOLETA_ASOCIADA: 123  -- Referencia a boleta de inicio
CARATULA: "Pérez Juan C/ González Raúl S/ Cuota alimentaria"
```

## Campos Relevantes para el Proyecto

### Para Identificación de Juicios

- `CARATULA`: Descripción del expediente
- `ID_BOLETA_ASOCIADA`: Vinculación entre inicio y fin
- `ID_TIPO_BOLETA`: Diferencia inicio de fin

### Para Gestión de Pagos

- `FECHA_PAGO`: Estado de pago
- `IMPORTE_PAGO`: Monto pagado
- `ID_TIPO_PAGO`: Método de pago
- `ID_ESTADO_BOLETA`: Estado actual

### Para Identificación del Usuario

- `NRO_AFILIADO`: Identificador del profesional
- `MATRICULA`: Matrícula profesional

## Consultas Útiles

### Obtener juicios de un afiliado

```sql
SELECT 
    COALESCE(b_inicio.ID_BOLETA_GENERADA, b_fin.ID_BOLETA_ASOCIADA) as id_juicio,
    COALESCE(b_inicio.CARATULA, b_fin.CARATULA) as caratula,
    b_inicio.ID_BOLETA_GENERADA as boleta_inicio_id,
    b_inicio.FECHA_PAGO as fecha_pago_inicio,
    b_fin.ID_BOLETA_GENERADA as boleta_fin_id,
    b_fin.FECHA_PAGO as fecha_pago_fin
FROM CD_BOLETA_GENERADA b_inicio
LEFT JOIN CD_BOLETA_GENERADA b_fin 
    ON b_inicio.ID_BOLETA_GENERADA = b_fin.ID_BOLETA_ASOCIADA
WHERE b_inicio.NRO_AFILIADO = :nro_afiliado 
    AND b_inicio.ID_TIPO_BOLETA = 1; -- Solo boletas de inicio
```

### Validar que existe boleta de inicio para crear fin

```sql
SELECT COUNT(*) as es_valida
FROM CD_BOLETA_GENERADA 
WHERE ID_BOLETA_GENERADA = :id_boleta_inicio
    AND NRO_AFILIADO = :nro_afiliado 
    AND ID_TIPO_BOLETA = 1
    AND NOT EXISTS (
        -- Verificar que no tenga ya una boleta de fin asociada
        SELECT 1 FROM CD_BOLETA_GENERADA bf 
        WHERE bf.ID_BOLETA_ASOCIADA = :id_boleta_inicio
    );
```
