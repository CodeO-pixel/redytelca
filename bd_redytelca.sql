-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 21, 2026 at 02:17 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bd_redytelca`
--

-- --------------------------------------------------------

--
-- Table structure for table `clientes`
--

CREATE TABLE `clientes` (
  `id_cliente` int(11) NOT NULL,
  `nombres` varchar(65) NOT NULL,
  `apellidos` varchar(65) NOT NULL,
  `cedula` varchar(15) NOT NULL,
  `num_telefono` varchar(25) NOT NULL,
  `correo` varchar(80) NOT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `nombres`, `apellidos`, `cedula`, `num_telefono`, `correo`, `fecha_registro`) VALUES
(1, 'marcelo', 'petronilo', '3192873', '0412-1234567', 'marcelo@gmail.com', '2026-07-10 23:41:47'),
(10, 'Juan', 'Pérez', 'V-12345678', '0412-1111111', 'juan@test.com', '2026-07-20 12:49:51'),
(11, 'María', 'González', 'E-87654321', '0412-2222222', 'maria@test.com', '2026-07-20 12:49:51'),
(12, 'Carlos', 'Rodríguez', 'V-11111111', '0412-3333333', 'carlos@test.com', '2026-07-20 12:49:51'),
(13, 'Ana', 'Martínez', 'V-22222222', '0412-4444444', 'ana@test.com', '2026-07-20 12:49:51');

-- --------------------------------------------------------

--
-- Table structure for table `clientes_credenciales`
--

CREATE TABLE `clientes_credenciales` (
  `id_credencial` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `username` varchar(15) NOT NULL,
  `password` varchar(255) NOT NULL,
  `correo_recuperacion` varchar(80) DEFAULT NULL,
  `estado` enum('activa','suspendida') DEFAULT 'activa',
  `must_change_password` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `ultimo_acceso` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `configuracion_empresa`
--

CREATE TABLE `configuracion_empresa` (
  `id_config` int(11) NOT NULL,
  `nombre_empresa` varchar(100) NOT NULL DEFAULT '',
  `logo_path` varchar(255) DEFAULT NULL,
  `color_primario` char(7) DEFAULT '#0f172a',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `configuracion_empresa`
--

INSERT INTO `configuracion_empresa` (`id_config`, `nombre_empresa`, `logo_path`, `color_primario`, `creado_en`, `actualizado_en`) VALUES
(1, 'REDYTELCA', 'Logos/logo_transparent.png', '#1453db', '2026-07-20 17:19:31', '2026-07-20 23:00:03');

-- --------------------------------------------------------

--
-- Table structure for table `contratos`
--

CREATE TABLE `contratos` (
  `id_contrato` int(11) NOT NULL,
  `id_servicio` int(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date DEFAULT NULL,
  `tipo_contrato` enum('indefinido','plazo_fijo','promocional') DEFAULT 'indefinido',
  `estado` enum('vigente','vencido','rescindido') DEFAULT 'vigente',
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `contratos`
--

INSERT INTO `contratos` (`id_contrato`, `id_servicio`, `fecha_inicio`, `fecha_fin`, `tipo_contrato`, `estado`, `observaciones`, `creado_en`) VALUES
(1, 1, '2026-07-11', '2026-08-11', 'plazo_fijo', 'vigente', 'balans', '2026-07-11 19:34:54'),
(2, 4, '2026-07-11', '2026-08-11', 'plazo_fijo', 'vigente', 'mondongo', '2026-07-11 21:03:08'),
(10, 10, '2026-01-01', NULL, 'indefinido', 'vigente', 'Contrato estándar', '2026-07-20 16:49:51'),
(11, 11, '2026-02-01', '2026-12-31', 'plazo_fijo', 'vigente', 'Contrato anual', '2026-07-20 16:49:51'),
(12, 12, '2026-03-01', NULL, 'indefinido', 'vencido', 'Expirado por falta de pago', '2026-07-20 16:49:51');

-- --------------------------------------------------------

--
-- Table structure for table `equipos`
--

CREATE TABLE `equipos` (
  `id_equipo` int(11) NOT NULL,
  `tipo` enum('ONU','ONT','ROUTER') NOT NULL,
  `marca` varchar(50) DEFAULT NULL,
  `modelo` varchar(50) DEFAULT NULL,
  `direccion_mac` char(17) NOT NULL,
  `num_puerto_nap` tinyint(4) NOT NULL,
  `estado_fisico` enum('operativo','averiado','stock') DEFAULT 'stock',
  `id_naps` int(11) NOT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `propiedad` enum('cliente','empresa') NOT NULL DEFAULT 'empresa'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `equipos`
--

INSERT INTO `equipos` (`id_equipo`, `tipo`, `marca`, `modelo`, `direccion_mac`, `num_puerto_nap`, `estado_fisico`, `id_naps`, `id_servicio`, `propiedad`) VALUES
(10, 'ONT', 'Huawei', 'HG8245', 'AA:BB:CC:DD:EE:10', 1, 'operativo', 10, 10, 'cliente'),
(11, 'ROUTER', 'Mikrotik', 'hAP ac2', 'AA:BB:CC:DD:EE:11', 2, 'operativo', 10, 11, 'empresa'),
(12, 'ONU', 'ZTE', 'F670L', 'AA:BB:CC:DD:EE:12', 1, 'stock', 12, NULL, 'empresa');

-- --------------------------------------------------------

--
-- Table structure for table `facturas`
--

CREATE TABLE `facturas` (
  `id_factura` int(11) NOT NULL,
  `id_servicio` int(11) NOT NULL,
  `periodo` varchar(7) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha_emision` date NOT NULL,
  `fecha_vencimiento` date NOT NULL,
  `estado` enum('pendiente','pagada','parcial','vencida','anulada') DEFAULT 'pendiente',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `facturas`
