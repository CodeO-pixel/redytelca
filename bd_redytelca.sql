-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 14, 2026 at 02:21 AM
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
-- Table structure for table `categorias_ticket`
--

CREATE TABLE `categorias_ticket` (
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(60) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `color` char(7) NOT NULL DEFAULT '#104aa8',
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categorias_ticket`
--

INSERT INTO `categorias_ticket` (`id_categoria`, `nombre`, `descripcion`, `color`, `activa`, `creado_en`) VALUES
(1, 'Soporte técnico', 'Problemas de conectividad, velocidad o hardware', '#104aa8', 1, '2026-10-13 07:00:17'),
(2, 'Facturación', 'Consultas y reclamos de facturación o pagos', '#f59e0b', 1, '2026-10-13 07:00:17'),
(3, 'Instalación', 'Solicitudes de nueva instalación o traslado', '#16a34a', 1, '2026-10-13 07:00:17'),
(4, 'Baja de servicio', 'Solicitudes de cancelación o suspensión', '#dc2626', 1, '2026-10-13 07:00:17');

--
-- Triggers `categorias_ticket`
--
DELIMITER $$
CREATE TRIGGER `trg_categorias_ticket_audit_delete` AFTER DELETE ON `categorias_ticket` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','categorias_ticket',OLD.id_categoria,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_categoria',OLD.id_categoria,'nombre',OLD.nombre,'activa',OLD.activa));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_categorias_ticket_audit_insert` AFTER INSERT ON `categorias_ticket` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','categorias_ticket',NEW.id_categoria,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_categoria',NEW.id_categoria,'nombre',NEW.nombre,'activa',NEW.activa));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_categorias_ticket_audit_update` AFTER UPDATE ON `categorias_ticket` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','categorias_ticket',NEW.id_categoria,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_categoria',OLD.id_categoria,'nombre',OLD.nombre,'activa',OLD.activa),
          JSON_OBJECT('id_categoria',NEW.id_categoria,'nombre',NEW.nombre,'activa',NEW.activa));
END
$$
DELIMITER ;

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
  `fecha_registro` datetime DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado` enum('activo','suspendido','inactivo') NOT NULL DEFAULT 'activo',
  `segmento` varchar(30) DEFAULT NULL
) ;

--
-- Dumping data for table `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `nombres`, `apellidos`, `cedula`, `num_telefono`, `correo`, `fecha_registro`, `actualizado_en`, `estado`, `segmento`) VALUES
(1, 'marcelo', 'petronilo', '3192873', '0412-1234567', 'marcelo@gmail.com', '2026-07-10 23:41:47', '2026-10-13 05:37:24', 'activo', NULL),
(10, 'Juan', 'Pérez', 'V-12345678', '0412-1111111', 'juan@test.com', '2026-07-20 12:49:51', '2026-10-13 05:37:24', 'activo', NULL),
(11, 'María', 'González', 'E-87654321', '0412-2222222', 'maria@test.com', '2026-07-20 12:49:51', '2026-10-13 05:37:24', 'activo', NULL),
(12, 'Carlos', 'Rodríguez', 'V-11111111', '0412-3333333', 'carlos@test.com', '2026-07-20 12:49:51', '2026-10-13 05:37:24', 'activo', NULL),
(13, 'Ana', 'Martínez', 'V-22222222', '0412-4444444', 'ana@test.com', '2026-07-20 12:49:51', '2026-10-13 05:37:24', 'activo', NULL),
(17, 'Test', 'Bug', 'V-99999999', '0412-0000000', 'test@bug.com', '2026-10-11 17:45:26', '2026-10-13 05:37:24', 'activo', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `clientes_credenciales`
--

CREATE TABLE `clientes_credenciales` (
  `id_credencial` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `correo_recuperacion` varchar(80) DEFAULT NULL,
  `estado` enum('activa','suspendida') DEFAULT 'activa',
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0,
  `bloqueado_hasta` datetime DEFAULT NULL,
  `must_change_password` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `ultimo_acceso` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cliente_contactos`
--

CREATE TABLE `cliente_contactos` (
  `id_contacto` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `parentesco` varchar(50) DEFAULT NULL,
  `telefono` varchar(25) DEFAULT NULL,
  `correo` varchar(80) DEFAULT NULL,
  `es_principal` tinyint(1) NOT NULL DEFAULT 0,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `cliente_contactos`
--
DELIMITER $$
CREATE TRIGGER `trg_cliente_contactos_audit_delete` AFTER DELETE ON `cliente_contactos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','cliente_contactos',OLD.id_contacto,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_contacto',OLD.id_contacto,'id_cliente',OLD.id_cliente,'nombre',OLD.nombre,
                      'es_principal',OLD.es_principal));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_cliente_contactos_audit_insert` AFTER INSERT ON `cliente_contactos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','cliente_contactos',NEW.id_contacto,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_contacto',NEW.id_contacto,'id_cliente',NEW.id_cliente,'nombre',NEW.nombre,
                      'es_principal',NEW.es_principal));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_cliente_contactos_audit_update` AFTER UPDATE ON `cliente_contactos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','cliente_contactos',NEW.id_contacto,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_contacto',OLD.id_contacto,'id_cliente',OLD.id_cliente,'nombre',OLD.nombre,
                      'es_principal',OLD.es_principal),
          JSON_OBJECT('id_contacto',NEW.id_contacto,'id_cliente',NEW.id_cliente,'nombre',NEW.nombre,
                      'es_principal',NEW.es_principal));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cliente_etiquetas`
--

CREATE TABLE `cliente_etiquetas` (
  `id_cliente_etiqueta` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_etiqueta` int(11) NOT NULL,
  `asignada_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `cliente_etiquetas`
--
DELIMITER $$
CREATE TRIGGER `trg_cliente_etiquetas_audit_delete` AFTER DELETE ON `cliente_etiquetas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','cliente_etiquetas',OLD.id_cliente_etiqueta,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_cliente_etiqueta',OLD.id_cliente_etiqueta,'id_cliente',OLD.id_cliente,'id_etiqueta',OLD.id_etiqueta));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_cliente_etiquetas_audit_insert` AFTER INSERT ON `cliente_etiquetas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','cliente_etiquetas',NEW.id_cliente_etiqueta,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_cliente_etiqueta',NEW.id_cliente_etiqueta,'id_cliente',NEW.id_cliente,'id_etiqueta',NEW.id_etiqueta));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_cliente_etiquetas_audit_update` AFTER UPDATE ON `cliente_etiquetas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','cliente_etiquetas',NEW.id_cliente_etiqueta,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_cliente_etiqueta',OLD.id_cliente_etiqueta,'id_cliente',OLD.id_cliente,'id_etiqueta',OLD.id_etiqueta),
          JSON_OBJECT('id_cliente_etiqueta',NEW.id_cliente_etiqueta,'id_cliente',NEW.id_cliente,'id_etiqueta',NEW.id_etiqueta));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cliente_notas`
--

CREATE TABLE `cliente_notas` (
  `id_nota` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `contenido` text NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `cliente_notas`
--
DELIMITER $$
CREATE TRIGGER `trg_cliente_notas_audit_delete` AFTER DELETE ON `cliente_notas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','cliente_notas',OLD.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_usuario',OLD.id_usuario));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_cliente_notas_audit_insert` AFTER INSERT ON `cliente_notas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','cliente_notas',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_usuario',NEW.id_usuario));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_cliente_notas_audit_update` AFTER UPDATE ON `cliente_notas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','cliente_notas',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_usuario',OLD.id_usuario),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_usuario',NEW.id_usuario));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `configuracion_empresa`
--

CREATE TABLE `configuracion_empresa` (
  `id_config` int(11) NOT NULL,
  `nombre_empresa` varchar(100) NOT NULL DEFAULT '',
  `logo_path` varchar(255) DEFAULT NULL,
  `color_primario` char(7) DEFAULT '#104aa8',
  `impuesto_porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `dia_facturacion` tinyint(2) NOT NULL DEFAULT 1,
  `dias_gracia_mora` tinyint(2) NOT NULL DEFAULT 5,
  `monto_recargo_mora` decimal(10,2) NOT NULL DEFAULT 0.00,
  `dias_corte_automatico` tinyint(2) NOT NULL DEFAULT 10,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `configuracion_empresa`
--

INSERT INTO `configuracion_empresa` (`id_config`, `nombre_empresa`, `logo_path`, `color_primario`, `impuesto_porcentaje`, `dia_facturacion`, `dias_gracia_mora`, `monto_recargo_mora`, `dias_corte_automatico`, `creado_en`, `actualizado_en`) VALUES
(1, 'REDYTELCA', 'Logos/logo_transparent.png', '#104aa8', 0.00, 1, 5, 0.00, 10, '2026-10-12 19:38:26', '2026-10-12 22:18:57');

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
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `contratos`
--

INSERT INTO `contratos` (`id_contrato`, `id_servicio`, `fecha_inicio`, `fecha_fin`, `tipo_contrato`, `estado`, `observaciones`, `creado_en`, `actualizado_en`) VALUES
(1, 1, '2026-07-11', '2026-08-11', 'plazo_fijo', 'vencido', 'balans', '2026-07-11 19:34:54', '2026-10-13 05:44:11'),
(2, 4, '2026-07-11', '2026-08-11', 'plazo_fijo', 'vencido', 'mondongo', '2026-07-11 21:03:08', '2026-10-13 05:44:11'),
(10, 10, '2026-01-01', NULL, 'indefinido', 'vigente', NULL, '2026-07-20 16:49:51', '2026-10-13 05:44:11'),
(11, 11, '2026-02-01', '2026-12-31', 'plazo_fijo', 'vigente', 'Contrato anual', '2026-07-20 16:49:51', '2026-10-13 05:44:11'),
(12, 12, '2026-03-01', NULL, 'indefinido', 'vencido', 'Expirado por falta de pago', '2026-07-20 16:49:51', '2026-10-13 05:44:11'),
(15, 1, '2026-10-12', '2026-10-13', 'indefinido', 'vigente', NULL, '2026-10-12 19:56:20', '2026-10-13 22:21:02'),
(16, 12, '2026-10-12', '2026-10-12', 'indefinido', 'vencido', NULL, '2026-10-12 19:59:21', '2026-10-13 14:29:27');

--
-- Triggers `contratos`
--
DELIMITER $$
CREATE TRIGGER `trg_contratos_audit_delete` AFTER DELETE ON `contratos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','contratos',OLD.id_contrato,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_contrato',OLD.id_contrato,'id_servicio',OLD.id_servicio,
                      'fecha_inicio',OLD.fecha_inicio,'fecha_fin',OLD.fecha_fin,
                      'tipo_contrato',OLD.tipo_contrato,'estado',OLD.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_contratos_audit_insert` AFTER INSERT ON `contratos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','contratos',NEW.id_contrato,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_contrato',NEW.id_contrato,'id_servicio',NEW.id_servicio,
                      'fecha_inicio',NEW.fecha_inicio,'fecha_fin',NEW.fecha_fin,
                      'tipo_contrato',NEW.tipo_contrato,'estado',NEW.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_contratos_audit_update` AFTER UPDATE ON `contratos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','contratos',NEW.id_contrato,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_contrato',OLD.id_contrato,'id_servicio',OLD.id_servicio,
                      'fecha_inicio',OLD.fecha_inicio,'fecha_fin',OLD.fecha_fin,
                      'tipo_contrato',OLD.tipo_contrato,'estado',OLD.estado),
          JSON_OBJECT('id_contrato',NEW.id_contrato,'id_servicio',NEW.id_servicio,
                      'fecha_inicio',NEW.fecha_inicio,'fecha_fin',NEW.fecha_fin,
                      'tipo_contrato',NEW.tipo_contrato,'estado',NEW.estado));
END
$$
DELIMITER ;
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
DELIMITER $$
CREATE TRIGGER `trg_contratos_validar_insert` BEFORE INSERT ON `contratos` FOR EACH ROW BEGIN
  IF NEW.estado <> 'vigente' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'INSERT de contrato solo permite estado vigente. Use UPDATE para transicionar.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_contratos_validar_transicion` BEFORE UPDATE ON `contratos` FOR EACH ROW BEGIN
  DECLARE msg VARCHAR(255);
  IF NEW.estado <> OLD.estado AND NOT EXISTS (
    SELECT 1 FROM transicion_estado
     WHERE tabla = 'contratos' AND estado_origen = OLD.estado AND estado_destino = NEW.estado
  ) THEN
    SET msg = CONCAT('Transicion no permitida en contratos: ', OLD.estado, ' -> ', NEW.estado);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `email_log`
--

CREATE TABLE `email_log` (
  `id_email` int(11) NOT NULL,
  `id_plantilla` int(11) DEFAULT NULL,
  `destinatario` varchar(120) NOT NULL,
  `asunto` varchar(150) NOT NULL,
  `cuerpo` text DEFAULT NULL,
  `estado` enum('pendiente','enviado','fallido') NOT NULL DEFAULT 'pendiente',
  `error_mensaje` varchar(255) DEFAULT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `enviado_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `email_plantillas`
--

CREATE TABLE `email_plantillas` (
  `id_plantilla` int(11) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `asunto` varchar(150) NOT NULL,
  `cuerpo` text NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `email_plantillas`
--

INSERT INTO `email_plantillas` (`id_plantilla`, `codigo`, `asunto`, `cuerpo`, `descripcion`, `activa`, `creado_en`, `actualizado_en`) VALUES
(1, 'bienvenida', 'Bienvenido a REDYTELCA', 'Estimado cliente,\n\nGracias por confiar en nosotros.\n\nSaludos,\nREDYTELCA', 'Email de bienvenida al dar de alta un cliente', 1, '2026-10-13 07:00:17', '2026-10-13 07:00:17'),
(2, 'factura_emitida', 'Nueva factura disponible', 'Estimado cliente,\n\nSu factura del periodo {periodo} ha sido emitida.\n\nSaldo: {monto}\nVencimiento: {vencimiento}', 'Notificación de nueva factura', 1, '2026-10-13 07:00:17', '2026-10-13 07:00:17'),
(3, 'factura_vencida', 'Factura vencida', 'Estimado cliente,\n\nSu factura del periodo {periodo} está vencida.\n\nRegularice su pago para evitar la suspensión.', 'Recordatorio de factura vencida', 1, '2026-10-13 07:00:17', '2026-10-13 07:00:17'),
(4, 'pago_confirmado', 'Pago confirmado', 'Estimado cliente,\n\nSu pago de {monto} ha sido validado correctamente.', 'Confirmación de pago validado', 1, '2026-10-13 07:00:17', '2026-10-13 07:00:17'),
(5, 'ticket_cerrado', 'Ticket cerrado', 'Su ticket \"{asunto}\" ha sido cerrado.\n\nDetalle: {detalle}', 'Cierre de ticket', 1, '2026-10-13 07:00:17', '2026-10-13 07:00:17'),
(6, 'recuperar_password', 'Recuperar contraseña', 'Use el siguiente enlace para recuperar su contraseña: {link}', 'Recuperación de contraseña', 1, '2026-10-13 07:00:17', '2026-10-13 07:00:17');

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
  `numero_serie` varchar(100) DEFAULT NULL,
  `num_puerto_nap` smallint(5) NOT NULL,
  `estado_fisico` enum('operativo','averiado','stock') DEFAULT 'stock',
  `estado_inventario` enum('stock','asignado','devuelto','averiado','baja') DEFAULT 'stock',
  `fecha_asignacion` date DEFAULT NULL,
  `fecha_devolucion` date DEFAULT NULL,
  `id_naps` int(11) NOT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `propiedad` enum('cliente','empresa') NOT NULL DEFAULT 'empresa',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `equipos`
--

INSERT INTO `equipos` (`id_equipo`, `tipo`, `marca`, `modelo`, `direccion_mac`, `numero_serie`, `num_puerto_nap`, `estado_fisico`, `estado_inventario`, `fecha_asignacion`, `fecha_devolucion`, `id_naps`, `id_servicio`, `propiedad`, `creado_en`, `actualizado_en`) VALUES
(10, 'ONT', 'Huawei', 'HG8245', 'AA:BB:CC:DD:EE:10', NULL, 1, 'operativo', 'asignado', '2026-09-28', NULL, 10, 10, 'cliente', '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(11, 'ROUTER', 'Mikrotik', 'hAP ac2', 'AA:BB:CC:DD:EE:11', NULL, 2, 'operativo', 'asignado', '2026-09-28', NULL, 10, 11, 'empresa', '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(12, 'ONU', 'ZTE', 'F670L', 'AA:BB:CC:DD:EE:12', NULL, 1, 'stock', 'stock', NULL, NULL, 12, NULL, 'empresa', '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(16, 'ROUTER', 'a', 'b', 'AA:BB:CC:DD:EE:FF', NULL, 7, 'operativo', 'stock', NULL, NULL, 11, NULL, 'cliente', '2026-10-13 05:37:24', '2026-10-13 15:14:03'),
(18, 'ONU', 'a', 'b', 'AA:BB:CC:DD:EE:F2', NULL, 2, 'operativo', 'stock', NULL, NULL, 11, NULL, 'cliente', '2026-10-13 05:37:24', '2026-10-13 15:14:03');

-- --------------------------------------------------------

--
-- Table structure for table `equipo_movimientos`
--

CREATE TABLE `equipo_movimientos` (
  `id_movimiento` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL,
  `tipo` enum('alta_stock','asignacion','devolucion','baja','reparacion','reemplazo') NOT NULL,
  `estado_anterior` enum('stock','asignado','devuelto','averiado','baja') DEFAULT NULL,
  `estado_nuevo` enum('stock','asignado','devuelto','averiado','baja') NOT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `notas` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `equipo_movimientos`
--
DELIMITER $$
CREATE TRIGGER `trg_equipo_movimientos_audit_delete` AFTER DELETE ON `equipo_movimientos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','equipo_movimientos',OLD.id_movimiento,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_movimiento',OLD.id_movimiento,'id_equipo',OLD.id_equipo,'tipo',OLD.tipo,
                      'estado_anterior',OLD.estado_anterior,'estado_nuevo',OLD.estado_nuevo,'id_servicio',OLD.id_servicio));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_equipo_movimientos_audit_insert` AFTER INSERT ON `equipo_movimientos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','equipo_movimientos',NEW.id_movimiento,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_movimiento',NEW.id_movimiento,'id_equipo',NEW.id_equipo,'tipo',NEW.tipo,
                      'estado_anterior',NEW.estado_anterior,'estado_nuevo',NEW.estado_nuevo,'id_servicio',NEW.id_servicio));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_equipo_movimientos_audit_update` AFTER UPDATE ON `equipo_movimientos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','equipo_movimientos',NEW.id_movimiento,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_movimiento',OLD.id_movimiento,'id_equipo',OLD.id_equipo,'tipo',OLD.tipo,
                      'estado_anterior',OLD.estado_anterior,'estado_nuevo',OLD.estado_nuevo,'id_servicio',OLD.id_servicio),
          JSON_OBJECT('id_movimiento',NEW.id_movimiento,'id_equipo',NEW.id_equipo,'tipo',NEW.tipo,
                      'estado_anterior',NEW.estado_anterior,'estado_nuevo',NEW.estado_nuevo,'id_servicio',NEW.id_servicio));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `etiquetas`
--

