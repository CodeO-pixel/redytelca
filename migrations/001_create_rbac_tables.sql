-- Migration: Create RBAC tables compatible with the existing app

CREATE TABLE IF NOT EXISTS rol (
  id_rol INT AUTO_INCREMENT PRIMARY KEY,
  nombre_rol VARCHAR(50) NOT NULL UNIQUE,
  descripcion TEXT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS permissions (
  id_permiso INT AUTO_INCREMENT PRIMARY KEY,
  nombre_permiso VARCHAR(150) NOT NULL UNIQUE,
  descripcion TEXT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS role_permission (
  id_rol INT NOT NULL,
  id_permiso INT NOT NULL,
  PRIMARY KEY (id_rol, id_permiso),
  FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE CASCADE,
  FOREIGN KEY (id_permiso) REFERENCES permissions(id_permiso) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS rol_modulo_pagina (
  id_rmp INT AUTO_INCREMENT PRIMARY KEY,
  id_rol INT NOT NULL,
  id_modulo INT NOT NULL,
  id_pagina INT NOT NULL,
  UNIQUE KEY uq_rol_pagina (id_rol, id_pagina),
  FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE CASCADE,
  FOREIGN KEY (id_modulo) REFERENCES modulos(id_modulo) ON DELETE CASCADE,
  FOREIGN KEY (id_pagina) REFERENCES paginas(id_pagina) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE OR REPLACE VIEW roles AS
SELECT id_rol, nombre_rol, descripcion FROM rol;

INSERT IGNORE INTO rol (id_rol, nombre_rol, descripcion) VALUES
(1, 'Administrador', 'Acceso total al sistema'),
(2, 'Operador', 'Funciones operativas y de campo');

INSERT IGNORE INTO permissions (id_permiso, nombre_permiso, descripcion) VALUES
(1, 'clientes.view', 'Ver lista de clientes'),
(2, 'clientes.create', 'Crear cliente'),
(3, 'clientes.edit', 'Editar cliente'),
(4, 'clientes.delete', 'Eliminar cliente'),
(5, 'roles.manage', 'Gestionar roles y permisos');

INSERT IGNORE INTO role_permission (id_rol, id_permiso)
SELECT 1, p.id_permiso FROM permissions p WHERE p.nombre_permiso IN ('clientes.view','clientes.create','clientes.edit','clientes.delete','roles.manage');

INSERT IGNORE INTO role_permission (id_rol, id_permiso)
SELECT 2, p.id_permiso FROM permissions p WHERE p.nombre_permiso IN ('clientes.view');
