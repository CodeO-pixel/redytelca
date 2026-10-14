-- =================================================================
-- P11 — Limpieza de datos inconsistentes
-- Fecha: 2026-10-13
-- Autorizado por: hallazgo operativo (ver MEMORY.md)
--
-- MOTIVO
-- Dos inconsistencias de datos detectadas por auditoría sobre el
-- dump actual de bd_redytelca:
--
--   BUG A — equipos en stock con id_servicio asignado
--     Un equipo con estado_inventario='stock' no puede tener
--     id_servicio asignado: los equipos en stock no están instalados
--     en ningún cliente. Se detectó al menos un equipo en la muestra
--     con estado 'stock' y id_servicio no nulo, lo que rompe el
--     ciclo de vida del inventario (stock → asignado → devuelto).
--     Fix: NULL el id_servicio de todo equipo que esté en stock.
--
--   BUG B — servicios con longitud positiva en Venezuela
--     Venezuela está entre -59° y -73° de longitud. Un valor positivo
--     es geográficamente imposible. Se detectó al menos un servicio
--     (ej. id 4) con longitud_instalacion positiva.
--     Fix: normalizar el signo con -ABS(...) preservando la magnitud.
--
-- ROLLBACK
--   BUG A: no hay rollback automático. Si algún equipo en stock
--          realmente debía tener servicio (falso positivo), el
--          operador debe reasignarlo manualmente desde el módulo
--          Equipos tras verificar su estado físico real.
--   BUG B: no hay rollback automático. El signo solo se corrige si
--          el valor era geográficamente imposible; en ese caso el
--          valor negativo era el correcto desde el inicio.
--   Como esta limpieza no borra información semántica (solo
--   normaliza datos imposibles), el rollback no es necesario:
--   cualquier cambio de magnitud requiere intervención manual.
--
-- ORDEN DE EJECUCIÓN
--   1. Diagnóstico BUG A (SELECT)
--   2. UPDATE BUG A
--   3. Diagnóstico BUG B (SELECT)
--   4. UPDATE BUG B
--   5. Verificación final (contadores en 0)
-- =================================================================

USE bd_redytelca;

-- =================================================================
-- BUG A — Equipos en stock con id_servicio asignado
-- =================================================================

-- Diagnóstico previo: filas que van a ser modificadas.
SELECT id_equipo, tipo, marca, modelo, estado_inventario, id_servicio
FROM equipos
WHERE estado_inventario = 'stock' AND id_servicio IS NOT NULL;

-- Corrección: un equipo en stock no está instalado en ningún cliente.
UPDATE equipos SET id_servicio = NULL
WHERE estado_inventario = 'stock' AND id_servicio IS NOT NULL;

-- =================================================================
-- BUG B — Servicios con longitud positiva en Venezuela
-- =================================================================

-- Diagnóstico previo: filas que van a ser modificadas.
SELECT id_servicio, alias, direccion_texto, latitud_instalacion, longitud_instalacion
FROM servicios
WHERE longitud_instalacion > 0;

-- Corrección: Venezuela está al oeste de Greenwich (longitud negativa).
UPDATE servicios SET longitud_instalacion = -ABS(longitud_instalacion)
WHERE longitud_instalacion > 0;

-- =================================================================
-- VERIFICACIÓN FINAL
-- Ambos contadores deben devolver 0.
-- =================================================================

SELECT 'equipos_stock_con_servicio' AS check_name, COUNT(*) AS pendientes
FROM equipos WHERE estado_inventario = 'stock' AND id_servicio IS NOT NULL
UNION ALL
SELECT 'servicios_longitud_positiva', COUNT(*)
FROM servicios WHERE longitud_instalacion > 0;

-- =================================================================
-- Fin P11.
-- =================================================================