-- =================================================================
-- P3 — Refactor BD-COMPLETA: tablas nuevas con FK a tablas core
-- Fecha: 2026-10-13
-- Autorizado por: docs/ADR/013-bd-completa-refactor.md
-- Backup previo: C:\backups\bd_redytelca_20261012_pre-refactor.sql
-- Rollback: DROP TABLE de las 9 tablas + DROP COLUMN id_categoria.
-- =================================================================

-- 1. notificaciones_staff
CREATE TABLE notificaciones_staff (
  id_notificacion INT(11) NOT NULL AUTO_INCREMENT,
  titulo VARCHAR(100) NOT NULL,
  mensaje VARCHAR(255) NOT NULL,
  tipo_evento VARCHAR(50) DEFAULT NULL,
  url_destino VARCHAR(255) DEFAULT NULL,
  estado ENUM('leido','no leido') NOT NULL DEFAULT 'no leido',
  id_usuario INT(11) NOT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  leida_en DATETIME DEFAULT NULL,
  PRIMARY KEY (id_notificacion),
  KEY idx_notif_staff_usuario_estado (id_usuario, estado),
  CONSTRAINT fk_notif_staff_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 2. pedidos
CREATE TABLE pedidos (
  id_pedido INT(11) NOT NULL AUTO_INCREMENT,
  id_cliente INT(11) NOT NULL,
  id_servicio INT(11) DEFAULT NULL,
  tipo ENUM('instalacion','reparacion','retiro','cambio_plan','traslado') NOT NULL,
  estado ENUM('pendiente','asignado','en_curso','completado','cancelado') NOT NULL DEFAULT 'pendiente',
  prioridad ENUM('Alta','Media','Baja') NOT NULL DEFAULT 'Media',
  direccion_texto VARCHAR(255) DEFAULT NULL,
  latitud DECIMAL(10,8) DEFAULT NULL,
  longitud DECIMAL(11,8) DEFAULT NULL,
  descripcion TEXT DEFAULT NULL,
  id_usuario_creador INT(11) DEFAULT NULL,
  id_tecnico_asignado INT(11) DEFAULT NULL,
  fecha_solicitud TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_programada DATE DEFAULT NULL,
  fecha_inicio DATETIME DEFAULT NULL,
  fecha_completado DATETIME DEFAULT NULL,
  observaciones_cierre TEXT DEFAULT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_pedido),
  KEY idx_pedido_cliente (id_cliente),
  KEY idx_pedido_servicio (id_servicio),
  KEY idx_pedido_estado (estado),
  KEY idx_pedido_tecnico (id_tecnico_asignado),
  KEY idx_pedido_creador (id_usuario_creador),
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente),
  CONSTRAINT fk_pedido_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE SET NULL,
  CONSTRAINT fk_pedido_creador FOREIGN KEY (id_usuario_creador) REFERENCES usuarios (id_usuario) ON DELETE SET NULL,
  CONSTRAINT fk_pedido_tecnico FOREIGN KEY (id_tecnico_asignado) REFERENCES usuarios (id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 3. pedido_materiales
CREATE TABLE pedido_materiales (
  id_material INT(11) NOT NULL AUTO_INCREMENT,
  id_pedido INT(11) NOT NULL,
  id_equipo INT(11) DEFAULT NULL,
  descripcion VARCHAR(150) NOT NULL,
  cantidad DECIMAL(10,2) NOT NULL DEFAULT 1.00,
  unidad VARCHAR(20) NOT NULL DEFAULT 'unidad',
  notas VARCHAR(255) DEFAULT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_material),
  KEY idx_material_pedido (id_pedido),
  KEY idx_material_equipo (id_equipo),
  CONSTRAINT fk_material_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido) ON DELETE CASCADE,
  CONSTRAINT fk_material_equipo FOREIGN KEY (id_equipo) REFERENCES equipos (id_equipo) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 4. pedido_asignaciones
