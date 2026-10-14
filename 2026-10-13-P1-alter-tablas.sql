-- =================================================================
-- P1 — Refactor BD-COMPLETA: ALTERs a tablas existentes
-- Fecha: 2026-10-13
-- Autorizado por: docs/ADR/013-bd-completa-refactor.md
-- Backup previo obligatorio: C:\backups\bd_redytelca_20261012_pre-refactor.sql
-- Rollback: restaurar el backup.
-- =================================================================

-- Bloque A.1 — clientes
ALTER TABLE clientes
  ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN estado ENUM('activo','suspendido','inactivo') NOT NULL DEFAULT 'activo',
  ADD COLUMN segmento VARCHAR(30) DEFAULT NULL;

ALTER TABLE clientes
  ADD CONSTRAINT chk_clientes_cedula CHECK (cedula REGEXP '^([VEJPG]-)?[0-9]{6,9}$');

ALTER TABLE clientes
  ADD INDEX idx_clientes_estado (estado),
  ADD INDEX idx_clientes_apellidos_nombres (apellidos, nombres);

-- Bloque A.2 — pagos
ALTER TABLE pagos
  ADD COLUMN creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE pagos ADD INDEX idx_pago_fecha (fecha_pago);

-- Bloque A.3 — nodos
ALTER TABLE nodos
  ADD COLUMN creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Bloque A.4 — olts
ALTER TABLE olts
  ADD COLUMN creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Bloque A.5 — naps
ALTER TABLE naps
  ADD COLUMN creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Bloque A.6 — equipos
ALTER TABLE equipos
  ADD COLUMN creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE equipos ADD INDEX idx_equipo_estado (estado_inventario);

-- Bloque A.7 — facturas
ALTER TABLE facturas
  ADD CONSTRAINT chk_facturas_periodo CHECK (periodo REGEXP '^[0-9]{4}-[0-9]{2}$');

ALTER TABLE facturas ADD INDEX idx_factura_periodo (periodo);

-- Bloque A.8 — sesiones
ALTER TABLE sesiones
  ADD CONSTRAINT chk_sesiones_un_tipo CHECK (
    (id_usuario IS NOT NULL AND id_credencial IS NULL) OR
    (id_usuario IS NULL AND id_credencial IS NOT NULL)
  );

-- Bloque A.9 — configuracion_empresa
ALTER TABLE configuracion_empresa
  ADD CONSTRAINT chk_config_singleton CHECK (id_config = 1);

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
-- Fin P1.
-- Verificar con:
--   SHOW CREATE TABLE clientes;
--   SHOW CREATE TABLE sesiones;
--   SHOW CREATE TABLE ip_asignaciones;
--   SHOW INDEX FROM clientes;
--   SHOW INDEX FROM facturas;
-- =================================================================