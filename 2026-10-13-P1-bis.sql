-- =================================================================
-- P1-bis — Refactor BD-COMPLETA: ALTERs pendientes (A.10 → A.16)
-- Fecha: 2026-10-13
-- Motivo: el intento original de P1 se interrumpió en A.9 por
--         "Duplicate CHECK constraint name". A.1–A.9 ya están
--         aplicados. Este archivo SOLO contiene lo que falta.
-- Autorizado por: docs/ADR/013-bd-completa-refactor.md
-- Rollback: restaurar C:\backups\bd_redytelca_20261012_pre-refactor.sql
-- =================================================================

USE bd_redytelca;

-- Bloque A.10 — logs
ALTER TABLE logs ADD INDEX idx_log_accion_fecha (accion, creado_en);

-- Bloque A.11 — tickets (SOLO sla_vence_en + índices; id_categoria va en P3)
ALTER TABLE tickets
  ADD COLUMN sla_vence_en DATETIME DEFAULT NULL;

ALTER TABLE tickets
  ADD INDEX idx_tickets_estado (estado),
  ADD INDEX idx_tickets_sla (sla_vence_en);

-- Bloque A.12 — notificaciones
ALTER TABLE notificaciones
  ADD COLUMN tipo_evento VARCHAR(50) DEFAULT NULL,
  ADD COLUMN url_destino VARCHAR(255) DEFAULT NULL,
  ADD COLUMN leida_en DATETIME DEFAULT NULL;

ALTER TABLE notificaciones ADD INDEX idx_notif_cliente_estado (id_cliente, estado);

-- Bloque A.13 — ip_asignaciones (Opción A: columna generada + UNIQUE)
ALTER TABLE ip_asignaciones DROP INDEX idx_ip_estado;

ALTER TABLE ip_asignaciones
  ADD COLUMN ip_activa VARCHAR(45) GENERATED ALWAYS AS
    (CASE WHEN estado = 'activa' THEN ip ELSE NULL END) STORED,
  ADD UNIQUE uq_ip_activa (ip_activa);

-- Bloque A.14 — servicios
ALTER TABLE servicios
  ADD COLUMN creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Bloque A.15 — planes
ALTER TABLE planes
  ADD COLUMN creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Bloque A.16 — contratos
ALTER TABLE contratos
  ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- =================================================================
-- Fin P1-bis.
-- Verificar con:
--   SHOW INDEX FROM logs WHERE Key_name = 'idx_log_accion_fecha';
--   SHOW CREATE TABLE tickets;
--   SHOW CREATE TABLE notificaciones;
--   SHOW CREATE TABLE ip_asignaciones;
--   SHOW COLUMNS FROM servicios;
--   SHOW COLUMNS FROM planes;
--   SHOW COLUMNS FROM contratos;
-- =================================================================