--

INSERT INTO `facturas` (`id_factura`, `id_servicio`, `periodo`, `monto`, `fecha_emision`, `fecha_vencimiento`, `estado`, `creado_en`) VALUES
(10, 10, '2026-06', 15.00, '2026-06-01', '2026-06-20', 'pagada', '2026-07-20 16:49:51'),
(11, 10, '2026-07', 15.00, '2026-07-01', '2026-07-20', 'vencida', '2026-07-20 16:49:51'),
(12, 11, '2026-07', 45.00, '2026-07-01', '2026-07-25', 'pendiente', '2026-07-20 16:49:51'),
(13, 12, '2026-06', 30.00, '2026-06-01', '2026-06-20', 'pagada', '2026-07-20 16:49:51');

-- --------------------------------------------------------

--
-- Table structure for table `logs`
--

CREATE TABLE `logs` (
  `id_log` bigint(20) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `accion` varchar(100) NOT NULL,
  `tabla_afectada` varchar(50) DEFAULT NULL,
  `id_registro_afectado` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `modulos`
--

CREATE TABLE `modulos` (
  `id_modulo` int(11) NOT NULL,
  `nombre_modulo` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `modulos`
--

INSERT INTO `modulos` (`id_modulo`, `nombre_modulo`) VALUES
(1, 'Principal'),
(2, 'Clientes'),
(3, 'Operación'),
(4, 'Configuración'),
(5, 'Reportes'),
(6, 'Infraestructura'),
(7, 'Finanzas');

-- --------------------------------------------------------

--
-- Table structure for table `naps`
--

CREATE TABLE `naps` (
  `id_nap` int(11) NOT NULL,
  `codigo` varchar(20) NOT NULL,
  `cantidad_puertos_max` tinyint(4) NOT NULL DEFAULT 16,
  `ubicacion_fisica` text DEFAULT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `id_olts` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `naps`
--

INSERT INTO `naps` (`id_nap`, `codigo`, `cantidad_puertos_max`, `ubicacion_fisica`, `latitud`, `longitud`, `id_olts`) VALUES
(1, 'NAP-01', 16, 'Calle Principal', 10.48200000, -66.90500000, 1),
(10, 'NAP-10', 16, 'Ubicación Física 1', 0.00000000, 0.00000000, 10),
(11, 'NAP-11', 8, 'Ubicación Física 2', 0.00000000, 0.00000000, 10),
(12, 'NAP-12', 16, 'Ubicación Física 3', 0.00000000, 0.00000000, 11);

-- --------------------------------------------------------

--
-- Table structure for table `nodos`
--

CREATE TABLE `nodos` (
  `id_nodo` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `ubicacion` varchar(255) DEFAULT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `estado` enum('activo','mantenimiento','inactivo') DEFAULT 'activo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `nodos`
--

INSERT INTO `nodos` (`id_nodo`, `nombre`, `ubicacion`, `latitud`, `longitud`, `estado`) VALUES
(1, 'Nodo Centro', 'Sector Centro', 10.48060000, -66.90360000, 'activo'),
(10, 'Nodo Norte', 'Ubicación prueba 1', 0.00000000, 0.00000000, 'activo'),
(11, 'Nodo Sur', 'Ubicación prueba 2', 0.00000000, 0.00000000, 'activo');

-- --------------------------------------------------------

--
-- Table structure for table `notificaciones`
--

CREATE TABLE `notificaciones` (
  `id_notificacion` int(11) NOT NULL,
  `titulo` varchar(100) NOT NULL,
  `mensaje` varchar(255) NOT NULL,
  `fecha_envio` datetime DEFAULT current_timestamp(),
  `estado` enum('leido','no leido') DEFAULT 'no leido',
  `id_cliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `olts`
--

CREATE TABLE `olts` (
  `id_olt` int(11) NOT NULL,
  `marca_modelo` varchar(100) NOT NULL,
  `puertos_pon` tinyint(4) NOT NULL DEFAULT 16,
  `ip_gestion` varchar(45) DEFAULT NULL,
  `id_nodos` int(11) NOT NULL,
  `codigo` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `olts`
--

INSERT INTO `olts` (`id_olt`, `marca_modelo`, `puertos_pon`, `ip_gestion`, `id_nodos`, `codigo`) VALUES
(1, 'Huawei MA5616', 16, '192.168.100.1', 1, 'OLT-01'),
(10, 'Huawei MA5680T', 16, '192.168.10.1', 10, 'OLT-10'),
(11, 'ZTE C320', 8, '192.168.10.2', 11, 'OLT-11');

-- --------------------------------------------------------

--
-- Table structure for table `paginas`
--

CREATE TABLE `paginas` (
  `id_pagina` int(11) NOT NULL,
  `nombre_pagina` varchar(100) NOT NULL,
  `url_pagina` varchar(255) NOT NULL,
  `id_modulo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `paginas`
--

INSERT INTO `paginas` (`id_pagina`, `nombre_pagina`, `url_pagina`, `id_modulo`) VALUES
(1, 'Inicio', 'dash', 1),
(2, 'Gestión de clientes', 'clientes', 2),
(3, 'Registrar cliente', 'registro', 2),
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
(20, 'Equipos', 'equipos', 6);

-- --------------------------------------------------------

--
-- Table structure for table `pagos`
--

CREATE TABLE `pagos` (
  `id_pago` int(11) NOT NULL,
  `id_factura` int(11) DEFAULT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_servicio` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `fecha_pago` datetime NOT NULL,
  `metodo_pago` enum('transferencia','pago_movil','zelle','efectivo') DEFAULT NULL,
  `referencia_bancaria` varchar(255) DEFAULT NULL,
  `estado` enum('pendiente','validado','rechazado') DEFAULT 'pendiente',
  `fecha_validacion` datetime DEFAULT NULL,
  `id_usuario_valido` int(11) DEFAULT NULL,
  `origen` enum('portal_cliente','backoffice') DEFAULT 'backoffice'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pagos`
--

INSERT INTO `pagos` (`id_pago`, `id_factura`, `id_cliente`, `id_servicio`, `monto`, `fecha_pago`, `metodo_pago`, `referencia_bancaria`, `estado`, `fecha_validacion`, `id_usuario_valido`, `origen`) VALUES
(10, 10, 10, 10, 15.00, '2026-06-15 10:00:00', 'transferencia', 'REF-001', 'validado', '2026-06-16 09:00:00', 1, 'backoffice'),
(11, 13, 11, 12, 30.00, '2026-06-10 14:30:00', 'pago_movil', 'REF-002', 'validado', '2026-06-11 08:00:00', 1, 'portal_cliente'),
(12, NULL, 12, 13, 20.00, '2026-07-05 11:00:00', 'efectivo', NULL, 'pendiente', NULL, NULL, 'backoffice');

-- --------------------------------------------------------

--
-- Table structure for table `planes`
--

CREATE TABLE `planes` (
  `id_plan` int(11) NOT NULL,
  `nombre` varchar(60) NOT NULL,
  `velocidad` varchar(60) NOT NULL,
  `precio_mensual` decimal(10,2) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'USD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `planes`
--

INSERT INTO `planes` (`id_plan`, `nombre`, `velocidad`, `precio_mensual`, `moneda`) VALUES
(1, 'Plan Básico', '10 Mbps', 15.00, 'USD'),
(2, 'Plan Hogar', '20 Mbps', 30.00, 'USD'),
(10, 'Plan Premium', '50 Mbps', 45.00, 'USD'),
(11, 'Plan Empresarial', '100 Mbps', 80.00, 'USD');

-- --------------------------------------------------------

--
-- Table structure for table `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nombre_rol` varchar(50) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id_permiso` int(11) NOT NULL,
  `nombre_permiso` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `role_permission`
--

CREATE TABLE `role_permission` (
  `id_rol` int(11) NOT NULL,
  `id_permiso` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Table structure for table `rol_modulo_pagina`
--

CREATE TABLE `rol_modulo_pagina` (
  `id_rmp` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL,
  `id_pagina` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rol`
--

INSERT INTO `rol` (`id_rol`, `nombre_rol`, `descripcion`) VALUES
(1, 'Administrador', 'Acceso total al sistema'),
(2, 'Operador', 'Funciones operativas y de campo');

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id_permiso`, `nombre_permiso`, `descripcion`) VALUES
(1, 'clientes.view', 'Ver lista de clientes'),
(2, 'clientes.create', 'Crear cliente'),
(3, 'clientes.edit', 'Editar cliente'),
(4, 'clientes.delete', 'Eliminar cliente'),
(5, 'roles.manage', 'Gestionar roles y permisos');

--
-- Dumping data for table `role_permission`
--

INSERT INTO `role_permission` (`id_rol`, `id_permiso`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(2, 1);

--
-- Dumping data for table `rol_modulo_pagina`
--

INSERT INTO `rol_modulo_pagina` (`id_rmp`, `id_rol`, `id_modulo`, `id_pagina`) VALUES
(65, 2, 1, 1),
(66, 2, 2, 2),
(67, 2, 2, 3),
(68, 2, 3, 4),
(69, 2, 3, 5),
(70, 2, 3, 6),
(71, 2, 4, 9),
(72, 2, 5, 11),
(73, 2, 6, 12),
(74, 2, 6, 13),
(75, 2, 6, 14),
(76, 2, 6, 20),
(77, 2, 7, 15),
(78, 2, 7, 16),
(79, 2, 7, 17),
(80, 2, 7, 18),
(81, 2, 7, 19),
(101, 1, 1, 1),
(102, 1, 2, 2),
(103, 1, 2, 3),
(104, 1, 3, 4),
(105, 1, 3, 5),
(106, 1, 3, 6),
(107, 1, 4, 7),
(108, 1, 4, 8),
(109, 1, 4, 9),
(110, 1, 4, 10),
(111, 1, 5, 11),
(112, 1, 6, 12),
(113, 1, 6, 13),
(114, 1, 6, 14),
(115, 1, 6, 20),
(116, 1, 7, 15),
(117, 1, 7, 16),
(118, 1, 7, 17),
(119, 1, 7, 18),
(120, 1, 7, 19);

CREATE OR REPLACE VIEW `roles` AS
SELECT `id_rol`, `nombre_rol`, `descripcion` FROM `rol`;

-- --------------------------------------------------------

--
-- Table structure for table `servicios`
--

CREATE TABLE `servicios` (
  `id_servicio` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `alias` varchar(50) DEFAULT NULL,
  `estado_comercial` enum('activo','suspendido','retirado','pendiente') DEFAULT 'pendiente',
  `id_plan` int(11) NOT NULL,
  `id_naps` int(11) DEFAULT NULL,
  `direccion_texto` varchar(255) NOT NULL DEFAULT '',
  `latitud_instalacion` decimal(10,8) DEFAULT NULL,
  `longitud_instalacion` decimal(11,8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `servicios`
--

INSERT INTO `servicios` (`id_servicio`, `id_cliente`, `alias`, `estado_comercial`, `id_plan`, `id_naps`, `direccion_texto`, `latitud_instalacion`, `longitud_instalacion`) VALUES
(1, 1, NULL, 'activo', 1, 1, 'San Francisco, calle 4', 10.48006000, -66.90300000),
(4, 1, 'casa principal', 'activo', 2, 1, 'san francisco al lado del otro servicio', 10.20399400, 66.90300000),
(10, 10, 'Servicio Casa 1', 'activo', 1, 10, 'Dir prueba 1', NULL, NULL),
(11, 10, 'Servicio Oficina', 'activo', 10, 12, 'Dir prueba 2', NULL, NULL),
(12, 11, 'Servicio Hogar', 'activo', 2, 10, 'Dir prueba 3', NULL, NULL),
(13, 12, 'Servicio Principal', 'suspendido', 1, 11, 'Dir prueba 4', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sesiones`
--

CREATE TABLE `sesiones` (
  `id_sesion` int(11) NOT NULL,
  `token` varchar(64) NOT NULL,
  `tipo_usuario` enum('staff','cliente') NOT NULL DEFAULT 'staff',
  `id_usuario` int(11) DEFAULT NULL,
  `id_credencial` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `expira_en` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sesiones`
--

INSERT INTO `sesiones` (`id_sesion`, `token`, `tipo_usuario`, `id_usuario`, `id_credencial`, `creado_en`, `expira_en`) VALUES
(29, 'a03998d411b5b27adca1759c9017e6b6f490d831abdfe3c12e9148f83a82cfae', 'staff', 2, NULL, '2026-07-19 19:25:22', '2026-08-18 21:25:22'),
(64, 'c9d9a1fb58d09726589fd50c25f2a3ed894a6ce096f242e278344ad04ebe2c51', 'staff', 1, NULL, '2026-07-20 23:11:20', '2026-08-20 01:11:20'),
(65, '7bcf4c3d605bb0396e8f47e1b29aed55e6dfd6650f46aa730d63919068394205', 'staff', 1, NULL, '2026-07-20 23:11:20', '2026-08-20 01:11:20'),
(66, '51df69836ef4952eb45438ef0b06f9dc629a1b986ef57ff7537ab0937804ff85', 'staff', 1, NULL, '2026-07-20 23:23:57', '2026-08-20 01:23:57'),
(67, '8da54fe60009ed21c7abb62faf2f6b809ecc2add8e5c58b58bbdfe0af09a9702', 'staff', 1, NULL, '2026-07-20 23:23:57', '2026-08-20 01:23:57'),
(68, 'dbf45925a9780194b6de65c1a79f78290bffe18f19c2efc5e26dd3a25cb863e9', 'staff', 1, NULL, '2026-07-20 23:29:35', '2026-08-20 01:40:47'),
(69, '47d7c425cfcbc89d9669c71829874f100f9cedb587848824d0d3c726f29cc982', 'staff', 1, NULL, '2026-07-20 23:40:56', '2026-07-20 20:15:16'),
(70, '0a1a55da6def09c91a2b91fdd802421268138acb979ea042a0c7bea784a87b6c', 'staff', 3, NULL, '2026-07-21 00:15:26', '2026-07-20 20:16:12');

-- --------------------------------------------------------

--
-- Table structure for table `tareas`
--

CREATE TABLE `tareas` (
  `id_tarea` int(11) NOT NULL,
  `titulo` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` varchar(30) NOT NULL DEFAULT 'Pendiente',
  `prioridad` varchar(20) NOT NULL DEFAULT 'Media',
  `id_cliente` int(11) DEFAULT NULL,
  `id_usuario_creador` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tareas`
--

INSERT INTO `tareas` (`id_tarea`, `titulo`, `descripcion`, `estado`, `prioridad`, `id_cliente`, `id_usuario_creador`, `creado_en`, `actualizado_en`) VALUES
(1, 'reparar', 'jajsjk', 'En curso', 'Media', 1, 2, '2026-07-11 19:28:16', '2026-07-11 19:28:16'),
(10, 'Revisar router cliente', 'Ir a la casa del cliente a revisar el router', 'Pendiente', 'Alta', 10, 1, '2026-07-20 16:49:51', '2026-07-20 16:49:51'),
(11, 'Actualizar firmware OLT', 'Programar actualización de firmware en OLT-10', 'En curso', 'Media', 11, 2, '2026-07-20 16:49:51', '2026-07-20 16:54:54');

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `id_ticket` int(11) NOT NULL,
  `asunto` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` varchar(30) NOT NULL DEFAULT 'Abierto',
  `prioridad` varchar(20) NOT NULL DEFAULT 'Media',
  `id_cliente` int(11) DEFAULT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `id_usuario_creador` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tickets`
--

INSERT INTO `tickets` (`id_ticket`, `asunto`, `descripcion`, `estado`, `prioridad`, `id_cliente`, `id_servicio`, `id_usuario_creador`, `creado_en`, `actualizado_en`) VALUES
(1, 'a', 'a', 'Abierto', 'Media', 1, NULL, 1, '2026-07-19 18:08:10', '2026-07-19 18:08:10'),
(10, 'Fallo de internet', 'El cliente reporta que no tiene señal desde ayer', 'Abierto', 'Alta', 10, 10, 1, '2026-07-20 16:49:51', '2026-07-20 16:49:51'),
(11, 'Revisión de velocidad', 'La velocidad no alcanza lo contratado', 'En proceso', 'Media', 11, 12, 2, '2026-07-20 16:49:51', '2026-07-20 16:49:51'),
(12, 'Instalación nueva', 'Solicita instalación para nueva oficina', 'Cerrado', 'Baja', 12, NULL, 1, '2026-07-20 16:49:51', '2026-07-20 16:49:51');

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `id_rol` int(11) NOT NULL DEFAULT 1,
  `email` varchar(100) NOT NULL DEFAULT '',
  `must_change_password` tinyint(1) NOT NULL DEFAULT 0,
  `email_verified` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `username`, `password`, `id_rol`, `email`, `must_change_password`, `email_verified`) VALUES
(1, 'admin', '$2y$10$3F914JmsON9GvY8A2Y6pxuV1/Yap2xLDhc0L9BUFvEK/.9v9pz3Im', 1, 'admin@gmail.com', 0, 1),
(2, 'Marcos', '$2y$10$C2sKEyEZCc5ADpW/Qnjfx.iGlu3/T1XAk0XgTIob0hVZrb7qzNtQS', 2, 'marcos@gmail.com', 0, 1),
(3, 'hebert', '$2y$10$WD/6oAtWdTmJtyTSRKlQnuI2HRZH7h1.n.aplmPRC6/ihGqH1SbKS', 1, 'hebert@prueba.com', 0, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id_cliente`),
  ADD UNIQUE KEY `cedula` (`cedula`);

--
-- Indexes for table `clientes_credenciales`
--
ALTER TABLE `clientes_credenciales`
  ADD PRIMARY KEY (`id_credencial`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `uq_cliente` (`id_cliente`);

--
-- Indexes for table `configuracion_empresa`
--
ALTER TABLE `configuracion_empresa`
  ADD PRIMARY KEY (`id_config`);

--
-- Indexes for table `contratos`
--
ALTER TABLE `contratos`
  ADD PRIMARY KEY (`id_contrato`),
  ADD KEY `fk_contrato_servicio` (`id_servicio`);

--
-- Indexes for table `equipos`
--
ALTER TABLE `equipos`
  ADD PRIMARY KEY (`id_equipo`),
  ADD UNIQUE KEY `direccion_mac` (`direccion_mac`),
  ADD UNIQUE KEY `idx_nap_puerto` (`id_naps`,`num_puerto_nap`),
  ADD UNIQUE KEY `id_servicio` (`id_servicio`);

--
-- Indexes for table `facturas`
--
ALTER TABLE `facturas`
  ADD PRIMARY KEY (`id_factura`),
  ADD KEY `fk_factura_servicio` (`id_servicio`);

--
-- Indexes for table `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `fk_log_usuario` (`id_usuario`);

--
-- Indexes for table `modulos`
--
ALTER TABLE `modulos`
  ADD PRIMARY KEY (`id_modulo`);

--
-- Indexes for table `naps`
--
ALTER TABLE `naps`
  ADD PRIMARY KEY (`id_nap`),
  ADD UNIQUE KEY `codigo` (`codigo`),
  ADD KEY `fk_nap_olt` (`id_olts`);

--
-- Indexes for table `nodos`
--
ALTER TABLE `nodos`
  ADD PRIMARY KEY (`id_nodo`);

--
-- Indexes for table `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id_notificacion`),
  ADD KEY `fk_notif_cliente` (`id_cliente`);

--
-- Indexes for table `olts`
--
ALTER TABLE `olts`
  ADD PRIMARY KEY (`id_olt`),
  ADD KEY `fk_olt_nodo` (`id_nodos`);

--
-- Indexes for table `paginas`
--
ALTER TABLE `paginas`
  ADD PRIMARY KEY (`id_pagina`),
  ADD KEY `fk_pagina_modulo` (`id_modulo`);

--
-- Indexes for table `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id_pago`),
  ADD KEY `fk_pago_factura` (`id_factura`),
  ADD KEY `fk_pago_cliente` (`id_cliente`),
  ADD KEY `fk_pago_servicio` (`id_servicio`),
  ADD KEY `fk_pago_usuario` (`id_usuario_valido`);

--
-- Indexes for table `planes`
--
ALTER TABLE `planes`
  ADD PRIMARY KEY (`id_plan`);

--
-- Indexes for table `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `nombre_rol` (`nombre_rol`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id_permiso`),
  ADD UNIQUE KEY `nombre_permiso` (`nombre_permiso`);

--
-- Indexes for table `role_permission`
--
ALTER TABLE `role_permission`
  ADD PRIMARY KEY (`id_rol`,`id_permiso`),
  ADD KEY `fk_rp_permiso` (`id_permiso`);

--
-- Indexes for table `rol_modulo_pagina`
--
ALTER TABLE `rol_modulo_pagina`
  ADD PRIMARY KEY (`id_rmp`),
  ADD UNIQUE KEY `uq_rol_pagina` (`id_rol`,`id_pagina`),
  ADD KEY `fk_rmp_rol` (`id_rol`),
  ADD KEY `fk_rmp_mod` (`id_modulo`),
  ADD KEY `fk_rmp_pag` (`id_pagina`);

--
-- Indexes for table `servicios`
--
ALTER TABLE `servicios`
  ADD PRIMARY KEY (`id_servicio`),
  ADD KEY `fk_srv_cliente` (`id_cliente`),
  ADD KEY `fk_srv_plan` (`id_plan`),
  ADD KEY `fk_srv_nap` (`id_naps`);

--
-- Indexes for table `sesiones`
--
ALTER TABLE `sesiones`
  ADD PRIMARY KEY (`id_sesion`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `fk_sesion_usuario` (`id_usuario`),
  ADD KEY `fk_sesion_credencial` (`id_credencial`);

--
-- Indexes for table `tareas`
--
ALTER TABLE `tareas`
  ADD PRIMARY KEY (`id_tarea`),
  ADD KEY `fk_tarea_cliente` (`id_cliente`),
  ADD KEY `fk_tarea_usuario` (`id_usuario_creador`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id_ticket`),
  ADD KEY `fk_ticket_cliente` (`id_cliente`),
  ADD KEY `fk_ticket_servicio` (`id_servicio`),
  ADD KEY `fk_ticket_usuario` (`id_usuario_creador`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `fk_usuario_rol` (`id_rol`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `clientes_credenciales`
--
ALTER TABLE `clientes_credenciales`
  MODIFY `id_credencial` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `configuracion_empresa`
--
ALTER TABLE `configuracion_empresa`
  MODIFY `id_config` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `contratos`
--
ALTER TABLE `contratos`
  MODIFY `id_contrato` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `equipos`
--
ALTER TABLE `equipos`
  MODIFY `id_equipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `facturas`
--
ALTER TABLE `facturas`
  MODIFY `id_factura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `logs`
--
ALTER TABLE `logs`
  MODIFY `id_log` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `modulos`
--
ALTER TABLE `modulos`
  MODIFY `id_modulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `naps`
--
ALTER TABLE `naps`
  MODIFY `id_nap` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `nodos`
--
ALTER TABLE `nodos`
  MODIFY `id_nodo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id_notificacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `olts`
--
ALTER TABLE `olts`
  MODIFY `id_olt` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `paginas`
--
ALTER TABLE `paginas`
  MODIFY `id_pagina` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id_pago` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `planes`
--
ALTER TABLE `planes`
  MODIFY `id_plan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `rol_modulo_pagina`
--
ALTER TABLE `rol_modulo_pagina`
  MODIFY `id_rmp` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=121;

--
-- AUTO_INCREMENT for table `servicios`
--
ALTER TABLE `servicios`
  MODIFY `id_servicio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `sesiones`
--
ALTER TABLE `sesiones`
  MODIFY `id_sesion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT for table `tareas`
--
ALTER TABLE `tareas`
  MODIFY `id_tarea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id_ticket` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `clientes_credenciales`
--
ALTER TABLE `clientes_credenciales`
  ADD CONSTRAINT `fk_credencial_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`);

--
-- Constraints for table `contratos`
--
ALTER TABLE `contratos`
  ADD CONSTRAINT `fk_contrato_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`);

--
-- Constraints for table `equipos`
--
ALTER TABLE `equipos`
  ADD CONSTRAINT `fk_equipo_nap` FOREIGN KEY (`id_naps`) REFERENCES `naps` (`id_nap`),
  ADD CONSTRAINT `fk_equipo_srv` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL;

--
-- Constraints for table `facturas`
--
ALTER TABLE `facturas`
  ADD CONSTRAINT `fk_factura_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`);

--
-- Constraints for table `logs`
--
ALTER TABLE `logs`
  ADD CONSTRAINT `fk_log_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL;

--
-- Constraints for table `naps`
--
ALTER TABLE `naps`
  ADD CONSTRAINT `fk_nap_olt` FOREIGN KEY (`id_olts`) REFERENCES `olts` (`id_olt`);

--
-- Constraints for table `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `fk_notif_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`);

--
-- Constraints for table `olts`
--
ALTER TABLE `olts`
  ADD CONSTRAINT `fk_olt_nodo` FOREIGN KEY (`id_nodos`) REFERENCES `nodos` (`id_nodo`);

--
-- Constraints for table `paginas`
--
ALTER TABLE `paginas`
  ADD CONSTRAINT `fk_pagina_modulo` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id_modulo`);

--
-- Constraints for table `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `fk_pago_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_pago_factura` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`),
  ADD CONSTRAINT `fk_pago_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`),
  ADD CONSTRAINT `fk_pago_usuario` FOREIGN KEY (`id_usuario_valido`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `role_permission`
--
ALTER TABLE `role_permission`
  ADD CONSTRAINT `fk_rp_permiso` FOREIGN KEY (`id_permiso`) REFERENCES `permissions` (`id_permiso`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rp_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE CASCADE;

--
-- Constraints for table `rol_modulo_pagina`
--
ALTER TABLE `rol_modulo_pagina`
  ADD CONSTRAINT `fk_rmp_mod` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id_modulo`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rmp_pag` FOREIGN KEY (`id_pagina`) REFERENCES `paginas` (`id_pagina`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rmp_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE CASCADE;

--
-- Constraints for table `servicios`
--
ALTER TABLE `servicios`
  ADD CONSTRAINT `fk_srv_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_srv_nap` FOREIGN KEY (`id_naps`) REFERENCES `naps` (`id_nap`),
  ADD CONSTRAINT `fk_srv_plan` FOREIGN KEY (`id_plan`) REFERENCES `planes` (`id_plan`);

--
-- Constraints for table `sesiones`
--
ALTER TABLE `sesiones`
  ADD CONSTRAINT `fk_sesion_credencial` FOREIGN KEY (`id_credencial`) REFERENCES `clientes_credenciales` (`id_credencial`),
  ADD CONSTRAINT `fk_sesion_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `tareas`
--
ALTER TABLE `tareas`
  ADD CONSTRAINT `fk_tarea_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_tarea_usuario` FOREIGN KEY (`id_usuario_creador`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `fk_ticket_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_ticket_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`),
  ADD CONSTRAINT `fk_ticket_usuario` FOREIGN KEY (`id_usuario_creador`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