CREATE TABLE pedido_asignaciones (
  id_asignacion INT(11) NOT NULL AUTO_INCREMENT,
  id_pedido INT(11) NOT NULL,
  id_tecnico INT(11) NOT NULL,
  id_usuario_asignador INT(11) DEFAULT NULL,
  estado ENUM('activa','completada','rechazada') NOT NULL DEFAULT 'activa',
  motivo_rechazo VARCHAR(255) DEFAULT NULL,
  asignado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cerrado_en DATETIME DEFAULT NULL,
  PRIMARY KEY (id_asignacion),
  KEY idx_asig_pedido (id_pedido),
  KEY idx_asig_tecnico (id_tecnico),
  KEY idx_asig_asignador (id_usuario_asignador),
  CONSTRAINT fk_asig_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido) ON DELETE CASCADE,
  CONSTRAINT fk_asig_tecnico FOREIGN KEY (id_tecnico) REFERENCES usuarios (id_usuario),
  CONSTRAINT fk_asig_asignador FOREIGN KEY (id_usuario_asignador) REFERENCES usuarios (id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 5. equipo_movimientos
CREATE TABLE equipo_movimientos (
  id_movimiento INT(11) NOT NULL AUTO_INCREMENT,
  id_equipo INT(11) NOT NULL,
  tipo ENUM('alta_stock','asignacion','devolucion','baja','reparacion','reemplazo') NOT NULL,
  estado_anterior ENUM('stock','asignado','devuelto','averiado','baja') DEFAULT NULL,
  estado_nuevo ENUM('stock','asignado','devuelto','averiado','baja') NOT NULL,
  id_servicio INT(11) DEFAULT NULL,
  id_usuario INT(11) DEFAULT NULL,
  notas VARCHAR(255) DEFAULT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_movimiento),
  KEY idx_mov_equipo (id_equipo),
  KEY idx_mov_servicio (id_servicio),
  KEY idx_mov_usuario (id_usuario),
  CONSTRAINT fk_mov_equipo FOREIGN KEY (id_equipo) REFERENCES equipos (id_equipo) ON DELETE CASCADE,
  CONSTRAINT fk_mov_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE SET NULL,
  CONSTRAINT fk_mov_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 6. notas_credito
CREATE TABLE notas_credito (
  id_nota INT(11) NOT NULL AUTO_INCREMENT,
  id_cliente INT(11) NOT NULL,
  id_factura INT(11) DEFAULT NULL,
  monto DECIMAL(10,2) NOT NULL,
  moneda VARCHAR(10) NOT NULL DEFAULT 'USD',
  motivo VARCHAR(255) NOT NULL,
  estado ENUM('emitida','aplicada','anulada') NOT NULL DEFAULT 'emitida',
  id_usuario_emisor INT(11) DEFAULT NULL,
  emitida_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aplicada_en DATETIME DEFAULT NULL,
  PRIMARY KEY (id_nota),
  KEY idx_nc_cliente (id_cliente),
  KEY idx_nc_factura (id_factura),
  KEY idx_nc_emisor (id_usuario_emisor),
  CONSTRAINT fk_nc_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente),
  CONSTRAINT fk_nc_factura FOREIGN KEY (id_factura) REFERENCES facturas (id_factura) ON DELETE SET NULL,
  CONSTRAINT fk_nc_emisor FOREIGN KEY (id_usuario_emisor) REFERENCES usuarios (id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 7. notas_debito
CREATE TABLE notas_debito (
  id_nota INT(11) NOT NULL AUTO_INCREMENT,
  id_cliente INT(11) NOT NULL,
  id_factura INT(11) DEFAULT NULL,
  monto DECIMAL(10,2) NOT NULL,
  moneda VARCHAR(10) NOT NULL DEFAULT 'USD',
  motivo VARCHAR(255) NOT NULL,
  estado ENUM('emitida','aplicada','anulada') NOT NULL DEFAULT 'emitida',
  id_usuario_emisor INT(11) DEFAULT NULL,
  emitida_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  aplicada_en DATETIME DEFAULT NULL,
  PRIMARY KEY (id_nota),
  KEY idx_nd_cliente (id_cliente),
  KEY idx_nd_factura (id_factura),
  KEY idx_nd_emisor (id_usuario_emisor),
  CONSTRAINT fk_nd_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente),
  CONSTRAINT fk_nd_factura FOREIGN KEY (id_factura) REFERENCES facturas (id_factura) ON DELETE SET NULL,
  CONSTRAINT fk_nd_emisor FOREIGN KEY (id_usuario_emisor) REFERENCES usuarios (id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 8. cliente_etiquetas
CREATE TABLE cliente_etiquetas (
  id_cliente_etiqueta INT(11) NOT NULL AUTO_INCREMENT,
  id_cliente INT(11) NOT NULL,
  id_etiqueta INT(11) NOT NULL,
  asignada_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_cliente_etiqueta),
  UNIQUE KEY uq_cliente_etiqueta (id_cliente, id_etiqueta),
  KEY idx_ce_etiqueta (id_etiqueta),
  CONSTRAINT fk_ce_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE CASCADE,
  CONSTRAINT fk_ce_etiqueta FOREIGN KEY (id_etiqueta) REFERENCES etiquetas (id_etiqueta) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 9. email_log
CREATE TABLE email_log (
  id_email INT(11) NOT NULL AUTO_INCREMENT,
  id_plantilla INT(11) DEFAULT NULL,
  destinatario VARCHAR(120) NOT NULL,
  asunto VARCHAR(150) NOT NULL,
  cuerpo TEXT DEFAULT NULL,
  estado ENUM('pendiente','enviado','fallido') NOT NULL DEFAULT 'pendiente',
  error_mensaje VARCHAR(255) DEFAULT NULL,
  id_cliente INT(11) DEFAULT NULL,
  id_usuario INT(11) DEFAULT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  enviado_en DATETIME DEFAULT NULL,
  PRIMARY KEY (id_email),
  KEY idx_email_plantilla (id_plantilla),
  KEY idx_email_cliente (id_cliente),
  KEY idx_email_usuario (id_usuario),
  KEY idx_email_estado (estado),
  CONSTRAINT fk_email_plantilla FOREIGN KEY (id_plantilla) REFERENCES email_plantillas (id_plantilla) ON DELETE SET NULL,
  CONSTRAINT fk_email_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE SET NULL,
  CONSTRAINT fk_email_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 10. ALTER tickets — añadir id_categoria (quedó pendiente de P1)
ALTER TABLE tickets
  ADD COLUMN id_categoria INT(11) DEFAULT NULL AFTER prioridad,
  ADD INDEX idx_tickets_categoria (id_categoria),
  ADD CONSTRAINT fk_ticket_categoria FOREIGN KEY (id_categoria) REFERENCES categorias_ticket (id_categoria) ON DELETE SET NULL;

-- =================================================================
-- Fin P3.
-- =================================================================