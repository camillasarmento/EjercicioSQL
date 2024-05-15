-- =============================================
-- Autor: Camilla Sarmento
-- =============================================

use evaluacion_continua;

-- 1. Total de Ventas por Producto:
-- Calcula el total de ventas para cada producto, ordenado de mayor a menor.
   SELECT c.nombre,
   SUM(p.cantidad) AS total_cantidad
   FROM detalles_pedidos p
   JOIN productos c ON p.id_producto = c.id_producto
   GROUP BY c.id_producto, c.nombre
   ORDER BY total_cantidad DESC;

-- 2. Último Pedido de Cada Cliente:
-- Identifica el último pedido realizado por cada cliente.
    SELECT c.nombre, p.fecha_pedido
    FROM clientes c
    JOIN pedidos p ON c.id_cliente = p.id_cliente
    WHERE p.fecha_pedido =
    (SELECT MAX(fecha_pedido)
         FROM pedidos
    WHERE id_cliente = c.id_cliente);

-- 3. Número de Pedidos por Ciudad:
-- Determina el número total de pedidos realizados por clientes en cada ciudad.
    SELECT c.ciudad,
    COUNT(P.id_pedido) AS total_pedidos
    FROM clientes c
    JOIN pedidos p ON c.id_cliente = p.id_cliente
    GROUP BY c.ciudad
    ORDER BY total_pedidos DESC;

-- 4. Productos que Nunca se Han Vendido:
-- Lista todos los productos que nunca han sido parte de un pedido.
    SELECT p.id_producto, p.nombre
    FROM productos p
    LEFT JOIN detalles_pedidos dp ON p.id_producto = dp.id_producto
    WHERE dp.id_producto IS NULL;

-- 5. Productos Más Vendidos por Cantidad:
-- Encuentra los productos más vendidos en términos de cantidad total vendida.
    SELECT c.nombre,
    SUM(p.cantidad) AS total_vendido
    FROM detalles_pedidos p
    JOIN productos c ON p.id_producto = c.id_producto
    GROUP BY p.id_producto, c.nombre
    ORDER BY total_vendido DESC;

-- 6. Clientes con Compras en Múltiples Categorías:
-- Identifica a los clientes que han realizado compras en más de una categoría de producto.
    SELECT c.nombre,
    COUNT(DISTINCT p.id_pedido) AS total_compras_categoria
    FROM clientes c
    JOIN pedidos p ON c.id_cliente = p.id_cliente
    JOIN detalles_pedidos dp ON p.id_pedido = dp.id_pedido
    JOIN productos pr ON dp.id_producto = pr.id_producto
    GROUP BY c.id_cliente, c.nombre
    HAVING COUNT(DISTINCT pr.categoría)>1
    ORDER BY total_compras_categoria DESC;

-- 7. Ventas Totales por Mes:
-- Muestra las ventas totales agrupadas por mes y año.
    SELECT YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    SUM(dp.cantidad * pr.precio) AS ventas_totales
    FROM pedidos p
    JOIN detalles_pedidos dp ON p.id_pedido = dp.id_pedido
    JOIN productos pr ON dp.id_producto = pr.id_producto
    GROUP BY YEAR(P.fecha_pedido), MONTH(P.fecha_pedido)
    ORDER BY año, mes;

-- 8. Promedio de Productos por Pedido:
-- Calcula la cantidad promedio de productos por pedido.
    SELECT AVG(cantidad) AS cantidad_promedio_pedido
    FROM detalles_pedidos;

-- 9. Tasa de Retención de Clientes:
-- Determina cuántos clientes han realizado pedidos en más de una ocasión.
    SELECT COUNT(*) AS clientes_mas_pedidos
    FROM (
        SELECT id_cliente FROM pedidos
        GROUP BY id_cliente
        HAVING COUNT(*) > 1) AS multiples_pedidos;

-- 10. Tiempo Promedio entre Pedidos:
-- Calcula el tiempo promedio que pasa entre pedidos para cada cliente.
    SELECT c.nombre,
        AVG(entre_pedidos) AS promedio_pedidos
    FROM (
        SELECT p.id_cliente,
            DATEDIFF(p.fecha_pedido,
                LAG(p.fecha_pedido) OVER (PARTITION BY p.id_cliente ORDER BY p.fecha_pedido)
            ) AS entre_pedidos
        FROM pedidos p
    ) AS diferencia_tiempo
    JOIN clientes c ON diferencia_tiempo.id_cliente = c.id_cliente
    GROUP BY diferencia_tiempo.id_cliente, c.nombre
    ORDER BY promedio_pedidos DESC;


