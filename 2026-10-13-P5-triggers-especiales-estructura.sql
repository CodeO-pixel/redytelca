-- =================================================================
-- P5 — Refactor BD-COMPLETA: triggers especiales + estructura
-- Fecha: 2026-10-13
-- Autorizado por: docs/ADR/013-bd-completa-refactor.md
-- Backup previo: C:\backups\bd_redytelca_20261012_pre-refactor.sql
-- Rollback: DROP TRIGGER de los 2 nuevos; revertir ALTERs.
-- =================================================================

-- 1. Trigger de unicidad de contrato vigente — INSERT (ADR 013 §P4)
DELIMITER $$
CREATE TRIGGER `trg_contratos_unico_vigente_insert` BEFORE INSERT ON `contratos` FOR EACH ROW BEGIN
  DECLARE existe INT DEFAULT 0;
  IF NEW.estado = 'vigente' THEN
    SELECT COUNT(*) INTO existe FROM contratos
     WHERE id_servicio = NEW.id_servicio AND estado = 'vigente';
    IF existe > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un contrato vigente para este servicio.';
    END IF;
  END IF;
END
$$
DELIMITER ;

-- 2. Trigger de unicidad de contrato vigente — UPDATE (ADR 013 §P4)
DELIMITER $$
CREATE TRIGGER `trg_contratos_unico_vigente_update` BEFORE UPDATE ON `contratos` FOR EACH ROW BEGIN
  DECLARE existe INT DEFAULT 0;
  IF NEW.estado = 'vigente' AND (OLD.estado <> 'vigente' OR OLD.id_servicio <> NEW.id_servicio) THEN
    SELECT COUNT(*) INTO existe FROM contratos
     WHERE id_servicio = NEW.id_servicio AND estado = 'vigente' AND id_contrato <> NEW.id_contrato;
    IF existe > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe otro contrato vigente para este servicio.';
    END IF;
  END IF;
END
$$
DELIMITER ;

-- 3. DELETE del rol id=4 huérfano (D17, spec 075)
DELETE FROM rol WHERE id_rol = 4;

-- 4. Cambio de tipo en equipos.num_puerto_nap (D33, spec 109)
ALTER TABLE equipos MODIFY COLUMN num_puerto_nap SMALLINT(5) NOT NULL;

-- 5. Añadir factura_lineas.id_servicio con FK (D34, spec 110)
ALTER TABLE factura_lineas
  ADD COLUMN id_servicio INT(11) DEFAULT NULL AFTER id_factura,
  ADD INDEX idx_linea_servicio (id_servicio);

ALTER TABLE factura_lineas
  ADD CONSTRAINT fk_linea_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE SET NULL;

-- 6. Deprecación de servicios.ip_asignada (D23 parcial, spec 103)
ALTER TABLE servicios
  MODIFY COLUMN ip_asignada VARCHAR(45) DEFAULT NULL COMMENT 'DEPRECATED: usar ip_asignaciones.id_asignacion';

-- =================================================================
-- Fin P5.
-- =================================================================