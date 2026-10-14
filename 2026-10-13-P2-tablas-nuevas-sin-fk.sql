-- =================================================================
-- P2 — Refactor BD-COMPLETA: tablas nuevas sin FK cross
-- Fecha: 2026-10-13
-- Autorizado por: docs/ADR/013-bd-completa-refactor.md
-- Backup previo: C:\backups\bd_redytelca_20261012_pre-refactor.sql
-- Rollback: DROP TABLE de las 8 tablas creadas por este archivo.
-- =================================================================

-- 1. categorias_ticket
CREATE TABLE categorias_ticket (
  id_categoria INT(11) NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(60) NOT NULL,
  descripcion VARCHAR(255) DEFAULT NULL,
  color CHAR(7) NOT NULL DEFAULT '#104aa8',
  activa TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_categoria),
  UNIQUE KEY uq_categoria_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 2. sla_definiciones
CREATE TABLE sla_definiciones (
  id_sla INT(11) NOT NULL AUTO_INCREMENT,
  id_categoria INT(11) NOT NULL,
  prioridad ENUM('Alta','Media','Baja') NOT NULL,
  horas_respuesta SMALLINT(5) NOT NULL,
  horas_resolucion SMALLINT(5) NOT NULL,
  descripcion VARCHAR(255) DEFAULT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_sla),
  UNIQUE KEY uq_sla_categoria_prioridad (id_categoria, prioridad),
  CONSTRAINT fk_sla_categoria FOREIGN KEY (id_categoria) REFERENCES categorias_ticket (id_categoria) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 3. metodos_pago
CREATE TABLE metodos_pago (
  id_metodo INT(11) NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(30) NOT NULL,
  nombre VARCHAR(60) NOT NULL,
  requiere_referencia TINYINT(1) NOT NULL DEFAULT 0,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  orden TINYINT(3) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_metodo),
  UNIQUE KEY uq_metodo_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 4. etiquetas
CREATE TABLE etiquetas (
  id_etiqueta INT(11) NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  color CHAR(7) NOT NULL DEFAULT '#64748b',
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_etiqueta),
  UNIQUE KEY uq_etiqueta_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 5. email_plantillas
CREATE TABLE email_plantillas (
  id_plantilla INT(11) NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(50) NOT NULL,
  asunto VARCHAR(150) NOT NULL,
  cuerpo TEXT NOT NULL,
  descripcion VARCHAR(255) DEFAULT NULL,
  activa TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_plantilla),
  UNIQUE KEY uq_plantilla_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 6. cliente_notas
CREATE TABLE cliente_notas (
  id_nota INT(11) NOT NULL AUTO_INCREMENT,
  id_cliente INT(11) NOT NULL,
  contenido TEXT NOT NULL,
  id_usuario INT(11) DEFAULT NULL,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_nota),
  KEY idx_nota_cliente (id_cliente),
  KEY idx_nota_usuario (id_usuario),
  CONSTRAINT fk_nota_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE CASCADE,
  CONSTRAINT fk_nota_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 7. cliente_contactos
CREATE TABLE cliente_contactos (
  id_contacto INT(11) NOT NULL AUTO_INCREMENT,
  id_cliente INT(11) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  parentesco VARCHAR(50) DEFAULT NULL,
  telefono VARCHAR(25) DEFAULT NULL,
  correo VARCHAR(80) DEFAULT NULL,
  es_principal TINYINT(1) NOT NULL DEFAULT 0,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_contacto),
  KEY idx_contacto_cliente (id_cliente),
  CONSTRAINT fk_contacto_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 8. plan_historial_precios
CREATE TABLE plan_historial_precios (
  id_historial INT(11) NOT NULL AUTO_INCREMENT,
  id_plan INT(11) NOT NULL,
  precio_anterior DECIMAL(10,2) NOT NULL,
  precio_nuevo DECIMAL(10,2) NOT NULL,
  moneda VARCHAR(10) NOT NULL DEFAULT 'USD',
  id_usuario INT(11) DEFAULT NULL,
  cambiado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  motivo VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_historial),
  KEY idx_hist_precio_plan (id_plan),
  KEY idx_hist_precio_usuario (id_usuario),
  CONSTRAINT fk_hist_precio_plan FOREIGN KEY (id_plan) REFERENCES planes (id_plan) ON DELETE CASCADE,
  CONSTRAINT fk_hist_precio_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =================================================================
-- Fin P2.
-- =================================================================