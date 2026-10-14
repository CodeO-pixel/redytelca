-- =================================================================
-- P12 — Constraints y triggers de prevención
-- Fecha: 2026-10-13
-- Autorizado por: hallazgo operativo (ver MEMORY.md)
--
-- MOTIVO
-- P11 limpió dos inconsistencias de datos (equipos en stock con
-- servicio asignado, servicios con longitud positiva en Venezuela)
-- y añadió el fix de saldo_pendiente en la vista de estado de cuenta.
-- Pero la limpieza sin prevención se degrada: los mismos bugs
-- reaparecen en la siguiente inserción si la capa de aplicación
-- no los bloquea. Este script añade defensas en la BD para que
-- las reglas de dominio se cumplan a nivel de esquema,
-- independientemente de lo que haga el código.
--
-- BLOQUE A — CHECK de coherencia en equipos
--   Previene BUG A de P11 (equipo en stock con id_servicio).
--   Además endurece la regla complementaria: un equipo con
--   estado_inventario='asignado' DEBE tener id_servicio (un
--   equipo no puede estar asignado a nadie). Los estados
--   'devuelto', 'averiado' y 'baja' quedan sin restricción
--   porque un equipo puede estar en tránsito o pendiente de
--   resolver su destino final.
--
-- BLOQUE B — Trigger SLA en INSERT de tickets
--   tickets.sla_vence_en existe en el esquema pero nunca se
--   calcula. El SLA se define como horas de resolución desde
--   la creación del ticket, cruzando (id_categoria, prioridad)
--   contra sla_definiciones. Se calcula en la BD para garantizar
--   consistencia independientemente del cliente (web, API,
--   SQL directo) que inserte el ticket.
--
-- BLOQUE C — Trigger SLA en UPDATE de tickets
--   Coherencia con el bloque B: si cambia id_categoria o
--   prioridad, el SLA se recalcula desde el momento del cambio.
--   Si la nueva combinación no tiene definición de SLA, se
--   deja NULL (mismo comportamiento que INSERT).
--
-- ROLLBACK
--   DROP CONSTRAINT chk_equipo_estado_servicio ON equipos;
--   DROP TRIGGER trg_tickets_sla_insert;
--   DROP TRIGGER trg_tickets_sla_update;
--
-- ORDEN DE EJECUCIÓN
--   1. Bloque A (ALTER TABLE)
--   2. Bloque B (CREATE TRIGGER insert)
--   3. Bloque C (CREATE TRIGGER update)
--   4. Verificación final
--
-- NOTA IMPORTANTE
--   El CHECK de equipos se añade DESPUÉS de P11, que ya limpió
--   las filas que lo violaban. Sin esa limpieza, el ALTER
--   fallaría con "Check constraint 'chk_equipo_estado_servicio'
--   is violated".
-- =================================================================

USE bd_redytelca;

-- =================================================================
-- BLOQUE A — CHECK de coherencia en equipos
--
-- Ciclo de vida del inventario: los CHECKs deben reflejar las
-- reglas del dominio (coherencia estado_inventario ↔ id_servicio),
-- no solo la integridad referencial.
--
--   stock     → id_servicio NULL   (no instalado en ningún cliente)
--   asignado  → id_servicio NOT NULL (instalado en un cliente)
--   devuelto  → sin restricción     (en tránsito hacia stock)
--   averiado  → sin restricción     (pendiente de reparación/baja)
--   baja      → sin restricción     (dado de baja, servicio irrelevante)
-- =================================================================

ALTER TABLE equipos
  ADD CONSTRAINT chk_equipo_estado_servicio CHECK (
    (estado_inventario = 'stock' AND id_servicio IS NULL) OR
    (estado_inventario = 'asignado' AND id_servicio IS NOT NULL) OR
    (estado_inventario IN ('devuelto', 'averiado', 'baja'))
  );

-- =================================================================
-- BLOQUE B — Trigger SLA en INSERT de tickets
--
-- El SLA se mide como horas de resolución desde la creación del
-- ticket. Se calcula en la BD para garantizar consistencia
-- independientemente del cliente que inserte.
-- =================================================================

DELIMITER $$
CREATE TRIGGER trg_tickets_sla_insert BEFORE INSERT ON tickets FOR EACH ROW BEGIN
  DECLARE horas SMALLINT DEFAULT NULL;
  IF NEW.id_categoria IS NOT NULL THEN
    SELECT horas_resolucion INTO horas FROM sla_definiciones
    WHERE id_categoria = NEW.id_categoria AND prioridad = NEW.prioridad LIMIT 1;
  END IF;
  IF horas IS NOT NULL THEN
    SET NEW.sla_vence_en = DATE_ADD(NOW(), INTERVAL horas HOUR);
  END IF;
END$$
DELIMITER ;

-- =================================================================
-- BLOQUE C — Trigger SLA en UPDATE de tickets (CORREGIDO)
--
-- Coherencia con el bloque B. Un cambio de prioridad a Alta debe
-- reducir el SLA automáticamente. Se usa el operador null-safe
-- `<=>` en lugar de `<>` para manejar correctamente las
-- transiciones NULL ↔ valor en id_categoria (que es nullable).
-- =================================================================

DELIMITER $$
CREATE TRIGGER trg_tickets_sla_update BEFORE UPDATE ON tickets FOR EACH ROW BEGIN
  DECLARE horas SMALLINT DEFAULT NULL;
  IF NOT (NEW.id_categoria <=> OLD.id_categoria)
     OR NOT (NEW.prioridad <=> OLD.prioridad) THEN
    IF NEW.id_categoria IS NOT NULL THEN
      SELECT horas_resolucion INTO horas FROM sla_definiciones
      WHERE id_categoria = NEW.id_categoria AND prioridad = NEW.prioridad LIMIT 1;
    END IF;
    IF horas IS NOT NULL THEN
      SET NEW.sla_vence_en = DATE_ADD(NOW(), INTERVAL horas HOUR);
    ELSE
      SET NEW.sla_vence_en = NULL;
    END IF;
  END IF;
END$$
DELIMITER ;

-- =================================================================
-- VERIFICACIÓN FINAL
-- Los 3 contadores deben devolver 1.
-- =================================================================

SELECT 'chk_equipo_estado_servicio' AS check_name, COUNT(*) AS creado
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bd_redytelca' AND CONSTRAINT_NAME = 'chk_equipo_estado_servicio'
UNION ALL
SELECT 'trg_tickets_sla_insert', COUNT(*)
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'bd_redytelca' AND TRIGGER_NAME = 'trg_tickets_sla_insert'
UNION ALL
SELECT 'trg_tickets_sla_update', COUNT(*)
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'bd_redytelca' AND TRIGGER_NAME = 'trg_tickets_sla_update';

-- =================================================================
-- Fin P12.
-- =================================================================