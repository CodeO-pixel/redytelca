SET NAMES utf8mb4;

INSERT IGNORE INTO `metodos_pago` (`codigo`, `nombre`, `requiere_referencia`, `activo`, `orden`) VALUES
('transferencia', 'Transferencia bancaria', 1, 1, 1),
('pago_movil', 'Pago móvil', 1, 1, 2),
('zelle', 'Zelle', 1, 1, 3),
('efectivo', 'Efectivo', 0, 1, 4);

INSERT IGNORE INTO `modulos` (`id_modulo`, `nombre_modulo`) VALUES
(1, 'Principal'),
(2, 'Clientes'),
(3, 'Operación'),
(4, 'Configuración'),
(5, 'Reportes'),
(6, 'Infraestructura'),
(7, 'Finanzas');

INSERT IGNORE INTO `paginas` (`id_pagina`, `nombre_pagina`, `url_pagina`, `id_modulo`) VALUES
(1, 'Inicio', 'dash', 1),
(2, 'Gestión de clientes', 'clientes', 2),
(4, 'Control de tareas', 'tareas', 3),
(5, 'Tickets', 'tickets', 3),
(6, 'Mapa', 'mapa', 3),
(7, 'Usuarios', 'usuarios', 4),
(8, 'Permisos', 'permisos', 4),
(9, 'Cambiar contraseña', 'password', 4),
(10, 'Roles', 'roles', 4),
(11, 'Reportes', 'reportes', 5),
(12, 'Nodos', 'nodos', 6),
(13, 'OLTs', 'olts', 6),
(14, 'NAPs', 'naps', 6),
(15, 'Facturación', 'facturas', 7),
(16, 'Pagos', 'pagos', 7),
(17, 'Planes', 'planes', 7),
(18, 'Contratos', 'contratos', 7),
(19, 'Notificaciones', 'notificaciones', 7),
(20, 'Equipos', 'equipos', 6),
(21, 'Configuración de empresa', 'empresa', 4),
(22, 'Servicios', 'servicios', 2);

INSERT IGNORE INTO `permisos` (`id_permiso`, `nombre`) VALUES
(1, 'leer'),
(2, 'crear'),
(3, 'editar'),
(4, 'eliminar'),
(5, 'validar');

INSERT IGNORE INTO `rol` (`id_rol`, `nombre_rol`, `descripcion`) VALUES
(1, 'Administrador', 'Acceso total al sistema');

INSERT IGNORE INTO `rol_modulo` (`id_rol`, `id_modulo`)
SELECT r.id_rol, m.id_modulo
FROM `rol` r
CROSS JOIN `modulos` m
WHERE r.nombre_rol = 'Administrador';

INSERT IGNORE INTO `rol_modulo_pagina` (`id_rol_modulo`, `id_modulo`, `id_pagina`)
SELECT rm.id_rol_modulo, p.id_modulo, p.id_pagina
FROM `rol_modulo` rm
INNER JOIN `paginas` p ON p.id_modulo = rm.id_modulo
INNER JOIN `rol` r ON r.id_rol = rm.id_rol
WHERE r.nombre_rol = 'Administrador';

INSERT IGNORE INTO `rol_modulo_permiso` (`id_rol_modulo`, `id_modulo`, `id_pagina`, `id_permiso`)
SELECT rm.id_rol_modulo, p.id_modulo, p.id_pagina, pe.id_permiso
FROM `rol_modulo` rm
INNER JOIN `paginas` p ON p.id_modulo = rm.id_modulo
CROSS JOIN `permisos` pe
INNER JOIN `rol` r ON r.id_rol = rm.id_rol
WHERE r.nombre_rol = 'Administrador';