CREATE TABLE `etiquetas` (
  `id_etiqueta` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `color` char(7) NOT NULL DEFAULT '#64748b',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `etiquetas`
--

INSERT INTO `etiquetas` (`id_etiqueta`, `nombre`, `color`, `creado_en`) VALUES
(1, 'VIP', '#f59e0b', '2026-10-13 07:00:17'),
(2, 'Moroso', '#dc2626', '2026-10-13 07:00:17'),
(3, 'Nuevo', '#16a34a', '2026-10-13 07:00:17'),
(4, 'Empresarial', '#104aa8', '2026-10-13 07:00:17'),
(5, 'Residencial', '#64748b', '2026-10-13 07:00:17');

-- --------------------------------------------------------

--
-- Table structure for table `facturas`
--

CREATE TABLE `facturas` (
  `id_factura` int(11) NOT NULL,
  `id_servicio` int(11) NOT NULL,
  `periodo` varchar(7) NOT NULL,
  `monto` decimal(10,2) NOT NULL COMMENT 'Monto en USD (precio de referencia del catálogo). Independiente de la moneda de presentación.',
  `moneda` varchar(3) NOT NULL DEFAULT 'USD' COMMENT 'Divisa de presentación fiscal. USD = factura en dólares; VES = factura en bolívares al cambio BCV.',
  `tasa_cambio` decimal(10,4) DEFAULT NULL COMMENT 'Tasa BCV (Bs/USD) al momento de emisión. Obligatoria si moneda=VES, NULL si moneda=USD.',
  `impuesto_aplicado` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Porcentaje congelado al emitir',
  `fecha_emision` date NOT NULL,
  `fecha_vencimiento` date NOT NULL,
  `estado` enum('pendiente','pagada','parcial','vencida','anulada') DEFAULT 'pendiente',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `facturas`
--

INSERT INTO `facturas` (`id_factura`, `id_servicio`, `periodo`, `monto`, `moneda`, `tasa_cambio`, `impuesto_aplicado`, `fecha_emision`, `fecha_vencimiento`, `estado`, `creado_en`, `actualizado_en`) VALUES
(10, 10, '2026-06', 31.00, 'USD', NULL, 0.00, '2026-06-01', '2026-06-20', 'pagada', '2026-07-20 16:49:51', '2026-10-13 21:36:34'),
(11, 10, '2026-07', 15.00, 'USD', NULL, 0.00, '2026-07-01', '2026-07-20', 'vencida', '2026-07-20 16:49:51', '2026-10-13 22:15:19'),
(12, 11, '2026-07', 45.00, 'USD', NULL, 0.00, '2026-07-01', '2026-07-25', 'vencida', '2026-07-20 16:49:51', '2026-09-25 23:26:01'),
(13, 12, '2026-06', 30.00, 'USD', NULL, 0.00, '2026-06-01', '2026-06-20', 'pagada', '2026-07-20 16:49:51', '2026-07-21 20:17:48'),
(15, 1, '2026-07', 3000.00, 'USD', NULL, 0.00, '2026-10-06', '2026-10-23', 'pendiente', '2026-10-06 22:16:40', '2026-10-06 22:16:40'),
(21, 13, '2026-01', 100.00, 'USD', NULL, 0.00, '2026-10-13', '2026-10-20', 'pendiente', '2026-10-13 16:20:19', '2026-10-13 16:20:19'),
(22, 13, '2026-03', 100.00, 'VES', 36.5000, 0.00, '2026-10-13', '2026-10-21', 'pendiente', '2026-10-13 16:24:36', '2026-10-13 16:24:36'),
(23, 13, '2028-01', 30.00, 'USD', NULL, 0.00, '2026-10-13', '2026-10-20', 'parcial', '2026-10-13 16:51:43', '2026-10-13 21:19:17'),
(24, 1, '2026-04', 30.00, 'VES', 760.0003, 0.00, '2026-10-13', '2026-10-29', 'pendiente', '2026-10-13 17:11:47', '2026-10-13 17:11:47');

--
-- Triggers `facturas`
--
DELIMITER $$
CREATE TRIGGER `trg_facturas_audit_delete` AFTER DELETE ON `facturas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','facturas',OLD.id_factura,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_factura',OLD.id_factura,'id_servicio',OLD.id_servicio,'periodo',OLD.periodo,
                      'monto',OLD.monto,'estado',OLD.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_facturas_audit_insert` AFTER INSERT ON `facturas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','facturas',NEW.id_factura,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_factura',NEW.id_factura,'id_servicio',NEW.id_servicio,'periodo',NEW.periodo,
                      'monto',NEW.monto,'estado',NEW.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_facturas_audit_update` AFTER UPDATE ON `facturas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','facturas',NEW.id_factura,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_factura',OLD.id_factura,'id_servicio',OLD.id_servicio,'periodo',OLD.periodo,
                      'monto',OLD.monto,'estado',OLD.estado),
          JSON_OBJECT('id_factura',NEW.id_factura,'id_servicio',NEW.id_servicio,'periodo',NEW.periodo,
                      'monto',NEW.monto,'estado',NEW.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_facturas_validar_insert` BEFORE INSERT ON `facturas` FOR EACH ROW BEGIN
  IF NEW.estado <> 'pendiente' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'INSERT de factura solo permite estado pendiente. Use UPDATE para transicionar.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_facturas_validar_transicion` BEFORE UPDATE ON `facturas` FOR EACH ROW BEGIN
  DECLARE msg VARCHAR(255);
  IF NEW.estado <> OLD.estado AND NOT EXISTS (
    SELECT 1 FROM transicion_estado
     WHERE tabla = 'facturas' AND estado_origen = OLD.estado AND estado_destino = NEW.estado
  ) THEN
    SET msg = CONCAT('Transicion no permitida en facturas: ', OLD.estado, ' -> ', NEW.estado);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `factura_lineas`
--

CREATE TABLE `factura_lineas` (
  `id_linea` int(11) NOT NULL,
  `id_factura` int(11) NOT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `concepto` varchar(100) NOT NULL,
  `cantidad` decimal(10,2) NOT NULL DEFAULT 1.00,
  `precio_unitario` decimal(10,2) NOT NULL,
  `monto_linea` decimal(10,2) NOT NULL,
  `impuesto_porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `impuesto_monto` decimal(10,2) NOT NULL DEFAULT 0.00,
  `descuento_monto` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_linea` decimal(10,2) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `factura_lineas`
--

INSERT INTO `factura_lineas` (`id_linea`, `id_factura`, `id_servicio`, `concepto`, `cantidad`, `precio_unitario`, `monto_linea`, `impuesto_porcentaje`, `impuesto_monto`, `descuento_monto`, `total_linea`, `creado_en`) VALUES
(1, 10, NULL, 'Servicio periodo 2026-06', 1.00, 20.00, 20.00, 0.00, 0.00, 0.00, 20.00, '2026-10-05 15:09:33'),
(2, 11, NULL, 'Servicio periodo 2026-07', 1.00, 15.00, 15.00, 0.00, 0.00, 0.00, 15.00, '2026-10-05 15:09:33'),
(3, 12, NULL, 'Servicio periodo 2026-07', 1.00, 45.00, 45.00, 0.00, 0.00, 0.00, 45.00, '2026-10-05 15:09:33'),
(4, 13, NULL, 'Servicio periodo 2026-06', 1.00, 30.00, 30.00, 0.00, 0.00, 0.00, 30.00, '2026-10-05 15:09:33');

-- --------------------------------------------------------

--
-- Table structure for table `ip_asignaciones`
--

CREATE TABLE `ip_asignaciones` (
  `id_asignacion` int(11) NOT NULL,
  `id_servicio` int(11) NOT NULL,
  `id_pool` int(11) NOT NULL,
  `ip` varchar(45) NOT NULL,
  `tipo` enum('estatica','pppoe') NOT NULL DEFAULT 'estatica',
  `estado` enum('activa','liberada','reservada') NOT NULL DEFAULT 'activa',
  `asignada_en` datetime NOT NULL DEFAULT current_timestamp(),
  `liberada_en` datetime DEFAULT NULL,
  `notas` varchar(255) DEFAULT NULL,
  `ip_activa` varchar(45) GENERATED ALWAYS AS (case when `estado` = 'activa' then `ip` else NULL end) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ip_pools`
--

CREATE TABLE `ip_pools` (
  `id_pool` int(11) NOT NULL,
  `nombre` varchar(60) NOT NULL,
  `cidr` varchar(43) NOT NULL,
  `gateway` varchar(45) DEFAULT NULL,
  `vlan` smallint(6) DEFAULT NULL,
  `id_nodo` int(11) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `logs`
--

CREATE TABLE `logs` (
  `id_log` bigint(20) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `accion` enum('INSERT','UPDATE','DELETE','LOGIN','LOGOUT','LOGIN_FALLIDO') NOT NULL,
  `tabla_afectada` varchar(50) DEFAULT NULL,
  `id_registro_afectado` int(11) DEFAULT NULL,
  `tipo_actor` enum('staff','cliente','sistema') NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_credencial` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `old_value` longtext DEFAULT NULL CHECK (json_valid(`old_value`)),
  `new_value` longtext DEFAULT NULL CHECK (json_valid(`new_value`))
) ;

--
-- Dumping data for table `logs`
--

INSERT INTO `logs` (`id_log`, `creado_en`, `accion`, `tabla_afectada`, `id_registro_afectado`, `tipo_actor`, `id_usuario`, `id_credencial`, `ip_address`, `old_value`, `new_value`) VALUES
(1, '2026-09-28 18:17:48', 'UPDATE', 'facturas', 11, 'sistema', NULL, NULL, NULL, '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"vencida\"}', '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"anulada\"}'),
(2, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 1, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 1, \"id_rol_modulo\": 1, \"id_pagina\": 1, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 1, \"id_rol_modulo\": 1, \"id_pagina\": 1, \"id_permiso\": 2}'),
(3, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 2, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 2, \"id_rol_modulo\": 1, \"id_pagina\": 1, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 2, \"id_rol_modulo\": 1, \"id_pagina\": 1, \"id_permiso\": 3}'),
(4, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 3, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 3, \"id_rol_modulo\": 1, \"id_pagina\": 1, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 3, \"id_rol_modulo\": 1, \"id_pagina\": 1, \"id_permiso\": 4}'),
(5, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 4, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 4, \"id_rol_modulo\": 1, \"id_pagina\": 1, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 4, \"id_rol_modulo\": 1, \"id_pagina\": 1, \"id_permiso\": 1}'),
(6, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 69, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 69, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 69, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 2}'),
(7, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 70, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 70, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 70, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 3}'),
(8, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 71, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 71, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 71, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 4}'),
(9, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 72, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 72, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 72, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 1}'),
(10, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 5, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 5, \"id_rol_modulo\": 2, \"id_pagina\": 2, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 5, \"id_rol_modulo\": 2, \"id_pagina\": 2, \"id_permiso\": 2}'),
(11, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 6, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 6, \"id_rol_modulo\": 2, \"id_pagina\": 2, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 6, \"id_rol_modulo\": 2, \"id_pagina\": 2, \"id_permiso\": 3}'),
(12, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 7, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 7, \"id_rol_modulo\": 2, \"id_pagina\": 2, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 7, \"id_rol_modulo\": 2, \"id_pagina\": 2, \"id_permiso\": 4}'),
(13, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 8, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 8, \"id_rol_modulo\": 2, \"id_pagina\": 2, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 8, \"id_rol_modulo\": 2, \"id_pagina\": 2, \"id_permiso\": 1}'),
(14, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 73, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 73, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 73, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 2}'),
(15, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 74, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 74, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 74, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 3}'),
(16, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 75, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 75, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 75, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 4}'),
(17, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 76, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 76, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 76, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 1}'),
(18, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 9, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 9, \"id_rol_modulo\": 2, \"id_pagina\": 3, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 9, \"id_rol_modulo\": 2, \"id_pagina\": 3, \"id_permiso\": 2}'),
(19, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 10, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 10, \"id_rol_modulo\": 2, \"id_pagina\": 3, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 10, \"id_rol_modulo\": 2, \"id_pagina\": 3, \"id_permiso\": 3}'),
(20, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 11, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 11, \"id_rol_modulo\": 2, \"id_pagina\": 3, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 11, \"id_rol_modulo\": 2, \"id_pagina\": 3, \"id_permiso\": 4}'),
(21, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 12, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 12, \"id_rol_modulo\": 2, \"id_pagina\": 3, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 12, \"id_rol_modulo\": 2, \"id_pagina\": 3, \"id_permiso\": 1}'),
(22, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 77, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 77, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 77, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 2}'),
(23, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 78, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 78, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 78, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 3}'),
(24, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 79, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 79, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 79, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 4}'),
(25, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 80, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 80, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 80, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 1}'),
(26, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 13, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 13, \"id_rol_modulo\": 3, \"id_pagina\": 4, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 13, \"id_rol_modulo\": 3, \"id_pagina\": 4, \"id_permiso\": 2}'),
(27, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 14, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 14, \"id_rol_modulo\": 3, \"id_pagina\": 4, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 14, \"id_rol_modulo\": 3, \"id_pagina\": 4, \"id_permiso\": 3}'),
(28, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 15, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 15, \"id_rol_modulo\": 3, \"id_pagina\": 4, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 15, \"id_rol_modulo\": 3, \"id_pagina\": 4, \"id_permiso\": 4}'),
(29, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 16, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 16, \"id_rol_modulo\": 3, \"id_pagina\": 4, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 16, \"id_rol_modulo\": 3, \"id_pagina\": 4, \"id_permiso\": 1}'),
(30, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 81, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 81, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 81, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 2}'),
(31, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 82, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 82, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 82, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 3}'),
(32, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 83, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 83, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 83, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 4}'),
(33, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 84, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 84, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 84, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 1}'),
(34, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 17, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 17, \"id_rol_modulo\": 3, \"id_pagina\": 5, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 17, \"id_rol_modulo\": 3, \"id_pagina\": 5, \"id_permiso\": 2}'),
(35, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 18, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 18, \"id_rol_modulo\": 3, \"id_pagina\": 5, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 18, \"id_rol_modulo\": 3, \"id_pagina\": 5, \"id_permiso\": 3}'),
(36, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 19, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 19, \"id_rol_modulo\": 3, \"id_pagina\": 5, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 19, \"id_rol_modulo\": 3, \"id_pagina\": 5, \"id_permiso\": 4}'),
(37, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 20, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 20, \"id_rol_modulo\": 3, \"id_pagina\": 5, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 20, \"id_rol_modulo\": 3, \"id_pagina\": 5, \"id_permiso\": 1}'),
(38, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 85, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 85, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 85, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 2}'),
(39, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 86, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 86, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 86, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 3}'),
(40, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 87, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 87, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 87, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 4}'),
(41, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 88, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 88, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 88, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 1}'),
(42, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 21, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 21, \"id_rol_modulo\": 3, \"id_pagina\": 6, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 21, \"id_rol_modulo\": 3, \"id_pagina\": 6, \"id_permiso\": 2}'),
(43, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 22, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 22, \"id_rol_modulo\": 3, \"id_pagina\": 6, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 22, \"id_rol_modulo\": 3, \"id_pagina\": 6, \"id_permiso\": 3}'),
(44, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 23, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 23, \"id_rol_modulo\": 3, \"id_pagina\": 6, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 23, \"id_rol_modulo\": 3, \"id_pagina\": 6, \"id_permiso\": 4}'),
(45, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 24, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 24, \"id_rol_modulo\": 3, \"id_pagina\": 6, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 24, \"id_rol_modulo\": 3, \"id_pagina\": 6, \"id_permiso\": 1}'),
(46, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 89, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 89, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 89, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 2}'),
(47, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 90, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 90, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 90, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 3}'),
(48, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 91, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 91, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 91, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 4}'),
(49, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 92, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 92, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 92, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 1}'),
(50, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 93, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 93, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 93, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 2}'),
(51, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 94, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 94, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 94, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 3}'),
(52, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 95, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 95, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 95, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 4}'),
(53, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 96, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 96, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 96, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 1}'),
(54, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 97, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 97, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 97, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 2}'),
(55, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 98, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 98, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 98, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 3}'),
(56, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 99, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 99, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 99, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 4}'),
(57, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 100, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 100, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 100, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 1}'),
(58, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 25, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 25, \"id_rol_modulo\": 4, \"id_pagina\": 9, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 25, \"id_rol_modulo\": 4, \"id_pagina\": 9, \"id_permiso\": 2}'),
(59, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 26, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 26, \"id_rol_modulo\": 4, \"id_pagina\": 9, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 26, \"id_rol_modulo\": 4, \"id_pagina\": 9, \"id_permiso\": 3}'),
(60, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 27, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 27, \"id_rol_modulo\": 4, \"id_pagina\": 9, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 27, \"id_rol_modulo\": 4, \"id_pagina\": 9, \"id_permiso\": 4}'),
(61, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 28, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 28, \"id_rol_modulo\": 4, \"id_pagina\": 9, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 28, \"id_rol_modulo\": 4, \"id_pagina\": 9, \"id_permiso\": 1}'),
(62, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 101, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 101, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 101, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 2}'),
(63, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 102, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 102, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 102, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 3}'),
(64, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 103, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 103, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 103, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 4}'),
(65, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 104, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 104, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 104, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 1}'),
(66, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 105, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 105, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 105, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 2}'),
(67, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 106, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 106, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 106, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 3}'),
(68, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 107, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 107, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 107, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 4}'),
(69, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 108, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 108, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 108, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 1}'),
(70, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 29, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 29, \"id_rol_modulo\": 5, \"id_pagina\": 11, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 29, \"id_rol_modulo\": 5, \"id_pagina\": 11, \"id_permiso\": 2}'),
(71, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 30, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 30, \"id_rol_modulo\": 5, \"id_pagina\": 11, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 30, \"id_rol_modulo\": 5, \"id_pagina\": 11, \"id_permiso\": 3}'),
(72, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 31, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 31, \"id_rol_modulo\": 5, \"id_pagina\": 11, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 31, \"id_rol_modulo\": 5, \"id_pagina\": 11, \"id_permiso\": 4}'),
(73, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 32, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 32, \"id_rol_modulo\": 5, \"id_pagina\": 11, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 32, \"id_rol_modulo\": 5, \"id_pagina\": 11, \"id_permiso\": 1}'),
(74, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 109, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 109, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 109, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 2}'),
(75, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 110, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 110, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 110, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 3}'),
(76, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 111, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 111, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 111, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 4}'),
(77, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 112, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 112, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 112, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 1}'),
(78, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 33, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 33, \"id_rol_modulo\": 6, \"id_pagina\": 12, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 33, \"id_rol_modulo\": 6, \"id_pagina\": 12, \"id_permiso\": 2}'),
(79, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 34, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 34, \"id_rol_modulo\": 6, \"id_pagina\": 12, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 34, \"id_rol_modulo\": 6, \"id_pagina\": 12, \"id_permiso\": 3}'),
(80, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 35, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 35, \"id_rol_modulo\": 6, \"id_pagina\": 12, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 35, \"id_rol_modulo\": 6, \"id_pagina\": 12, \"id_permiso\": 4}'),
(81, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 36, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 36, \"id_rol_modulo\": 6, \"id_pagina\": 12, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 36, \"id_rol_modulo\": 6, \"id_pagina\": 12, \"id_permiso\": 1}'),
(82, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 113, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 113, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 113, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 2}'),
(83, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 114, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 114, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 114, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 3}'),
(84, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 115, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 115, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 115, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 4}'),
(85, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 116, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 116, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 116, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 1}'),
(86, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 37, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 37, \"id_rol_modulo\": 6, \"id_pagina\": 13, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 37, \"id_rol_modulo\": 6, \"id_pagina\": 13, \"id_permiso\": 2}'),
(87, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 38, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 38, \"id_rol_modulo\": 6, \"id_pagina\": 13, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 38, \"id_rol_modulo\": 6, \"id_pagina\": 13, \"id_permiso\": 3}'),
(88, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 39, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 39, \"id_rol_modulo\": 6, \"id_pagina\": 13, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 39, \"id_rol_modulo\": 6, \"id_pagina\": 13, \"id_permiso\": 4}'),
(89, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 40, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 40, \"id_rol_modulo\": 6, \"id_pagina\": 13, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 40, \"id_rol_modulo\": 6, \"id_pagina\": 13, \"id_permiso\": 1}'),
(90, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 117, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 117, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 117, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 2}'),
(91, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 118, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 118, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 118, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 3}'),
(92, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 119, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 119, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 119, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 4}'),
(93, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 120, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 120, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 120, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 1}'),
(94, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 41, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 41, \"id_rol_modulo\": 6, \"id_pagina\": 14, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 41, \"id_rol_modulo\": 6, \"id_pagina\": 14, \"id_permiso\": 2}'),
(95, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 42, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 42, \"id_rol_modulo\": 6, \"id_pagina\": 14, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 42, \"id_rol_modulo\": 6, \"id_pagina\": 14, \"id_permiso\": 3}'),
(96, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 43, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 43, \"id_rol_modulo\": 6, \"id_pagina\": 14, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 43, \"id_rol_modulo\": 6, \"id_pagina\": 14, \"id_permiso\": 4}'),
(97, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 44, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 44, \"id_rol_modulo\": 6, \"id_pagina\": 14, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 44, \"id_rol_modulo\": 6, \"id_pagina\": 14, \"id_permiso\": 1}'),
(98, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 121, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 121, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 121, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 2}'),
(99, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 122, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 122, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 122, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 3}'),
(100, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 123, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 123, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 123, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 4}'),
(101, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 124, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 124, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 124, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 1}'),
(102, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 45, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 45, \"id_rol_modulo\": 6, \"id_pagina\": 20, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 45, \"id_rol_modulo\": 6, \"id_pagina\": 20, \"id_permiso\": 2}'),
(103, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 46, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 46, \"id_rol_modulo\": 6, \"id_pagina\": 20, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 46, \"id_rol_modulo\": 6, \"id_pagina\": 20, \"id_permiso\": 3}'),
(104, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 47, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 47, \"id_rol_modulo\": 6, \"id_pagina\": 20, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 47, \"id_rol_modulo\": 6, \"id_pagina\": 20, \"id_permiso\": 4}'),
(105, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 48, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 48, \"id_rol_modulo\": 6, \"id_pagina\": 20, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 48, \"id_rol_modulo\": 6, \"id_pagina\": 20, \"id_permiso\": 1}'),
(106, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 125, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 125, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 125, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 2}'),
(107, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 126, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 126, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 126, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 3}'),
(108, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 127, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 127, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 127, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 4}'),
(109, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 128, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 128, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 128, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 1}'),
(110, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 49, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 49, \"id_rol_modulo\": 7, \"id_pagina\": 15, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 49, \"id_rol_modulo\": 7, \"id_pagina\": 15, \"id_permiso\": 2}'),
(111, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 50, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 50, \"id_rol_modulo\": 7, \"id_pagina\": 15, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 50, \"id_rol_modulo\": 7, \"id_pagina\": 15, \"id_permiso\": 3}'),
(112, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 51, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 51, \"id_rol_modulo\": 7, \"id_pagina\": 15, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 51, \"id_rol_modulo\": 7, \"id_pagina\": 15, \"id_permiso\": 4}'),
(113, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 52, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 52, \"id_rol_modulo\": 7, \"id_pagina\": 15, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 52, \"id_rol_modulo\": 7, \"id_pagina\": 15, \"id_permiso\": 1}'),
(114, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 129, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 129, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 129, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 2}'),
(115, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 130, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 130, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 130, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 3}'),
(116, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 131, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 131, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 131, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 4}'),
(117, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 132, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 132, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 132, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 1}'),
(118, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 53, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 53, \"id_rol_modulo\": 7, \"id_pagina\": 16, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 53, \"id_rol_modulo\": 7, \"id_pagina\": 16, \"id_permiso\": 2}'),
(119, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 54, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 54, \"id_rol_modulo\": 7, \"id_pagina\": 16, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 54, \"id_rol_modulo\": 7, \"id_pagina\": 16, \"id_permiso\": 3}'),
(120, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 55, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 55, \"id_rol_modulo\": 7, \"id_pagina\": 16, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 55, \"id_rol_modulo\": 7, \"id_pagina\": 16, \"id_permiso\": 4}'),
(121, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 56, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 56, \"id_rol_modulo\": 7, \"id_pagina\": 16, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 56, \"id_rol_modulo\": 7, \"id_pagina\": 16, \"id_permiso\": 1}'),
(122, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 133, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 133, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 133, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 2}'),
(123, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 134, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 134, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 134, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 3}'),
(124, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 135, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 135, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 135, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 4}'),
(125, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 136, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 136, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 136, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 1}'),
(126, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 57, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 57, \"id_rol_modulo\": 7, \"id_pagina\": 17, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 57, \"id_rol_modulo\": 7, \"id_pagina\": 17, \"id_permiso\": 2}'),
(127, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 58, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 58, \"id_rol_modulo\": 7, \"id_pagina\": 17, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 58, \"id_rol_modulo\": 7, \"id_pagina\": 17, \"id_permiso\": 3}'),
(128, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 59, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 59, \"id_rol_modulo\": 7, \"id_pagina\": 17, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 59, \"id_rol_modulo\": 7, \"id_pagina\": 17, \"id_permiso\": 4}'),
(129, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 60, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 60, \"id_rol_modulo\": 7, \"id_pagina\": 17, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 60, \"id_rol_modulo\": 7, \"id_pagina\": 17, \"id_permiso\": 1}'),
(130, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 137, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 137, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 137, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 2}'),
(131, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 138, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 138, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 138, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 3}'),
(132, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 139, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 139, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 139, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 4}'),
(133, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 140, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 140, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 140, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 1}'),
(134, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 61, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 61, \"id_rol_modulo\": 7, \"id_pagina\": 18, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 61, \"id_rol_modulo\": 7, \"id_pagina\": 18, \"id_permiso\": 2}'),
(135, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 62, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 62, \"id_rol_modulo\": 7, \"id_pagina\": 18, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 62, \"id_rol_modulo\": 7, \"id_pagina\": 18, \"id_permiso\": 3}'),
(136, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 63, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 63, \"id_rol_modulo\": 7, \"id_pagina\": 18, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 63, \"id_rol_modulo\": 7, \"id_pagina\": 18, \"id_permiso\": 4}'),
(137, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 64, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 64, \"id_rol_modulo\": 7, \"id_pagina\": 18, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 64, \"id_rol_modulo\": 7, \"id_pagina\": 18, \"id_permiso\": 1}'),
(138, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 141, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 141, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 141, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 2}'),
(139, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 142, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 142, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 142, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 3}'),
(140, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 143, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 143, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 143, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 4}'),
(141, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 144, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 144, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 144, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 1}'),
(142, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 65, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 65, \"id_rol_modulo\": 7, \"id_pagina\": 19, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 65, \"id_rol_modulo\": 7, \"id_pagina\": 19, \"id_permiso\": 2}'),
(143, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 66, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 66, \"id_rol_modulo\": 7, \"id_pagina\": 19, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 66, \"id_rol_modulo\": 7, \"id_pagina\": 19, \"id_permiso\": 3}'),
(144, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 67, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 67, \"id_rol_modulo\": 7, \"id_pagina\": 19, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 67, \"id_rol_modulo\": 7, \"id_pagina\": 19, \"id_permiso\": 4}'),
(145, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 68, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 68, \"id_rol_modulo\": 7, \"id_pagina\": 19, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 68, \"id_rol_modulo\": 7, \"id_pagina\": 19, \"id_permiso\": 1}'),
(146, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 145, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 145, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 2}', '{\"id_rol_modulo_permiso\": 145, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 2}'),
(147, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 146, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 146, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 3}', '{\"id_rol_modulo_permiso\": 146, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 3}'),
(148, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 147, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 147, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 4}', '{\"id_rol_modulo_permiso\": 147, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 4}'),
(149, '2026-09-28 20:07:49', 'UPDATE', 'rol_modulo_permiso', 148, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 148, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 1}', '{\"id_rol_modulo_permiso\": 148, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 1}'),
(150, '2026-09-28 22:15:05', 'UPDATE', 'facturas', 10, 'sistema', NULL, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 15.00, \"estado\": \"pagada\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 20.00, \"estado\": \"pagada\"}'),
(151, '2026-10-05 02:56:35', 'UPDATE', 'usuario_rol', 0, 'sistema', NULL, NULL, NULL, NULL, '{\"migracion\": \"001a-rbac-migracion-esquema\", \"filas_usuario_rol_final\": 3}'),
(152, '2026-10-05 02:56:36', 'UPDATE', 'usuario_rol', 0, 'sistema', NULL, NULL, NULL, NULL, '{\"migracion\": \"001a-rbac-migracion-esquema\", \"estado\": \"completada\", \"tablas_eliminadas\": [\"sesion_rol_activo\", \"rol_modulo_pagina\"], \"columnas_eliminadas\": [\"usuarios.id_rol\"]}'),
(153, '2026-10-05 02:57:07', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(154, '2026-10-05 02:57:07', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(155, '2026-10-05 02:57:07', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(156, '2026-10-05 03:14:13', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(157, '2026-10-05 03:14:13', 'INSERT', 'sesiones', 104, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 104, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 05:14:13\"}'),
(158, '2026-10-05 03:17:34', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(159, '2026-10-05 03:17:34', 'INSERT', 'sesiones', 105, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 105, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 05:17:34\"}'),
(160, '2026-10-05 03:27:59', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(161, '2026-10-05 03:28:02', 'INSERT', 'sesiones', 106, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 106, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 05:28:02\"}'),
(162, '2026-10-05 03:31:16', 'INSERT', 'usuarios', 4, 'sistema', NULL, NULL, NULL, NULL, '{\"id_usuario\": 4, \"username\": \"a\", \"email\": \"a@gamil.com\", \"estado\": \"Activo\", \"email_verified\": 0}'),
(163, '2026-10-05 03:31:16', 'INSERT', 'usuario_rol', 5, 'sistema', NULL, NULL, NULL, NULL, '{\"id_usuario_rol\": 5, \"id_usuario\": 4, \"id_rol\": 2}'),
(164, '2026-10-05 03:31:25', 'DELETE', 'usuario_rol', 5, 'sistema', NULL, NULL, NULL, '{\"id_usuario_rol\": 5, \"id_usuario\": 4, \"id_rol\": 2}', NULL),
(165, '2026-10-05 03:31:25', 'DELETE', 'usuarios', 4, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 4, \"username\": \"a\", \"email\": \"a@gamil.com\", \"estado\": \"Activo\"}', NULL),
(166, '2026-10-05 03:45:27', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(167, '2026-10-05 03:45:28', 'INSERT', 'sesiones', 107, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 107, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 05:45:28\"}'),
(168, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 69, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 69, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 2}', NULL),
(169, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 70, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 70, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 3}', NULL),
(170, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 71, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 71, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 4}', NULL),
(171, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 72, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 72, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 1}', NULL),
(172, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 73, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 73, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 2}', NULL),
(173, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 74, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 74, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 3}', NULL),
(174, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 75, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 75, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 4}', NULL),
(175, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 76, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 76, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 1}', NULL),
(176, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 77, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 77, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 2}', NULL),
(177, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 78, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 78, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 3}', NULL),
(178, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 79, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 79, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 4}', NULL),
(179, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 80, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 80, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 1}', NULL);
INSERT INTO `logs` (`id_log`, `creado_en`, `accion`, `tabla_afectada`, `id_registro_afectado`, `tipo_actor`, `id_usuario`, `id_credencial`, `ip_address`, `old_value`, `new_value`) VALUES
(180, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 81, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 81, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 2}', NULL),
(181, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 82, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 82, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 3}', NULL),
(182, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 83, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 83, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 4}', NULL),
(183, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 84, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 84, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 1}', NULL),
(184, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 85, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 85, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 2}', NULL),
(185, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 86, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 86, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 3}', NULL),
(186, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 87, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 87, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 4}', NULL),
(187, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 88, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 88, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 1}', NULL),
(188, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 89, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 89, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 2}', NULL),
(189, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 90, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 90, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 3}', NULL),
(190, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 91, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 91, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 4}', NULL),
(191, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 92, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 92, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 1}', NULL),
(192, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 93, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 93, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 2}', NULL),
(193, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 94, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 94, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 3}', NULL),
(194, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 95, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 95, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 4}', NULL),
(195, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 96, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 96, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 1}', NULL),
(196, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 97, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 97, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 2}', NULL),
(197, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 98, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 98, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 3}', NULL),
(198, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 99, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 99, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 4}', NULL),
(199, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 100, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 100, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 1}', NULL),
(200, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 101, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 101, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 2}', NULL),
(201, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 102, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 102, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 3}', NULL),
(202, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 103, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 103, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 4}', NULL),
(203, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 104, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 104, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 1}', NULL),
(204, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 105, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 105, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 2}', NULL),
(205, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 106, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 106, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 3}', NULL),
(206, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 107, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 107, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 4}', NULL),
(207, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 108, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 108, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 1}', NULL),
(208, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 109, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 109, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 2}', NULL),
(209, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 110, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 110, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 3}', NULL),
(210, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 111, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 111, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 4}', NULL),
(211, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 112, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 112, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 1}', NULL),
(212, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 113, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 113, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 2}', NULL),
(213, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 114, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 114, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 3}', NULL),
(214, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 115, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 115, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 4}', NULL),
(215, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 116, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 116, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 1}', NULL),
(216, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 117, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 117, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 2}', NULL),
(217, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 118, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 118, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 3}', NULL),
(218, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 119, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 119, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 4}', NULL),
(219, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 120, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 120, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 1}', NULL),
(220, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 121, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 121, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 2}', NULL),
(221, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 122, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 122, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 3}', NULL),
(222, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 123, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 123, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 4}', NULL),
(223, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 124, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 124, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 1}', NULL),
(224, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 125, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 125, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 2}', NULL),
(225, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 126, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 126, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 3}', NULL),
(226, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 127, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 127, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 4}', NULL),
(227, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 128, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 128, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 1}', NULL),
(228, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 129, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 129, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 2}', NULL),
(229, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 130, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 130, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 3}', NULL),
(230, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 131, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 131, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 4}', NULL),
(231, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 132, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 132, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 1}', NULL),
(232, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 133, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 133, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 2}', NULL),
(233, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 134, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 134, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 3}', NULL),
(234, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 135, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 135, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 4}', NULL),
(235, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 136, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 136, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 1}', NULL),
(236, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 137, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 137, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 2}', NULL),
(237, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 138, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 138, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 3}', NULL),
(238, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 139, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 139, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 4}', NULL),
(239, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 140, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 140, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 1}', NULL),
(240, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 141, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 141, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 2}', NULL),
(241, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 142, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 142, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 3}', NULL),
(242, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 143, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 143, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 4}', NULL),
(243, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 144, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 144, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 1}', NULL),
(244, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 145, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 145, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 2}', NULL),
(245, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 146, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 146, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 3}', NULL),
(246, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 147, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 147, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 4}', NULL),
(247, '2026-10-05 03:46:50', 'DELETE', 'rol_modulo_permiso', 148, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 148, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 1}', NULL),
(248, '2026-10-05 03:46:53', 'INSERT', 'rol_modulo_permiso', 258, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 258, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 2}'),
(249, '2026-10-05 03:47:00', 'INSERT', 'rol_modulo_permiso', 259, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 259, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 3}'),
(250, '2026-10-05 03:47:00', 'INSERT', 'rol_modulo_permiso', 260, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 260, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 4}'),
(251, '2026-10-05 03:47:00', 'INSERT', 'rol_modulo_permiso', 261, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 261, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 1}'),
(252, '2026-10-05 03:47:00', 'INSERT', 'rol_modulo_permiso', 262, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 262, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 2}'),
(253, '2026-10-05 03:47:01', 'INSERT', 'rol_modulo_permiso', 263, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 263, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 3}'),
(254, '2026-10-05 03:47:01', 'INSERT', 'rol_modulo_permiso', 264, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 264, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 4}'),
(255, '2026-10-05 03:47:01', 'INSERT', 'rol_modulo_permiso', 265, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 265, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 1}'),
(256, '2026-10-05 03:47:01', 'INSERT', 'rol_modulo_permiso', 266, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 266, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 2}'),
(257, '2026-10-05 03:47:02', 'INSERT', 'rol_modulo_permiso', 267, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 267, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 3}'),
(258, '2026-10-05 03:47:02', 'INSERT', 'rol_modulo_permiso', 268, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 268, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 4}'),
(259, '2026-10-05 03:47:02', 'INSERT', 'rol_modulo_permiso', 269, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 269, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 1}'),
(260, '2026-10-05 03:47:02', 'INSERT', 'rol_modulo_permiso', 270, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 270, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 2}'),
(261, '2026-10-05 03:47:02', 'INSERT', 'rol_modulo_permiso', 271, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 271, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 3}'),
(262, '2026-10-05 03:47:02', 'INSERT', 'rol_modulo_permiso', 272, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 272, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 4}'),
(263, '2026-10-05 03:47:02', 'INSERT', 'rol_modulo_permiso', 273, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 273, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 1}'),
(264, '2026-10-05 03:47:03', 'INSERT', 'rol_modulo_permiso', 274, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 274, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 2}'),
(265, '2026-10-05 03:47:03', 'INSERT', 'rol_modulo_permiso', 275, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 275, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 3}'),
(266, '2026-10-05 03:47:03', 'INSERT', 'rol_modulo_permiso', 276, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 276, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 4}'),
(267, '2026-10-05 03:47:03', 'INSERT', 'rol_modulo_permiso', 277, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 277, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 1}'),
(268, '2026-10-05 03:47:05', 'INSERT', 'rol_modulo_permiso', 278, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 278, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 2}'),
(269, '2026-10-05 03:47:05', 'INSERT', 'rol_modulo_permiso', 279, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 279, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 3}'),
(270, '2026-10-05 03:47:05', 'INSERT', 'rol_modulo_permiso', 280, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 280, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 4}'),
(271, '2026-10-05 03:47:06', 'INSERT', 'rol_modulo_permiso', 281, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 281, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 1}'),
(272, '2026-10-05 03:47:07', 'INSERT', 'rol_modulo_permiso', 282, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 282, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 2}'),
(273, '2026-10-05 03:47:07', 'INSERT', 'rol_modulo_permiso', 283, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 283, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 3}'),
(274, '2026-10-05 03:47:07', 'INSERT', 'rol_modulo_permiso', 284, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 284, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 4}'),
(275, '2026-10-05 03:47:07', 'INSERT', 'rol_modulo_permiso', 285, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 285, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 1}'),
(276, '2026-10-05 03:47:07', 'INSERT', 'rol_modulo_permiso', 286, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 286, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 2}'),
(277, '2026-10-05 03:47:07', 'INSERT', 'rol_modulo_permiso', 287, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 287, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 3}'),
(278, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 288, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 288, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 4}'),
(279, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 289, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 289, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 1}'),
(280, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 290, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 290, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 2}'),
(281, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 291, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 291, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 3}'),
(282, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 292, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 292, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 4}'),
(283, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 293, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 293, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 1}'),
(284, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 294, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 294, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 2}'),
(285, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 295, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 295, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 3}'),
(286, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 296, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 296, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 4}'),
(287, '2026-10-05 03:47:08', 'INSERT', 'rol_modulo_permiso', 297, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 297, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 1}'),
(288, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 298, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 298, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 2}'),
(289, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 299, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 299, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 3}'),
(290, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 300, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 300, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 4}'),
(291, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 301, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 301, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 1}'),
(292, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 302, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 302, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 2}'),
(293, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 303, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 303, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 3}'),
(294, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 304, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 304, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 4}'),
(295, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 305, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 305, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 1}'),
(296, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 306, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 306, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 2}'),
(297, '2026-10-05 03:47:09', 'INSERT', 'rol_modulo_permiso', 307, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 307, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 3}'),
(298, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 308, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 308, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 4}'),
(299, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 309, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 309, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 1}'),
(300, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 310, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 310, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 2}'),
(301, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 311, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 311, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 3}'),
(302, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 312, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 312, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 4}'),
(303, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 313, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 313, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 1}'),
(304, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 314, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 314, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 2}'),
(305, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 315, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 315, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 3}'),
(306, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 316, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 316, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 4}'),
(307, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 317, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 317, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 1}'),
(308, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 318, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 318, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 2}'),
(309, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 319, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 319, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 3}'),
(310, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 320, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 320, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 4}'),
(311, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 321, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 321, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 1}'),
(312, '2026-10-05 03:47:10', 'INSERT', 'rol_modulo_permiso', 322, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 322, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 2}'),
(313, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 323, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 323, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 3}'),
(314, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 324, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 324, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 4}'),
(315, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 325, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 325, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 1}'),
(316, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 326, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 326, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 2}'),
(317, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 327, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 327, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 3}'),
(318, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 328, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 328, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 4}'),
(319, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 329, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 329, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 1}'),
(320, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 330, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 330, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 2}'),
(321, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 331, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 331, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 3}'),
(322, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 332, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 332, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 4}'),
(323, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 333, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 333, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 1}'),
(324, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 334, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 334, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 2}'),
(325, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 335, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 335, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 3}'),
(326, '2026-10-05 03:47:11', 'INSERT', 'rol_modulo_permiso', 336, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 336, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 4}'),
(327, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 258, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 258, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 2}', NULL),
(328, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 259, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 259, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 3}', NULL),
(329, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 260, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 260, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 4}', NULL),
(330, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 261, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 261, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 1}', NULL),
(331, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 262, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 262, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 2}', NULL),
(332, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 263, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 263, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 3}', NULL),
(333, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 264, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 264, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 4}', NULL),
(334, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 265, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 265, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 1}', NULL),
(335, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 266, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 266, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 2}', NULL),
(336, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 267, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 267, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 3}', NULL),
(337, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 268, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 268, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 4}', NULL),
(338, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 269, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 269, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 1}', NULL),
(339, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 270, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 270, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 2}', NULL),
(340, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 271, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 271, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 3}', NULL),
(341, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 272, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 272, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 4}', NULL),
(342, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 273, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 273, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 1}', NULL),
(343, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 274, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 274, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 2}', NULL),
(344, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 275, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 275, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 3}', NULL),
(345, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 276, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 276, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 4}', NULL),
(346, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 277, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 277, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 1}', NULL),
(347, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 278, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 278, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 2}', NULL),
(348, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 279, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 279, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 3}', NULL),
(349, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 280, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 280, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 4}', NULL),
(350, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 281, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 281, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 1}', NULL),
(351, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 282, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 282, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 2}', NULL),
(352, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 283, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 283, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 3}', NULL),
(353, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 284, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 284, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 4}', NULL),
(354, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 285, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 285, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 1}', NULL),
(355, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 286, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 286, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 2}', NULL),
(356, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 287, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 287, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 3}', NULL),
(357, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 288, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 288, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 4}', NULL),
(358, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 289, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 289, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 1}', NULL),
(359, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 290, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 290, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 2}', NULL),
(360, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 291, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 291, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 3}', NULL),
(361, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 292, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 292, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 4}', NULL),
(362, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 293, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 293, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 1}', NULL),
(363, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 294, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 294, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 2}', NULL),
(364, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 295, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 295, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 3}', NULL),
(365, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 296, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 296, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 4}', NULL),
(366, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 297, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 297, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 1}', NULL),
(367, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 298, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 298, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 2}', NULL),
(368, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 299, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 299, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 3}', NULL),
(369, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 300, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 300, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 4}', NULL),
(370, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 301, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 301, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 1}', NULL),
(371, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 302, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 302, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 2}', NULL),
(372, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 303, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 303, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 3}', NULL),
(373, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 304, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 304, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 4}', NULL),
(374, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 305, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 305, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 1}', NULL),
(375, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 306, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 306, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 2}', NULL),
(376, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 307, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 307, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 3}', NULL),
(377, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 308, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 308, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 4}', NULL),
(378, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 309, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 309, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 1}', NULL),
(379, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 310, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 310, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 2}', NULL),
(380, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 311, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 311, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 3}', NULL),
(381, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 312, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 312, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 4}', NULL),
(382, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 313, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 313, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 1}', NULL),
(383, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 314, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 314, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 2}', NULL),
(384, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 315, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 315, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 3}', NULL),
(385, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 316, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 316, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 4}', NULL),
(386, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 317, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 317, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 1}', NULL),
(387, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 318, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 318, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 2}', NULL),
(388, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 319, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 319, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 3}', NULL),
(389, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 320, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 320, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 4}', NULL),
(390, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 321, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 321, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 1}', NULL),
(391, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 322, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 322, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 2}', NULL),
(392, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 323, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 323, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 3}', NULL),
(393, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 324, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 324, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 4}', NULL),
(394, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 325, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 325, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 1}', NULL),
(395, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 326, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 326, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 2}', NULL),
(396, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 327, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 327, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 3}', NULL),
(397, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 328, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 328, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 4}', NULL),
(398, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 329, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 329, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 1}', NULL),
(399, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 330, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 330, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 2}', NULL),
(400, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 331, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 331, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 3}', NULL),
(401, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 332, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 332, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 4}', NULL),
(402, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 333, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 333, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 1}', NULL),
(403, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 334, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 334, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 2}', NULL),
(404, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 335, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 335, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 3}', NULL),
(405, '2026-10-05 03:47:27', 'DELETE', 'rol_modulo_permiso', 336, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 336, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 4}', NULL),
(406, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 337, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 337, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 1}'),
(407, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 338, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 338, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 2}'),
(408, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 339, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 339, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 3}'),
(409, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 340, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 340, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 4}'),
(410, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 341, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 341, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 1}'),
(411, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 342, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 342, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 2}'),
(412, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 343, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 343, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 3}'),
(413, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 344, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 344, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 4}'),
(414, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 345, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 345, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 1}'),
(415, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 346, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 346, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 2}'),
(416, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 347, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 347, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 3}'),
(417, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 348, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 348, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 4}'),
(418, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 349, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 349, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 1}'),
(419, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 350, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 350, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 2}'),
(420, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 351, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 351, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 3}'),
(421, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 352, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 352, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 4}'),
(422, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 353, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 353, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 1}'),
(423, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 354, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 354, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 2}'),
(424, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 355, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 355, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 3}'),
(425, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 356, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 356, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 4}'),
(426, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 357, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 357, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 1}'),
(427, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 358, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 358, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 2}'),
(428, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 359, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 359, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 3}'),
(429, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 360, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 360, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 4}'),
(430, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 361, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 361, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 1}'),
(431, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 362, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 362, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 2}'),
(432, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 363, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 363, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 3}');
INSERT INTO `logs` (`id_log`, `creado_en`, `accion`, `tabla_afectada`, `id_registro_afectado`, `tipo_actor`, `id_usuario`, `id_credencial`, `ip_address`, `old_value`, `new_value`) VALUES
(433, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 364, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 364, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 4}'),
(434, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 365, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 365, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 1}'),
(435, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 366, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 366, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 2}'),
(436, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 367, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 367, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 3}'),
(437, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 368, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 368, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 4}'),
(438, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 369, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 369, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 1}'),
(439, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 370, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 370, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 2}'),
(440, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 371, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 371, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 3}'),
(441, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 372, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 372, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 4}'),
(442, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 373, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 373, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 1}'),
(443, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 374, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 374, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 2}'),
(444, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 375, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 375, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 3}'),
(445, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 376, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 376, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 4}'),
(446, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 377, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 377, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 1}'),
(447, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 378, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 378, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 2}'),
(448, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 379, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 379, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 3}'),
(449, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 380, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 380, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 4}'),
(450, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 381, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 381, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 1}'),
(451, '2026-10-05 03:47:27', 'INSERT', 'rol_modulo_permiso', 382, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 382, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 2}'),
(452, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 383, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 383, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 3}'),
(453, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 384, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 384, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 4}'),
(454, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 385, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 385, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 1}'),
(455, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 386, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 386, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 2}'),
(456, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 387, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 387, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 3}'),
(457, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 388, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 388, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 4}'),
(458, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 389, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 389, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 1}'),
(459, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 390, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 390, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 2}'),
(460, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 391, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 391, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 3}'),
(461, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 392, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 392, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 4}'),
(462, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 393, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 393, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 1}'),
(463, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 394, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 394, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 2}'),
(464, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 395, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 395, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 3}'),
(465, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 396, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 396, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 4}'),
(466, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 397, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 397, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 1}'),
(467, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 398, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 398, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 2}'),
(468, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 399, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 399, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 3}'),
(469, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 400, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 400, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 4}'),
(470, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 401, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 401, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 1}'),
(471, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 402, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 402, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 2}'),
(472, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 403, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 403, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 3}'),
(473, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 404, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 404, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 4}'),
(474, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 405, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 405, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 1}'),
(475, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 406, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 406, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 2}'),
(476, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 407, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 407, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 3}'),
(477, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 408, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 408, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 4}'),
(478, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 409, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 409, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 1}'),
(479, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 410, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 410, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 2}'),
(480, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 411, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 411, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 3}'),
(481, '2026-10-05 03:47:28', 'INSERT', 'rol_modulo_permiso', 412, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 412, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 4}'),
(482, '2026-10-05 04:02:12', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(483, '2026-10-05 04:02:12', 'INSERT', 'sesiones', 108, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 108, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 06:02:12\"}'),
(484, '2026-10-05 04:04:53', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(485, '2026-10-05 04:04:53', 'INSERT', 'sesiones', 109, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 109, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 06:04:53\"}'),
(486, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 337, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 337, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 1}', NULL),
(487, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 338, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 338, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 2}', NULL),
(488, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 339, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 339, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 3}', NULL),
(489, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 340, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 340, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 4}', NULL),
(490, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 341, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 341, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 1}', NULL),
(491, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 342, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 342, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 2}', NULL),
(492, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 343, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 343, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 3}', NULL),
(493, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 344, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 344, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 4}', NULL),
(494, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 345, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 345, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 1}', NULL),
(495, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 346, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 346, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 2}', NULL),
(496, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 347, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 347, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 3}', NULL),
(497, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 348, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 348, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 4}', NULL),
(498, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 349, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 349, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 1}', NULL),
(499, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 350, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 350, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 2}', NULL),
(500, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 351, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 351, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 3}', NULL),
(501, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 352, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 352, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 4}', NULL),
(502, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 353, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 353, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 1}', NULL),
(503, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 354, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 354, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 2}', NULL),
(504, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 355, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 355, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 3}', NULL),
(505, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 356, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 356, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 4}', NULL),
(506, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 357, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 357, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 1}', NULL),
(507, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 358, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 358, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 2}', NULL),
(508, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 359, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 359, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 3}', NULL),
(509, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 360, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 360, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 4}', NULL),
(510, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 361, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 361, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 1}', NULL),
(511, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 362, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 362, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 2}', NULL),
(512, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 363, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 363, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 3}', NULL),
(513, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 364, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 364, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 4}', NULL),
(514, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 365, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 365, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 1}', NULL),
(515, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 366, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 366, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 2}', NULL),
(516, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 367, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 367, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 3}', NULL),
(517, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 368, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 368, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 4}', NULL),
(518, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 369, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 369, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 1}', NULL),
(519, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 370, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 370, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 2}', NULL),
(520, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 371, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 371, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 3}', NULL),
(521, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 372, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 372, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 4}', NULL),
(522, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 373, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 373, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 1}', NULL),
(523, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 374, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 374, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 2}', NULL),
(524, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 375, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 375, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 3}', NULL),
(525, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 376, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 376, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 4}', NULL),
(526, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 377, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 377, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 1}', NULL),
(527, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 378, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 378, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 2}', NULL),
(528, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 379, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 379, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 3}', NULL),
(529, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 380, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 380, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 4}', NULL),
(530, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 381, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 381, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 1}', NULL),
(531, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 382, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 382, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 2}', NULL),
(532, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 383, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 383, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 3}', NULL),
(533, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 384, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 384, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 4}', NULL),
(534, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 385, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 385, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 1}', NULL),
(535, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 386, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 386, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 2}', NULL),
(536, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 387, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 387, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 3}', NULL),
(537, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 388, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 388, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 4}', NULL),
(538, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 389, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 389, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 1}', NULL),
(539, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 390, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 390, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 2}', NULL),
(540, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 391, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 391, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 3}', NULL),
(541, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 392, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 392, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 4}', NULL),
(542, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 393, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 393, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 1}', NULL),
(543, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 394, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 394, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 2}', NULL),
(544, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 395, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 395, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 3}', NULL),
(545, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 396, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 396, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 4}', NULL),
(546, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 397, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 397, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 1}', NULL),
(547, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 398, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 398, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 2}', NULL),
(548, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 399, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 399, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 3}', NULL),
(549, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 400, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 400, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 4}', NULL),
(550, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 401, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 401, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 1}', NULL),
(551, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 402, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 402, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 2}', NULL),
(552, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 403, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 403, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 3}', NULL),
(553, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 404, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 404, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 4}', NULL),
(554, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 405, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 405, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 1}', NULL),
(555, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 406, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 406, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 2}', NULL),
(556, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 407, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 407, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 3}', NULL),
(557, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 408, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 408, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 4}', NULL),
(558, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 409, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 409, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 1}', NULL),
(559, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 410, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 410, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 2}', NULL),
(560, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 411, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 411, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 3}', NULL),
(561, '2026-10-05 04:06:10', 'DELETE', 'rol_modulo_permiso', 412, 'sistema', NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 412, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 4}', NULL),
(562, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 413, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 413, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 1}'),
(563, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 414, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 414, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 2}'),
(564, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 415, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 415, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 3}'),
(565, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 416, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 416, \"id_rol_modulo\": 8, \"id_pagina\": 1, \"id_permiso\": 4}'),
(566, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 417, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 417, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 1}'),
(567, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 418, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 418, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 2}'),
(568, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 419, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 419, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 3}'),
(569, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 420, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 420, \"id_rol_modulo\": 9, \"id_pagina\": 2, \"id_permiso\": 4}'),
(570, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 421, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 421, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 1}'),
(571, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 422, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 422, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 2}'),
(572, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 423, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 423, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 3}'),
(573, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 424, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 424, \"id_rol_modulo\": 9, \"id_pagina\": 3, \"id_permiso\": 4}'),
(574, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 425, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 425, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 1}'),
(575, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 426, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 426, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 2}'),
(576, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 427, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 427, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 3}'),
(577, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 428, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 428, \"id_rol_modulo\": 10, \"id_pagina\": 4, \"id_permiso\": 4}'),
(578, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 429, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 429, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 1}'),
(579, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 430, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 430, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 2}'),
(580, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 431, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 431, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 3}'),
(581, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 432, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 432, \"id_rol_modulo\": 10, \"id_pagina\": 5, \"id_permiso\": 4}'),
(582, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 433, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 433, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 1}'),
(583, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 434, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 434, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 2}'),
(584, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 435, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 435, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 3}'),
(585, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 436, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 436, \"id_rol_modulo\": 10, \"id_pagina\": 6, \"id_permiso\": 4}'),
(586, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 437, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 437, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 1}'),
(587, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 438, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 438, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 2}'),
(588, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 439, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 439, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 3}'),
(589, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 440, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 440, \"id_rol_modulo\": 11, \"id_pagina\": 7, \"id_permiso\": 4}'),
(590, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 441, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 441, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 1}'),
(591, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 442, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 442, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 2}'),
(592, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 443, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 443, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 3}'),
(593, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 444, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 444, \"id_rol_modulo\": 11, \"id_pagina\": 8, \"id_permiso\": 4}'),
(594, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 445, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 445, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 1}'),
(595, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 446, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 446, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 2}'),
(596, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 447, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 447, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 3}'),
(597, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 448, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 448, \"id_rol_modulo\": 11, \"id_pagina\": 9, \"id_permiso\": 4}'),
(598, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 449, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 449, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 1}'),
(599, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 450, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 450, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 2}'),
(600, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 451, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 451, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 3}'),
(601, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 452, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 452, \"id_rol_modulo\": 11, \"id_pagina\": 10, \"id_permiso\": 4}'),
(602, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 453, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 453, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 1}'),
(603, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 454, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 454, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 2}'),
(604, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 455, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 455, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 3}'),
(605, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 456, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 456, \"id_rol_modulo\": 12, \"id_pagina\": 11, \"id_permiso\": 4}'),
(606, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 457, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 457, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 1}'),
(607, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 458, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 458, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 2}'),
(608, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 459, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 459, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 3}'),
(609, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 460, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 460, \"id_rol_modulo\": 13, \"id_pagina\": 12, \"id_permiso\": 4}'),
(610, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 461, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 461, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 1}'),
(611, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 462, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 462, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 2}'),
(612, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 463, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 463, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 3}'),
(613, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 464, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 464, \"id_rol_modulo\": 13, \"id_pagina\": 13, \"id_permiso\": 4}'),
(614, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 465, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 465, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 1}'),
(615, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 466, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 466, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 2}'),
(616, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 467, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 467, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 3}'),
(617, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 468, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 468, \"id_rol_modulo\": 13, \"id_pagina\": 14, \"id_permiso\": 4}'),
(618, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 469, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 469, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 1}'),
(619, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 470, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 470, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 2}'),
(620, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 471, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 471, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 3}'),
(621, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 472, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 472, \"id_rol_modulo\": 14, \"id_pagina\": 15, \"id_permiso\": 4}'),
(622, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 473, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 473, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 1}'),
(623, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 474, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 474, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 2}'),
(624, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 475, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 475, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 3}'),
(625, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 476, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 476, \"id_rol_modulo\": 14, \"id_pagina\": 16, \"id_permiso\": 4}'),
(626, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 477, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 477, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 1}'),
(627, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 478, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 478, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 2}'),
(628, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 479, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 479, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 3}'),
(629, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 480, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 480, \"id_rol_modulo\": 14, \"id_pagina\": 17, \"id_permiso\": 4}'),
(630, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 481, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 481, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 1}'),
(631, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 482, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 482, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 2}'),
(632, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 483, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 483, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 3}'),
(633, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 484, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 484, \"id_rol_modulo\": 14, \"id_pagina\": 18, \"id_permiso\": 4}'),
(634, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 485, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 485, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 1}'),
(635, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 486, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 486, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 2}'),
(636, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 487, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 487, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 3}'),
(637, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 488, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 488, \"id_rol_modulo\": 14, \"id_pagina\": 19, \"id_permiso\": 4}'),
(638, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 489, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 489, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 1}'),
(639, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 490, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 490, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 2}'),
(640, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 491, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 491, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 3}'),
(641, '2026-10-05 04:06:10', 'INSERT', 'rol_modulo_permiso', 492, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 492, \"id_rol_modulo\": 13, \"id_pagina\": 20, \"id_permiso\": 4}'),
(642, '2026-10-05 04:06:55', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(643, '2026-10-05 04:06:55', 'DELETE', 'sesiones', 70, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 70, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null}', NULL),
(644, '2026-10-05 04:06:55', 'INSERT', 'sesiones', 110, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 110, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-04 06:06:55\"}'),
(645, '2026-10-05 04:07:30', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(646, '2026-10-05 04:07:30', 'INSERT', 'sesiones', 111, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 111, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-04 06:07:30\"}'),
(647, '2026-10-05 04:09:42', 'UPDATE', 'servicios', 10, 'sistema', NULL, NULL, NULL, '{\"id_servicio\": 10, \"id_cliente\": 10, \"alias\": \"Servicio Casa 1\", \"estado_comercial\": \"activo\", \"id_plan\": 1, \"id_naps\": 10}', '{\"id_servicio\": 10, \"id_cliente\": 10, \"alias\": \"Servicio Casa 1\", \"estado_comercial\": \"activo\", \"id_plan\": 1, \"id_naps\": 10}'),
(648, '2026-10-05 04:11:15', 'UPDATE', 'pagos', 12, 'sistema', NULL, NULL, NULL, '{\"id_pago\": 12, \"id_factura\": null, \"monto\": 20.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}', '{\"id_pago\": 12, \"id_factura\": null, \"monto\": 20.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}'),
(649, '2026-10-05 04:17:34', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(650, '2026-10-05 04:17:34', 'INSERT', 'sesiones', 112, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 112, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 06:17:34\"}'),
(651, '2026-10-05 04:18:36', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(652, '2026-10-05 04:18:36', 'DELETE', 'usuario_rol', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario_rol\": 3, \"id_usuario\": 2, \"id_rol\": 2}', NULL),
(653, '2026-10-05 04:18:36', 'INSERT', 'usuario_rol', 6, 'sistema', NULL, NULL, NULL, NULL, '{\"id_usuario_rol\": 6, \"id_usuario\": 2, \"id_rol\": 1}'),
(654, '2026-10-05 04:18:43', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(655, '2026-10-05 04:18:43', 'DELETE', 'usuario_rol', 6, 'sistema', NULL, NULL, NULL, '{\"id_usuario_rol\": 6, \"id_usuario\": 2, \"id_rol\": 1}', NULL),
(656, '2026-10-05 04:18:43', 'INSERT', 'usuario_rol', 7, 'sistema', NULL, NULL, NULL, NULL, '{\"id_usuario_rol\": 7, \"id_usuario\": 2, \"id_rol\": 2}'),
(657, '2026-10-05 04:20:01', 'INSERT', 'rol_modulo_permiso', 493, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 493, \"id_rol_modulo\": 15, \"id_pagina\": 4, \"id_permiso\": 1}'),
(658, '2026-10-05 04:20:01', 'INSERT', 'rol_modulo_permiso', 494, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 494, \"id_rol_modulo\": 15, \"id_pagina\": 4, \"id_permiso\": 2}'),
(659, '2026-10-05 04:20:01', 'INSERT', 'rol_modulo_permiso', 495, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 495, \"id_rol_modulo\": 15, \"id_pagina\": 4, \"id_permiso\": 3}'),
(660, '2026-10-05 04:20:01', 'INSERT', 'rol_modulo_permiso', 496, 'sistema', NULL, NULL, NULL, NULL, '{\"id_rol_modulo_permiso\": 496, \"id_rol_modulo\": 15, \"id_pagina\": 4, \"id_permiso\": 4}'),
(661, '2026-10-05 04:20:15', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(662, '2026-10-05 04:20:15', 'INSERT', 'sesiones', 113, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 113, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 06:20:15\"}'),
(663, '2026-10-05 15:39:19', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(664, '2026-10-05 15:39:32', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(665, '2026-10-05 15:40:34', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(666, '2026-10-05 15:42:39', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(667, '2026-10-05 15:43:05', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(668, '2026-10-05 15:43:49', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}');
INSERT INTO `logs` (`id_log`, `creado_en`, `accion`, `tabla_afectada`, `id_registro_afectado`, `tipo_actor`, `id_usuario`, `id_credencial`, `ip_address`, `old_value`, `new_value`) VALUES
(669, '2026-10-05 15:48:14', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(670, '2026-10-05 15:48:14', 'INSERT', 'sesiones', 114, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 114, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 17:48:14\"}'),
(671, '2026-10-05 15:53:26', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(672, '2026-10-05 15:53:26', 'INSERT', 'sesiones', 115, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 115, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 17:53:26\"}'),
(673, '2026-10-05 16:05:40', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(674, '2026-10-05 16:05:41', 'INSERT', 'sesiones', 116, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 116, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 18:05:41\"}'),
(675, '2026-10-05 16:06:53', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(676, '2026-10-05 16:06:53', 'INSERT', 'sesiones', 117, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 117, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 18:06:53\"}'),
(677, '2026-10-05 16:18:20', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(678, '2026-10-05 16:18:20', 'INSERT', 'sesiones', 118, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 118, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 18:18:20\"}'),
(679, '2026-10-05 17:14:39', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(680, '2026-10-05 17:14:39', 'INSERT', 'sesiones', 119, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 119, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-04 19:14:39\"}'),
(681, '2026-10-06 15:35:16', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(682, '2026-10-06 15:35:16', 'INSERT', 'sesiones', 120, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 120, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 17:35:16\"}'),
(683, '2026-10-06 15:38:45', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(684, '2026-10-06 15:38:52', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(685, '2026-10-06 15:38:52', 'INSERT', 'sesiones', 121, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 121, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 17:38:52\"}'),
(686, '2026-10-06 17:07:58', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(687, '2026-10-06 17:07:58', 'INSERT', 'sesiones', 122, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 122, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-05 19:07:58\"}'),
(688, '2026-10-06 17:11:12', 'UPDATE', 'pagos', 10, 'staff', 2, NULL, NULL, '{\"id_pago\": 10, \"id_factura\": 10, \"monto\": 15.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}', '{\"id_pago\": 10, \"id_factura\": 10, \"monto\": 15.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}'),
(689, '2026-10-06 17:11:12', 'UPDATE', 'facturas', 10, 'staff', 2, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 20.00, \"estado\": \"pagada\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 20.00, \"estado\": \"parcial\"}'),
(690, '2026-10-06 17:17:25', 'UPDATE', 'sesiones', 122, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 122, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 122, \"revocado_en\": \"2026-10-06 13:17:25\", \"motivo_cierre\": \"logout\"}'),
(691, '2026-10-06 17:17:31', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(692, '2026-10-06 17:17:31', 'INSERT', 'sesiones', 123, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 123, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 19:17:31\"}'),
(693, '2026-10-06 19:18:01', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(694, '2026-10-06 19:18:01', 'INSERT', 'sesiones', 124, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 124, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 21:18:01\"}'),
(695, '2026-10-06 19:23:17', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(696, '2026-10-06 19:23:17', 'INSERT', 'sesiones', 125, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 125, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 21:23:17\"}'),
(697, '2026-10-06 19:33:39', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(698, '2026-10-06 19:33:39', 'INSERT', 'sesiones', 126, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 126, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 21:33:39\"}'),
(699, '2026-10-06 19:34:58', 'UPDATE', 'sesiones', 126, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 126, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 126, \"revocado_en\": \"2026-10-06 15:34:58\", \"motivo_cierre\": \"logout\"}'),
(700, '2026-10-06 19:35:09', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(701, '2026-10-06 19:35:09', 'INSERT', 'sesiones', 127, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 127, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-05 21:35:09\"}'),
(702, '2026-10-06 19:36:31', 'UPDATE', 'sesiones', 127, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 127, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 127, \"revocado_en\": \"2026-10-06 15:36:31\", \"motivo_cierre\": \"logout\"}'),
(703, '2026-10-06 19:36:37', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(704, '2026-10-06 19:36:37', 'INSERT', 'sesiones', 128, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 128, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 21:36:37\"}'),
(705, '2026-10-06 20:17:06', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(706, '2026-10-06 20:17:06', 'INSERT', 'sesiones', 129, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 129, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:17:06\"}'),
(707, '2026-10-06 20:17:31', 'UPDATE', 'sesiones', 129, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 129, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 129, \"revocado_en\": \"2026-10-06 16:17:31\", \"motivo_cierre\": \"logout\"}'),
(708, '2026-10-06 20:17:41', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(709, '2026-10-06 20:17:41', 'INSERT', 'sesiones', 130, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 130, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:17:41\"}'),
(710, '2026-10-06 20:18:35', 'UPDATE', 'sesiones', 130, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 130, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 130, \"revocado_en\": \"2026-10-06 16:18:35\", \"motivo_cierre\": \"logout\"}'),
(711, '2026-10-06 20:18:42', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(712, '2026-10-06 20:18:42', 'INSERT', 'sesiones', 131, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 131, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:18:42\"}'),
(713, '2026-10-06 20:19:19', 'UPDATE', 'usuarios', 3, 'staff', 1, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(714, '2026-10-06 20:19:46', 'UPDATE', 'usuarios', 3, 'staff', 1, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(715, '2026-10-06 20:20:44', 'UPDATE', 'usuarios', 3, 'staff', 1, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(716, '2026-10-06 20:21:22', 'INSERT', 'usuarios', 5, 'staff', 1, NULL, NULL, NULL, '{\"id_usuario\": 5, \"username\": \"ange\", \"email\": \"ange@gamil.com\", \"estado\": \"Activo\", \"email_verified\": 0}'),
(717, '2026-10-06 20:21:29', 'DELETE', 'usuarios', 5, 'staff', 1, NULL, NULL, '{\"id_usuario\": 5, \"username\": \"ange\", \"email\": \"ange@gamil.com\", \"estado\": \"Activo\"}', NULL),
(718, '2026-10-06 20:25:16', 'UPDATE', 'usuarios', 3, 'staff', 1, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(719, '2026-10-06 20:25:34', 'UPDATE', 'sesiones', 131, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 131, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 131, \"revocado_en\": \"2026-10-06 16:25:34\", \"motivo_cierre\": \"logout\"}'),
(720, '2026-10-06 20:25:40', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(721, '2026-10-06 20:25:40', 'INSERT', 'sesiones', 132, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 132, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:25:40\"}'),
(722, '2026-10-06 20:50:20', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(723, '2026-10-06 20:50:20', 'INSERT', 'sesiones', 133, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 133, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:50:20\"}'),
(724, '2026-10-06 20:52:47', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(725, '2026-10-06 20:52:47', 'INSERT', 'sesiones', 134, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 134, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:52:47\"}'),
(726, '2026-10-06 20:54:42', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(727, '2026-10-06 20:54:42', 'INSERT', 'sesiones', 135, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 135, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:54:42\"}'),
(728, '2026-10-06 20:54:49', 'UPDATE', 'sesiones', 135, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 135, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 135, \"revocado_en\": \"2026-10-06 16:54:49\", \"motivo_cierre\": \"logout\"}'),
(729, '2026-10-06 20:54:59', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(730, '2026-10-06 20:54:59', 'INSERT', 'sesiones', 136, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 136, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:54:59\"}'),
(731, '2026-10-06 20:56:25', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(732, '2026-10-06 20:56:25', 'INSERT', 'sesiones', 137, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 137, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:56:25\"}'),
(733, '2026-10-06 20:56:43', 'UPDATE', 'sesiones', 137, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 137, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 137, \"revocado_en\": \"2026-10-06 16:56:43\", \"motivo_cierre\": \"logout\"}'),
(734, '2026-10-06 20:56:51', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(735, '2026-10-06 20:56:51', 'INSERT', 'sesiones', 138, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 138, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:56:51\"}'),
(736, '2026-10-06 20:57:56', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(737, '2026-10-06 20:57:56', 'INSERT', 'sesiones', 139, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 139, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-05 22:57:56\"}'),
(738, '2026-10-06 21:02:35', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(739, '2026-10-06 21:02:35', 'INSERT', 'sesiones', 140, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 140, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:02:35\"}'),
(740, '2026-10-06 21:03:12', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(741, '2026-10-06 21:03:12', 'INSERT', 'sesiones', 141, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 141, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:03:12\"}'),
(742, '2026-10-06 21:03:54', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(743, '2026-10-06 21:03:54', 'INSERT', 'sesiones', 142, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 142, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:03:54\"}'),
(744, '2026-10-06 21:04:09', 'UPDATE', 'sesiones', 142, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 142, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 142, \"revocado_en\": \"2026-10-06 17:04:09\", \"motivo_cierre\": \"logout\"}'),
(745, '2026-10-06 21:04:17', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(746, '2026-10-06 21:04:17', 'INSERT', 'sesiones', 143, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 143, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:04:17\"}'),
(747, '2026-10-06 21:04:39', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(748, '2026-10-06 21:04:39', 'INSERT', 'sesiones', 144, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 144, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:04:39\"}'),
(749, '2026-10-06 21:26:31', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(750, '2026-10-06 21:26:31', 'INSERT', 'sesiones', 145, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 145, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:26:31\"}'),
(751, '2026-10-06 21:27:44', 'UPDATE', 'sesiones', 145, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 145, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 145, \"revocado_en\": \"2026-10-06 17:27:44\", \"motivo_cierre\": \"logout\"}'),
(752, '2026-10-06 21:28:02', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(753, '2026-10-06 21:28:09', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(754, '2026-10-06 21:28:09', 'INSERT', 'sesiones', 146, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 146, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:28:09\"}'),
(755, '2026-10-06 21:33:45', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(756, '2026-10-06 21:33:45', 'INSERT', 'sesiones', 147, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 147, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:33:45\"}'),
(757, '2026-10-06 21:34:00', 'UPDATE', 'sesiones', 147, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 147, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 147, \"revocado_en\": \"2026-10-06 17:34:00\", \"motivo_cierre\": \"logout\"}'),
(758, '2026-10-06 21:34:16', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(759, '2026-10-06 21:34:16', 'INSERT', 'sesiones', 148, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 148, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:34:16\"}'),
(760, '2026-10-06 21:37:08', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(761, '2026-10-06 21:37:08', 'INSERT', 'sesiones', 149, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 149, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:37:08\"}'),
(762, '2026-10-06 21:37:46', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(763, '2026-10-06 21:37:46', 'INSERT', 'sesiones', 150, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 150, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:37:46\"}'),
(764, '2026-10-06 21:47:58', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(765, '2026-10-06 21:47:58', 'INSERT', 'sesiones', 151, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 151, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:47:58\"}'),
(766, '2026-10-06 21:48:13', 'UPDATE', 'sesiones', 151, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 151, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 151, \"revocado_en\": \"2026-10-06 17:48:13\", \"motivo_cierre\": \"logout\"}'),
(767, '2026-10-06 21:54:08', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(768, '2026-10-06 21:54:08', 'INSERT', 'sesiones', 152, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 152, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-05 23:54:08\"}'),
(769, '2026-10-06 22:04:19', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(770, '2026-10-06 22:04:19', 'INSERT', 'sesiones', 153, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 153, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:04:19\"}'),
(771, '2026-10-06 22:04:36', 'UPDATE', 'sesiones', 153, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 153, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 153, \"revocado_en\": \"2026-10-06 18:04:36\", \"motivo_cierre\": \"logout\"}'),
(772, '2026-10-06 22:04:47', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(773, '2026-10-06 22:04:47', 'INSERT', 'sesiones', 154, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 154, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:04:47\"}'),
(774, '2026-10-06 22:04:52', 'UPDATE', 'sesiones', 154, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 154, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 154, \"revocado_en\": \"2026-10-06 18:04:52\", \"motivo_cierre\": \"logout\"}'),
(775, '2026-10-06 22:04:59', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(776, '2026-10-06 22:04:59', 'INSERT', 'sesiones', 155, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 155, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:04:59\"}'),
(777, '2026-10-06 22:05:04', 'UPDATE', 'sesiones', 155, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 155, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 155, \"revocado_en\": \"2026-10-06 18:05:04\", \"motivo_cierre\": \"logout\"}'),
(778, '2026-10-06 22:05:14', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(779, '2026-10-06 22:05:14', 'INSERT', 'sesiones', 156, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 156, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:05:14\"}'),
(780, '2026-10-06 22:09:47', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(781, '2026-10-06 22:09:47', 'INSERT', 'sesiones', 157, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 157, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:09:47\"}'),
(782, '2026-10-06 22:10:04', 'UPDATE', 'sesiones', 157, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 157, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 157, \"revocado_en\": \"2026-10-06 18:10:04\", \"motivo_cierre\": \"logout\"}'),
(783, '2026-10-06 22:10:14', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(784, '2026-10-06 22:10:14', 'INSERT', 'sesiones', 158, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 158, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:10:14\"}'),
(785, '2026-10-06 22:10:38', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(786, '2026-10-06 22:10:38', 'INSERT', 'sesiones', 159, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 159, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:10:38\"}'),
(787, '2026-10-06 22:12:19', 'UPDATE', 'sesiones', 159, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 159, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 159, \"revocado_en\": \"2026-10-06 18:12:19\", \"motivo_cierre\": \"logout\"}'),
(788, '2026-10-06 22:12:26', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(789, '2026-10-06 22:12:26', 'INSERT', 'sesiones', 160, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 160, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:12:26\"}'),
(790, '2026-10-06 22:13:06', 'UPDATE', 'sesiones', 160, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 160, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 160, \"revocado_en\": \"2026-10-06 18:13:06\", \"motivo_cierre\": \"logout\"}'),
(791, '2026-10-06 22:13:13', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(792, '2026-10-06 22:13:13', 'INSERT', 'sesiones', 161, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 161, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:13:13\"}'),
(793, '2026-10-06 22:14:01', 'UPDATE', 'sesiones', 161, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 161, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 161, \"revocado_en\": \"2026-10-06 18:14:01\", \"motivo_cierre\": \"logout\"}'),
(794, '2026-10-06 22:14:09', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(795, '2026-10-06 22:14:09', 'INSERT', 'sesiones', 162, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 162, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:14:09\"}'),
(796, '2026-10-06 22:14:25', 'UPDATE', 'sesiones', 162, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 162, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 162, \"revocado_en\": \"2026-10-06 18:14:25\", \"motivo_cierre\": \"logout\"}'),
(797, '2026-10-06 22:14:32', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(798, '2026-10-06 22:14:32', 'INSERT', 'sesiones', 163, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 163, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:14:32\"}'),
(799, '2026-10-06 22:14:48', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}'),
(800, '2026-10-06 22:14:48', 'INSERT', 'sesiones', 164, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 164, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:14:48\"}'),
(801, '2026-10-06 22:15:37', 'UPDATE', 'sesiones', 164, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 164, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 164, \"revocado_en\": \"2026-10-06 18:15:37\", \"motivo_cierre\": \"logout\"}'),
(802, '2026-10-06 22:15:44', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(803, '2026-10-06 22:15:44', 'INSERT', 'sesiones', 165, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 165, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:15:44\"}'),
(804, '2026-10-06 22:16:40', 'INSERT', 'facturas', 15, 'staff', 2, NULL, NULL, NULL, '{\"id_factura\": 15, \"id_servicio\": 1, \"periodo\": \"2026-07\", \"monto\": 3000.00, \"estado\": \"pendiente\"}'),
(805, '2026-10-06 22:17:35', 'INSERT', 'pagos', 13, 'staff', 2, NULL, NULL, NULL, '{\"id_pago\": 13, \"id_factura\": 15, \"monto\": 1000.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}'),
(806, '2026-10-06 22:19:35', 'UPDATE', 'sesiones', 165, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 165, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 165, \"revocado_en\": \"2026-10-06 18:19:35\", \"motivo_cierre\": \"logout\"}'),
(807, '2026-10-06 22:19:42', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(808, '2026-10-06 22:19:42', 'INSERT', 'sesiones', 166, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 166, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-06 00:19:42\"}'),
(809, '2026-10-08 14:55:34', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(810, '2026-10-08 14:55:34', 'INSERT', 'sesiones', 167, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 167, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 16:55:34\"}'),
(811, '2026-10-08 15:28:17', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(812, '2026-10-08 15:28:17', 'INSERT', 'sesiones', 168, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 168, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 17:28:17\"}'),
(813, '2026-10-08 15:29:07', 'INSERT', 'usuarios', 6, 'staff', 1, NULL, NULL, NULL, '{\"id_usuario\": 6, \"username\": \"operador2\", \"email\": \"perador2@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 0}'),
(814, '2026-10-08 15:29:17', 'DELETE', 'usuarios', 6, 'staff', 1, NULL, NULL, '{\"id_usuario\": 6, \"username\": \"operador2\", \"email\": \"perador2@gmail.com\", \"estado\": \"Activo\"}', NULL),
(815, '2026-10-08 15:37:22', 'UPDATE', 'usuarios', 3, 'staff', 1, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 0, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(816, '2026-10-08 15:42:30', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(817, '2026-10-08 15:42:30', 'INSERT', 'sesiones', 169, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 169, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 17:42:30\"}'),
(818, '2026-10-08 15:45:22', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(819, '2026-10-08 15:45:22', 'INSERT', 'sesiones', 170, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 170, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 17:45:22\"}'),
(820, '2026-10-08 15:52:08', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(821, '2026-10-08 15:52:08', 'INSERT', 'sesiones', 171, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 171, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 17:52:08\"}'),
(822, '2026-10-08 15:56:02', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(823, '2026-10-08 15:56:02', 'INSERT', 'sesiones', 172, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 172, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 17:56:02\"}'),
(824, '2026-10-08 15:57:34', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(825, '2026-10-08 15:57:34', 'INSERT', 'sesiones', 173, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 173, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 17:57:34\"}'),
(826, '2026-10-08 15:58:19', 'UPDATE', 'sesiones', 173, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 173, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 173, \"revocado_en\": \"2026-10-08 11:58:19\", \"motivo_cierre\": \"logout\"}'),
(827, '2026-10-08 15:58:28', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(828, '2026-10-08 15:58:28', 'INSERT', 'sesiones', 174, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 174, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-07 17:58:28\"}'),
(829, '2026-10-08 16:03:28', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(830, '2026-10-08 16:03:28', 'INSERT', 'sesiones', 175, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 175, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 18:03:28\"}'),
(831, '2026-10-08 16:04:34', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(832, '2026-10-08 16:04:34', 'INSERT', 'sesiones', 176, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 176, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 18:04:34\"}');
INSERT INTO `logs` (`id_log`, `creado_en`, `accion`, `tabla_afectada`, `id_registro_afectado`, `tipo_actor`, `id_usuario`, `id_credencial`, `ip_address`, `old_value`, `new_value`) VALUES
(833, '2026-10-08 16:04:47', 'UPDATE', 'sesiones', 176, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 176, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 176, \"revocado_en\": \"2026-10-08 12:04:47\", \"motivo_cierre\": \"logout\"}'),
(834, '2026-10-08 16:04:59', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(835, '2026-10-08 16:04:59', 'INSERT', 'sesiones', 177, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 177, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-07 18:04:59\"}'),
(836, '2026-10-08 16:07:09', 'UPDATE', 'sesiones', 177, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 177, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 177, \"revocado_en\": \"2026-10-08 12:07:09\", \"motivo_cierre\": \"logout\"}'),
(837, '2026-10-08 16:07:16', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(838, '2026-10-08 16:07:16', 'INSERT', 'sesiones', 178, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 178, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 18:07:16\"}'),
(839, '2026-10-08 16:07:37', 'UPDATE', 'sesiones', 178, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 178, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 178, \"revocado_en\": \"2026-10-08 12:07:37\", \"motivo_cierre\": \"logout\"}'),
(840, '2026-10-08 16:07:45', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(841, '2026-10-08 16:07:45', 'INSERT', 'sesiones', 179, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 179, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-07 18:07:45\"}'),
(842, '2026-10-08 16:15:09', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(843, '2026-10-08 16:15:09', 'INSERT', 'sesiones', 180, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 180, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 18:15:09\"}'),
(844, '2026-10-08 16:16:41', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(845, '2026-10-08 16:16:41', 'INSERT', 'sesiones', 181, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 181, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 18:16:41\"}'),
(846, '2026-10-08 16:23:57', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(847, '2026-10-08 16:23:57', 'INSERT', 'sesiones', 182, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 182, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 18:23:57\"}'),
(848, '2026-10-08 16:28:16', 'INSERT', 'servicios', 14, 'staff', 1, NULL, NULL, NULL, '{\"id_servicio\": 14, \"id_cliente\": 14, \"alias\": \"micasa\", \"estado_comercial\": \"pendiente\", \"id_plan\": 1, \"id_naps\": 1}'),
(849, '2026-10-08 16:28:37', 'UPDATE', 'servicios', 14, 'staff', 1, NULL, NULL, '{\"id_servicio\": 14, \"id_cliente\": 14, \"alias\": \"micasa\", \"estado_comercial\": \"pendiente\", \"id_plan\": 1, \"id_naps\": 1}', '{\"id_servicio\": 14, \"id_cliente\": 14, \"alias\": \"micasa\", \"estado_comercial\": \"activo\", \"id_plan\": 1, \"id_naps\": 1}'),
(850, '2026-10-08 16:28:54', 'DELETE', 'servicios', 14, 'staff', 1, NULL, NULL, '{\"id_servicio\": 14, \"id_cliente\": 14, \"alias\": \"micasa\", \"estado_comercial\": \"activo\", \"id_plan\": 1, \"id_naps\": 1}', NULL),
(851, '2026-10-08 16:34:41', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(852, '2026-10-08 16:34:41', 'INSERT', 'sesiones', 183, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 183, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-07 18:34:41\"}'),
(853, '2026-10-09 18:52:17', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(854, '2026-10-09 18:52:18', 'INSERT', 'sesiones', 184, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 184, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-08 20:52:18\"}'),
(855, '2026-10-09 18:54:06', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(856, '2026-10-09 18:54:06', 'INSERT', 'sesiones', 185, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 185, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-08 20:54:06\"}'),
(857, '2026-10-09 18:54:59', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(858, '2026-10-09 18:54:59', 'INSERT', 'sesiones', 186, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 186, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-08 20:54:59\"}'),
(859, '2026-10-09 19:10:07', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(860, '2026-10-09 19:10:07', 'INSERT', 'sesiones', 187, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 187, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-08 21:10:07\"}'),
(861, '2026-10-10 04:10:36', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(862, '2026-10-10 04:10:36', 'INSERT', 'sesiones', 188, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 188, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-09 06:10:36\"}'),
(863, '2026-10-10 04:11:18', 'UPDATE', 'sesiones', 188, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 188, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 188, \"revocado_en\": \"2026-10-10 00:11:18\", \"motivo_cierre\": \"logout\"}'),
(864, '2026-10-10 04:11:30', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(865, '2026-10-10 04:11:30', 'INSERT', 'sesiones', 189, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 189, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-09 06:11:30\"}'),
(866, '2026-10-10 04:16:55', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(867, '2026-10-10 04:16:55', 'INSERT', 'sesiones', 190, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 190, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-09 06:16:55\"}'),
(868, '2026-10-10 04:18:54', 'UPDATE', 'sesiones', 190, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 190, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 190, \"revocado_en\": \"2026-10-10 00:18:54\", \"motivo_cierre\": \"logout\"}'),
(869, '2026-10-10 04:19:01', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(870, '2026-10-10 04:19:01', 'INSERT', 'sesiones', 191, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 191, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-09 06:19:01\"}'),
(871, '2026-10-10 04:19:46', 'UPDATE', 'sesiones', 191, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 191, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 191, \"revocado_en\": \"2026-10-10 00:19:46\", \"motivo_cierre\": \"logout\"}'),
(872, '2026-10-10 04:19:54', 'UPDATE', 'usuarios', 3, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 3, \"username\": \"hebert\", \"email\": \"hebert123@prueba.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(873, '2026-10-10 04:19:54', 'INSERT', 'sesiones', 192, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 192, \"tipo_usuario\": \"staff\", \"id_usuario\": 3, \"id_credencial\": null, \"expira_en\": \"2026-11-09 06:19:54\"}'),
(874, '2026-10-10 04:20:11', 'UPDATE', 'sesiones', 192, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 192, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 192, \"revocado_en\": \"2026-10-10 00:20:11\", \"motivo_cierre\": \"logout\"}'),
(875, '2026-10-10 04:25:03', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(876, '2026-10-10 04:25:03', 'INSERT', 'sesiones', 193, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 193, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-09 06:25:03\"}'),
(877, '2026-10-10 04:31:50', 'INSERT', 'usuarios', 7, 'staff', 1, NULL, NULL, NULL, '{\"id_usuario\": 7, \"username\": \"a\", \"email\": \"a@gamil.com\", \"estado\": \"Activo\", \"email_verified\": 0}'),
(878, '2026-10-10 04:31:56', 'DELETE', 'usuarios', 7, 'staff', 1, NULL, NULL, '{\"id_usuario\": 7, \"username\": \"a\", \"email\": \"a@gamil.com\", \"estado\": \"Activo\"}', NULL),
(879, '2026-10-10 18:24:53', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(880, '2026-10-10 18:24:53', 'INSERT', 'sesiones', 194, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 194, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-09 20:24:53\"}'),
(881, '2026-10-11 04:15:55', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(882, '2026-10-11 04:15:55', 'INSERT', 'sesiones', 195, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 195, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 06:15:55\"}'),
(883, '2026-10-11 04:44:11', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(884, '2026-10-11 04:44:11', 'INSERT', 'sesiones', 196, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 196, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 06:44:11\"}'),
(885, '2026-10-11 04:45:24', 'UPDATE', 'sesiones', 196, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 196, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 196, \"revocado_en\": \"2026-10-11 00:45:24\", \"motivo_cierre\": \"logout\"}'),
(886, '2026-10-11 04:45:32', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(887, '2026-10-11 04:45:32', 'INSERT', 'sesiones', 197, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 197, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 06:45:32\"}'),
(888, '2026-10-11 04:46:07', 'UPDATE', 'sesiones', 197, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 197, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 197, \"revocado_en\": \"2026-10-11 00:46:07\", \"motivo_cierre\": \"logout\"}'),
(889, '2026-10-11 04:46:25', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(890, '2026-10-11 04:46:25', 'INSERT', 'sesiones', 198, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 198, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 06:46:25\"}'),
(891, '2026-10-11 04:49:27', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(892, '2026-10-11 04:49:27', 'INSERT', 'sesiones', 199, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 199, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 06:49:27\"}'),
(893, '2026-10-11 04:50:16', 'UPDATE', 'sesiones', 199, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 199, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 199, \"revocado_en\": \"2026-10-11 00:50:16\", \"motivo_cierre\": \"logout\"}'),
(894, '2026-10-11 04:50:31', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(895, '2026-10-11 04:50:31', 'INSERT', 'sesiones', 200, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 200, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 06:50:31\"}'),
(896, '2026-10-11 04:55:32', 'UPDATE', 'sesiones', 200, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 200, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 200, \"revocado_en\": \"2026-10-11 00:55:32\", \"motivo_cierre\": \"logout\"}'),
(897, '2026-10-11 04:55:39', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(898, '2026-10-11 04:55:39', 'INSERT', 'sesiones', 201, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 201, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 06:55:39\"}'),
(899, '2026-10-11 05:00:35', 'UPDATE', 'sesiones', 201, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 201, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 201, \"revocado_en\": \"2026-10-11 01:00:35\", \"motivo_cierre\": \"logout\"}'),
(900, '2026-10-11 05:00:40', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(901, '2026-10-11 05:00:40', 'INSERT', 'sesiones', 202, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 202, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 07:00:40\"}'),
(902, '2026-10-11 05:01:16', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(903, '2026-10-11 05:01:16', 'INSERT', 'sesiones', 203, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 203, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 07:01:16\"}'),
(904, '2026-10-11 05:04:48', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(905, '2026-10-11 05:04:48', 'INSERT', 'sesiones', 204, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 204, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 07:04:48\"}'),
(906, '2026-10-11 05:55:46', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(907, '2026-10-11 05:55:46', 'INSERT', 'sesiones', 205, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 205, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 07:55:46\"}'),
(908, '2026-10-11 05:56:09', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(909, '2026-10-11 05:56:09', 'INSERT', 'sesiones', 206, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 206, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 07:56:09\"}'),
(910, '2026-10-11 05:57:23', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(911, '2026-10-11 05:57:23', 'INSERT', 'sesiones', 207, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 207, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 07:57:23\"}'),
(912, '2026-10-11 06:01:56', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(913, '2026-10-11 06:01:56', 'INSERT', 'sesiones', 208, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 208, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 08:01:56\"}'),
(914, '2026-10-11 06:02:34', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(915, '2026-10-11 06:02:34', 'INSERT', 'sesiones', 209, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 209, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 08:02:34\"}'),
(916, '2026-10-11 06:10:31', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(917, '2026-10-11 06:10:31', 'INSERT', 'sesiones', 210, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 210, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 08:10:31\"}'),
(918, '2026-10-11 06:11:13', 'UPDATE', 'sesiones', 210, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 210, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 210, \"revocado_en\": \"2026-10-11 02:11:13\", \"motivo_cierre\": \"logout\"}'),
(919, '2026-10-11 06:11:23', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(920, '2026-10-11 06:11:23', 'INSERT', 'sesiones', 211, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 211, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 08:11:23\"}'),
(921, '2026-10-11 17:24:10', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(922, '2026-10-11 17:24:10', 'INSERT', 'sesiones', 212, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 212, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:24:10\"}'),
(923, '2026-10-11 17:24:52', 'UPDATE', 'sesiones', 212, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 212, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 212, \"revocado_en\": \"2026-10-11 13:24:52\", \"motivo_cierre\": \"logout\"}'),
(924, '2026-10-11 17:25:01', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(925, '2026-10-11 17:25:01', 'INSERT', 'sesiones', 213, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 213, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:25:01\"}'),
(926, '2026-10-11 17:26:13', 'UPDATE', 'sesiones', 213, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 213, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 213, \"revocado_en\": \"2026-10-11 13:26:13\", \"motivo_cierre\": \"logout\"}'),
(927, '2026-10-11 17:26:20', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(928, '2026-10-11 17:26:20', 'INSERT', 'sesiones', 214, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 214, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:26:20\"}'),
(929, '2026-10-11 17:26:46', 'UPDATE', 'sesiones', 214, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 214, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 214, \"revocado_en\": \"2026-10-11 13:26:46\", \"motivo_cierre\": \"logout\"}'),
(930, '2026-10-11 17:26:54', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(931, '2026-10-11 17:26:54', 'INSERT', 'sesiones', 215, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 215, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:26:54\"}'),
(932, '2026-10-11 17:32:24', 'UPDATE', 'sesiones', 215, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 215, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 215, \"revocado_en\": \"2026-10-11 13:32:24\", \"motivo_cierre\": \"logout\"}'),
(933, '2026-10-11 17:32:31', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(934, '2026-10-11 17:32:31', 'INSERT', 'sesiones', 216, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 216, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:32:31\"}'),
(935, '2026-10-11 17:33:05', 'UPDATE', 'sesiones', 216, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 216, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 216, \"revocado_en\": \"2026-10-11 13:33:05\", \"motivo_cierre\": \"logout\"}'),
(936, '2026-10-11 17:33:12', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(937, '2026-10-11 17:33:12', 'INSERT', 'sesiones', 217, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 217, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:33:12\"}'),
(938, '2026-10-11 17:33:35', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(939, '2026-10-11 17:33:35', 'INSERT', 'sesiones', 218, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 218, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:33:35\"}'),
(940, '2026-10-11 17:35:09', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(941, '2026-10-11 17:35:09', 'INSERT', 'sesiones', 219, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 219, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:35:09\"}'),
(942, '2026-10-11 17:35:59', 'UPDATE', 'sesiones', 219, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 219, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 219, \"revocado_en\": \"2026-10-11 13:35:59\", \"motivo_cierre\": \"logout\"}'),
(943, '2026-10-11 17:36:07', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(944, '2026-10-11 17:36:07', 'INSERT', 'sesiones', 220, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 220, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:36:07\"}'),
(945, '2026-10-11 17:36:35', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(946, '2026-10-11 17:36:35', 'INSERT', 'sesiones', 221, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 221, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:36:35\"}'),
(947, '2026-10-11 17:36:57', 'UPDATE', 'sesiones', 221, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 221, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 221, \"revocado_en\": \"2026-10-11 13:36:57\", \"motivo_cierre\": \"logout\"}'),
(948, '2026-10-11 17:37:53', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(949, '2026-10-11 17:37:53', 'INSERT', 'sesiones', 222, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 222, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:37:53\"}'),
(950, '2026-10-11 17:38:19', 'UPDATE', 'sesiones', 222, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 222, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 222, \"revocado_en\": \"2026-10-11 13:38:19\", \"motivo_cierre\": \"logout\"}'),
(951, '2026-10-11 17:38:27', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(952, '2026-10-11 17:38:27', 'INSERT', 'sesiones', 223, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 223, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:38:27\"}'),
(953, '2026-10-11 17:38:54', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(954, '2026-10-11 17:38:54', 'INSERT', 'sesiones', 224, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 224, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:38:54\"}'),
(955, '2026-10-11 17:45:01', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(956, '2026-10-11 17:45:09', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(957, '2026-10-11 17:45:09', 'INSERT', 'sesiones', 225, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 225, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:45:09\"}'),
(958, '2026-10-11 17:45:59', 'UPDATE', 'sesiones', 225, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 225, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 225, \"revocado_en\": \"2026-10-11 13:45:59\", \"motivo_cierre\": \"logout\"}'),
(959, '2026-10-11 17:46:10', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(960, '2026-10-11 17:46:10', 'INSERT', 'sesiones', 226, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 226, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:46:10\"}'),
(961, '2026-10-11 17:48:10', 'UPDATE', 'sesiones', 226, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 226, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 226, \"revocado_en\": \"2026-10-11 13:48:10\", \"motivo_cierre\": \"logout\"}'),
(962, '2026-10-11 17:48:18', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(963, '2026-10-11 17:48:18', 'INSERT', 'sesiones', 227, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 227, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-10 19:48:18\"}'),
(964, '2026-10-11 21:45:02', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(965, '2026-10-11 21:45:02', 'INSERT', 'sesiones', 228, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 228, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-10 23:45:02\"}'),
(966, '2026-10-11 21:45:26', 'INSERT', 'servicios', 15, 'staff', 1, NULL, NULL, NULL, '{\"id_servicio\": 15, \"id_cliente\": 17, \"alias\": \"Principal\", \"estado_comercial\": \"pendiente\", \"id_plan\": 1, \"id_naps\": null}'),
(967, '2026-10-11 22:27:31', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(968, '2026-10-11 22:27:32', 'INSERT', 'sesiones', 229, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 229, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 00:27:32\"}'),
(969, '2026-10-11 22:31:03', 'DELETE', 'servicios', 15, 'staff', 1, NULL, NULL, '{\"id_servicio\": 15, \"id_cliente\": 17, \"alias\": \"Principal\", \"estado_comercial\": \"pendiente\", \"id_plan\": 1, \"id_naps\": null}', NULL),
(970, '2026-10-11 22:31:22', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(971, '2026-10-11 22:31:22', 'INSERT', 'sesiones', 230, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 230, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 00:31:22\"}'),
(972, '2026-10-11 22:33:38', 'INSERT', 'servicios', 16, 'staff', 1, NULL, NULL, NULL, '{\"id_servicio\": 16, \"id_cliente\": 17, \"alias\": \"wiwi\", \"estado_comercial\": \"pendiente\", \"id_plan\": 1, \"id_naps\": 11}'),
(973, '2026-10-11 22:34:46', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(974, '2026-10-11 22:34:46', 'INSERT', 'sesiones', 231, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 231, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 00:34:46\"}'),
(975, '2026-10-11 22:36:37', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(976, '2026-10-11 22:36:37', 'INSERT', 'sesiones', 232, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 232, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 00:36:37\"}'),
(977, '2026-10-11 22:37:04', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(978, '2026-10-11 22:37:04', 'INSERT', 'sesiones', 233, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 233, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 00:37:04\"}'),
(979, '2026-10-11 22:40:15', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(980, '2026-10-11 22:40:15', 'INSERT', 'sesiones', 234, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 234, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-11 00:40:15\"}'),
(981, '2026-10-11 22:41:45', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(982, '2026-10-11 22:41:45', 'INSERT', 'sesiones', 235, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 235, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 00:41:45\"}'),
(983, '2026-10-11 22:42:50', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(984, '2026-10-11 22:42:50', 'INSERT', 'sesiones', 236, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 236, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 00:42:50\"}'),
(985, '2026-10-11 23:16:25', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(986, '2026-10-11 23:16:25', 'INSERT', 'sesiones', 237, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 237, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 01:16:25\"}'),
(987, '2026-10-11 23:21:33', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(988, '2026-10-11 23:21:33', 'INSERT', 'sesiones', 238, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 238, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 01:21:33\"}'),
(989, '2026-10-11 23:22:55', 'UPDATE', 'sesiones', 238, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 238, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 238, \"revocado_en\": \"2026-10-11 19:22:55\", \"motivo_cierre\": \"logout\"}'),
(990, '2026-10-11 23:23:07', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(991, '2026-10-11 23:23:07', 'INSERT', 'sesiones', 239, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 239, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 01:23:07\"}'),
(992, '2026-10-11 23:24:14', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(993, '2026-10-11 23:24:14', 'INSERT', 'sesiones', 240, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 240, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 01:24:14\"}'),
(994, '2026-10-11 23:24:31', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(995, '2026-10-11 23:24:31', 'INSERT', 'sesiones', 241, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 241, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 01:24:31\"}'),
(996, '2026-10-11 23:27:00', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(997, '2026-10-11 23:27:00', 'INSERT', 'sesiones', 242, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 242, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 01:27:00\"}'),
(998, '2026-10-11 23:31:09', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}');
INSERT INTO `logs` (`id_log`, `creado_en`, `accion`, `tabla_afectada`, `id_registro_afectado`, `tipo_actor`, `id_usuario`, `id_credencial`, `ip_address`, `old_value`, `new_value`) VALUES
(999, '2026-10-11 23:31:09', 'INSERT', 'sesiones', 243, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 243, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 01:31:09\"}'),
(1000, '2026-10-11 23:32:08', 'INSERT', 'facturas', 16, 'staff', 1, NULL, NULL, NULL, '{\"id_factura\": 16, \"id_servicio\": 16, \"periodo\": \"2026-01\", \"monto\": 50.00, \"estado\": \"pendiente\"}'),
(1001, '2026-10-11 23:32:40', 'UPDATE', 'facturas', 16, 'staff', 1, NULL, NULL, '{\"id_factura\": 16, \"id_servicio\": 16, \"periodo\": \"2026-01\", \"monto\": 50.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 16, \"id_servicio\": 16, \"periodo\": \"2026-01\", \"monto\": 10.00, \"estado\": \"pendiente\"}'),
(1002, '2026-10-11 23:33:39', 'INSERT', 'contratos', 13, 'staff', 1, NULL, NULL, NULL, '{\"id_contrato\": 13, \"id_servicio\": 16, \"fecha_inicio\": \"2026-10-11\", \"fecha_fin\": \"2026-10-12\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}'),
(1003, '2026-10-11 23:33:49', 'UPDATE', 'contratos', 13, 'staff', 1, NULL, NULL, '{\"id_contrato\": 13, \"id_servicio\": 16, \"fecha_inicio\": \"2026-10-11\", \"fecha_fin\": \"2026-10-12\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}', '{\"id_contrato\": 13, \"id_servicio\": 16, \"fecha_inicio\": \"2026-10-11\", \"fecha_fin\": \"2026-10-12\", \"tipo_contrato\": \"indefinido\", \"estado\": \"rescindido\"}'),
(1004, '2026-10-11 23:33:49', 'UPDATE', 'servicios', 16, 'staff', 1, NULL, NULL, '{\"id_servicio\": 16, \"id_cliente\": 17, \"alias\": \"wiwi\", \"estado_comercial\": \"pendiente\", \"id_plan\": 1, \"id_naps\": 11}', '{\"id_servicio\": 16, \"id_cliente\": 17, \"alias\": \"wiwi\", \"estado_comercial\": \"retirado\", \"id_plan\": 1, \"id_naps\": 11}'),
(1005, '2026-10-11 23:34:30', 'DELETE', 'contratos', 13, 'staff', 1, NULL, NULL, '{\"id_contrato\": 13, \"id_servicio\": 16, \"fecha_inicio\": \"2026-10-11\", \"fecha_fin\": \"2026-10-12\", \"tipo_contrato\": \"indefinido\", \"estado\": \"rescindido\"}', NULL),
(1006, '2026-10-11 23:34:39', 'DELETE', 'facturas', 16, 'staff', 1, NULL, NULL, '{\"id_factura\": 16, \"id_servicio\": 16, \"periodo\": \"2026-01\", \"monto\": 10.00, \"estado\": \"pendiente\"}', NULL),
(1007, '2026-10-11 23:38:30', 'INSERT', 'facturas', 18, 'sistema', NULL, NULL, NULL, NULL, '{\"id_factura\": 18, \"id_servicio\": 1, \"periodo\": \"2020-01\", \"monto\": 5.00, \"estado\": \"pendiente\"}'),
(1008, '2026-10-11 23:40:07', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1009, '2026-10-11 23:40:07', 'INSERT', 'sesiones', 244, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 244, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 01:40:07\"}'),
(1010, '2026-10-11 23:40:08', 'UPDATE', 'facturas', 18, 'staff', 1, NULL, NULL, '{\"id_factura\": 18, \"id_servicio\": 1, \"periodo\": \"2020-01\", \"monto\": 5.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 18, \"id_servicio\": 1, \"periodo\": \"2020-01\", \"monto\": 5.00, \"estado\": \"vencida\"}'),
(1011, '2026-10-11 23:44:39', 'DELETE', 'facturas', 18, 'sistema', NULL, NULL, NULL, '{\"id_factura\": 18, \"id_servicio\": 1, \"periodo\": \"2020-01\", \"monto\": 5.00, \"estado\": \"vencida\"}', NULL),
(1012, '2026-10-11 23:44:39', 'INSERT', 'facturas', 19, 'sistema', NULL, NULL, NULL, NULL, '{\"id_factura\": 19, \"id_servicio\": 1, \"periodo\": \"2020-01\", \"monto\": 5.00, \"estado\": \"pendiente\"}'),
(1013, '2026-10-11 23:46:16', 'UPDATE', 'facturas', 19, 'staff', 1, NULL, NULL, '{\"id_factura\": 19, \"id_servicio\": 1, \"periodo\": \"2020-01\", \"monto\": 5.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 19, \"id_servicio\": 1, \"periodo\": \"2020-01\", \"monto\": 5.00, \"estado\": \"vencida\"}'),
(1014, '2026-10-11 23:46:55', 'DELETE', 'facturas', 19, 'sistema', NULL, NULL, NULL, '{\"id_factura\": 19, \"id_servicio\": 1, \"periodo\": \"2020-01\", \"monto\": 5.00, \"estado\": \"vencida\"}', NULL),
(1015, '2026-10-12 19:28:05', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1016, '2026-10-12 19:28:06', 'INSERT', 'sesiones', 245, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 245, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 21:28:06\"}'),
(1017, '2026-10-12 19:44:52', 'INSERT', 'contratos', 14, 'staff', 1, NULL, NULL, NULL, '{\"id_contrato\": 14, \"id_servicio\": 13, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": null, \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}'),
(1018, '2026-10-12 19:45:23', 'DELETE', 'contratos', 14, 'sistema', NULL, NULL, NULL, '{\"id_contrato\": 14, \"id_servicio\": 13, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": null, \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}', NULL),
(1019, '2026-10-12 19:47:39', 'UPDATE', 'facturas', 13, 'staff', 1, NULL, NULL, '{\"id_factura\": 13, \"id_servicio\": 12, \"periodo\": \"2026-06\", \"monto\": 30.00, \"estado\": \"pagada\"}', '{\"id_factura\": 13, \"id_servicio\": 12, \"periodo\": \"2026-06\", \"monto\": 30.00, \"estado\": \"pagada\"}'),
(1020, '2026-10-12 19:47:48', 'UPDATE', 'contratos', 10, 'staff', 1, NULL, NULL, '{\"id_contrato\": 10, \"id_servicio\": 10, \"fecha_inicio\": \"2026-01-01\", \"fecha_fin\": null, \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}', '{\"id_contrato\": 10, \"id_servicio\": 10, \"fecha_inicio\": \"2026-01-01\", \"fecha_fin\": null, \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}'),
(1021, '2026-10-12 19:49:21', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1022, '2026-10-12 19:49:21', 'INSERT', 'sesiones', 246, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 246, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 21:49:21\"}'),
(1023, '2026-10-12 19:56:20', 'INSERT', 'contratos', 15, 'staff', 1, NULL, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}'),
(1024, '2026-10-12 19:59:21', 'INSERT', 'contratos', 16, 'staff', 1, NULL, NULL, NULL, '{\"id_contrato\": 16, \"id_servicio\": 12, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-12\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}'),
(1025, '2026-10-12 20:03:24', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1026, '2026-10-12 20:03:24', 'INSERT', 'sesiones', 247, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 247, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 22:03:24\"}'),
(1027, '2026-10-12 20:04:49', 'UPDATE', 'sesiones', 247, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 247, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 247, \"revocado_en\": \"2026-10-12 16:04:49\", \"motivo_cierre\": \"logout\"}'),
(1028, '2026-10-12 20:04:59', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1029, '2026-10-12 20:04:59', 'INSERT', 'sesiones', 248, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 248, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-11 22:04:59\"}'),
(1030, '2026-10-12 21:20:57', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1031, '2026-10-12 21:22:59', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1032, '2026-10-12 21:22:59', 'INSERT', 'sesiones', 249, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 249, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 23:22:59\"}'),
(1033, '2026-10-12 21:23:54', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1034, '2026-10-12 21:24:09', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1035, '2026-10-12 21:24:09', 'INSERT', 'sesiones', 250, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 250, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-11 23:24:09\"}'),
(1036, '2026-10-12 21:30:40', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1037, '2026-10-12 21:30:40', 'INSERT', 'sesiones', 251, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 251, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 23:30:40\"}'),
(1038, '2026-10-12 21:39:43', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1039, '2026-10-12 21:39:43', 'INSERT', 'sesiones', 252, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 252, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 23:39:43\"}'),
(1040, '2026-10-12 21:40:46', 'UPDATE', 'sesiones', 252, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 252, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 252, \"revocado_en\": \"2026-10-12 17:40:46\", \"motivo_cierre\": \"logout\"}'),
(1041, '2026-10-12 21:40:54', 'UPDATE', 'usuarios', 2, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 2, \"username\": \"Marcos\", \"email\": \"marcos@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1042, '2026-10-12 21:40:54', 'INSERT', 'sesiones', 253, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 253, \"tipo_usuario\": \"staff\", \"id_usuario\": 2, \"id_credencial\": null, \"expira_en\": \"2026-11-11 23:40:54\"}'),
(1043, '2026-10-12 21:42:53', 'UPDATE', 'sesiones', 253, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 253, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 253, \"revocado_en\": \"2026-10-12 17:42:53\", \"motivo_cierre\": \"logout\"}'),
(1044, '2026-10-12 21:42:59', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1045, '2026-10-12 21:42:59', 'INSERT', 'sesiones', 254, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 254, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 23:42:59\"}'),
(1046, '2026-10-12 21:45:06', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1047, '2026-10-12 21:45:06', 'INSERT', 'sesiones', 255, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 255, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-11 23:45:06\"}'),
(1048, '2026-10-12 21:45:13', 'UPDATE', 'sesiones', 255, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 255, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 255, \"revocado_en\": \"2026-10-12 17:45:13\", \"motivo_cierre\": \"logout\"}'),
(1049, '2026-10-12 22:17:35', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1050, '2026-10-12 22:17:35', 'INSERT', 'sesiones', 256, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 256, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 00:17:35\"}'),
(1051, '2026-10-12 22:19:26', 'UPDATE', 'sesiones', 256, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 256, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 256, \"revocado_en\": \"2026-10-12 18:19:26\", \"motivo_cierre\": \"logout\"}'),
(1052, '2026-10-12 22:19:43', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1053, '2026-10-12 22:19:43', 'INSERT', 'sesiones', 257, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 257, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 00:19:43\"}'),
(1054, '2026-10-12 22:42:42', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1055, '2026-10-12 22:42:42', 'INSERT', 'sesiones', 258, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 258, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 00:42:42\"}'),
(1056, '2026-10-12 22:43:29', 'UPDATE', 'sesiones', 258, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 258, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 258, \"revocado_en\": \"2026-10-12 18:43:29\", \"motivo_cierre\": \"logout\"}'),
(1057, '2026-10-12 22:43:36', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1058, '2026-10-12 22:43:36', 'INSERT', 'sesiones', 259, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 259, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 00:43:36\"}'),
(1059, '2026-10-12 22:43:51', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1060, '2026-10-12 22:43:51', 'INSERT', 'sesiones', 260, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 260, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 00:43:51\"}'),
(1061, '2026-10-13 06:25:16', 'INSERT', 'categorias_ticket', 5, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 5, \"nombre\": \"Soporte t├®cnico\", \"activa\": 1}'),
(1062, '2026-10-13 06:25:16', 'INSERT', 'categorias_ticket', 6, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 6, \"nombre\": \"Facturaci├│n\", \"activa\": 1}'),
(1063, '2026-10-13 06:25:16', 'INSERT', 'categorias_ticket', 7, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 7, \"nombre\": \"Instalaci├│n\", \"activa\": 1}'),
(1064, '2026-10-13 06:25:16', 'INSERT', 'categorias_ticket', 8, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 8, \"nombre\": \"Baja de servicio\", \"activa\": 1}'),
(1065, '2026-10-13 06:29:12', 'DELETE', 'categorias_ticket', 5, 'sistema', NULL, NULL, NULL, '{\"id_categoria\": 5, \"nombre\": \"Soporte t├®cnico\", \"activa\": 1}', NULL),
(1066, '2026-10-13 06:29:12', 'DELETE', 'categorias_ticket', 6, 'sistema', NULL, NULL, NULL, '{\"id_categoria\": 6, \"nombre\": \"Facturaci├│n\", \"activa\": 1}', NULL),
(1067, '2026-10-13 06:29:12', 'DELETE', 'categorias_ticket', 7, 'sistema', NULL, NULL, NULL, '{\"id_categoria\": 7, \"nombre\": \"Instalaci├│n\", \"activa\": 1}', NULL),
(1068, '2026-10-13 06:29:12', 'DELETE', 'categorias_ticket', 8, 'sistema', NULL, NULL, NULL, '{\"id_categoria\": 8, \"nombre\": \"Baja de servicio\", \"activa\": 1}', NULL),
(1069, '2026-10-13 06:30:37', 'INSERT', 'categorias_ticket', 1, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 1, \"nombre\": \"Soporte t├®cnico\", \"activa\": 1}'),
(1070, '2026-10-13 06:30:37', 'INSERT', 'categorias_ticket', 2, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 2, \"nombre\": \"Facturaci├│n\", \"activa\": 1}'),
(1071, '2026-10-13 06:30:37', 'INSERT', 'categorias_ticket', 3, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 3, \"nombre\": \"Instalaci├│n\", \"activa\": 1}'),
(1072, '2026-10-13 06:30:37', 'INSERT', 'categorias_ticket', 4, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 4, \"nombre\": \"Baja de servicio\", \"activa\": 1}'),
(1073, '2026-10-13 06:30:37', 'INSERT', 'sla_definiciones', 1, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sla\": 1, \"id_categoria\": 1, \"prioridad\": \"Alta\", \"horas_respuesta\": 1, \"horas_resolucion\": 4}'),
(1074, '2026-10-13 06:30:37', 'INSERT', 'sla_definiciones', 2, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sla\": 2, \"id_categoria\": 1, \"prioridad\": \"Media\", \"horas_respuesta\": 4, \"horas_resolucion\": 24}'),
(1075, '2026-10-13 06:30:37', 'INSERT', 'sla_definiciones', 3, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sla\": 3, \"id_categoria\": 2, \"prioridad\": \"Alta\", \"horas_respuesta\": 2, \"horas_resolucion\": 8}'),
(1076, '2026-10-13 06:30:37', 'INSERT', 'metodos_pago', 1, 'sistema', NULL, NULL, NULL, NULL, '{\"id_metodo\": 1, \"codigo\": \"transferencia\", \"nombre\": \"Transferencia bancaria\", \"activo\": 1}'),
(1077, '2026-10-13 06:30:37', 'INSERT', 'metodos_pago', 2, 'sistema', NULL, NULL, NULL, NULL, '{\"id_metodo\": 2, \"codigo\": \"pago_movil\", \"nombre\": \"Pago m├│vil\", \"activo\": 1}'),
(1078, '2026-10-13 06:30:37', 'INSERT', 'metodos_pago', 3, 'sistema', NULL, NULL, NULL, NULL, '{\"id_metodo\": 3, \"codigo\": \"zelle\", \"nombre\": \"Zelle\", \"activo\": 1}'),
(1079, '2026-10-13 06:30:37', 'INSERT', 'metodos_pago', 4, 'sistema', NULL, NULL, NULL, NULL, '{\"id_metodo\": 4, \"codigo\": \"efectivo\", \"nombre\": \"Efectivo\", \"activo\": 1}'),
(1080, '2026-10-13 06:59:45', 'DELETE', 'sla_definiciones', 1, 'sistema', NULL, NULL, NULL, '{\"id_sla\": 1, \"id_categoria\": 1, \"prioridad\": \"Alta\", \"horas_respuesta\": 1, \"horas_resolucion\": 4}', NULL),
(1081, '2026-10-13 06:59:45', 'DELETE', 'sla_definiciones', 2, 'sistema', NULL, NULL, NULL, '{\"id_sla\": 2, \"id_categoria\": 1, \"prioridad\": \"Media\", \"horas_respuesta\": 4, \"horas_resolucion\": 24}', NULL),
(1082, '2026-10-13 06:59:45', 'DELETE', 'sla_definiciones', 3, 'sistema', NULL, NULL, NULL, '{\"id_sla\": 3, \"id_categoria\": 2, \"prioridad\": \"Alta\", \"horas_respuesta\": 2, \"horas_resolucion\": 8}', NULL),
(1083, '2026-10-13 06:59:45', 'DELETE', 'categorias_ticket', 1, 'sistema', NULL, NULL, NULL, '{\"id_categoria\": 1, \"nombre\": \"Soporte t├®cnico\", \"activa\": 1}', NULL),
(1084, '2026-10-13 06:59:45', 'DELETE', 'categorias_ticket', 2, 'sistema', NULL, NULL, NULL, '{\"id_categoria\": 2, \"nombre\": \"Facturaci├│n\", \"activa\": 1}', NULL),
(1085, '2026-10-13 06:59:45', 'DELETE', 'categorias_ticket', 3, 'sistema', NULL, NULL, NULL, '{\"id_categoria\": 3, \"nombre\": \"Instalaci├│n\", \"activa\": 1}', NULL),
(1086, '2026-10-13 06:59:45', 'DELETE', 'categorias_ticket', 4, 'sistema', NULL, NULL, NULL, '{\"id_categoria\": 4, \"nombre\": \"Baja de servicio\", \"activa\": 1}', NULL),
(1087, '2026-10-13 06:59:45', 'DELETE', 'metodos_pago', 1, 'sistema', NULL, NULL, NULL, '{\"id_metodo\": 1, \"codigo\": \"transferencia\", \"nombre\": \"Transferencia bancaria\", \"activo\": 1}', NULL),
(1088, '2026-10-13 06:59:45', 'DELETE', 'metodos_pago', 2, 'sistema', NULL, NULL, NULL, '{\"id_metodo\": 2, \"codigo\": \"pago_movil\", \"nombre\": \"Pago m├│vil\", \"activo\": 1}', NULL),
(1089, '2026-10-13 06:59:45', 'DELETE', 'metodos_pago', 3, 'sistema', NULL, NULL, NULL, '{\"id_metodo\": 3, \"codigo\": \"zelle\", \"nombre\": \"Zelle\", \"activo\": 1}', NULL),
(1090, '2026-10-13 06:59:45', 'DELETE', 'metodos_pago', 4, 'sistema', NULL, NULL, NULL, '{\"id_metodo\": 4, \"codigo\": \"efectivo\", \"nombre\": \"Efectivo\", \"activo\": 1}', NULL),
(1091, '2026-10-13 07:00:17', 'INSERT', 'categorias_ticket', 1, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 1, \"nombre\": \"Soporte técnico\", \"activa\": 1}'),
(1092, '2026-10-13 07:00:17', 'INSERT', 'categorias_ticket', 2, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 2, \"nombre\": \"Facturación\", \"activa\": 1}'),
(1093, '2026-10-13 07:00:17', 'INSERT', 'categorias_ticket', 3, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 3, \"nombre\": \"Instalación\", \"activa\": 1}'),
(1094, '2026-10-13 07:00:17', 'INSERT', 'categorias_ticket', 4, 'sistema', NULL, NULL, NULL, NULL, '{\"id_categoria\": 4, \"nombre\": \"Baja de servicio\", \"activa\": 1}'),
(1095, '2026-10-13 07:00:17', 'INSERT', 'sla_definiciones', 1, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sla\": 1, \"id_categoria\": 1, \"prioridad\": \"Alta\", \"horas_respuesta\": 1, \"horas_resolucion\": 4}'),
(1096, '2026-10-13 07:00:17', 'INSERT', 'sla_definiciones', 2, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sla\": 2, \"id_categoria\": 1, \"prioridad\": \"Media\", \"horas_respuesta\": 4, \"horas_resolucion\": 24}'),
(1097, '2026-10-13 07:00:17', 'INSERT', 'sla_definiciones', 3, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sla\": 3, \"id_categoria\": 2, \"prioridad\": \"Alta\", \"horas_respuesta\": 2, \"horas_resolucion\": 8}'),
(1098, '2026-10-13 07:00:17', 'INSERT', 'metodos_pago', 1, 'sistema', NULL, NULL, NULL, NULL, '{\"id_metodo\": 1, \"codigo\": \"transferencia\", \"nombre\": \"Transferencia bancaria\", \"activo\": 1}'),
(1099, '2026-10-13 07:00:17', 'INSERT', 'metodos_pago', 2, 'sistema', NULL, NULL, NULL, NULL, '{\"id_metodo\": 2, \"codigo\": \"pago_movil\", \"nombre\": \"Pago móvil\", \"activo\": 1}'),
(1100, '2026-10-13 07:00:17', 'INSERT', 'metodos_pago', 3, 'sistema', NULL, NULL, NULL, NULL, '{\"id_metodo\": 3, \"codigo\": \"zelle\", \"nombre\": \"Zelle\", \"activo\": 1}'),
(1101, '2026-10-13 07:00:17', 'INSERT', 'metodos_pago', 4, 'sistema', NULL, NULL, NULL, NULL, '{\"id_metodo\": 4, \"codigo\": \"efectivo\", \"nombre\": \"Efectivo\", \"activo\": 1}'),
(1102, '2026-10-13 14:29:22', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1103, '2026-10-13 14:29:24', 'INSERT', 'sesiones', 261, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 261, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 16:29:24\"}'),
(1104, '2026-10-13 14:29:27', 'UPDATE', 'contratos', 16, 'staff', 1, NULL, NULL, '{\"id_contrato\": 16, \"id_servicio\": 12, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-12\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}', '{\"id_contrato\": 16, \"id_servicio\": 12, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-12\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vencido\"}'),
(1105, '2026-10-13 14:30:10', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1106, '2026-10-13 14:30:10', 'INSERT', 'sesiones', 262, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 262, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 16:30:10\"}'),
(1107, '2026-10-13 15:00:45', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1108, '2026-10-13 15:00:45', 'INSERT', 'sesiones', 263, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 263, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 16:00:45\"}'),
(1109, '2026-10-13 15:07:14', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1110, '2026-10-13 15:07:14', 'INSERT', 'sesiones', 264, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 264, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 15:07:14\"}'),
(1111, '2026-10-13 15:14:03', 'UPDATE', 'servicios', 4, 'sistema', NULL, NULL, NULL, '{\"id_servicio\": 4, \"id_cliente\": 1, \"alias\": \"casa principal\", \"estado_comercial\": \"activo\", \"id_plan\": 2, \"id_naps\": 1}', '{\"id_servicio\": 4, \"id_cliente\": 1, \"alias\": \"casa principal\", \"estado_comercial\": \"activo\", \"id_plan\": 2, \"id_naps\": 1}'),
(1112, '2026-10-13 16:18:41', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1113, '2026-10-13 16:18:42', 'INSERT', 'sesiones', 265, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 265, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 16:18:42\"}'),
(1114, '2026-10-13 16:20:19', 'INSERT', 'facturas', 21, 'staff', 1, NULL, NULL, NULL, '{\"id_factura\": 21, \"id_servicio\": 13, \"periodo\": \"2026-01\", \"monto\": 100.00, \"estado\": \"pendiente\"}'),
(1115, '2026-10-13 16:24:36', 'INSERT', 'facturas', 22, 'staff', 1, NULL, NULL, NULL, '{\"id_factura\": 22, \"id_servicio\": 13, \"periodo\": \"2026-03\", \"monto\": 100.00, \"estado\": \"pendiente\"}'),
(1116, '2026-10-13 16:49:55', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1117, '2026-10-13 16:49:55', 'INSERT', 'sesiones', 266, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 266, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 16:49:55\"}'),
(1118, '2026-10-13 16:51:43', 'INSERT', 'facturas', 23, 'staff', 1, NULL, NULL, NULL, '{\"id_factura\": 23, \"id_servicio\": 13, \"periodo\": \"2028-01\", \"monto\": 30.00, \"estado\": \"pendiente\"}'),
(1119, '2026-10-13 17:10:05', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1120, '2026-10-13 17:10:05', 'INSERT', 'sesiones', 267, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 267, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 17:10:05\"}'),
(1121, '2026-10-13 17:11:47', 'INSERT', 'facturas', 24, 'staff', 1, NULL, NULL, NULL, '{\"id_factura\": 24, \"id_servicio\": 1, \"periodo\": \"2026-04\", \"monto\": 30.00, \"estado\": \"pendiente\"}'),
(1122, '2026-10-13 17:20:47', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1123, '2026-10-13 17:20:48', 'INSERT', 'sesiones', 268, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 268, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 17:20:48\"}'),
(1124, '2026-10-13 17:23:19', 'INSERT', 'pagos', 14, 'staff', 1, NULL, NULL, NULL, '{\"id_pago\": 14, \"id_factura\": 23, \"monto\": 30.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}'),
(1125, '2026-10-13 17:24:53', 'INSERT', 'pagos', 15, 'staff', 1, NULL, NULL, NULL, '{\"id_pago\": 15, \"id_factura\": 24, \"monto\": 30.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}'),
(1126, '2026-10-13 17:26:39', 'UPDATE', 'pagos', 15, 'staff', 1, NULL, NULL, '{\"id_pago\": 15, \"id_factura\": 24, \"monto\": 30.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}', '{\"id_pago\": 15, \"id_factura\": 24, \"monto\": 30.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}'),
(1127, '2026-10-13 17:26:39', 'UPDATE', 'facturas', 24, 'staff', 1, NULL, NULL, '{\"id_factura\": 24, \"id_servicio\": 1, \"periodo\": \"2026-04\", \"monto\": 30.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 24, \"id_servicio\": 1, \"periodo\": \"2026-04\", \"monto\": 30.00, \"estado\": \"pendiente\"}'),
(1128, '2026-10-13 17:27:06', 'DELETE', 'pagos', 14, 'sistema', NULL, NULL, NULL, '{\"id_pago\": 14, \"id_factura\": 23, \"monto\": 30.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}', NULL),
(1129, '2026-10-13 17:27:06', 'DELETE', 'pagos', 15, 'sistema', NULL, NULL, NULL, '{\"id_pago\": 15, \"id_factura\": 24, \"monto\": 30.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}', NULL),
(1130, '2026-10-13 18:24:17', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1131, '2026-10-13 18:24:17', 'INSERT', 'sesiones', 269, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 269, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 18:24:17\"}'),
(1132, '2026-10-13 19:17:00', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1133, '2026-10-13 19:17:00', 'INSERT', 'sesiones', 270, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 270, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 19:17:00\"}'),
(1134, '2026-10-13 19:42:55', 'UPDATE', 'pagos', 10, 'sistema', NULL, NULL, NULL, '{\"id_pago\": 10, \"id_factura\": 10, \"monto\": 15.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}', '{\"id_pago\": 10, \"id_factura\": 10, \"monto\": 15.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}'),
(1135, '2026-10-13 19:42:55', 'UPDATE', 'pagos', 12, 'sistema', NULL, NULL, NULL, '{\"id_pago\": 12, \"id_factura\": null, \"monto\": 20.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}', '{\"id_pago\": 12, \"id_factura\": null, \"monto\": 20.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}'),
(1136, '2026-10-13 19:42:55', 'UPDATE', 'pagos', 11, 'sistema', NULL, NULL, NULL, '{\"id_pago\": 11, \"id_factura\": 13, \"monto\": 30.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}', '{\"id_pago\": 11, \"id_factura\": 13, \"monto\": 30.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}'),
(1137, '2026-10-13 19:42:55', 'UPDATE', 'pagos', 13, 'sistema', NULL, NULL, NULL, '{\"id_pago\": 13, \"id_factura\": 15, \"monto\": 1000.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}', '{\"id_pago\": 13, \"id_factura\": 15, \"monto\": 1000.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}'),
(1138, '2026-10-13 20:57:09', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1139, '2026-10-13 20:57:09', 'INSERT', 'sesiones', 271, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 271, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 20:57:09\"}'),
(1140, '2026-10-13 20:58:32', 'INSERT', 'pagos', 16, 'staff', 1, NULL, NULL, NULL, '{\"id_pago\": 16, \"id_factura\": 10, \"monto\": 15.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}'),
(1141, '2026-10-13 21:00:35', 'UPDATE', 'pagos', 12, 'staff', 1, NULL, NULL, '{\"id_pago\": 12, \"id_factura\": null, \"monto\": 20.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}', '{\"id_pago\": 12, \"id_factura\": null, \"monto\": 20.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}'),
(1142, '2026-10-13 21:00:53', 'UPDATE', 'pagos', 13, 'staff', 1, NULL, NULL, '{\"id_pago\": 13, \"id_factura\": 15, \"monto\": 1000.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}', '{\"id_pago\": 13, \"id_factura\": 15, \"monto\": 1000.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}'),
(1143, '2026-10-13 21:00:53', 'UPDATE', 'facturas', 15, 'staff', 1, NULL, NULL, '{\"id_factura\": 15, \"id_servicio\": 1, \"periodo\": \"2026-07\", \"monto\": 3000.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 15, \"id_servicio\": 1, \"periodo\": \"2026-07\", \"monto\": 3000.00, \"estado\": \"pendiente\"}'),
(1144, '2026-10-13 21:18:19', 'UPDATE', 'pagos', 16, 'staff', 1, NULL, NULL, '{\"id_pago\": 16, \"id_factura\": 10, \"monto\": 15.00, \"estado\": \"pendiente\", \"id_usuario_valido\": null}', '{\"id_pago\": 16, \"id_factura\": null, \"monto\": 15.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}'),
(1145, '2026-10-13 21:18:19', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 20.00, \"estado\": \"parcial\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 20.00, \"estado\": \"parcial\"}'),
(1146, '2026-10-13 21:18:55', 'UPDATE', 'pagos', 16, 'staff', 1, NULL, NULL, '{\"id_pago\": 16, \"id_factura\": null, \"monto\": 15.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}', '{\"id_pago\": 16, \"id_factura\": 10, \"monto\": 15.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}'),
(1147, '2026-10-13 21:18:55', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 20.00, \"estado\": \"parcial\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 20.00, \"estado\": \"pagada\"}'),
(1148, '2026-10-13 21:19:17', 'UPDATE', 'pagos', 12, 'staff', 1, NULL, NULL, '{\"id_pago\": 12, \"id_factura\": null, \"monto\": 20.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}', '{\"id_pago\": 12, \"id_factura\": 23, \"monto\": 20.00, \"estado\": \"validado\", \"id_usuario_valido\": 1}'),
(1149, '2026-10-13 21:19:17', 'UPDATE', 'facturas', 23, 'staff', 1, NULL, NULL, '{\"id_factura\": 23, \"id_servicio\": 13, \"periodo\": \"2028-01\", \"monto\": 30.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 23, \"id_servicio\": 13, \"periodo\": \"2028-01\", \"monto\": 30.00, \"estado\": \"parcial\"}'),
(1150, '2026-10-13 21:21:04', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 20.00, \"estado\": \"pagada\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"pagada\"}'),
(1151, '2026-10-13 21:21:15', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"pagada\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"parcial\"}'),
(1152, '2026-10-13 21:22:00', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"parcial\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"pagada\"}'),
(1153, '2026-10-13 21:22:29', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"pagada\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"parcial\"}'),
(1154, '2026-10-13 21:22:45', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"parcial\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"vencida\"}'),
(1155, '2026-10-13 21:23:03', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"vencida\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"anulada\"}'),
(1156, '2026-10-13 21:35:09', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1157, '2026-10-13 21:35:09', 'INSERT', 'sesiones', 272, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 272, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 21:35:09\"}'),
(1158, '2026-10-13 21:36:10', 'UPDATE', 'facturas', 11, 'staff', 1, NULL, NULL, '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"anulada\"}', '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"pendiente\"}'),
(1159, '2026-10-13 21:36:12', 'UPDATE', 'facturas', 11, 'staff', 1, NULL, NULL, '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"vencida\"}'),
(1160, '2026-10-13 21:36:20', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"anulada\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"pendiente\"}'),
(1161, '2026-10-13 21:36:21', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"vencida\"}'),
(1162, '2026-10-13 21:36:34', 'UPDATE', 'facturas', 10, 'staff', 1, NULL, NULL, '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"vencida\"}', '{\"id_factura\": 10, \"id_servicio\": 10, \"periodo\": \"2026-06\", \"monto\": 31.00, \"estado\": \"pagada\"}'),
(1163, '2026-10-13 21:39:59', 'UPDATE', 'facturas', 11, 'staff', 1, NULL, NULL, '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"vencida\"}', '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"anulada\"}'),
(1164, '2026-10-13 21:40:21', 'UPDATE', 'facturas', 11, 'staff', 1, NULL, NULL, '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"anulada\"}', '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"pendiente\"}'),
(1165, '2026-10-13 21:40:22', 'UPDATE', 'facturas', 11, 'staff', 1, NULL, NULL, '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"vencida\"}'),
(1166, '2026-10-13 22:14:25', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1167, '2026-10-13 22:14:25', 'INSERT', 'sesiones', 273, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 273, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 22:14:25\"}'),
(1168, '2026-10-13 22:14:53', 'UPDATE', 'facturas', 11, 'staff', 1, NULL, NULL, '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"vencida\"}', '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"anulada\"}'),
(1169, '2026-10-13 22:15:18', 'UPDATE', 'facturas', 11, 'staff', 1, NULL, NULL, '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"anulada\"}', '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"pendiente\"}'),
(1170, '2026-10-13 22:15:19', 'UPDATE', 'facturas', 11, 'staff', 1, NULL, NULL, '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"pendiente\"}', '{\"id_factura\": 11, \"id_servicio\": 10, \"periodo\": \"2026-07\", \"monto\": 15.00, \"estado\": \"vencida\"}'),
(1171, '2026-10-13 22:16:05', 'UPDATE', 'servicios', 16, 'staff', 1, NULL, NULL, '{\"id_servicio\": 16, \"id_cliente\": 17, \"alias\": \"wiwi\", \"estado_comercial\": \"retirado\", \"id_plan\": 1, \"id_naps\": 11}', '{\"id_servicio\": 16, \"id_cliente\": 17, \"alias\": \"wiwi\", \"estado_comercial\": \"activo\", \"id_plan\": 1, \"id_naps\": 11}'),
(1172, '2026-10-13 22:16:14', 'UPDATE', 'servicios', 16, 'staff', 1, NULL, NULL, '{\"id_servicio\": 16, \"id_cliente\": 17, \"alias\": \"wiwi\", \"estado_comercial\": \"activo\", \"id_plan\": 1, \"id_naps\": 11}', '{\"id_servicio\": 16, \"id_cliente\": 17, \"alias\": \"wiwi\", \"estado_comercial\": \"retirado\", \"id_plan\": 1, \"id_naps\": 11}'),
(1173, '2026-10-13 22:16:29', 'UPDATE', 'servicios', 16, 'staff', 1, NULL, NULL, '{\"id_servicio\": 16, \"id_cliente\": 17, \"alias\": \"wiwi\", \"estado_comercial\": \"retirado\", \"id_plan\": 1, \"id_naps\": 11}', '{\"id_servicio\": 16, \"id_cliente\": 17, \"alias\": \"wiwi\", \"estado_comercial\": \"activo\", \"id_plan\": 1, \"id_naps\": 11}'),
(1174, '2026-10-13 22:19:34', 'UPDATE', 'contratos', 15, 'staff', 1, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}', '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vencido\"}'),
(1175, '2026-10-13 22:19:41', 'UPDATE', 'contratos', 15, 'staff', 1, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vencido\"}', '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"rescindido\"}'),
(1176, '2026-10-13 22:19:41', 'UPDATE', 'servicios', 1, 'staff', 1, NULL, NULL, '{\"id_servicio\": 1, \"id_cliente\": 1, \"alias\": null, \"estado_comercial\": \"activo\", \"id_plan\": 1, \"id_naps\": 1}', '{\"id_servicio\": 1, \"id_cliente\": 1, \"alias\": null, \"estado_comercial\": \"retirado\", \"id_plan\": 1, \"id_naps\": 1}'),
(1177, '2026-10-13 22:19:57', 'UPDATE', 'contratos', 15, 'staff', 1, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"rescindido\"}', '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}'),
(1178, '2026-10-13 22:20:08', 'UPDATE', 'contratos', 15, 'staff', 1, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}', '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"rescindido\"}');
INSERT INTO `logs` (`id_log`, `creado_en`, `accion`, `tabla_afectada`, `id_registro_afectado`, `tipo_actor`, `id_usuario`, `id_credencial`, `ip_address`, `old_value`, `new_value`) VALUES
(1179, '2026-10-13 22:20:21', 'UPDATE', 'contratos', 15, 'staff', 1, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"rescindido\"}', '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}'),
(1180, '2026-10-13 22:20:37', 'UPDATE', 'contratos', 15, 'staff', 1, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}', '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"rescindido\"}'),
(1181, '2026-10-13 22:20:45', 'UPDATE', 'contratos', 15, 'staff', 1, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"rescindido\"}', '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}'),
(1182, '2026-10-13 22:20:54', 'UPDATE', 'contratos', 15, 'staff', 1, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}', '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vencido\"}'),
(1183, '2026-10-13 22:21:02', 'UPDATE', 'contratos', 15, 'staff', 1, NULL, NULL, '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vencido\"}', '{\"id_contrato\": 15, \"id_servicio\": 1, \"fecha_inicio\": \"2026-10-12\", \"fecha_fin\": \"2026-10-13\", \"tipo_contrato\": \"indefinido\", \"estado\": \"vigente\"}'),
(1184, '2026-10-13 23:25:42', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1185, '2026-10-13 23:25:42', 'INSERT', 'sesiones', 274, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 274, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 23:25:42\"}'),
(1186, '2026-10-13 23:26:27', 'UPDATE', 'sesiones', 274, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 274, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 274, \"revocado_en\": \"2026-10-13 23:26:27\", \"motivo_cierre\": \"logout\"}'),
(1187, '2026-10-13 23:27:15', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1188, '2026-10-13 23:27:15', 'INSERT', 'sesiones', 275, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 275, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 23:27:15\"}'),
(1189, '2026-10-13 23:27:34', 'UPDATE', 'sesiones', 275, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 275, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 275, \"revocado_en\": \"2026-10-13 23:27:34\", \"motivo_cierre\": \"logout\"}'),
(1190, '2026-10-13 23:27:42', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1191, '2026-10-13 23:27:42', 'INSERT', 'sesiones', 276, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 276, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 23:27:42\"}'),
(1192, '2026-10-13 23:29:26', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1193, '2026-10-13 23:29:26', 'INSERT', 'sesiones', 277, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 277, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 23:29:26\"}'),
(1194, '2026-10-13 23:36:37', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1195, '2026-10-13 23:36:37', 'INSERT', 'sesiones', 278, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 278, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 23:36:37\"}'),
(1196, '2026-10-13 23:37:03', 'UPDATE', 'sesiones', 278, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 278, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 278, \"revocado_en\": \"2026-10-13 23:37:03\", \"motivo_cierre\": \"logout\"}'),
(1197, '2026-10-13 23:37:09', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1198, '2026-10-13 23:37:09', 'INSERT', 'sesiones', 279, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 279, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 23:37:09\"}'),
(1199, '2026-10-13 23:37:54', 'UPDATE', 'sesiones', 279, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 279, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 279, \"revocado_en\": \"2026-10-13 23:37:54\", \"motivo_cierre\": \"logout\"}'),
(1200, '2026-10-13 23:37:59', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1201, '2026-10-13 23:37:59', 'INSERT', 'sesiones', 280, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 280, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 23:37:59\"}'),
(1202, '2026-10-13 23:38:28', 'UPDATE', 'sesiones', 280, 'sistema', NULL, NULL, NULL, '{\"id_sesion\": 280, \"revocado_en\": null, \"motivo_cierre\": null}', '{\"id_sesion\": 280, \"revocado_en\": \"2026-10-13 23:38:28\", \"motivo_cierre\": \"logout\"}'),
(1203, '2026-10-13 23:38:34', 'UPDATE', 'usuarios', 1, 'sistema', NULL, NULL, NULL, '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}', '{\"id_usuario\": 1, \"username\": \"admin\", \"email\": \"admin@gmail.com\", \"estado\": \"Activo\", \"email_verified\": 1, \"must_change_password\": 0}'),
(1204, '2026-10-13 23:38:34', 'INSERT', 'sesiones', 281, 'sistema', NULL, NULL, NULL, NULL, '{\"id_sesion\": 281, \"tipo_usuario\": \"staff\", \"id_usuario\": 1, \"id_credencial\": null, \"expira_en\": \"2026-11-12 23:38:34\"}');

--
-- Triggers `logs`
--
DELIMITER $$
CREATE TRIGGER `trg_logs_inmutable_delete` BEFORE DELETE ON `logs` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'logs es inmutable: DELETE bloqueado.';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_logs_inmutable_update` BEFORE UPDATE ON `logs` FOR EACH ROW BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'logs es inmutable: UPDATE bloqueado.';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `metodos_pago`
--

CREATE TABLE `metodos_pago` (
  `id_metodo` int(11) NOT NULL,
  `codigo` varchar(30) NOT NULL,
  `nombre` varchar(60) NOT NULL,
  `requiere_referencia` tinyint(1) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `orden` tinyint(3) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `metodos_pago`
--

INSERT INTO `metodos_pago` (`id_metodo`, `codigo`, `nombre`, `requiere_referencia`, `activo`, `orden`) VALUES
(1, 'transferencia', 'Transferencia bancaria', 1, 1, 1),
(2, 'pago_movil', 'Pago móvil', 1, 1, 2),
(3, 'zelle', 'Zelle', 1, 1, 3),
(4, 'efectivo', 'Efectivo', 0, 1, 4);

--
-- Triggers `metodos_pago`
--
DELIMITER $$
CREATE TRIGGER `trg_metodos_pago_audit_delete` AFTER DELETE ON `metodos_pago` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','metodos_pago',OLD.id_metodo,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_metodo',OLD.id_metodo,'codigo',OLD.codigo,'nombre',OLD.nombre,'activo',OLD.activo));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_metodos_pago_audit_insert` AFTER INSERT ON `metodos_pago` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','metodos_pago',NEW.id_metodo,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_metodo',NEW.id_metodo,'codigo',NEW.codigo,'nombre',NEW.nombre,'activo',NEW.activo));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_metodos_pago_audit_update` AFTER UPDATE ON `metodos_pago` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','metodos_pago',NEW.id_metodo,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_metodo',OLD.id_metodo,'codigo',OLD.codigo,'nombre',OLD.nombre,'activo',OLD.activo),
          JSON_OBJECT('id_metodo',NEW.id_metodo,'codigo',NEW.codigo,'nombre',NEW.nombre,'activo',NEW.activo));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `modulos`
--

CREATE TABLE `modulos` (
  `id_modulo` int(11) NOT NULL,
  `nombre_modulo` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `id_olts` int(11) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `naps`
--

INSERT INTO `naps` (`id_nap`, `codigo`, `cantidad_puertos_max`, `ubicacion_fisica`, `latitud`, `longitud`, `id_olts`, `creado_en`, `actualizado_en`) VALUES
(1, 'NAP-01', 16, 'Calle Principal', 10.48200000, -66.90500000, 1, '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(10, 'NAP-10', 16, 'Ubicación Física 1', 0.00000000, 0.00000000, 10, '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(11, 'NAP-11', 8, 'Ubicación Física 2', 0.00000000, 0.00000000, 10, '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(12, 'NAP-12', 16, 'Ubicación Física 3', 0.00000000, 0.00000000, 11, '2026-10-13 05:37:24', '2026-10-13 05:37:24');

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
  `estado` enum('activo','mantenimiento','inactivo') DEFAULT 'activo',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `nodos`
--

INSERT INTO `nodos` (`id_nodo`, `nombre`, `ubicacion`, `latitud`, `longitud`, `estado`, `creado_en`, `actualizado_en`) VALUES
(1, 'Nodo Centro', 'Sector Centro', 10.48060000, -66.90360000, 'activo', '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(10, 'Nodo Norte', 'Ubicación prueba 1', 0.00000000, 0.00000000, 'activo', '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(11, 'Nodo Sur', 'Ubicación prueba 2', 0.00000000, 0.00000000, 'activo', '2026-10-13 05:37:24', '2026-10-13 05:37:24');

-- --------------------------------------------------------

--
-- Table structure for table `notas_credito`
--

CREATE TABLE `notas_credito` (
  `id_nota` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_factura` int(11) DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'USD',
  `motivo` varchar(255) NOT NULL,
  `estado` enum('emitida','aplicada','anulada') NOT NULL DEFAULT 'emitida',
  `id_usuario_emisor` int(11) DEFAULT NULL,
  `emitida_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `aplicada_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `notas_credito`
--
DELIMITER $$
CREATE TRIGGER `trg_notas_credito_audit_delete` AFTER DELETE ON `notas_credito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','notas_credito',OLD.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_factura',OLD.id_factura,
                      'monto',OLD.monto,'estado',OLD.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_notas_credito_audit_insert` AFTER INSERT ON `notas_credito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','notas_credito',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_factura',NEW.id_factura,
                      'monto',NEW.monto,'estado',NEW.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_notas_credito_audit_update` AFTER UPDATE ON `notas_credito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','notas_credito',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_factura',OLD.id_factura,
                      'monto',OLD.monto,'estado',OLD.estado),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_factura',NEW.id_factura,
                      'monto',NEW.monto,'estado',NEW.estado));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `notas_debito`
--

CREATE TABLE `notas_debito` (
  `id_nota` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_factura` int(11) DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'USD',
  `motivo` varchar(255) NOT NULL,
  `estado` enum('emitida','aplicada','anulada') NOT NULL DEFAULT 'emitida',
  `id_usuario_emisor` int(11) DEFAULT NULL,
  `emitida_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `aplicada_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `notas_debito`
--
DELIMITER $$
CREATE TRIGGER `trg_notas_debito_audit_delete` AFTER DELETE ON `notas_debito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','notas_debito',OLD.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_factura',OLD.id_factura,
                      'monto',OLD.monto,'estado',OLD.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_notas_debito_audit_insert` AFTER INSERT ON `notas_debito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','notas_debito',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_factura',NEW.id_factura,
                      'monto',NEW.monto,'estado',NEW.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_notas_debito_audit_update` AFTER UPDATE ON `notas_debito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','notas_debito',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_factura',OLD.id_factura,
                      'monto',OLD.monto,'estado',OLD.estado),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_factura',NEW.id_factura,
                      'monto',NEW.monto,'estado',NEW.estado));
END
$$
DELIMITER ;

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
  `id_cliente` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `tipo_evento` varchar(50) DEFAULT NULL,
  `url_destino` varchar(255) DEFAULT NULL,
  `leida_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notificaciones_staff`
--

CREATE TABLE `notificaciones_staff` (
  `id_notificacion` int(11) NOT NULL,
  `titulo` varchar(100) NOT NULL,
  `mensaje` varchar(255) NOT NULL,
  `tipo_evento` varchar(50) DEFAULT NULL,
  `url_destino` varchar(255) DEFAULT NULL,
  `estado` enum('leido','no leido') NOT NULL DEFAULT 'no leido',
  `id_usuario` int(11) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `leida_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `notificaciones_staff`
--
DELIMITER $$
CREATE TRIGGER `trg_notificaciones_staff_audit_delete` AFTER DELETE ON `notificaciones_staff` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','notificaciones_staff',OLD.id_notificacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_notificacion',OLD.id_notificacion,'titulo',OLD.titulo,'tipo_evento',OLD.tipo_evento,
                      'estado',OLD.estado,'id_usuario',OLD.id_usuario));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_notificaciones_staff_audit_insert` AFTER INSERT ON `notificaciones_staff` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','notificaciones_staff',NEW.id_notificacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_notificacion',NEW.id_notificacion,'titulo',NEW.titulo,'tipo_evento',NEW.tipo_evento,
                      'estado',NEW.estado,'id_usuario',NEW.id_usuario));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_notificaciones_staff_audit_update` AFTER UPDATE ON `notificaciones_staff` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','notificaciones_staff',NEW.id_notificacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_notificacion',OLD.id_notificacion,'titulo',OLD.titulo,'tipo_evento',OLD.tipo_evento,
                      'estado',OLD.estado,'id_usuario',OLD.id_usuario),
          JSON_OBJECT('id_notificacion',NEW.id_notificacion,'titulo',NEW.titulo,'tipo_evento',NEW.tipo_evento,
                      'estado',NEW.estado,'id_usuario',NEW.id_usuario));
END
$$
DELIMITER ;

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
  `codigo` varchar(20) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `olts`
--

INSERT INTO `olts` (`id_olt`, `marca_modelo`, `puertos_pon`, `ip_gestion`, `id_nodos`, `codigo`, `creado_en`, `actualizado_en`) VALUES
(1, 'Huawei MA5616', 16, '192.168.100.1', 1, 'OLT-01', '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(10, 'Huawei MA5680T', 16, '192.168.10.1', 10, 'OLT-10', '2026-10-13 05:37:24', '2026-10-13 05:37:24'),
(11, 'ZTE C320', 8, '192.168.10.2', 11, 'OLT-11', '2026-10-13 05:37:24', '2026-10-13 05:37:24');

-- --------------------------------------------------------

--
-- Table structure for table `paginas`
--

CREATE TABLE `paginas` (
  `id_pagina` int(11) NOT NULL,
  `nombre_pagina` varchar(100) NOT NULL,
  `url_pagina` varchar(255) NOT NULL,
  `id_modulo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `paginas`
--

INSERT INTO `paginas` (`id_pagina`, `nombre_pagina`, `url_pagina`, `id_modulo`) VALUES
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

-- --------------------------------------------------------

--
-- Table structure for table `pagos`
--

CREATE TABLE `pagos` (
  `id_pago` int(11) NOT NULL,
  `id_factura` int(11) DEFAULT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_servicio` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL COMMENT 'Monto en USD (precio de referencia). Independiente de la moneda_pago.',
  `moneda_pago` enum('USD','VES') NOT NULL DEFAULT 'USD' COMMENT 'Divisa en la que se realizó el pago. USD = pago en dólares; VES = pago en bolívares.',
  `tasa_cambio` decimal(10,4) DEFAULT NULL COMMENT 'Tasa BCV (Bs/USD) del día del pago. Obligatoria si moneda_pago=VES, NULL si moneda_pago=USD.',
  `fecha_pago` datetime NOT NULL,
  `id_metodo` int(11) DEFAULT NULL,
  `referencia_bancaria` varchar(255) DEFAULT NULL,
  `comprobante_path` varchar(255) DEFAULT NULL,
  `estado` enum('pendiente','validado','rechazado') DEFAULT 'pendiente',
  `motivo_rechazo` varchar(255) DEFAULT NULL,
  `fecha_validacion` datetime DEFAULT NULL,
  `id_usuario_valido` int(11) DEFAULT NULL,
  `origen` enum('portal_cliente','backoffice') DEFAULT 'backoffice',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `pagos`
--

INSERT INTO `pagos` (`id_pago`, `id_factura`, `id_cliente`, `id_servicio`, `monto`, `moneda_pago`, `tasa_cambio`, `fecha_pago`, `id_metodo`, `referencia_bancaria`, `comprobante_path`, `estado`, `motivo_rechazo`, `fecha_validacion`, `id_usuario_valido`, `origen`, `creado_en`, `actualizado_en`) VALUES
(10, 10, 10, 10, 15.00, 'USD', NULL, '2026-06-15 10:00:00', 4, 'REF-001', NULL, 'validado', NULL, '2026-06-16 09:00:00', 1, 'backoffice', '2026-10-13 05:37:24', '2026-10-13 19:42:55'),
(11, 13, 11, 12, 30.00, 'USD', NULL, '2026-06-10 14:30:00', 2, 'REF-002', NULL, 'validado', NULL, '2026-06-11 08:00:00', 1, 'portal_cliente', '2026-10-13 05:37:24', '2026-10-13 19:42:55'),
(12, 23, 12, 13, 20.00, 'USD', NULL, '2026-07-05 11:00:00', 4, NULL, NULL, 'validado', NULL, '2026-07-21 13:13:03', 1, 'backoffice', '2026-10-13 05:37:24', '2026-10-13 21:19:17'),
(13, 15, 1, 1, 1000.00, 'VES', 789.0000, '2026-10-08 18:17:00', 2, '123456 miami me lo confirmo', NULL, 'pendiente', NULL, NULL, NULL, 'backoffice', '2026-10-13 05:37:24', '2026-10-13 21:00:53'),
(16, 10, 10, 10, 15.00, 'VES', 789.0000, '2026-10-13 16:58:00', 2, NULL, NULL, 'validado', NULL, '2026-10-13 21:18:19', 1, 'backoffice', '2026-10-13 20:58:32', '2026-10-13 21:18:55');

--
-- Triggers `pagos`
--
DELIMITER $$
CREATE TRIGGER `trg_pagos_audit_delete` AFTER DELETE ON `pagos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','pagos',OLD.id_pago,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_pago',OLD.id_pago,'id_factura',OLD.id_factura,'monto',OLD.monto,
                      'estado',OLD.estado,'id_usuario_valido',OLD.id_usuario_valido));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pagos_audit_insert` AFTER INSERT ON `pagos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','pagos',NEW.id_pago,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_pago',NEW.id_pago,'id_factura',NEW.id_factura,'monto',NEW.monto,
                      'estado',NEW.estado,'id_usuario_valido',NEW.id_usuario_valido));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pagos_audit_update` AFTER UPDATE ON `pagos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','pagos',NEW.id_pago,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_pago',OLD.id_pago,'id_factura',OLD.id_factura,'monto',OLD.monto,
                      'estado',OLD.estado,'id_usuario_valido',OLD.id_usuario_valido),
          JSON_OBJECT('id_pago',NEW.id_pago,'id_factura',NEW.id_factura,'monto',NEW.monto,
                      'estado',NEW.estado,'id_usuario_valido',NEW.id_usuario_valido));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pagos_validar_insert` BEFORE INSERT ON `pagos` FOR EACH ROW BEGIN
  IF NEW.estado <> 'pendiente' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'INSERT de pago solo permite estado pendiente. Use UPDATE para transicionar.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pagos_validar_transicion` BEFORE UPDATE ON `pagos` FOR EACH ROW BEGIN
  DECLARE msg VARCHAR(255);
  IF NEW.estado <> OLD.estado AND NOT EXISTS (
    SELECT 1 FROM transicion_estado
     WHERE tabla = 'pagos' AND estado_origen = OLD.estado AND estado_destino = NEW.estado
  ) THEN
    SET msg = CONCAT('Transicion no permitida en pagos: ', OLD.estado, ' -> ', NEW.estado);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pedidos`
--

CREATE TABLE `pedidos` (
  `id_pedido` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `tipo` enum('instalacion','reparacion','retiro','cambio_plan','traslado') NOT NULL,
  `estado` enum('pendiente','asignado','en_curso','completado','cancelado') NOT NULL DEFAULT 'pendiente',
  `prioridad` enum('Alta','Media','Baja') NOT NULL DEFAULT 'Media',
  `direccion_texto` varchar(255) DEFAULT NULL,
  `latitud` decimal(10,8) DEFAULT NULL,
  `longitud` decimal(11,8) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `id_usuario_creador` int(11) DEFAULT NULL,
  `id_tecnico_asignado` int(11) DEFAULT NULL,
  `fecha_solicitud` timestamp NOT NULL DEFAULT current_timestamp(),
  `fecha_programada` date DEFAULT NULL,
  `fecha_inicio` datetime DEFAULT NULL,
  `fecha_completado` datetime DEFAULT NULL,
  `observaciones_cierre` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `pedidos`
--
DELIMITER $$
CREATE TRIGGER `trg_pedidos_audit_delete` AFTER DELETE ON `pedidos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','pedidos',OLD.id_pedido,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_pedido',OLD.id_pedido,'id_cliente',OLD.id_cliente,'id_servicio',OLD.id_servicio,
                      'tipo',OLD.tipo,'estado',OLD.estado,'prioridad',OLD.prioridad));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pedidos_audit_insert` AFTER INSERT ON `pedidos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','pedidos',NEW.id_pedido,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_pedido',NEW.id_pedido,'id_cliente',NEW.id_cliente,'id_servicio',NEW.id_servicio,
                      'tipo',NEW.tipo,'estado',NEW.estado,'prioridad',NEW.prioridad));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pedidos_audit_update` AFTER UPDATE ON `pedidos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','pedidos',NEW.id_pedido,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_pedido',OLD.id_pedido,'id_cliente',OLD.id_cliente,'id_servicio',OLD.id_servicio,
                      'tipo',OLD.tipo,'estado',OLD.estado,'prioridad',OLD.prioridad),
          JSON_OBJECT('id_pedido',NEW.id_pedido,'id_cliente',NEW.id_cliente,'id_servicio',NEW.id_servicio,
                      'tipo',NEW.tipo,'estado',NEW.estado,'prioridad',NEW.prioridad));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pedido_asignaciones`
--

CREATE TABLE `pedido_asignaciones` (
  `id_asignacion` int(11) NOT NULL,
  `id_pedido` int(11) NOT NULL,
  `id_tecnico` int(11) NOT NULL,
  `id_usuario_asignador` int(11) DEFAULT NULL,
  `estado` enum('activa','completada','rechazada') NOT NULL DEFAULT 'activa',
  `motivo_rechazo` varchar(255) DEFAULT NULL,
  `asignado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `cerrado_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `pedido_asignaciones`
--
DELIMITER $$
CREATE TRIGGER `trg_pedido_asignaciones_audit_delete` AFTER DELETE ON `pedido_asignaciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','pedido_asignaciones',OLD.id_asignacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_asignacion',OLD.id_asignacion,'id_pedido',OLD.id_pedido,'id_tecnico',OLD.id_tecnico,
                      'estado',OLD.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pedido_asignaciones_audit_insert` AFTER INSERT ON `pedido_asignaciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','pedido_asignaciones',NEW.id_asignacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_asignacion',NEW.id_asignacion,'id_pedido',NEW.id_pedido,'id_tecnico',NEW.id_tecnico,
                      'estado',NEW.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pedido_asignaciones_audit_update` AFTER UPDATE ON `pedido_asignaciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','pedido_asignaciones',NEW.id_asignacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_asignacion',OLD.id_asignacion,'id_pedido',OLD.id_pedido,'id_tecnico',OLD.id_tecnico,
                      'estado',OLD.estado),
          JSON_OBJECT('id_asignacion',NEW.id_asignacion,'id_pedido',NEW.id_pedido,'id_tecnico',NEW.id_tecnico,
                      'estado',NEW.estado));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pedido_materiales`
--

CREATE TABLE `pedido_materiales` (
  `id_material` int(11) NOT NULL,
  `id_pedido` int(11) NOT NULL,
  `id_equipo` int(11) DEFAULT NULL,
  `descripcion` varchar(150) NOT NULL,
  `cantidad` decimal(10,2) NOT NULL DEFAULT 1.00,
  `unidad` varchar(20) NOT NULL DEFAULT 'unidad',
  `notas` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `pedido_materiales`
--
DELIMITER $$
CREATE TRIGGER `trg_pedido_materiales_audit_delete` AFTER DELETE ON `pedido_materiales` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','pedido_materiales',OLD.id_material,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_material',OLD.id_material,'id_pedido',OLD.id_pedido,'id_equipo',OLD.id_equipo,
                      'descripcion',OLD.descripcion,'cantidad',OLD.cantidad));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pedido_materiales_audit_insert` AFTER INSERT ON `pedido_materiales` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','pedido_materiales',NEW.id_material,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_material',NEW.id_material,'id_pedido',NEW.id_pedido,'id_equipo',NEW.id_equipo,
                      'descripcion',NEW.descripcion,'cantidad',NEW.cantidad));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pedido_materiales_audit_update` AFTER UPDATE ON `pedido_materiales` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','pedido_materiales',NEW.id_material,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_material',OLD.id_material,'id_pedido',OLD.id_pedido,'id_equipo',OLD.id_equipo,
                      'descripcion',OLD.descripcion,'cantidad',OLD.cantidad),
          JSON_OBJECT('id_material',NEW.id_material,'id_pedido',NEW.id_pedido,'id_equipo',NEW.id_equipo,
                      'descripcion',NEW.descripcion,'cantidad',NEW.cantidad));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `permisos`
--

CREATE TABLE `permisos` (
  `id_permiso` int(11) NOT NULL,
  `nombre` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permisos`
--

INSERT INTO `permisos` (`id_permiso`, `nombre`) VALUES
(2, 'crear'),
(3, 'editar'),
(4, 'eliminar'),
(1, 'leer'),
(5, 'validar');

-- --------------------------------------------------------

--
-- Table structure for table `planes`
--

CREATE TABLE `planes` (
  `id_plan` int(11) NOT NULL,
  `nombre` varchar(60) NOT NULL,
  `velocidad_bajada_mbps` decimal(8,2) DEFAULT NULL,
  `velocidad_subida_mbps` decimal(8,2) DEFAULT NULL,
  `tecnologia` enum('FTTH','HFC','WISP','OTRO') NOT NULL DEFAULT 'FTTH',
  `precio_mensual` decimal(10,2) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'USD',
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `planes`
--

INSERT INTO `planes` (`id_plan`, `nombre`, `velocidad_bajada_mbps`, `velocidad_subida_mbps`, `tecnologia`, `precio_mensual`, `moneda`, `estado`, `creado_en`, `actualizado_en`) VALUES
(1, 'Plan Básico', 10.00, 10.00, 'FTTH', 15.00, 'USD', 'activo', '2026-10-13 05:44:11', '2026-10-13 17:39:11'),
(2, 'Plan Hogar', 20.00, 20.00, 'FTTH', 30.00, 'USD', 'activo', '2026-10-13 05:44:11', '2026-10-13 17:39:11'),
(10, 'Plan Premium', 50.00, 50.00, 'FTTH', 45.00, 'USD', 'activo', '2026-10-13 05:44:11', '2026-10-13 17:39:11'),
(11, 'Plan Empresarial', 100.00, 100.00, 'FTTH', 80.00, 'USD', 'activo', '2026-10-13 05:44:11', '2026-10-13 17:39:11'),
(12, 'goty', 100000.00, 999999.99, 'FTTH', 100.00, 'USD', 'activo', '2026-10-13 19:17:54', '2026-10-13 19:17:54');

-- --------------------------------------------------------

--
-- Table structure for table `plan_historial_precios`
--

CREATE TABLE `plan_historial_precios` (
  `id_historial` int(11) NOT NULL,
  `id_plan` int(11) NOT NULL,
  `precio_anterior` decimal(10,2) NOT NULL,
  `precio_nuevo` decimal(10,2) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'USD',
  `id_usuario` int(11) DEFAULT NULL,
  `cambiado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `motivo` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `plan_historial_precios`
--
DELIMITER $$
CREATE TRIGGER `trg_plan_historial_precios_audit_insert` AFTER INSERT ON `plan_historial_precios` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','plan_historial_precios',NEW.id_historial,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_historial',NEW.id_historial,'id_plan',NEW.id_plan,'precio_anterior',NEW.precio_anterior,
                      'precio_nuevo',NEW.precio_nuevo,'id_usuario',NEW.id_usuario));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nombre_rol` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rol`
--

INSERT INTO `rol` (`id_rol`, `nombre_rol`, `descripcion`) VALUES
(1, 'Administrador', NULL),
(2, 'Operador', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `rol_modulo`
--

CREATE TABLE `rol_modulo` (
  `id_rol_modulo` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rol_modulo`
--

INSERT INTO `rol_modulo` (`id_rol_modulo`, `id_rol`, `id_modulo`) VALUES
(8, 1, 1),
(9, 1, 2),
(10, 1, 3),
(11, 1, 4),
(12, 1, 5),
(13, 1, 6),
(14, 1, 7),
(1, 2, 1),
(2, 2, 2),
(3, 2, 3),
(5, 2, 5),
(6, 2, 6),
(7, 2, 7);

-- --------------------------------------------------------

--
-- Table structure for table `rol_modulo_pagina`
--

CREATE TABLE `rol_modulo_pagina` (
  `id_rol_modulo_pagina` int(11) NOT NULL,
  `id_rol_modulo` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL,
  `id_pagina` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rol_modulo_pagina`
--

INSERT INTO `rol_modulo_pagina` (`id_rol_modulo_pagina`, `id_rol_modulo`, `id_modulo`, `id_pagina`) VALUES
(1356, 1, 1, 1),
(1357, 2, 2, 2),
(1358, 2, 2, 22),
(1359, 3, 3, 4),
(1360, 3, 3, 5),
(1361, 3, 3, 6),
(1362, 5, 5, 11),
(1363, 6, 6, 12),
(1364, 6, 6, 13),
(1365, 6, 6, 14),
(1366, 6, 6, 20),
(1367, 7, 7, 15),
(1368, 7, 7, 16),
(1369, 7, 7, 17),
(1370, 7, 7, 18),
(1371, 7, 7, 19),
(1660, 8, 1, 1),
(1661, 9, 2, 2),
(1662, 9, 2, 22),
(1663, 10, 3, 4),
(1664, 10, 3, 5),
(1665, 10, 3, 6),
(1666, 11, 4, 7),
(1667, 11, 4, 8),
(1668, 11, 4, 9),
(1669, 11, 4, 10),
(1670, 11, 4, 21),
(1671, 12, 5, 11),
(1672, 13, 6, 12),
(1673, 13, 6, 13),
(1674, 13, 6, 14),
(1675, 13, 6, 20),
(1676, 14, 7, 15),
(1677, 14, 7, 16),
(1678, 14, 7, 17),
(1679, 14, 7, 18),
(1680, 14, 7, 19);

-- --------------------------------------------------------

--
-- Table structure for table `rol_modulo_permiso`
--

CREATE TABLE `rol_modulo_permiso` (
  `id_rol_modulo_permiso` int(11) NOT NULL,
  `id_rol_modulo` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL,
  `id_pagina` int(11) NOT NULL,
  `id_permiso` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rol_modulo_permiso`
--

INSERT INTO `rol_modulo_permiso` (`id_rol_modulo_permiso`, `id_rol_modulo`, `id_modulo`, `id_pagina`, `id_permiso`) VALUES
(7195, 1, 1, 1, 1),
(7196, 1, 1, 1, 2),
(7197, 1, 1, 1, 3),
(7198, 2, 2, 2, 1),
(7199, 2, 2, 2, 2),
(7200, 2, 2, 2, 3),
(7201, 2, 2, 22, 1),
(7202, 2, 2, 22, 2),
(7203, 2, 2, 22, 3),
(7204, 3, 3, 4, 2),
(7205, 3, 3, 4, 3),
(7206, 3, 3, 5, 2),
(7207, 3, 3, 5, 3),
(7208, 3, 3, 6, 1),
(7209, 3, 3, 6, 2),
(7210, 3, 3, 6, 3),
(7211, 5, 5, 11, 2),
(7212, 5, 5, 11, 3),
(7213, 6, 6, 12, 1),
(7214, 6, 6, 12, 2),
(7215, 6, 6, 12, 3),
(7216, 6, 6, 13, 1),
(7217, 6, 6, 13, 2),
(7218, 6, 6, 13, 3),
(7219, 6, 6, 14, 1),
(7220, 6, 6, 14, 2),
(7221, 6, 6, 14, 3),
(7222, 6, 6, 20, 1),
(7223, 6, 6, 20, 2),
(7224, 6, 6, 20, 3),
(7225, 7, 7, 15, 1),
(7226, 7, 7, 15, 2),
(7227, 7, 7, 15, 3),
(7228, 7, 7, 16, 1),
(7229, 7, 7, 16, 2),
(7230, 7, 7, 16, 3),
(7231, 7, 7, 17, 1),
(7232, 7, 7, 17, 2),
(7233, 7, 7, 17, 3),
(7234, 7, 7, 18, 1),
(7235, 7, 7, 18, 2),
(7236, 7, 7, 18, 3),
(7237, 7, 7, 19, 1),
(7238, 7, 7, 19, 2),
(7239, 7, 7, 19, 3),
(8426, 8, 1, 1, 1),
(8427, 8, 1, 1, 2),
(8428, 8, 1, 1, 3),
(8429, 8, 1, 1, 4),
(8430, 9, 2, 2, 1),
(8431, 9, 2, 2, 2),
(8432, 9, 2, 2, 3),
(8433, 9, 2, 2, 4),
(8434, 9, 2, 22, 1),
(8435, 9, 2, 22, 2),
(8436, 9, 2, 22, 3),
(8437, 9, 2, 22, 4),
(8438, 10, 3, 4, 1),
(8439, 10, 3, 4, 2),
(8440, 10, 3, 4, 3),
(8441, 10, 3, 4, 4),
(8442, 10, 3, 5, 1),
(8443, 10, 3, 5, 2),
(8444, 10, 3, 5, 3),
(8445, 10, 3, 5, 4),
(8446, 10, 3, 6, 1),
(8447, 10, 3, 6, 2),
(8448, 10, 3, 6, 3),
(8449, 10, 3, 6, 4),
(8450, 11, 4, 7, 1),
(8451, 11, 4, 7, 2),
(8452, 11, 4, 7, 3),
(8453, 11, 4, 7, 4),
(8454, 11, 4, 8, 1),
(8455, 11, 4, 8, 2),
(8456, 11, 4, 8, 3),
(8457, 11, 4, 8, 4),
(8458, 11, 4, 9, 1),
(8459, 11, 4, 9, 2),
(8460, 11, 4, 9, 3),
(8461, 11, 4, 9, 4),
(8462, 11, 4, 10, 1),
(8463, 11, 4, 10, 2),
(8464, 11, 4, 10, 3),
(8465, 11, 4, 10, 4),
(8466, 11, 4, 21, 1),
(8467, 11, 4, 21, 2),
(8468, 11, 4, 21, 3),
(8469, 11, 4, 21, 4),
(8470, 12, 5, 11, 1),
(8471, 12, 5, 11, 2),
(8472, 12, 5, 11, 3),
(8473, 12, 5, 11, 4),
(8474, 13, 6, 12, 1),
(8475, 13, 6, 12, 2),
(8476, 13, 6, 12, 3),
(8477, 13, 6, 12, 4),
(8478, 13, 6, 13, 1),
(8479, 13, 6, 13, 2),
(8480, 13, 6, 13, 3),
(8481, 13, 6, 13, 4),
(8482, 13, 6, 14, 1),
(8483, 13, 6, 14, 2),
(8484, 13, 6, 14, 3),
(8485, 13, 6, 14, 4),
(8486, 13, 6, 20, 1),
(8487, 13, 6, 20, 2),
(8488, 13, 6, 20, 3),
(8489, 13, 6, 20, 4),
(8490, 14, 7, 15, 1),
(8491, 14, 7, 15, 2),
(8492, 14, 7, 15, 3),
(8493, 14, 7, 15, 4),
(8494, 14, 7, 16, 1),
(8495, 14, 7, 16, 2),
(8496, 14, 7, 16, 3),
(8497, 14, 7, 16, 4),
(8498, 14, 7, 16, 5),
(8499, 14, 7, 17, 1),
(8500, 14, 7, 17, 2),
(8501, 14, 7, 17, 3),
(8502, 14, 7, 17, 4),
(8503, 14, 7, 18, 1),
(8504, 14, 7, 18, 2),
(8505, 14, 7, 18, 3),
(8506, 14, 7, 18, 4),
(8507, 14, 7, 19, 1),
(8508, 14, 7, 19, 2),
(8509, 14, 7, 19, 3),
(8510, 14, 7, 19, 4);

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
  `ip_asignada` varchar(45) DEFAULT NULL COMMENT 'DEPRECATED: usar ip_asignaciones.id_asignacion',
  `latitud_instalacion` decimal(10,8) DEFAULT NULL,
  `longitud_instalacion` decimal(11,8) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `servicios`
--

INSERT INTO `servicios` (`id_servicio`, `id_cliente`, `alias`, `estado_comercial`, `id_plan`, `id_naps`, `direccion_texto`, `ip_asignada`, `latitud_instalacion`, `longitud_instalacion`, `creado_en`, `actualizado_en`) VALUES
(1, 1, NULL, 'retirado', 1, 1, 'San Francisco, calle 4', NULL, 10.48006000, -66.90300000, '2026-10-13 05:44:11', '2026-10-13 22:19:41'),
(4, 1, 'casa principal', 'activo', 2, 1, 'san francisco al lado del otro servicio', NULL, 10.20399400, -66.90300000, '2026-10-13 05:44:11', '2026-10-13 15:14:03'),
(10, 10, 'Servicio Casa 1', 'activo', 1, 10, 'Dir prueba 2', NULL, NULL, NULL, '2026-10-13 05:44:11', '2026-10-13 05:44:11'),
(11, 10, 'Servicio Oficina', 'activo', 10, 12, 'Dir prueba 2', NULL, NULL, NULL, '2026-10-13 05:44:11', '2026-10-13 05:44:11'),
(12, 11, 'Servicio Hogar', 'activo', 2, 10, 'Dir prueba 3', NULL, NULL, NULL, '2026-10-13 05:44:11', '2026-10-13 05:44:11'),
(13, 12, 'Servicio Principal', 'suspendido', 1, 11, 'Dir prueba 4', NULL, NULL, NULL, '2026-10-13 05:44:11', '2026-10-13 05:44:11'),
(16, 17, 'wiwi', 'activo', 1, 11, 'en su casa', NULL, NULL, NULL, '2026-10-13 05:44:11', '2026-10-13 22:16:29');

--
-- Triggers `servicios`
--
DELIMITER $$
CREATE TRIGGER `trg_servicios_audit_delete` AFTER DELETE ON `servicios` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','servicios',OLD.id_servicio,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_servicio',OLD.id_servicio,'id_cliente',OLD.id_cliente,'alias',OLD.alias,
                      'estado_comercial',OLD.estado_comercial,'id_plan',OLD.id_plan,'id_naps',OLD.id_naps));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_servicios_audit_insert` AFTER INSERT ON `servicios` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','servicios',NEW.id_servicio,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_servicio',NEW.id_servicio,'id_cliente',NEW.id_cliente,'alias',NEW.alias,
                      'estado_comercial',NEW.estado_comercial,'id_plan',NEW.id_plan,'id_naps',NEW.id_naps));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_servicios_audit_update` AFTER UPDATE ON `servicios` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','servicios',NEW.id_servicio,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_servicio',OLD.id_servicio,'id_cliente',OLD.id_cliente,'alias',OLD.alias,
                      'estado_comercial',OLD.estado_comercial,'id_plan',OLD.id_plan,'id_naps',OLD.id_naps),
          JSON_OBJECT('id_servicio',NEW.id_servicio,'id_cliente',NEW.id_cliente,'alias',NEW.alias,
                      'estado_comercial',NEW.estado_comercial,'id_plan',NEW.id_plan,'id_naps',NEW.id_naps));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_servicios_validar_insert` BEFORE INSERT ON `servicios` FOR EACH ROW BEGIN
  IF NEW.estado_comercial <> 'pendiente' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'INSERT de servicio solo permite estado pendiente. Use UPDATE para transicionar.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_servicios_validar_transicion` BEFORE UPDATE ON `servicios` FOR EACH ROW BEGIN
  DECLARE msg VARCHAR(255);
  IF NEW.estado_comercial <> OLD.estado_comercial AND NOT EXISTS (
    SELECT 1 FROM transicion_estado
     WHERE tabla = 'servicios' AND estado_origen = OLD.estado_comercial AND estado_destino = NEW.estado_comercial
  ) THEN
    SET msg = CONCAT('Transicion no permitida en servicios: ', OLD.estado_comercial, ' -> ', NEW.estado_comercial);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
  END IF;
END
$$
DELIMITER ;

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
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `creado_en` datetime NOT NULL DEFAULT current_timestamp(),
  `expira_en` datetime NOT NULL,
  `revocado_en` datetime DEFAULT NULL,
  `motivo_cierre` enum('logout','cambio_password','revocada_por_admin','seguridad') DEFAULT NULL
) ;

--
-- Dumping data for table `sesiones`
--

INSERT INTO `sesiones` (`id_sesion`, `token`, `tipo_usuario`, `id_usuario`, `id_credencial`, `ip_address`, `user_agent`, `creado_en`, `expira_en`, `revocado_en`, `motivo_cierre`) VALUES
(29, 'a03998d411b5b27adca1759c9017e6b6f490d831abdfe3c12e9148f83a82cfae', 'staff', 2, NULL, NULL, NULL, '2026-07-19 19:25:22', '2026-08-18 21:25:22', NULL, NULL),
(64, 'c9d9a1fb58d09726589fd50c25f2a3ed894a6ce096f242e278344ad04ebe2c51', 'staff', 1, NULL, NULL, NULL, '2026-07-20 23:11:20', '2026-08-20 01:11:20', NULL, NULL),
(65, '7bcf4c3d605bb0396e8f47e1b29aed55e6dfd6650f46aa730d63919068394205', 'staff', 1, NULL, NULL, NULL, '2026-07-20 23:11:20', '2026-08-20 01:11:20', NULL, NULL),
(66, '51df69836ef4952eb45438ef0b06f9dc629a1b986ef57ff7537ab0937804ff85', 'staff', 1, NULL, NULL, NULL, '2026-07-20 23:23:57', '2026-08-20 01:23:57', NULL, NULL),
(67, '8da54fe60009ed21c7abb62faf2f6b809ecc2add8e5c58b58bbdfe0af09a9702', 'staff', 1, NULL, NULL, NULL, '2026-07-20 23:23:57', '2026-08-20 01:23:57', NULL, NULL),
(68, 'dbf45925a9780194b6de65c1a79f78290bffe18f19c2efc5e26dd3a25cb863e9', 'staff', 1, NULL, NULL, NULL, '2026-07-20 23:29:35', '2026-08-20 01:40:47', NULL, NULL),
(72, 'b28a8eaf85bef1f0cccf055e46f794048e0f5c314c96cdeb2e20ccaac90a4a32', 'staff', 1, NULL, NULL, NULL, '2026-07-21 15:58:41', '2026-08-20 17:58:41', NULL, NULL),
(73, 'c6d8325330b94af32987601aaf9d89a64e8cbe5f0d60ce6f1138bc9b3dc7af51', 'staff', 1, NULL, NULL, NULL, '2026-07-21 17:08:42', '2026-08-20 19:08:42', NULL, NULL),
(74, '9b74729876e5b672cf377eb1d1d7a0d22af9d89b3085f3b0bcbe92e7e6d1e7e5', 'staff', 1, NULL, NULL, NULL, '2026-07-21 17:10:12', '2026-08-20 20:29:44', NULL, NULL),
(75, '9d72a6588de956a482896e27994959a1eee7a8b9ef8a2b8f424964772da10b04', 'staff', 1, NULL, NULL, NULL, '2026-07-21 18:28:48', '2026-08-20 20:29:04', NULL, NULL),
(76, '4e5d047edbeadf488bd6aea5b23dd304799589bde0fd6ec287e4cfa7d16038f4', 'staff', 1, NULL, NULL, NULL, '2026-07-21 18:29:24', '2026-08-20 20:29:24', NULL, NULL),
(77, '4eccbd99c350605ddff2a9d06b04e541d2e73ad13be87382da3e6966bacbc89f', 'staff', 1, NULL, NULL, NULL, '2026-07-21 18:29:50', '2026-08-20 20:36:44', NULL, NULL),
(78, 'd40d1f064832fd1e41833e27134f76ce3272950a6ea51f54e87528254a402866', 'staff', 1, NULL, NULL, NULL, '2026-07-21 18:30:14', '2026-08-20 20:30:14', NULL, NULL),
(79, 'd8ec056a5494a5bb8a53d3b1b2d1c17f514c1e5f9f0e9bf4f1bcc5597a1ceec2', 'staff', 1, NULL, NULL, NULL, '2026-07-21 18:30:41', '2026-08-20 20:30:41', NULL, NULL),
(80, '4559b7379f079c4d76ea7b554a8540b7c57c5701c39f9a5573de0ea9cbe379aa', 'staff', 1, NULL, NULL, NULL, '2026-07-21 18:33:23', '2026-08-20 20:36:59', NULL, NULL),
(81, 'e7ca832f0bd2a48e8204a6d385822b8de9049343d6ec09b9994cf68eeba9fb38', 'staff', 1, NULL, NULL, NULL, '2026-07-21 18:36:52', '2026-08-20 21:11:00', NULL, NULL),
(82, 'c998f053d64ba07e6b971a2540b3720c3b105dd1ddd78c62e6cf88e672417880', 'staff', 1, NULL, NULL, NULL, '2026-07-21 18:37:05', '2026-08-20 20:37:45', NULL, NULL),
(83, '9a4ccf8ccb83b04c43a9fd29068431b228c94e72ee724e87e1c7d009e4bbf210', 'staff', 1, NULL, NULL, NULL, '2026-07-21 20:44:37', '2026-08-20 22:44:37', NULL, NULL),
(84, '9ec2656561d83594a36c2757dc35ed8b4d9152edc32dc903bd5a9e9e2a0cbbd7', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-21 21:21:54', '2026-08-20 23:21:54', NULL, NULL),
(85, 'ed0bc3c4bc64c4e3a6ab3d67cb2e4419e2e1098b8e318658e469b1d83629de5a', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-21 21:23:42', '2026-08-20 23:23:42', NULL, NULL),
(86, '3f24282d41325bb0679a25a40163d1eaecbac83d68850686aad5d7844e3c608e', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-21 21:30:15', '2026-08-20 23:30:15', NULL, NULL),
(87, '853de080af3bd00f5c3ba3f113a9690187046faac7c983c066d0dad7bf49c4fc', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-21 21:37:39', '2026-08-20 23:37:39', NULL, NULL),
(88, 'cccee6ca9be258d97e189e25f7257df822a81084d3b23953dbabf18435ecc1c0', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-21 22:45:43', '2026-08-21 00:45:43', NULL, NULL),
(89, 'e3e0d6830b78c531ae77d5565cdad3f5ead05b004fd9108b2b83cd9907b21f54', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-21 22:55:42', '2026-08-21 00:55:42', NULL, NULL),
(90, '6be1f56573410cc5f27c5f15ee15b402680c9b6574e3be51afd3cbbe14c614fa', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 16:54:43', '2026-08-21 18:54:43', NULL, NULL),
(91, '00d96a69c4f8cfb349780612c7ad8784ef7b42d25f8b366356116a79dfcb7884', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 17:20:10', '2026-08-21 19:20:10', NULL, NULL),
(92, '05d13db9cd4fe9a7bf7302f90dbaa7c2205178f9de5c6e32d91629e28091e00c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 17:20:51', '2026-08-21 19:20:51', NULL, NULL),
(93, '7a0e3d0bc40a9ae3d4f123696a13de5e01b2d082e2193b1faf4063c9314a42e0', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 17:26:50', '2026-08-21 19:26:50', NULL, NULL),
(94, '2d0e269005d7f25be4ea4af8f23323b49b922157f3ba70b9c4b679acff4b9217', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 17:38:41', '2026-08-21 19:38:41', NULL, NULL),
(95, 'f880f8b2796dd7710a279e9efd53569e8c3ea00767cc029f8f82afab59837b7f', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 17:42:23', '2026-08-21 19:42:23', NULL, NULL),
(96, '934d284860491b8b74b38e62b49a9675ab212a06cc44c6268e77ce8fbf968326', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 18:16:11', '2026-08-21 20:16:11', NULL, NULL),
(97, '859a000e4d38237d02d6cecd748787065db08c5710ecef1bbed6aba0dc782f61', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 19:34:20', '2026-08-21 21:34:20', NULL, NULL),
(98, 'f1de0b5425a8100f26422381336baee58cb90315f9da4a699f478fd420e9e86d', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 19:51:35', '2026-08-21 21:51:35', NULL, NULL),
(99, '1c87c4c5e70a876ab40c9440af75cebb0ef6d687196640ebca3770b094eb1678', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 21:07:24', '2026-08-21 23:07:24', NULL, NULL),
(100, 'b9e79ffb2b7951376398100076f38b6ae3716d7ed7c5d2538caff01c678a1a69', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 21:15:28', '2026-08-21 23:15:28', NULL, NULL),
(101, 'cdbdc37cf0bf40cc552732a2b02f4017f0ac54a1fcb21572681de554d31ffce1', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-22 21:30:58', '2026-08-21 23:30:58', NULL, NULL),
(103, '448df05a6a57c86fe70521ef62619d59ff338486e969dd2b858a42b3d72ec999', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-25 23:26:01', '2026-10-26 01:26:01', NULL, NULL),
(104, 'd68e028590ff45c3ef525a83a62a93e08a847ad8fb507441e7b785e10923c251', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 03:14:13', '2026-11-04 05:17:28', NULL, NULL),
(105, '401c5cc62ff58421c4131145e775bd3e04823f5f6976b653fb6e113e4803d19a', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 03:17:34', '2026-11-04 05:25:15', NULL, NULL),
(106, '1819230e4eab3155d18d4ea88405d573da0da97675e50facd566de123d0e735a', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 03:28:02', '2026-11-04 05:28:02', NULL, NULL),
(107, 'cffbd80e8634d13c3f11d0dd52e03d2d20c633b0a8381601fb88d169c55f03ac', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 03:45:28', '2026-11-04 05:47:28', NULL, NULL),
(108, '35c31b046f11e9a8ef673564ccb648103b58f4fa6312a13239e8db128b92f094', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 04:02:12', '2026-11-04 17:39:13', NULL, NULL),
(109, 'a238377db17e014db48b0e05fccfd618cd092a0a35d7be70bda1a3640f9b1990', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 04:04:53', '2026-11-04 04:04:53', NULL, NULL),
(110, 'ab0a79aa17ff7d6b196a45de6ce9c19a75c2f1f8f6216853b5f02919184f2ecd', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 04:06:55', '2026-11-04 04:06:55', NULL, NULL),
(111, '42bf8e3571c9d5c272f680b9c2d3b27ec39a37286eb36c6ac4fce1b0a781a9e2', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 04:07:30', '2026-11-04 04:07:30', NULL, NULL),
(112, '6443daaf98ec2593aef2bdfa14bdc5cc27454feccd4fd61b8d61510b5c5cb606', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 04:17:34', '2026-11-04 04:17:34', NULL, NULL),
(113, '5e84deea6c3b3ee2a33e0173ea30a573c39aa42de7a191e1aff375c7be9f856d', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 04:20:15', '2026-11-04 06:20:15', NULL, NULL),
(114, '00efa3786059fea53521e069e2b67a777fb0dc841feee8ce2f7a331e86791998', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 15:48:14', '2026-11-04 17:48:14', NULL, NULL),
(115, 'eef169e7fd335eae1fa81edfafc197cc4021901e21b438010b4f32c1be881241', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 15:53:26', '2026-11-04 17:53:26', NULL, NULL),
(116, '112675183818f91160db13221a99c2ab941608f362d773951498ef78830c829d', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 16:05:41', '2026-11-04 18:05:41', NULL, NULL),
(117, '194a0367e9804b09811d9f67248a837a7a0235e00c0c28e232e93d3cfd166aa0', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 16:06:53', '2026-11-04 18:06:53', NULL, NULL),
(118, 'cd2c9ced8c71f999416dc34b2b17fe98ecc43a75e754bd3d3dcd4d9461a466d4', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 16:18:20', '2026-11-04 18:18:20', NULL, NULL),
(119, 'de60857df8dce97f6e95599153357cbd48e2e616facd074ea2c82336a4f7ee44', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 17:14:39', '2026-11-04 19:14:39', NULL, NULL),
(120, '37dceac9f9eaa7efb5e2c475ec11169b8c8324b8bb33c74845bd25fd82ce4c79', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 15:35:16', '2026-11-05 17:38:31', NULL, NULL),
(121, 'c5c2d571458b0d753d5e3bf512e3b564ec319786bcf0d655da9549b6cd67710c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 15:38:52', '2026-11-05 17:38:52', NULL, NULL),
(122, 'e4d95739f3ac732420c592392646ccbb67030ba44d82e64d150d39d427cba218', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 17:07:58', '2026-11-05 17:07:58', '2026-10-06 13:17:25', 'logout'),
(123, '21d422442786b0bc40fdd9991f085e693e39fddb277d7ceb33c400e9653098a9', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 17:17:31', '2026-11-05 19:17:31', NULL, NULL),
(124, '0c4a85a7dd0d52531d7de6535f8fdd22156140964dcea2d69c1f328b51044cdb', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 19:18:01', '2026-11-05 21:18:01', NULL, NULL),
(125, '1f28e4ebd152fca042afec1efdb8147961f3db07f941f830c9b84076b856f748', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 19:23:17', '2026-11-05 21:23:17', NULL, NULL),
(126, '004575e267c8d5236655685a7a6c88591b20c5a52b4ad9eb80c44793eaa13745', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 19:33:39', '2026-11-05 19:33:39', '2026-10-06 15:34:58', 'logout'),
(127, 'c096e8654931b0ecbbc0412d7e6ef2dae554dc18cd2880d738e1323e228b5dd4', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 19:35:09', '2026-11-05 19:35:09', '2026-10-06 15:36:31', 'logout'),
(128, '4611ba908cc3773b40b597952149b7622c0c110af2a5ea0467efe1bfb96a4b0d', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 19:36:37', '2026-11-05 21:36:37', NULL, NULL),
(129, 'c70e7705dd4ef484891af1937c4704b990407cf2a4043c2e49aabbff2171be1c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 20:17:06', '2026-11-05 20:17:06', '2026-10-06 16:17:31', 'logout'),
(130, '3499fd49befcb0869f3a5c17a8efdd1fc1b1b08551134b0d2d2dbc5040bc39e8', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 20:17:41', '2026-11-05 20:17:41', '2026-10-06 16:18:35', 'logout'),
(131, 'd65bc39a253aaac8c81d6c52ecd0ac1865c16c8d8b8ebbc568a54094ef84ec7c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 20:18:42', '2026-11-05 20:18:42', '2026-10-06 16:25:34', 'logout'),
(132, 'c7948a1fdf9d466929d5996c08ccf018b46c315b8a0120b3efc03271a2b2fada', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 20:25:40', '2026-11-05 22:25:40', NULL, NULL),
(133, '190d235af0b33292818107b3d1adc6d94447704d6eb2e4cd39e5f7b2f055bde5', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 20:50:20', '2026-11-05 22:52:31', NULL, NULL),
(134, 'bfb738f0d1bf341cf749c4f18f400f614b732fee27a7885acaba7cdd29138d86', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 20:52:47', '2026-11-05 22:52:47', NULL, NULL),
(135, '179a8d949061adf473e65192d27378853f40c19fba7d5f754cef716380f32600', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 20:54:42', '2026-11-05 20:54:42', '2026-10-06 16:54:49', 'logout'),
(136, 'e2cfb3d1ccaca07225da6d108a5a1af7c832a4958c0183eb3ced54885fa466fb', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 20:54:59', '2026-11-05 22:56:17', NULL, NULL),
(137, 'e84c23ead6b214fb87d62927c396e3784d8f6f6461996b0c0bdc5256a0d27df8', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 20:56:25', '2026-11-05 20:56:25', '2026-10-06 16:56:43', 'logout'),
(138, '534918274dcdd9171b4fcbc5ff7ac43775b6843d10541d888d24614e0154d5ed', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 20:56:51', '2026-11-05 22:57:49', NULL, NULL),
(139, '8a113d1945062a93a187747890f8e49b5015e90d2e5b54f47b04b72e12f32b73', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 20:57:56', '2026-11-05 22:57:56', NULL, NULL),
(140, '0674da6f522d08aac71abe7781e78ee20292df9ed513b7f9c73202f5b8ab29e1', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 21:02:35', '2026-11-05 23:03:04', NULL, NULL),
(141, 'f666209686117011f32531e2d135e5c3cca37129a0c2113ba1375497f9d659a8', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 21:03:12', '2026-11-05 23:03:46', NULL, NULL),
(142, '017fc84696f0ab8a5f799affb10fae5a7d4fa14a3df2a939e16d8a5b4994f498', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 21:03:54', '2026-11-05 21:03:54', '2026-10-06 17:04:09', 'logout'),
(143, 'b53e6f26ba9f1076bc4a753c86a6ebe2dc8a8f7e7194c7a89c0da0b0198efe7d', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 21:04:17', '2026-11-05 23:04:28', NULL, NULL),
(144, '7a96561456630299028e62c00c5faeee24ce89c55f680749f1d3d9e44ce96142', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 21:04:39', '2026-11-05 23:04:39', NULL, NULL),
(145, 'b5d5743090bb2a54463591722cb381971820560bf023d7acb6845c0985002af4', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 21:26:31', '2026-11-05 21:26:31', '2026-10-06 17:27:44', 'logout'),
(146, 'd28379ec28eaf68adbf443ce84d9187c2daf149bbec8e9a657fce48a4d6304fa', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 21:28:09', '2026-11-05 23:28:09', NULL, NULL),
(147, '39f70642afcbbf5ec127126b9dff9e71c321f52e3059f05eb1205e5f81d2fca3', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 21:33:45', '2026-11-05 21:33:45', '2026-10-06 17:34:00', 'logout'),
(148, 'c3b780acbe5447009473534585e65e70c352e188a8a41c7bc4c506ea106b9b90', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 21:34:16', '2026-11-05 23:34:16', NULL, NULL),
(149, 'd7f6c626daa8725307efa64ccc66e819a73b72b643cc69c1a1436431919660dc', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 21:37:08', '2026-11-05 23:37:08', NULL, NULL),
(150, '902d503a89f172da34397f1efd71c61854b5b4f671179ff8d3835fb5c0651d66', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 21:37:46', '2026-11-05 23:37:46', NULL, NULL),
(151, 'a542eca76098da9b20f12c72b0abe19b4ec9b62b25a2e6fc16a87e519279c111', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 21:47:58', '2026-11-05 21:47:58', '2026-10-06 17:48:13', 'logout'),
(152, '7ab442031bd9bcd4a3c22803a7a80d34318e015b8f7c007de1aa5d25b94f19bf', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 21:54:08', '2026-11-05 23:54:21', NULL, NULL),
(153, 'a3b2c5fe47739d2b66de31db484e6ce56b8dbd01ad7f7241893543726ef4106d', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:04:19', '2026-11-05 22:04:19', '2026-10-06 18:04:36', 'logout'),
(154, 'edb88d0924d0043b17dafb2ea3329bd2b98f0701da3230ecb17b40cf63db2244', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:04:47', '2026-11-05 22:04:47', '2026-10-06 18:04:52', 'logout'),
(155, 'd1c99e5503092afb0c70735cfc34b8600406bea7ec2d8433415e9214db2348d3', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:04:59', '2026-11-05 22:04:59', '2026-10-06 18:05:04', 'logout'),
(156, '568f9e65b5a08e334ac4bcf52c378ac2a92c0a1d2812d7b008abb36782a93d43', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:05:14', '2026-11-06 00:09:41', NULL, NULL),
(157, '6d335e29e63351f8a6e026365f8ea51833e94898252d91ea4b3a2f263ed93e3d', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 22:09:47', '2026-11-05 22:09:47', '2026-10-06 18:10:04', 'logout'),
(158, 'a11cc64885146b3206fc122406bb602bb75e18e433fa8b6206b0aa38bbd5599f', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:10:14', '2026-11-06 00:10:31', NULL, NULL),
(159, '1a70bdf79b82432760a01ed9a6cd4c58ae897b0004f7606107439f90a5f4d56a', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:10:38', '2026-11-05 22:10:38', '2026-10-06 18:12:19', 'logout'),
(160, 'd372242cfdc7d8f8a8ba0799a9441958d0194b89ca34672005979d04d2e50b83', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:12:26', '2026-11-05 22:12:26', '2026-10-06 18:13:06', 'logout'),
(161, '044810f5eae540422d8e08d0f1271dd6bca73530d225c533678a3a58c02b34e9', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:13:13', '2026-11-05 22:13:13', '2026-10-06 18:14:01', 'logout'),
(162, '748d84b302408bf7d9614a1b7ecbb8775d4dba583292fd7c726a307882c3b963', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:14:09', '2026-11-05 22:14:09', '2026-10-06 18:14:25', 'logout'),
(163, 'e5d0ccc0b620ba72761b6eb9dbcfe27906989cfac1ef32c86526f6783dfd7114', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:14:32', '2026-11-06 00:14:42', NULL, NULL),
(164, '1aae75731375e288d99c2e5862d4a0b006c2e1bcb19947380c475eea6a4d4d30', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-06 22:14:48', '2026-11-05 22:14:48', '2026-10-06 18:15:37', 'logout'),
(165, 'd0a7d4bf63452ed9cabc21507a117309ca7ad485f82584237cf018316b21996f', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:15:44', '2026-11-05 22:15:44', '2026-10-06 18:19:35', 'logout'),
(166, '6e9c7a22791a3e435e4b5fb2fbc5b451dbc234f11753adf36e8bc9d4e8514cf7', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 22:19:42', '2026-11-06 00:19:42', NULL, NULL),
(167, 'd1443bf45f8d5e2b6f11d0e7c29f2f084e2cba96ede8e0adfb5d0cb5c0784361', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 14:55:34', '2026-11-07 16:55:34', NULL, NULL),
(168, '7517aff7e74232aeb35649248e57e73756d7347e44a4e0e1de794566362b188c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 15:28:17', '2026-11-07 17:28:17', NULL, NULL),
(169, 'a3001e1f088b5ee279b885356789a7d12bac602c846f26bf16cfb7289d621282', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 15:42:30', '2026-11-07 17:42:30', NULL, NULL),
(170, '58a8b409531f043f915b7779f255628064b22404fac7719a8725a4f1c87f65fc', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 15:45:22', '2026-11-07 17:45:22', NULL, NULL),
(171, '3f5379cabadcb161c523f9ca232b78fcb3ebbf9b50852f7bf7137800f40ee29f', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 15:52:08', '2026-11-07 17:52:08', NULL, NULL),
(172, '4596d9fdec403f22817f90b987341db56712b0602d411cd9f358c58e5dd6fa6a', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 15:56:02', '2026-11-07 17:57:27', NULL, NULL),
(173, '8fe2fedc4b13fb9b25e4805665346301b54339116b4dbc5935a5b4c7eac785b7', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 15:57:34', '2026-11-07 15:57:34', '2026-10-08 11:58:19', 'logout'),
(174, 'cd365274319a7f3bc758ea21c8735fb3867b5696d86bcc6a49ecf7d2c5bf963b', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 15:58:28', '2026-11-07 17:58:28', NULL, NULL),
(175, '76c34d98847e31f16bc17bde72e48ab83e77fe7bd6d0b75c460670d189224d9a', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 16:03:28', '2026-11-07 18:04:01', NULL, NULL),
(176, 'cce4d431d13ce751d148183c9dee164bebb7aeaaa51bfa94b9ca0694d6a05a09', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 16:04:34', '2026-11-07 16:04:34', '2026-10-08 12:04:47', 'logout'),
(177, 'f1ede32fe25f10d3434f28898376a91029a28f8f8145ebb272fc45070135771e', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 16:04:59', '2026-11-07 16:04:59', '2026-10-08 12:07:09', 'logout'),
(178, '6a0a1afb490028ac11409a420ed8198f0f3c5ad7689cc82a134cefcc773c3adc', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 16:07:16', '2026-11-07 16:07:16', '2026-10-08 12:07:37', 'logout'),
(179, 'f1f6ee93afe63b8311da01dcf28110406aabda6d32c7e2badbcc8d773da9828a', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 16:07:45', '2026-11-07 18:07:45', NULL, NULL),
(180, '6a4959a176764160d249b36695c55201e43cd69e5a72f984d6438bec64eaee7a', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 16:15:09', '2026-11-07 18:15:35', NULL, NULL),
(181, '65cd5cc18027e9952c8336a65c08feed77efb1b275dffc5697dd932917c8d470', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 16:16:41', '2026-11-07 18:16:53', NULL, NULL),
(182, 'a988e2c1ad897046f24e99cb0033ba00080be0d6e163107a98a4d86576e92c35', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 16:23:57', '2026-11-07 18:23:57', NULL, NULL),
(183, '9e411e7a5e0d2aa442bbeec6c2ab55c0ce447139d186ebe87aaffc4fd80a5cab', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-08 16:34:41', '2026-11-07 18:34:41', NULL, NULL),
(184, '42d7c6eb43c0e17a589b3c478859ba80f89f66b93bc459cd3443a015b756c3cd', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-09 18:52:18', '2026-11-08 20:53:55', NULL, NULL),
(185, 'd590554f754313622f21a9c6811ff34476e3cf1dacdcb74954daad6c52fc138f', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-09 18:54:06', '2026-11-08 20:54:50', NULL, NULL),
(186, '665014deb91f2669ea57d0b49d470c6a46481b755fa0033312effabca26a38ec', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-09 18:54:59', '2026-11-08 20:54:59', NULL, NULL),
(187, '6e86be806f4547b7fb10a7b9608a4b8304a9da469ae02236d63fc6aab1e3ddd9', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-09 19:10:07', '2026-11-08 21:10:07', NULL, NULL),
(188, '121cd505bcdcca83c483786c6f4da1b318019d3d93396b865687dce2963376f4', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-10 04:10:36', '2026-11-09 04:10:36', '2026-10-10 00:11:18', 'logout'),
(189, '6b5611cfb3c14edbaf19b9a4394651303fdbfac557a922f3d559b48c65ed23cb', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-10 04:11:30', '2026-11-09 06:11:30', NULL, NULL),
(190, '59a74d7c88593e178cbbc82e79ae80ebf43a94d3185e56c27f340833e26ac858', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-10 04:16:55', '2026-11-09 04:16:55', '2026-10-10 00:18:54', 'logout'),
(191, '5c8a84a69a58a4628ab71a5857271f56e5529974be23614c89f4169d3fcd9d05', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-10 04:19:01', '2026-11-09 04:19:01', '2026-10-10 00:19:46', 'logout'),
(192, '1c92d5d8fff157c028c842c440cb9d19e4bd7fd4eaa13766c441e5f858f16a66', 'staff', 3, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-10 04:19:54', '2026-11-09 04:19:54', '2026-10-10 00:20:11', 'logout'),
(193, '366976a64fd7f4c92d1f76cc1bd4954106f36bcec6d33b4d5805f2321855d056', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-10 04:25:03', '2026-11-09 06:31:25', NULL, NULL),
(194, 'c1a04f0448fa66d348a51dc1b65ff2f40190f18935243d8b528934bab1c595d7', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-10 18:24:53', '2026-11-09 20:24:53', NULL, NULL),
(195, '8c910d665ff8734aa705280dc3c2ae1cb5da65b6bad18e073e136e0b64b6fb8c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 04:15:55', '2026-11-10 06:15:55', NULL, NULL),
(196, 'c6e9d3a46f8a41a1262c1aaa55ca1882d1a0a5bb75270617949501c8bc14e8d3', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 04:44:11', '2026-11-10 04:44:11', '2026-10-11 00:45:24', 'logout'),
(197, '59f5d5202783ea58846a00338f4d4f7f7d30021e45634cd77d0d5b4b3400f9f8', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 04:45:32', '2026-11-10 04:45:32', '2026-10-11 00:46:07', 'logout'),
(198, '2f5ab3dc588132b8ce9f4e1204d4f9953c7aed9b787d2372d7946b71d6e118c2', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 04:46:25', '2026-11-10 06:49:10', NULL, NULL),
(199, '7ea1159b61f1bdc1f877606ec69f1bdea2c2ae0ce769921def86d4e26f028873', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 04:49:27', '2026-11-10 04:49:27', '2026-10-11 00:50:16', 'logout'),
(200, 'f25ea48194af474b389c1594204bde593ad484283ace7d6695f0095bfd9d02ef', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 04:50:31', '2026-11-10 04:50:31', '2026-10-11 00:55:32', 'logout'),
(201, '15afce68d66bf20e3165151b2994315a3c48b83a68388f884ef622e727b985b9', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 04:55:39', '2026-11-10 04:55:39', '2026-10-11 01:00:35', 'logout'),
(202, 'aa7e3327bdc49f7b9a26cee851b59daf5934348ed8532044c650407350b6f4dc', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 05:00:40', '2026-11-10 07:00:56', NULL, NULL),
(203, 'd5bcde0e8b77a6a5dce74216f4ae915711e870306fb61bf3153629f184c03dd2', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 05:01:16', '2026-11-10 07:01:16', NULL, NULL),
(204, 'b232980814ce48fd5ab876a44feb589fc95a7d8f2d52b1a6d393136169aa6563', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 05:04:48', '2026-11-10 07:04:48', NULL, NULL),
(205, '7ebf609e4490d39efd68a5e4af9e4669ee63afabece9fe3ec7a33b5a248ab757', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 05:55:46', '2026-11-10 07:55:46', NULL, NULL),
(206, 'd7f80381af2d5082cf7e472efe5db04a89553e0633e6e177da663ed9295eb826', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 05:56:09', '2026-11-10 07:56:09', NULL, NULL),
(207, '1397a68a63d55301e817990b31739dc94793349d7cb6462f99c03379dd66f4ca', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 05:57:23', '2026-11-10 07:57:23', NULL, NULL),
(208, '6cf6240c99c7938b9a0e7f4026bdfd36202c26bd945d2d13ce3541459b27b9dc', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 06:01:56', '2026-11-10 08:01:56', NULL, NULL),
(209, '7898a68f336bd08267fb7d436ad1c9c1e2cd22b39afea1d306534d7f117e0aa0', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 06:02:34', '2026-11-10 08:02:34', NULL, NULL),
(210, '65f7f18feb6b8bfd9afaf9ee3ffea90135ec0de3fc9a2c62a1d4a6fa82a44249', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 06:10:31', '2026-11-10 06:10:31', '2026-10-11 02:11:13', 'logout'),
(211, '6517a21ec618db5329db0f944c15813dfec93898b890166d834daee8fedc9c12', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 06:11:23', '2026-11-10 08:16:54', NULL, NULL),
(212, 'a894e7e23c6a561a53d87c058ec7ce7199668bc30415036c98c14706d8f22c2d', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:24:10', '2026-11-10 17:24:10', '2026-10-11 13:24:52', 'logout'),
(213, 'deac873a51ca02f72ff172822a4319812fda3b5eb99ff9dc88bd7e3fe4bfb66a', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:25:01', '2026-11-10 17:25:01', '2026-10-11 13:26:13', 'logout'),
(214, '169a83954617b166f430c260d32b009caa31e4cc5918fbae9ad9937309b9368e', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:26:20', '2026-11-10 17:26:20', '2026-10-11 13:26:46', 'logout'),
(215, 'f86e0b4a0ef6c5cc1bca76c05c8ff0bdc4536f8bfd3f1a2457d8f5c1850f1d5f', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:26:54', '2026-11-10 17:26:54', '2026-10-11 13:32:24', 'logout'),
(216, '84d2ba8f93a006d31d540ddd1750b00ad13db02a8fef286b83dd7ea8b7d822c5', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:32:31', '2026-11-10 17:32:31', '2026-10-11 13:33:05', 'logout'),
(217, 'bfabd33fcb7e426f550b51b343362865a0183bd872a00a1ee44057ad03fa77a4', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:33:12', '2026-11-10 19:33:12', NULL, NULL),
(218, 'a54c761c3aaf0e1d73f50ec9d1f8cf4d04465f70ca18ed26d444b1868345941f', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:33:35', '2026-11-10 19:34:08', NULL, NULL),
(219, '05d75b951bae0cab2fe7947462895d969c23797fe3e5e78c5cd6a51696645fd6', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:35:09', '2026-11-10 17:35:09', '2026-10-11 13:35:59', 'logout'),
(220, '22935796e7803158027f9b137272fc4aa166085341b56133209329d85ed6013c', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:36:07', '2026-11-10 19:36:07', NULL, NULL),
(221, 'afa5f2a32f1a149311ca98aebd9df85a92fe148c7e3dcfc7677a59a80b2e1282', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:36:35', '2026-11-10 17:36:35', '2026-10-11 13:36:57', 'logout'),
(222, 'dbf658d303b2f504140c3d2da7a9b9f6557e47e593f2476a934c396ffe8c08d9', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:37:53', '2026-11-10 17:37:53', '2026-10-11 13:38:19', 'logout'),
(223, '6852a8292c700d2dcf83fad7e58d6085af1abf7d086d1a477442e07b3d4d6790', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:38:27', '2026-11-10 19:38:27', NULL, NULL),
(224, '4f6d9f75e7ed283f3925101fce5f1822a73e1987c1f40beed61a0c07ccf37c5c', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 17:38:54', '2026-11-10 19:44:49', NULL, NULL),
(225, 'c71c6340f811fc85bd394c11230f2ad44577d69ee6511186a2f36456623cb69c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-11 17:45:09', '2026-11-10 17:45:09', '2026-10-11 13:45:59', 'logout'),
(226, '31577b13ad1e2f605c3f495fe957ff14f44bac8f44bc66d6848411c1bd91b12e', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-11 17:46:10', '2026-11-10 17:46:10', '2026-10-11 13:48:10', 'logout'),
(227, 'a16d0f71cc4cbc15a8b11006b745838c78158f51a052002c77ba68fca07a620b', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-11 17:48:18', '2026-11-10 19:48:18', NULL, NULL),
(228, 'bd2934ec23489c448e25d771c21498e961c63806830c29dd8f796d2af4de0140', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 21:45:02', '2026-11-10 23:45:02', NULL, NULL),
(229, 'f45fc688bd06844fbe0b1ab2d67537410f609b5518e48bd24df9ea6e74eb3947', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 22:27:32', '2026-11-11 00:27:32', NULL, NULL),
(230, '06a7880b1432a553e66d2593adcbae473eb05b86ebd6b3e2d53e9b9904947dfa', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 22:31:22', '2026-11-11 00:31:22', NULL, NULL),
(231, '5aeb45c3e4e4ef697b654fb4e41f1fc0593059f29bc3e9384af07fe6978af8d7', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 22:34:46', '2026-11-11 00:36:19', NULL, NULL),
(232, 'c787c03870eb85f7767528d09d206c5a9c6f5d346f708926636075d232cebb81', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 22:36:37', '2026-11-11 00:36:49', NULL, NULL),
(233, '70d59bab28106a46e782220fbdc96f791c810f760b4037ab4afa8b96484d4c21', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 22:37:04', '2026-11-11 00:39:51', NULL, NULL),
(234, '7ddf8852a925ed3407272473163ecc496a0e79d80a031c828ca1c955e5c73eca', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 22:40:15', '2026-11-11 00:40:15', NULL, NULL),
(235, '16c32c1f263a6098287c154dda3937b1b1b4dab3dfd2083e6f63b58323c7de72', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 22:41:45', '2026-11-11 00:41:55', NULL, NULL),
(236, 'a456e2c00d1a7eb41bb5a1344ad09edded4da0279ad40f566679dbf45c5d0523', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 22:42:50', '2026-11-11 00:42:50', NULL, NULL),
(237, '19b8994ffed95217451f07a78be0e738bde3c1c25945acb0ee143bcfa53391f1', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 23:16:25', '2026-11-11 01:16:25', NULL, NULL),
(238, '3a3addc986cc3636c9af6248aff873b13762e259fc1cebf33468ece22e12ee96', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 23:21:33', '2026-11-10 23:21:33', '2026-10-11 19:22:55', 'logout'),
(239, '6853cdabebf0248fb9762151c7096c567b92b99684baafb2537f77c820bf8785', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-11 23:23:07', '2026-11-11 01:23:07', NULL, NULL),
(240, '3cbba0cd16116c8c4a24958c53e0d5df4765700bb0544c168f139b0a66f8d769', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 23:24:14', '2026-11-11 01:24:23', NULL, NULL),
(241, '73804a1988346eb1d92c6561582a06154a827c5eba6b7768294e119d691e41fd', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-11 23:24:31', '2026-11-11 01:26:47', NULL, NULL),
(242, 'c85350d315ffb35c7250b138d4ba711408eb49312719d24e1e2f378276e20e41', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-11 23:27:00', '2026-11-11 01:27:00', NULL, NULL),
(243, '0f30f20223de6e346db134ab1058039d2703e3769e6bbf639994a1dc422bc5dc', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 23:31:09', '2026-11-11 01:31:09', NULL, NULL),
(244, '568315906c138fd410860f31466ef1fc1c81bc2bed580a9e694956e83eabd767', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-11 23:40:07', '2026-11-11 01:40:07', NULL, NULL),
(245, 'b6c8b1738394bd691e61c52735852a7a697b36a108c862990ec690d60c740580', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 19:28:06', '2026-11-11 21:28:06', NULL, NULL),
(246, '98722a24176d24163edf219f26b4af22a157ac59aca3029916ccb28a22690fba', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 19:49:21', '2026-11-11 21:49:21', NULL, NULL),
(247, '22bc4295905804edd30d4f92abfe5b96962c989ab696aabc61248a75ee67cfa5', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 20:03:24', '2026-11-11 20:03:24', '2026-10-12 16:04:49', 'logout'),
(248, '8a6ddf7e6b7e2e9bfea4c16af166b487edd345255618df849b518147e46f388e', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 20:04:59', '2026-11-11 22:04:59', NULL, NULL),
(249, '0c31ef841cedf102d13368394ba3d9f0b618f0778abd956d167b4d766d8d1a91', 'staff', 1, NULL, '127.0.0.1', 'curl/8.21.0', '2026-10-12 21:22:59', '2026-11-11 23:22:59', NULL, NULL),
(250, '74af8d2bb186e9f332467783db893cce5f79724cf04bafbb041d56113490fce0', 'staff', 2, NULL, '127.0.0.1', 'curl/8.21.0', '2026-10-12 21:24:09', '2026-11-11 23:24:09', NULL, NULL);
INSERT INTO `sesiones` (`id_sesion`, `token`, `tipo_usuario`, `id_usuario`, `id_credencial`, `ip_address`, `user_agent`, `creado_en`, `expira_en`, `revocado_en`, `motivo_cierre`) VALUES
(251, 'ffe821dd3d0c6bb39cff6d3956af515d267abf873327de5f7af851a525bf74f2', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 21:30:40', '2026-11-11 23:30:40', NULL, NULL),
(252, 'd463c1724023ca4c8ea0aca6bc2af334c88b052a9995338041a71017b00fa8d8', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-12 21:39:43', '2026-11-11 21:39:43', '2026-10-12 17:40:46', 'logout'),
(253, '063b267d22ad0b8add13092db27e3cb1136fea97be985bb2b650ea68cbf3e798', 'staff', 2, NULL, '127.0.0.1', 'Mozilla/5.0 (Linux; Android 16; Pixel 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-12 21:40:54', '2026-11-11 21:40:54', '2026-10-12 17:42:53', 'logout'),
(254, '141a970cc39b2abf8107983ca4ccecf7a77e99b52c44efbfc5246d20107cf2ec', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 21:42:59', '2026-11-11 23:42:59', NULL, NULL),
(255, '8db9de8a2029889cae35bd4ca76bc702981b7ef05c3abd281535f0f746362274', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 21:45:06', '2026-11-11 21:45:06', '2026-10-12 17:45:13', 'logout'),
(256, '015dd1be17c3e4fe1b1ce48fed60138d5fe1d187c683a284ff106df72407a89c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 22:17:35', '2026-11-11 22:17:35', '2026-10-12 18:19:26', 'logout'),
(257, 'a84778f4c6e6711dc6dcd28d1b1f01ef7f7645e218a1393d1e96d41c581578b0', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 22:19:43', '2026-11-12 00:19:43', NULL, NULL),
(258, 'fa671e61a55341b400ccc89dcbb8188d54394b9f8ac02af0adce7d4a52c6dc1c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 22:42:42', '2026-11-11 22:42:42', '2026-10-12 18:43:29', 'logout'),
(259, 'e6aa438b99478d8c03abc7ebbb54a908935f8b964096c252d522a12bf111bb00', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 22:43:36', '2026-11-12 00:43:36', NULL, NULL),
(260, 'e87ab93639777ebe20ccd5e5b7b32d4f621353c76b95bd6ca208e06bb6823999', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 22:43:51', '2026-11-12 00:43:51', NULL, NULL),
(261, '97836510a10e13831c6211a286bd817933b305c5f60baa8e7c8af297f5c1ac05', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 14:29:24', '2026-11-12 16:29:51', NULL, NULL),
(262, '4ae0b5b6c795a5d77cde7b68da625b42b0c0fbf2ec17e0a95dbd56da07c77b80', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 14:30:10', '2026-11-12 16:30:10', NULL, NULL),
(263, 'dbe9c84f1432c317ff32b0e8638548fdb58df93b20e46c267fd2517894153312', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 15:00:45', '2026-11-12 16:00:45', NULL, NULL),
(264, 'b131564ff636f319e564db6cdae8793639b54ecfbaf3685f6246e9ce8c9052c7', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 15:07:14', '2026-11-12 15:07:14', NULL, NULL),
(265, '002f0d23d510312812f473e2f278daa5fc6c5760a70f6b380b110086cfb285e1', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 16:18:42', '2026-11-12 16:18:42', NULL, NULL),
(266, '7795cf15df3777969ce928e7b4a1cad405692c21bb2a511f1893f61744ace6ac', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 16:49:55', '2026-11-12 16:49:55', NULL, NULL),
(267, '74aadcf822c3901e865085c024d5550fe27d42796873663855b27383c8ee095e', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 17:10:05', '2026-11-12 17:10:05', NULL, NULL),
(268, '6a4fd225a10167b9c95aa3abddd315994884aaa9a120eebc165703855b4af7d8', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 17:20:48', '2026-11-12 17:20:48', NULL, NULL),
(269, '2b313c8bcf00e7ebac8a41aa6239b13d098d86e4361f66e88527337cd736ce1b', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 18:24:17', '2026-11-12 18:24:17', NULL, NULL),
(270, '623c019c0292c278c637c2f7213e12570baacdb2654624885f01ab856de169ba', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 19:17:00', '2026-11-12 19:17:00', NULL, NULL),
(271, '8e15aadebfa097b21982265d2268ced0be2b367aa3b4d0af4f528ca5b1994800', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 20:57:09', '2026-11-12 20:57:09', NULL, NULL),
(272, '25f0c3a6cd3e83f097fd3d826a6bbd898d9688d6232161a4c3f430f19aebf0e0', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 21:35:09', '2026-11-12 21:35:09', NULL, NULL),
(273, '80acc11a31551af856dccd41bd8d64827014c41ab574f96df2eee2f079ad9549', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 22:14:25', '2026-11-12 22:14:25', NULL, NULL),
(274, '563d7edb1dac38a759c71649921499c9ef6e29ba742b320f0e3930d55aee3ea5', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 23:25:42', '2026-10-13 23:26:27', '2026-10-13 23:26:27', 'logout'),
(275, '3e304620306dc00b61a01dcc27dd141b223cd9daa955cd5639feef8a0b153d5c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 23:27:15', '2026-10-13 23:27:34', '2026-10-13 23:27:34', 'logout'),
(276, '15d53ffa2a7b42176db3560e774c1e4f88ffabbf01c44fba29d73acb2d95d247', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 23:27:42', '2026-11-12 23:27:42', NULL, NULL),
(277, '7aab34996bcba7993247e6831cb6ff327ecd55453432056196239982c36e467c', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 23:29:26', '2026-11-12 23:29:26', NULL, NULL),
(278, '32d2ef8533f8ed6b670a6c8392813d24eec0dea10de7c4188e980ce7150d001d', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 23:36:37', '2026-10-13 23:37:03', '2026-10-13 23:37:03', 'logout'),
(279, 'dc13be8b4e65f61b80318d0191de42a4b1314fa5d4ba9fa61d3b5bd545470b81', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 23:37:09', '2026-10-13 23:37:54', '2026-10-13 23:37:54', 'logout'),
(280, 'c3d1ffe66bf010bb510db7af875e4ccc5eacc0d82e49d4fc3f8dca45df03df39', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 23:37:59', '2026-10-13 23:38:28', '2026-10-13 23:38:28', 'logout'),
(281, '943a8e1af708ca55c4f36611ae08b091d1394f34186ca66df5c14a3b4db16f8f', 'staff', 1, NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 23:38:34', '2026-11-12 23:45:30', NULL, NULL);

--
-- Triggers `sesiones`
--
DELIMITER $$
CREATE TRIGGER `trg_sesiones_audit_delete` AFTER DELETE ON `sesiones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','sesiones',OLD.id_sesion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_sesion',OLD.id_sesion,'tipo_usuario',OLD.tipo_usuario,'id_usuario',OLD.id_usuario,
                      'id_credencial',OLD.id_credencial));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_sesiones_audit_insert` AFTER INSERT ON `sesiones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','sesiones',NEW.id_sesion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_sesion',NEW.id_sesion,'tipo_usuario',NEW.tipo_usuario,'id_usuario',NEW.id_usuario,
                      'id_credencial',NEW.id_credencial,'expira_en',NEW.expira_en));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_sesiones_audit_update` AFTER UPDATE ON `sesiones` FOR EACH ROW BEGIN
  IF NOT (NEW.revocado_en <=> OLD.revocado_en) THEN
    INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
    VALUES ('UPDATE','sesiones',NEW.id_sesion,
            COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
            JSON_OBJECT('id_sesion',OLD.id_sesion,'revocado_en',OLD.revocado_en,'motivo_cierre',OLD.motivo_cierre),
            JSON_OBJECT('id_sesion',NEW.id_sesion,'revocado_en',NEW.revocado_en,'motivo_cierre',NEW.motivo_cierre));
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `sla_definiciones`
--

CREATE TABLE `sla_definiciones` (
  `id_sla` int(11) NOT NULL,
  `id_categoria` int(11) NOT NULL,
  `prioridad` enum('Alta','Media','Baja') NOT NULL,
  `horas_respuesta` smallint(5) NOT NULL,
  `horas_resolucion` smallint(5) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sla_definiciones`
--

INSERT INTO `sla_definiciones` (`id_sla`, `id_categoria`, `prioridad`, `horas_respuesta`, `horas_resolucion`, `descripcion`, `creado_en`) VALUES
(1, 1, 'Alta', 1, 4, 'SLA de soporte técnico — prioridad alta', '2026-10-13 07:00:17'),
(2, 1, 'Media', 4, 24, 'SLA de soporte técnico — prioridad media', '2026-10-13 07:00:17'),
(3, 2, 'Alta', 2, 8, 'SLA de facturación — prioridad alta', '2026-10-13 07:00:17');

--
-- Triggers `sla_definiciones`
--
DELIMITER $$
CREATE TRIGGER `trg_sla_definiciones_audit_delete` AFTER DELETE ON `sla_definiciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','sla_definiciones',OLD.id_sla,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_sla',OLD.id_sla,'id_categoria',OLD.id_categoria,'prioridad',OLD.prioridad,
                      'horas_respuesta',OLD.horas_respuesta,'horas_resolucion',OLD.horas_resolucion));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_sla_definiciones_audit_insert` AFTER INSERT ON `sla_definiciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','sla_definiciones',NEW.id_sla,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_sla',NEW.id_sla,'id_categoria',NEW.id_categoria,'prioridad',NEW.prioridad,
                      'horas_respuesta',NEW.horas_respuesta,'horas_resolucion',NEW.horas_resolucion));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_sla_definiciones_audit_update` AFTER UPDATE ON `sla_definiciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','sla_definiciones',NEW.id_sla,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_sla',OLD.id_sla,'id_categoria',OLD.id_categoria,'prioridad',OLD.prioridad,
                      'horas_respuesta',OLD.horas_respuesta,'horas_resolucion',OLD.horas_resolucion),
          JSON_OBJECT('id_sla',NEW.id_sla,'id_categoria',NEW.id_categoria,'prioridad',NEW.prioridad,
                      'horas_respuesta',NEW.horas_respuesta,'horas_resolucion',NEW.horas_resolucion));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tareas`
--

CREATE TABLE `tareas` (
  `id_tarea` int(11) NOT NULL,
  `titulo` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` enum('Pendiente','En curso','Completada') NOT NULL DEFAULT 'Pendiente',
  `prioridad` enum('Alta','Media','Baja') NOT NULL DEFAULT 'Media',
  `id_cliente` int(11) DEFAULT NULL,
  `id_ticket` int(11) DEFAULT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `id_usuario_creador` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tareas`
--

INSERT INTO `tareas` (`id_tarea`, `titulo`, `descripcion`, `estado`, `prioridad`, `id_cliente`, `id_ticket`, `id_servicio`, `id_usuario_creador`, `creado_en`, `actualizado_en`) VALUES
(1, 'reparar', 'jajsjk', 'En curso', 'Media', 1, NULL, NULL, 2, '2026-07-11 19:28:16', '2026-07-11 19:28:16'),
(10, 'Revisar router cliente', 'Ir a la casa del cliente a revisar el router', 'Pendiente', 'Alta', 1, 10, NULL, 1, '2026-07-20 16:49:51', '2026-07-22 18:21:42'),
(11, 'Actualizar firmware OLT', 'Programar actualización de firmware en OLT-10', 'En curso', 'Media', 11, NULL, NULL, 2, '2026-07-20 16:49:51', '2026-07-20 16:54:54');

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `id_ticket` int(11) NOT NULL,
  `asunto` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` enum('Abierto','En proceso','Cerrado') NOT NULL DEFAULT 'Abierto',
  `prioridad` enum('Alta','Media','Baja') NOT NULL DEFAULT 'Media',
  `id_categoria` int(11) DEFAULT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `id_usuario_creador` int(11) DEFAULT NULL,
  `origen` enum('portal_cliente','backoffice') NOT NULL DEFAULT 'backoffice',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `sla_vence_en` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tickets`
--

INSERT INTO `tickets` (`id_ticket`, `asunto`, `descripcion`, `estado`, `prioridad`, `id_categoria`, `id_cliente`, `id_servicio`, `id_usuario_creador`, `origen`, `creado_en`, `actualizado_en`, `sla_vence_en`) VALUES
(1, 'a', 'a', 'Abierto', 'Media', NULL, 1, NULL, 1, 'portal_cliente', '2026-07-19 18:08:10', '2026-07-22 18:22:07', NULL),
(10, 'Fallo de internet', 'El cliente reporta que no tiene señal desde ayer', 'Abierto', 'Alta', NULL, 10, 10, 1, 'backoffice', '2026-07-20 16:49:51', '2026-09-28 21:52:03', NULL),
(11, 'Revisión de velocidad', 'La velocidad no alcanza lo contratado', 'En proceso', 'Media', NULL, 11, 12, 2, 'backoffice', '2026-07-20 16:49:51', '2026-07-20 16:49:51', NULL),
(12, 'Instalación nueva', 'Solicita instalación para nueva oficina', 'Cerrado', 'Baja', NULL, 12, NULL, 1, 'backoffice', '2026-07-20 16:49:51', '2026-07-20 16:49:51', NULL);

--
-- Triggers `tickets`
--
DELIMITER $$
CREATE TRIGGER `trg_tickets_sla_insert` BEFORE INSERT ON `tickets` FOR EACH ROW BEGIN
  DECLARE horas SMALLINT DEFAULT NULL;
  IF NEW.id_categoria IS NOT NULL THEN
    SELECT horas_resolucion INTO horas FROM sla_definiciones
    WHERE id_categoria = NEW.id_categoria AND prioridad = NEW.prioridad LIMIT 1;
  END IF;
  IF horas IS NOT NULL THEN
    SET NEW.sla_vence_en = DATE_ADD(NOW(), INTERVAL horas HOUR);
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_tickets_sla_update` BEFORE UPDATE ON `tickets` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ticket_respuestas`
--

CREATE TABLE `ticket_respuestas` (
  `id_respuesta` int(11) NOT NULL,
  `id_ticket` int(11) NOT NULL,
  `tipo_autor` enum('staff','cliente') NOT NULL,
  `mensaje` text NOT NULL,
  `adjunto_path` varchar(255) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL COMMENT 'Si respondió el staff',
  `id_credencial` int(11) DEFAULT NULL COMMENT 'Si respondió el cliente',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Table structure for table `transicion_estado`
--

CREATE TABLE `transicion_estado` (
  `id_transicion` int(11) NOT NULL,
  `tabla` varchar(50) NOT NULL,
  `estado_origen` varchar(30) NOT NULL,
  `estado_destino` varchar(30) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `transicion_estado`
--

INSERT INTO `transicion_estado` (`id_transicion`, `tabla`, `estado_origen`, `estado_destino`, `descripcion`) VALUES
(1, 'facturas', 'pendiente', 'pagada', 'Pago validado cubre el monto'),
(2, 'facturas', 'pendiente', 'parcial', 'Pago validado cubre parte'),
(3, 'facturas', 'pendiente', 'vencida', 'Fecha de vencimiento superada'),
(4, 'facturas', 'pendiente', 'anulada', 'Anulación manual'),
(5, 'facturas', 'parcial', 'pagada', 'Pago adicional completa'),
(6, 'facturas', 'parcial', 'pendiente', 'Reversión: pagos parciales rechazados'),
(7, 'facturas', 'parcial', 'vencida', 'Vencimiento estando parcial'),
(8, 'facturas', 'parcial', 'anulada', 'Anulación manual'),
(9, 'facturas', 'pagada', 'parcial', 'Reversión: pago validado pasa a rechazado'),
(10, 'facturas', 'pagada', 'pendiente', 'Reversión: todos los pagos rechazados'),
(11, 'facturas', 'pagada', 'anulada', 'Anulación manual'),
(12, 'facturas', 'vencida', 'pagada', 'Pago validado posterior'),
(13, 'facturas', 'vencida', 'parcial', 'Pago parcial posterior'),
(14, 'facturas', 'vencida', 'anulada', 'Anulación manual'),
(15, 'facturas', 'anulada', 'pendiente', 'Reapertura manual'),
(16, 'pagos', 'pendiente', 'validado', 'Administrador valida'),
(17, 'pagos', 'pendiente', 'rechazado', 'Administrador rechaza'),
(18, 'pagos', 'validado', 'rechazado', 'Corrección posterior'),
(19, 'pagos', 'rechazado', 'pendiente', 'Reapertura para revisión'),
(20, 'contratos', 'vigente', 'vencido', 'Fecha de fin superada'),
(21, 'contratos', 'vigente', 'rescindido', 'Rescisión'),
(22, 'contratos', 'vencido', 'vigente', 'Renovación'),
(23, 'contratos', 'vencido', 'rescindido', 'Rescisión posterior'),
(24, 'contratos', 'rescindido', 'vigente', 'Reactivación'),
(25, 'servicios', 'pendiente', 'activo', 'Instalación completada'),
(26, 'servicios', 'pendiente', 'retirado', 'Cancelación antes de activar'),
(27, 'servicios', 'activo', 'suspendido', 'Suspensión por mora/incidencia'),
(28, 'servicios', 'activo', 'retirado', 'Baja del servicio'),
(29, 'servicios', 'suspendido', 'activo', 'Reactivación'),
(30, 'servicios', 'suspendido', 'retirado', 'Baja estando suspendido'),
(31, 'servicios', 'retirado', 'activo', 'Reactivación de retirado');

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL DEFAULT '',
  `must_change_password` tinyint(1) NOT NULL DEFAULT 0,
  `email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `estado` enum('Activo','Inactivo','Bloqueado') NOT NULL DEFAULT 'Activo',
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0,
  `bloqueado_hasta` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `username`, `password`, `email`, `must_change_password`, `email_verified`, `estado`, `intentos_fallidos`, `bloqueado_hasta`) VALUES
(1, 'admin', '$2y$10$3F914JmsON9GvY8A2Y6pxuV1/Yap2xLDhc0L9BUFvEK/.9v9pz3Im', 'admin@gmail.com', 0, 1, 'Activo', 0, NULL),
(2, 'Marcos', '$2y$10$C2sKEyEZCc5ADpW/Qnjfx.iGlu3/T1XAk0XgTIob0hVZrb7qzNtQS', 'marcos@gmail.com', 0, 1, 'Activo', 0, NULL),
(3, 'hebert', '$2y$10$WD/6oAtWdTmJtyTSRKlQnuI2HRZH7h1.n.aplmPRC6/ihGqH1SbKS', 'hebert123@prueba.com', 0, 1, 'Activo', 0, NULL);

--
-- Triggers `usuarios`
--
DELIMITER $$
CREATE TRIGGER `trg_usuarios_audit_delete` AFTER DELETE ON `usuarios` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','usuarios',OLD.id_usuario,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_usuario',OLD.id_usuario,'username',OLD.username,'email',OLD.email,
                      'estado',OLD.estado));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_usuarios_audit_insert` AFTER INSERT ON `usuarios` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','usuarios',NEW.id_usuario,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_usuario',NEW.id_usuario,'username',NEW.username,'email',NEW.email,
                      'estado',NEW.estado,'email_verified',NEW.email_verified));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_usuarios_audit_update` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','usuarios',NEW.id_usuario,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_usuario',OLD.id_usuario,'username',OLD.username,'email',OLD.email,
                      'estado',OLD.estado,'email_verified',OLD.email_verified,
                      'must_change_password',OLD.must_change_password),
          JSON_OBJECT('id_usuario',NEW.id_usuario,'username',NEW.username,'email',NEW.email,
                      'estado',NEW.estado,'email_verified',NEW.email_verified,
                      'must_change_password',NEW.must_change_password));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `usuario_rol`
--

CREATE TABLE `usuario_rol` (
  `id_usuario_rol` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `usuario_rol`
--

INSERT INTO `usuario_rol` (`id_usuario_rol`, `id_usuario`, `id_rol`) VALUES
(1, 1, 1),
(2, 2, 2),
(9, 3, 1),
(10, 3, 2);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_clientes_360`
-- (See below for the actual view)
--
CREATE TABLE `v_clientes_360` (
`id_cliente` int(11)
,`cliente` varchar(131)
,`cedula` varchar(15)
,`correo` varchar(80)
,`num_telefono` varchar(25)
,`fecha_registro` datetime
,`estado_cliente` enum('activo','suspendido','inactivo')
,`segmento` varchar(30)
,`servicios_activos` bigint(21)
,`tickets_abiertos` bigint(21)
,`facturas_vencidas` bigint(21)
,`ultima_actividad` datetime
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_equipos_asignados`
-- (See below for the actual view)
--
CREATE TABLE `v_equipos_asignados` (
`id_equipo` int(11)
,`tipo` enum('ONU','ONT','ROUTER')
,`marca` varchar(50)
,`modelo` varchar(50)
,`direccion_mac` char(17)
,`num_puerto_nap` smallint(5)
,`estado_fisico` enum('operativo','averiado','stock')
,`estado_inventario` enum('stock','asignado','devuelto','averiado','baja')
,`propiedad` enum('cliente','empresa')
,`nap_codigo` varchar(20)
,`olt_codigo` varchar(20)
,`nodo_nombre` varchar(100)
,`id_servicio` int(11)
,`servicio_alias` varchar(50)
,`direccion_texto` varchar(255)
,`id_cliente` int(11)
,`cliente` varchar(131)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_estado_cuenta_cliente`
-- (See below for the actual view)
--
CREATE TABLE `v_estado_cuenta_cliente` (
`id_cliente` int(11)
,`cliente` varchar(131)
,`cedula` varchar(15)
,`correo` varchar(80)
,`num_telefono` varchar(25)
,`saldo_pendiente` decimal(55,2)
,`facturas_vencidas` bigint(21)
,`facturas_pagadas` bigint(21)
,`ultima_fecha_vencimiento` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_facturas_con_saldo`
-- (See below for the actual view)
--
CREATE TABLE `v_facturas_con_saldo` (
`id_factura` int(11)
,`id_servicio` int(11)
,`periodo` varchar(7)
,`monto` decimal(10,2)
,`fecha_emision` date
,`fecha_vencimiento` date
,`estado` enum('pendiente','pagada','parcial','vencida','anulada')
,`total_pagado` decimal(32,2)
,`saldo` decimal(33,2)
,`servicio_alias` varchar(50)
,`id_cliente` int(11)
,`cliente` varchar(131)
,`cedula` varchar(15)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_ip_asignadas`
-- (See below for the actual view)
--
CREATE TABLE `v_ip_asignadas` (
`id_asignacion` int(11)
,`ip` varchar(45)
,`tipo` enum('estatica','pppoe')
,`estado` enum('activa','liberada','reservada')
,`asignada_en` datetime
,`liberada_en` datetime
,`pool_nombre` varchar(60)
,`pool_cidr` varchar(43)
,`vlan` smallint(6)
,`id_servicio` int(11)
,`servicio_alias` varchar(50)
,`id_cliente` int(11)
,`cliente` varchar(131)
);

-- --------------------------------------------------------

--
-- Structure for view `v_clientes_360`
--
DROP TABLE IF EXISTS `v_clientes_360`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_clientes_360`  AS SELECT `c`.`id_cliente` AS `id_cliente`, concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente`, `c`.`cedula` AS `cedula`, `c`.`correo` AS `correo`, `c`.`num_telefono` AS `num_telefono`, `c`.`fecha_registro` AS `fecha_registro`, `c`.`estado` AS `estado_cliente`, `c`.`segmento` AS `segmento`, (select count(0) from `servicios` `s` where `s`.`id_cliente` = `c`.`id_cliente` and `s`.`estado_comercial` <> 'retirado') AS `servicios_activos`, (select count(0) from `tickets` `t` where `t`.`id_cliente` = `c`.`id_cliente` and `t`.`estado` <> 'Cerrado') AS `tickets_abiertos`, (select count(0) from (`facturas` `f` join `servicios` `s2` on(`s2`.`id_servicio` = `f`.`id_servicio`)) where `s2`.`id_cliente` = `c`.`id_cliente` and `f`.`estado` = 'vencida') AS `facturas_vencidas`, (select max(`cc`.`ultimo_acceso`) from `clientes_credenciales` `cc` where `cc`.`id_cliente` = `c`.`id_cliente`) AS `ultima_actividad` FROM `clientes` AS `c` ;

-- --------------------------------------------------------

--
-- Structure for view `v_equipos_asignados`
--
DROP TABLE IF EXISTS `v_equipos_asignados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_equipos_asignados`  AS SELECT `eq`.`id_equipo` AS `id_equipo`, `eq`.`tipo` AS `tipo`, `eq`.`marca` AS `marca`, `eq`.`modelo` AS `modelo`, `eq`.`direccion_mac` AS `direccion_mac`, `eq`.`num_puerto_nap` AS `num_puerto_nap`, `eq`.`estado_fisico` AS `estado_fisico`, `eq`.`estado_inventario` AS `estado_inventario`, `eq`.`propiedad` AS `propiedad`, `na`.`codigo` AS `nap_codigo`, `o`.`codigo` AS `olt_codigo`, `n`.`nombre` AS `nodo_nombre`, `s`.`id_servicio` AS `id_servicio`, `s`.`alias` AS `servicio_alias`, `s`.`direccion_texto` AS `direccion_texto`, `c`.`id_cliente` AS `id_cliente`, concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente` FROM (((((`equipos` `eq` join `naps` `na` on(`na`.`id_nap` = `eq`.`id_naps`)) left join `olts` `o` on(`o`.`id_olt` = `na`.`id_olts`)) left join `nodos` `n` on(`n`.`id_nodo` = `o`.`id_nodos`)) left join `servicios` `s` on(`s`.`id_servicio` = `eq`.`id_servicio`)) left join `clientes` `c` on(`c`.`id_cliente` = `s`.`id_cliente`)) WHERE `eq`.`estado_inventario` = 'asignado' AND `eq`.`id_servicio` is not null ;

-- --------------------------------------------------------

--
-- Structure for view `v_estado_cuenta_cliente`
--
DROP TABLE IF EXISTS `v_estado_cuenta_cliente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_estado_cuenta_cliente`  AS SELECT `c`.`id_cliente` AS `id_cliente`, concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente`, `c`.`cedula` AS `cedula`, `c`.`correo` AS `correo`, `c`.`num_telefono` AS `num_telefono`, coalesce(sum(case when `f`.`estado` in ('pendiente','parcial','vencida') then greatest(`f`.`monto` - coalesce(`pv`.`total_pagado`,0),0) else 0 end),0) AS `saldo_pendiente`, count(distinct case when `f`.`estado` = 'vencida' then `f`.`id_factura` end) AS `facturas_vencidas`, count(distinct case when `f`.`estado` = 'pagada' then `f`.`id_factura` end) AS `facturas_pagadas`, max(`f`.`fecha_vencimiento`) AS `ultima_fecha_vencimiento` FROM (((`clientes` `c` left join `servicios` `s` on(`s`.`id_cliente` = `c`.`id_cliente`)) left join `facturas` `f` on(`f`.`id_servicio` = `s`.`id_servicio`)) left join (select `pagos`.`id_factura` AS `id_factura`,sum(`pagos`.`monto`) AS `total_pagado` from `pagos` where `pagos`.`estado` = 'validado' group by `pagos`.`id_factura`) `pv` on(`pv`.`id_factura` = `f`.`id_factura`)) GROUP BY `c`.`id_cliente`, `c`.`nombres`, `c`.`apellidos`, `c`.`cedula`, `c`.`correo`, `c`.`num_telefono` ;

-- --------------------------------------------------------

--
-- Structure for view `v_facturas_con_saldo`
--
DROP TABLE IF EXISTS `v_facturas_con_saldo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_facturas_con_saldo`  AS SELECT `f`.`id_factura` AS `id_factura`, `f`.`id_servicio` AS `id_servicio`, `f`.`periodo` AS `periodo`, `f`.`monto` AS `monto`, `f`.`fecha_emision` AS `fecha_emision`, `f`.`fecha_vencimiento` AS `fecha_vencimiento`, `f`.`estado` AS `estado`, coalesce((select sum(`pagos`.`monto`) from `pagos` where `pagos`.`id_factura` = `f`.`id_factura` and `pagos`.`estado` = 'validado'),0) AS `total_pagado`, greatest(`f`.`monto` - coalesce((select sum(`pagos`.`monto`) from `pagos` where `pagos`.`id_factura` = `f`.`id_factura` and `pagos`.`estado` = 'validado'),0),0) AS `saldo`, `s`.`alias` AS `servicio_alias`, `c`.`id_cliente` AS `id_cliente`, concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente`, `c`.`cedula` AS `cedula` FROM ((`facturas` `f` join `servicios` `s` on(`s`.`id_servicio` = `f`.`id_servicio`)) join `clientes` `c` on(`c`.`id_cliente` = `s`.`id_cliente`)) WHERE `f`.`estado` in ('pendiente','parcial','vencida') ;

-- --------------------------------------------------------

--
-- Structure for view `v_ip_asignadas`
--
DROP TABLE IF EXISTS `v_ip_asignadas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_ip_asignadas`  AS SELECT `ia`.`id_asignacion` AS `id_asignacion`, `ia`.`ip` AS `ip`, `ia`.`tipo` AS `tipo`, `ia`.`estado` AS `estado`, `ia`.`asignada_en` AS `asignada_en`, `ia`.`liberada_en` AS `liberada_en`, `ip`.`nombre` AS `pool_nombre`, `ip`.`cidr` AS `pool_cidr`, `ip`.`vlan` AS `vlan`, `s`.`id_servicio` AS `id_servicio`, `s`.`alias` AS `servicio_alias`, `c`.`id_cliente` AS `id_cliente`, concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente` FROM (((`ip_asignaciones` `ia` join `ip_pools` `ip` on(`ip`.`id_pool` = `ia`.`id_pool`)) join `servicios` `s` on(`s`.`id_servicio` = `ia`.`id_servicio`)) join `clientes` `c` on(`c`.`id_cliente` = `s`.`id_cliente`)) WHERE `ia`.`estado` = 'activa' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categorias_ticket`
--
ALTER TABLE `categorias_ticket`
  ADD PRIMARY KEY (`id_categoria`),
  ADD UNIQUE KEY `uq_categoria_nombre` (`nombre`);

--
-- Indexes for table `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id_cliente`),
  ADD UNIQUE KEY `cedula` (`cedula`),
  ADD KEY `idx_clientes_estado` (`estado`),
  ADD KEY `idx_clientes_apellidos_nombres` (`apellidos`,`nombres`);

--
-- Indexes for table `clientes_credenciales`
--
ALTER TABLE `clientes_credenciales`
  ADD PRIMARY KEY (`id_credencial`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `uq_cliente` (`id_cliente`);

--
-- Indexes for table `cliente_contactos`
--
ALTER TABLE `cliente_contactos`
  ADD PRIMARY KEY (`id_contacto`),
  ADD KEY `idx_contacto_cliente` (`id_cliente`);

--
-- Indexes for table `cliente_etiquetas`
--
ALTER TABLE `cliente_etiquetas`
  ADD PRIMARY KEY (`id_cliente_etiqueta`),
  ADD UNIQUE KEY `uq_cliente_etiqueta` (`id_cliente`,`id_etiqueta`),
  ADD KEY `idx_ce_etiqueta` (`id_etiqueta`);

--
-- Indexes for table `cliente_notas`
--
ALTER TABLE `cliente_notas`
  ADD PRIMARY KEY (`id_nota`),
  ADD KEY `idx_nota_cliente` (`id_cliente`),
  ADD KEY `idx_nota_usuario` (`id_usuario`);

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
-- Indexes for table `email_log`
--
ALTER TABLE `email_log`
  ADD PRIMARY KEY (`id_email`),
  ADD KEY `idx_email_plantilla` (`id_plantilla`),
  ADD KEY `idx_email_cliente` (`id_cliente`),
  ADD KEY `idx_email_usuario` (`id_usuario`),
  ADD KEY `idx_email_estado` (`estado`);

--
-- Indexes for table `email_plantillas`
--
ALTER TABLE `email_plantillas`
  ADD PRIMARY KEY (`id_plantilla`),
  ADD UNIQUE KEY `uq_plantilla_codigo` (`codigo`);

--
-- Indexes for table `equipos`
--
ALTER TABLE `equipos`
  ADD PRIMARY KEY (`id_equipo`),
  ADD UNIQUE KEY `direccion_mac` (`direccion_mac`),
  ADD UNIQUE KEY `idx_nap_puerto` (`id_naps`,`num_puerto_nap`),
  ADD UNIQUE KEY `uq_numero_serie` (`numero_serie`),
  ADD KEY `idx_equipo_servicio` (`id_servicio`),
  ADD KEY `idx_equipo_estado` (`estado_inventario`);

--
-- Indexes for table `equipo_movimientos`
--
ALTER TABLE `equipo_movimientos`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `idx_mov_equipo` (`id_equipo`),
  ADD KEY `idx_mov_servicio` (`id_servicio`),
  ADD KEY `idx_mov_usuario` (`id_usuario`);

--
-- Indexes for table `etiquetas`
--
ALTER TABLE `etiquetas`
  ADD PRIMARY KEY (`id_etiqueta`),
  ADD UNIQUE KEY `uq_etiqueta_nombre` (`nombre`);

--
-- Indexes for table `facturas`
--
ALTER TABLE `facturas`
  ADD PRIMARY KEY (`id_factura`),
  ADD UNIQUE KEY `uq_factura_servicio_periodo` (`id_servicio`,`periodo`),
  ADD KEY `fk_factura_servicio` (`id_servicio`),
  ADD KEY `idx_factura_estado_vencimiento` (`estado`,`fecha_vencimiento`),
  ADD KEY `idx_factura_periodo` (`periodo`);

--
-- Indexes for table `factura_lineas`
--
ALTER TABLE `factura_lineas`
  ADD PRIMARY KEY (`id_linea`),
  ADD KEY `fk_linea_factura` (`id_factura`),
  ADD KEY `idx_linea_servicio` (`id_servicio`);

--
-- Indexes for table `ip_asignaciones`
--
ALTER TABLE `ip_asignaciones`
  ADD PRIMARY KEY (`id_asignacion`),
  ADD UNIQUE KEY `uq_ip_activa` (`ip_activa`),
  ADD KEY `fk_ip_asig_servicio` (`id_servicio`),
  ADD KEY `fk_ip_asig_pool` (`id_pool`);

--
-- Indexes for table `ip_pools`
--
ALTER TABLE `ip_pools`
  ADD PRIMARY KEY (`id_pool`),
  ADD UNIQUE KEY `uq_ip_pool_cidr` (`cidr`),
  ADD KEY `fk_ip_pool_nodo` (`id_nodo`);

--
-- Indexes for table `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `fk_log_usuario` (`id_usuario`),
  ADD KEY `idx_log_fecha` (`creado_en`),
  ADD KEY `idx_log_tabla_registro` (`tabla_afectada`,`id_registro_afectado`),
  ADD KEY `idx_log_accion_fecha` (`accion`,`creado_en`),
  ADD KEY `fk_log_credencial` (`id_credencial`);

--
-- Indexes for table `metodos_pago`
--
ALTER TABLE `metodos_pago`
  ADD PRIMARY KEY (`id_metodo`),
  ADD UNIQUE KEY `uq_metodo_codigo` (`codigo`);

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
  ADD PRIMARY KEY (`id_nodo`),
  ADD UNIQUE KEY `uq_nodo_nombre` (`nombre`);

--
-- Indexes for table `notas_credito`
--
ALTER TABLE `notas_credito`
  ADD PRIMARY KEY (`id_nota`),
  ADD KEY `idx_nc_cliente` (`id_cliente`),
  ADD KEY `idx_nc_factura` (`id_factura`),
  ADD KEY `idx_nc_emisor` (`id_usuario_emisor`);

--
-- Indexes for table `notas_debito`
--
ALTER TABLE `notas_debito`
  ADD PRIMARY KEY (`id_nota`),
  ADD KEY `idx_nd_cliente` (`id_cliente`),
  ADD KEY `idx_nd_factura` (`id_factura`),
  ADD KEY `idx_nd_emisor` (`id_usuario_emisor`);

--
-- Indexes for table `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD PRIMARY KEY (`id_notificacion`),
  ADD KEY `fk_notif_cliente` (`id_cliente`),
  ADD KEY `idx_notif_cliente_estado` (`id_cliente`,`estado`),
  ADD KEY `fk_notif_usuario` (`id_usuario`);

--
-- Indexes for table `notificaciones_staff`
--
ALTER TABLE `notificaciones_staff`
  ADD PRIMARY KEY (`id_notificacion`),
  ADD KEY `idx_notif_staff_usuario_estado` (`id_usuario`,`estado`);

--
-- Indexes for table `olts`
--
ALTER TABLE `olts`
  ADD PRIMARY KEY (`id_olt`),
  ADD UNIQUE KEY `uq_olt_codigo` (`codigo`),
  ADD UNIQUE KEY `uq_olt_ip_gestion` (`ip_gestion`),
  ADD KEY `fk_olt_nodo` (`id_nodos`);

--
-- Indexes for table `paginas`
--
ALTER TABLE `paginas`
  ADD PRIMARY KEY (`id_pagina`),
  ADD UNIQUE KEY `uq_pagina_modulo` (`id_pagina`,`id_modulo`),
  ADD KEY `fk_pagina_modulo` (`id_modulo`);

--
-- Indexes for table `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id_pago`),
  ADD KEY `fk_pago_factura` (`id_factura`),
  ADD KEY `fk_pago_cliente` (`id_cliente`),
  ADD KEY `fk_pago_servicio` (`id_servicio`),
  ADD KEY `fk_pago_usuario` (`id_usuario_valido`),
  ADD KEY `idx_pago_estado` (`estado`),
  ADD KEY `idx_pago_factura_estado` (`id_factura`,`estado`),
  ADD KEY `idx_pago_fecha` (`fecha_pago`),
  ADD KEY `idx_pago_metodo` (`id_metodo`);

--
-- Indexes for table `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`id_pedido`),
  ADD KEY `idx_pedido_cliente` (`id_cliente`),
  ADD KEY `idx_pedido_servicio` (`id_servicio`),
  ADD KEY `idx_pedido_estado` (`estado`),
  ADD KEY `idx_pedido_tecnico` (`id_tecnico_asignado`),
  ADD KEY `idx_pedido_creador` (`id_usuario_creador`);

--
-- Indexes for table `pedido_asignaciones`
--
ALTER TABLE `pedido_asignaciones`
  ADD PRIMARY KEY (`id_asignacion`),
  ADD KEY `idx_asig_pedido` (`id_pedido`),
  ADD KEY `idx_asig_tecnico` (`id_tecnico`),
  ADD KEY `idx_asig_asignador` (`id_usuario_asignador`);

--
-- Indexes for table `pedido_materiales`
--
ALTER TABLE `pedido_materiales`
  ADD PRIMARY KEY (`id_material`),
  ADD KEY `idx_material_pedido` (`id_pedido`),
  ADD KEY `idx_material_equipo` (`id_equipo`);

--
-- Indexes for table `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`id_permiso`),
  ADD UNIQUE KEY `uq_permiso_nombre` (`nombre`);

--
-- Indexes for table `planes`
--
ALTER TABLE `planes`
  ADD PRIMARY KEY (`id_plan`);

--
-- Indexes for table `plan_historial_precios`
--
ALTER TABLE `plan_historial_precios`
  ADD PRIMARY KEY (`id_historial`),
  ADD KEY `idx_hist_precio_plan` (`id_plan`),
  ADD KEY `idx_hist_precio_usuario` (`id_usuario`);

--
-- Indexes for table `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `nombre_rol` (`nombre_rol`);

--
-- Indexes for table `rol_modulo`
--
ALTER TABLE `rol_modulo`
  ADD PRIMARY KEY (`id_rol_modulo`),
  ADD UNIQUE KEY `uq_rol_modulo` (`id_rol`,`id_modulo`),
  ADD UNIQUE KEY `uq_rolmodulo_modulo` (`id_rol_modulo`,`id_modulo`),
  ADD KEY `fk_rm_rol` (`id_rol`),
  ADD KEY `fk_rm_modulo` (`id_modulo`);

--
-- Indexes for table `rol_modulo_pagina`
--
ALTER TABLE `rol_modulo_pagina`
  ADD PRIMARY KEY (`id_rol_modulo_pagina`),
  ADD UNIQUE KEY `uq_rolmodulo_pagina` (`id_rol_modulo`,`id_pagina`),
  ADD KEY `fk_rmpag_pagina` (`id_pagina`);

--
-- Indexes for table `rol_modulo_permiso`
--
ALTER TABLE `rol_modulo_permiso`
  ADD PRIMARY KEY (`id_rol_modulo_permiso`),
  ADD UNIQUE KEY `uq_rm_permiso` (`id_rol_modulo`,`id_pagina`,`id_permiso`),
  ADD KEY `fk_rmp_rolmodulo` (`id_rol_modulo`),
  ADD KEY `fk_rmp_pagina` (`id_pagina`),
  ADD KEY `fk_rmp_permiso` (`id_permiso`),
  ADD KEY `fk_rmp_pagina_modulo` (`id_pagina`,`id_modulo`),
  ADD KEY `fk_rmp_rolmodulo_modulo` (`id_rol_modulo`,`id_modulo`);

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
  ADD KEY `fk_sesion_credencial` (`id_credencial`),
  ADD KEY `idx_sesion_expira` (`expira_en`);

--
-- Indexes for table `sla_definiciones`
--
ALTER TABLE `sla_definiciones`
  ADD PRIMARY KEY (`id_sla`),
  ADD UNIQUE KEY `uq_sla_categoria_prioridad` (`id_categoria`,`prioridad`);

--
-- Indexes for table `tareas`
--
ALTER TABLE `tareas`
  ADD PRIMARY KEY (`id_tarea`),
  ADD KEY `fk_tarea_cliente` (`id_cliente`),
  ADD KEY `fk_tarea_usuario` (`id_usuario_creador`),
  ADD KEY `fk_tarea_servicio` (`id_servicio`),
  ADD KEY `fk_tarea_ticket` (`id_ticket`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id_ticket`),
  ADD KEY `fk_ticket_cliente` (`id_cliente`),
  ADD KEY `fk_ticket_servicio` (`id_servicio`),
  ADD KEY `fk_ticket_usuario` (`id_usuario_creador`),
  ADD KEY `idx_tickets_estado` (`estado`),
  ADD KEY `idx_tickets_sla` (`sla_vence_en`),
  ADD KEY `idx_tickets_categoria` (`id_categoria`);

--
-- Indexes for table `ticket_respuestas`
--
ALTER TABLE `ticket_respuestas`
  ADD PRIMARY KEY (`id_respuesta`),
  ADD KEY `fk_respuesta_credencial` (`id_credencial`),
  ADD KEY `fk_respuesta_ticket` (`id_ticket`),
  ADD KEY `fk_respuesta_usuario` (`id_usuario`);

--
-- Indexes for table `transicion_estado`
--
ALTER TABLE `transicion_estado`
  ADD PRIMARY KEY (`id_transicion`),
  ADD UNIQUE KEY `uq_transicion` (`tabla`,`estado_origen`,`estado_destino`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `uq_usuario_email` (`email`);

--
-- Indexes for table `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD PRIMARY KEY (`id_usuario_rol`),
  ADD UNIQUE KEY `uq_usuario_rol` (`id_usuario`,`id_rol`),
  ADD KEY `fk_ur_usuario` (`id_usuario`),
  ADD KEY `fk_ur_rol` (`id_rol`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categorias_ticket`
--
ALTER TABLE `categorias_ticket`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `clientes_credenciales`
--
ALTER TABLE `clientes_credenciales`
  MODIFY `id_credencial` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cliente_contactos`
--
ALTER TABLE `cliente_contactos`
  MODIFY `id_contacto` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cliente_etiquetas`
--
ALTER TABLE `cliente_etiquetas`
  MODIFY `id_cliente_etiqueta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cliente_notas`
--
ALTER TABLE `cliente_notas`
  MODIFY `id_nota` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `contratos`
--
ALTER TABLE `contratos`
  MODIFY `id_contrato` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_log`
--
ALTER TABLE `email_log`
  MODIFY `id_email` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_plantillas`
--
ALTER TABLE `email_plantillas`
  MODIFY `id_plantilla` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `equipos`
--
ALTER TABLE `equipos`
  MODIFY `id_equipo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `equipo_movimientos`
--
ALTER TABLE `equipo_movimientos`
  MODIFY `id_movimiento` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `etiquetas`
--
ALTER TABLE `etiquetas`
  MODIFY `id_etiqueta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `facturas`
--
ALTER TABLE `facturas`
  MODIFY `id_factura` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `factura_lineas`
--
ALTER TABLE `factura_lineas`
  MODIFY `id_linea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ip_asignaciones`
--
ALTER TABLE `ip_asignaciones`
  MODIFY `id_asignacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ip_pools`
--
ALTER TABLE `ip_pools`
  MODIFY `id_pool` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logs`
--
ALTER TABLE `logs`
  MODIFY `id_log` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `metodos_pago`
--
ALTER TABLE `metodos_pago`
  MODIFY `id_metodo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `modulos`
--
ALTER TABLE `modulos`
  MODIFY `id_modulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `naps`
--
ALTER TABLE `naps`
  MODIFY `id_nap` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `nodos`
--
ALTER TABLE `nodos`
  MODIFY `id_nodo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notas_credito`
--
ALTER TABLE `notas_credito`
  MODIFY `id_nota` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notas_debito`
--
ALTER TABLE `notas_debito`
  MODIFY `id_nota` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notificaciones`
--
ALTER TABLE `notificaciones`
  MODIFY `id_notificacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notificaciones_staff`
--
ALTER TABLE `notificaciones_staff`
  MODIFY `id_notificacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `olts`
--
ALTER TABLE `olts`
  MODIFY `id_olt` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `paginas`
--
ALTER TABLE `paginas`
  MODIFY `id_pagina` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id_pago` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `id_pedido` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pedido_asignaciones`
--
ALTER TABLE `pedido_asignaciones`
  MODIFY `id_asignacion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pedido_materiales`
--
ALTER TABLE `pedido_materiales`
  MODIFY `id_material` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `permisos`
--
ALTER TABLE `permisos`
  MODIFY `id_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `planes`
--
ALTER TABLE `planes`
  MODIFY `id_plan` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `plan_historial_precios`
--
ALTER TABLE `plan_historial_precios`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `rol_modulo`
--
ALTER TABLE `rol_modulo`
  MODIFY `id_rol_modulo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `rol_modulo_pagina`
--
ALTER TABLE `rol_modulo_pagina`
  MODIFY `id_rol_modulo_pagina` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1681;

--
-- AUTO_INCREMENT for table `rol_modulo_permiso`
--
ALTER TABLE `rol_modulo_permiso`
  MODIFY `id_rol_modulo_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8511;

--
-- AUTO_INCREMENT for table `servicios`
--
ALTER TABLE `servicios`
  MODIFY `id_servicio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sesiones`
--
ALTER TABLE `sesiones`
  MODIFY `id_sesion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sla_definiciones`
--
ALTER TABLE `sla_definiciones`
  MODIFY `id_sla` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tareas`
--
ALTER TABLE `tareas`
  MODIFY `id_tarea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id_ticket` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `ticket_respuestas`
--
ALTER TABLE `ticket_respuestas`
  MODIFY `id_respuesta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transicion_estado`
--
ALTER TABLE `transicion_estado`
  MODIFY `id_transicion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `usuario_rol`
--
ALTER TABLE `usuario_rol`
  MODIFY `id_usuario_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `clientes_credenciales`
--
ALTER TABLE `clientes_credenciales`
  ADD CONSTRAINT `fk_credencial_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`);

--
-- Constraints for table `cliente_contactos`
--
ALTER TABLE `cliente_contactos`
  ADD CONSTRAINT `fk_contacto_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE;

--
-- Constraints for table `cliente_etiquetas`
--
ALTER TABLE `cliente_etiquetas`
  ADD CONSTRAINT `fk_ce_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ce_etiqueta` FOREIGN KEY (`id_etiqueta`) REFERENCES `etiquetas` (`id_etiqueta`) ON DELETE CASCADE;

--
-- Constraints for table `cliente_notas`
--
ALTER TABLE `cliente_notas`
  ADD CONSTRAINT `fk_nota_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_nota_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL;

--
-- Constraints for table `contratos`
--
ALTER TABLE `contratos`
  ADD CONSTRAINT `fk_contrato_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`);

--
-- Constraints for table `email_log`
--
ALTER TABLE `email_log`
  ADD CONSTRAINT `fk_email_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_email_plantilla` FOREIGN KEY (`id_plantilla`) REFERENCES `email_plantillas` (`id_plantilla`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_email_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL;

--
-- Constraints for table `equipos`
--
ALTER TABLE `equipos`
  ADD CONSTRAINT `fk_equipo_nap` FOREIGN KEY (`id_naps`) REFERENCES `naps` (`id_nap`),
  ADD CONSTRAINT `fk_equipo_srv` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL;

--
-- Constraints for table `equipo_movimientos`
--
ALTER TABLE `equipo_movimientos`
  ADD CONSTRAINT `fk_mov_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipos` (`id_equipo`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_mov_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_mov_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL;

--
-- Constraints for table `facturas`
--
ALTER TABLE `facturas`
  ADD CONSTRAINT `fk_factura_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`);

--
-- Constraints for table `factura_lineas`
--
ALTER TABLE `factura_lineas`
  ADD CONSTRAINT `fk_linea_factura` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_linea_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL;

--
-- Constraints for table `ip_asignaciones`
--
ALTER TABLE `ip_asignaciones`
  ADD CONSTRAINT `fk_ip_asig_pool` FOREIGN KEY (`id_pool`) REFERENCES `ip_pools` (`id_pool`),
  ADD CONSTRAINT `fk_ip_asig_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`);

--
-- Constraints for table `ip_pools`
--
ALTER TABLE `ip_pools`
  ADD CONSTRAINT `fk_ip_pool_nodo` FOREIGN KEY (`id_nodo`) REFERENCES `nodos` (`id_nodo`) ON DELETE SET NULL;

--
-- Constraints for table `logs`
--
ALTER TABLE `logs`
  ADD CONSTRAINT `fk_log_credencial` FOREIGN KEY (`id_credencial`) REFERENCES `clientes_credenciales` (`id_credencial`),
  ADD CONSTRAINT `fk_log_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `naps`
--
ALTER TABLE `naps`
  ADD CONSTRAINT `fk_nap_olt` FOREIGN KEY (`id_olts`) REFERENCES `olts` (`id_olt`);

--
-- Constraints for table `notas_credito`
--
ALTER TABLE `notas_credito`
  ADD CONSTRAINT `fk_nc_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_nc_emisor` FOREIGN KEY (`id_usuario_emisor`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_nc_factura` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`) ON DELETE SET NULL;

--
-- Constraints for table `notas_debito`
--
ALTER TABLE `notas_debito`
  ADD CONSTRAINT `fk_nd_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_nd_emisor` FOREIGN KEY (`id_usuario_emisor`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_nd_factura` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`) ON DELETE SET NULL;

--
-- Constraints for table `notificaciones`
--
ALTER TABLE `notificaciones`
  ADD CONSTRAINT `fk_notif_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_notif_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE;

--
-- Constraints for table `notificaciones_staff`
--
ALTER TABLE `notificaciones_staff`
  ADD CONSTRAINT `fk_notif_staff_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE;

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
  ADD CONSTRAINT `fk_pago_metodo` FOREIGN KEY (`id_metodo`) REFERENCES `metodos_pago` (`id_metodo`),
  ADD CONSTRAINT `fk_pago_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`),
  ADD CONSTRAINT `fk_pago_usuario` FOREIGN KEY (`id_usuario_valido`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `fk_pedido_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_pedido_creador` FOREIGN KEY (`id_usuario_creador`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_pedido_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_pedido_tecnico` FOREIGN KEY (`id_tecnico_asignado`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL;

--
-- Constraints for table `pedido_asignaciones`
--
ALTER TABLE `pedido_asignaciones`
  ADD CONSTRAINT `fk_asig_asignador` FOREIGN KEY (`id_usuario_asignador`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_asig_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_asig_tecnico` FOREIGN KEY (`id_tecnico`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `pedido_materiales`
--
ALTER TABLE `pedido_materiales`
  ADD CONSTRAINT `fk_material_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipos` (`id_equipo`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_material_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE;

--
-- Constraints for table `plan_historial_precios`
--
ALTER TABLE `plan_historial_precios`
  ADD CONSTRAINT `fk_hist_precio_plan` FOREIGN KEY (`id_plan`) REFERENCES `planes` (`id_plan`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_hist_precio_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL;

--
-- Constraints for table `rol_modulo`
--
ALTER TABLE `rol_modulo`
  ADD CONSTRAINT `fk_rm_modulo` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id_modulo`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rm_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE CASCADE;

--
-- Constraints for table `rol_modulo_pagina`
--
ALTER TABLE `rol_modulo_pagina`
  ADD CONSTRAINT `fk_rmpag_pagina` FOREIGN KEY (`id_pagina`) REFERENCES `paginas` (`id_pagina`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rmpag_rolmodulo` FOREIGN KEY (`id_rol_modulo`) REFERENCES `rol_modulo` (`id_rol_modulo`) ON DELETE CASCADE;

--
-- Constraints for table `rol_modulo_permiso`
--
ALTER TABLE `rol_modulo_permiso`
  ADD CONSTRAINT `fk_rmp_pagina` FOREIGN KEY (`id_pagina`) REFERENCES `paginas` (`id_pagina`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rmp_pagina_modulo` FOREIGN KEY (`id_pagina`,`id_modulo`) REFERENCES `paginas` (`id_pagina`, `id_modulo`),
  ADD CONSTRAINT `fk_rmp_permiso` FOREIGN KEY (`id_permiso`) REFERENCES `permisos` (`id_permiso`),
  ADD CONSTRAINT `fk_rmp_rolmodulo` FOREIGN KEY (`id_rol_modulo`) REFERENCES `rol_modulo` (`id_rol_modulo`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rmp_rolmodulo_modulo` FOREIGN KEY (`id_rol_modulo`,`id_modulo`) REFERENCES `rol_modulo` (`id_rol_modulo`, `id_modulo`);

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
-- Constraints for table `sla_definiciones`
--
ALTER TABLE `sla_definiciones`
  ADD CONSTRAINT `fk_sla_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias_ticket` (`id_categoria`) ON DELETE CASCADE;

--
-- Constraints for table `tareas`
--
ALTER TABLE `tareas`
  ADD CONSTRAINT `fk_tarea_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_tarea_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tarea_ticket` FOREIGN KEY (`id_ticket`) REFERENCES `tickets` (`id_ticket`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tarea_usuario` FOREIGN KEY (`id_usuario_creador`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `fk_ticket_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias_ticket` (`id_categoria`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_ticket_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_ticket_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`),
  ADD CONSTRAINT `fk_ticket_usuario` FOREIGN KEY (`id_usuario_creador`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `ticket_respuestas`
--
ALTER TABLE `ticket_respuestas`
  ADD CONSTRAINT `fk_respuesta_credencial` FOREIGN KEY (`id_credencial`) REFERENCES `clientes_credenciales` (`id_credencial`),
  ADD CONSTRAINT `fk_respuesta_ticket` FOREIGN KEY (`id_ticket`) REFERENCES `tickets` (`id_ticket`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_respuesta_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Constraints for table `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD CONSTRAINT `fk_ur_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`),
  ADD CONSTRAINT `fk_ur_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
