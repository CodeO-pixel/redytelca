
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categorias_ticket` (
  `id_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `color` char(7) NOT NULL DEFAULT '#104aa8',
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `uq_categoria_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_categorias_ticket_audit_insert` AFTER INSERT ON `categorias_ticket` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','categorias_ticket',NEW.id_categoria,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_categoria',NEW.id_categoria,'nombre',NEW.nombre,'activa',NEW.activa));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_categorias_ticket_audit_update` AFTER UPDATE ON `categorias_ticket` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','categorias_ticket',NEW.id_categoria,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_categoria',OLD.id_categoria,'nombre',OLD.nombre,'activa',OLD.activa),
          JSON_OBJECT('id_categoria',NEW.id_categoria,'nombre',NEW.nombre,'activa',NEW.activa));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_categorias_ticket_audit_delete` AFTER DELETE ON `categorias_ticket` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','categorias_ticket',OLD.id_categoria,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_categoria',OLD.id_categoria,'nombre',OLD.nombre,'activa',OLD.activa));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cliente_contactos` (
  `id_contacto` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `parentesco` varchar(50) DEFAULT NULL,
  `telefono` varchar(25) DEFAULT NULL,
  `correo` varchar(80) DEFAULT NULL,
  `es_principal` tinyint(1) NOT NULL DEFAULT 0,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_contacto`),
  KEY `idx_contacto_cliente` (`id_cliente`),
  CONSTRAINT `fk_contacto_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_cliente_contactos_audit_insert` AFTER INSERT ON `cliente_contactos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','cliente_contactos',NEW.id_contacto,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_contacto',NEW.id_contacto,'id_cliente',NEW.id_cliente,'nombre',NEW.nombre,
                      'es_principal',NEW.es_principal));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_cliente_contactos_audit_update` AFTER UPDATE ON `cliente_contactos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','cliente_contactos',NEW.id_contacto,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_contacto',OLD.id_contacto,'id_cliente',OLD.id_cliente,'nombre',OLD.nombre,
                      'es_principal',OLD.es_principal),
          JSON_OBJECT('id_contacto',NEW.id_contacto,'id_cliente',NEW.id_cliente,'nombre',NEW.nombre,
                      'es_principal',NEW.es_principal));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_cliente_contactos_audit_delete` AFTER DELETE ON `cliente_contactos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','cliente_contactos',OLD.id_contacto,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_contacto',OLD.id_contacto,'id_cliente',OLD.id_cliente,'nombre',OLD.nombre,
                      'es_principal',OLD.es_principal));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cliente_etiquetas` (
  `id_cliente_etiqueta` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente` int(11) NOT NULL,
  `id_etiqueta` int(11) NOT NULL,
  `asignada_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_cliente_etiqueta`),
  UNIQUE KEY `uq_cliente_etiqueta` (`id_cliente`,`id_etiqueta`),
  KEY `idx_ce_etiqueta` (`id_etiqueta`),
  CONSTRAINT `fk_ce_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE,
  CONSTRAINT `fk_ce_etiqueta` FOREIGN KEY (`id_etiqueta`) REFERENCES `etiquetas` (`id_etiqueta`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_cliente_etiquetas_audit_insert` AFTER INSERT ON `cliente_etiquetas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','cliente_etiquetas',NEW.id_cliente_etiqueta,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_cliente_etiqueta',NEW.id_cliente_etiqueta,'id_cliente',NEW.id_cliente,'id_etiqueta',NEW.id_etiqueta));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_cliente_etiquetas_audit_update` AFTER UPDATE ON `cliente_etiquetas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','cliente_etiquetas',NEW.id_cliente_etiqueta,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_cliente_etiqueta',OLD.id_cliente_etiqueta,'id_cliente',OLD.id_cliente,'id_etiqueta',OLD.id_etiqueta),
          JSON_OBJECT('id_cliente_etiqueta',NEW.id_cliente_etiqueta,'id_cliente',NEW.id_cliente,'id_etiqueta',NEW.id_etiqueta));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_cliente_etiquetas_audit_delete` AFTER DELETE ON `cliente_etiquetas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','cliente_etiquetas',OLD.id_cliente_etiqueta,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_cliente_etiqueta',OLD.id_cliente_etiqueta,'id_cliente',OLD.id_cliente,'id_etiqueta',OLD.id_etiqueta));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cliente_notas` (
  `id_nota` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente` int(11) NOT NULL,
  `contenido` text NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_nota`),
  KEY `idx_nota_cliente` (`id_cliente`),
  KEY `idx_nota_usuario` (`id_usuario`),
  CONSTRAINT `fk_nota_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE,
  CONSTRAINT `fk_nota_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_cliente_notas_audit_insert` AFTER INSERT ON `cliente_notas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','cliente_notas',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_usuario',NEW.id_usuario));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_cliente_notas_audit_update` AFTER UPDATE ON `cliente_notas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','cliente_notas',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_usuario',OLD.id_usuario),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_usuario',NEW.id_usuario));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_cliente_notas_audit_delete` AFTER DELETE ON `cliente_notas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','cliente_notas',OLD.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_usuario',OLD.id_usuario));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clientes` (
  `id_cliente` int(11) NOT NULL AUTO_INCREMENT,
  `nombres` varchar(65) NOT NULL,
  `apellidos` varchar(65) NOT NULL,
  `cedula` varchar(15) NOT NULL,
  `num_telefono` varchar(25) NOT NULL,
  `correo` varchar(80) NOT NULL,
  `fecha_registro` datetime DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `estado` enum('activo','suspendido','inactivo') NOT NULL DEFAULT 'activo',
  `segmento` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `cedula` (`cedula`),
  KEY `idx_clientes_estado` (`estado`),
  KEY `idx_clientes_apellidos_nombres` (`apellidos`,`nombres`),
  CONSTRAINT `chk_clientes_cedula` CHECK (`cedula` regexp '^([VEJPG]-)?[0-9]{6,9}$')
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clientes_credenciales` (
  `id_credencial` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `correo_recuperacion` varchar(80) DEFAULT NULL,
  `estado` enum('activa','suspendida') DEFAULT 'activa',
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0,
  `bloqueado_hasta` datetime DEFAULT NULL,
  `must_change_password` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `ultimo_acceso` datetime DEFAULT NULL,
  PRIMARY KEY (`id_credencial`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `uq_cliente` (`id_cliente`),
  CONSTRAINT `fk_credencial_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_config`),
  CONSTRAINT `chk_config_singleton` CHECK (`id_config` = 1),
  CONSTRAINT `chk_config_impuesto` CHECK (`impuesto_porcentaje` between 0 and 100),
  CONSTRAINT `chk_config_dia_facturacion` CHECK (`dia_facturacion` between 1 and 31),
  CONSTRAINT `chk_config_dias_gracia` CHECK (`dias_gracia_mora` >= 0),
  CONSTRAINT `chk_config_recargo` CHECK (`monto_recargo_mora` >= 0),
  CONSTRAINT `chk_config_dias_corte` CHECK (`dias_corte_automatico` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contratos` (
  `id_contrato` int(11) NOT NULL AUTO_INCREMENT,
  `id_servicio` int(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date DEFAULT NULL,
  `tipo_contrato` enum('indefinido','plazo_fijo','promocional') DEFAULT 'indefinido',
  `estado` enum('vigente','vencido','rescindido') DEFAULT 'vigente',
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_contrato`),
  KEY `fk_contrato_servicio` (`id_servicio`),
  CONSTRAINT `fk_contrato_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`),
  CONSTRAINT `chk_contrato_fechas` CHECK (`fecha_fin` is null or `fecha_fin` >= `fecha_inicio`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_contratos_validar_insert` BEFORE INSERT ON `contratos`

FOR EACH ROW BEGIN

  IF NEW.estado <> 'vigente' THEN

    SIGNAL SQLSTATE '45000'

      SET MESSAGE_TEXT = 'INSERT de contrato solo permite estado vigente. Use UPDATE para transicionar.';

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_contratos_unico_vigente_insert` BEFORE INSERT ON `contratos` FOR EACH ROW BEGIN
  DECLARE existe INT DEFAULT 0;
  IF NEW.estado = 'vigente' THEN
    SELECT COUNT(*) INTO existe FROM contratos
     WHERE id_servicio = NEW.id_servicio AND estado = 'vigente';
    IF existe > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un contrato vigente para este servicio.';
    END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_contratos_audit_insert AFTER INSERT ON contratos FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)

  VALUES ('INSERT','contratos',NEW.id_contrato,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_contrato',NEW.id_contrato,'id_servicio',NEW.id_servicio,

                      'fecha_inicio',NEW.fecha_inicio,'fecha_fin',NEW.fecha_fin,

                      'tipo_contrato',NEW.tipo_contrato,'estado',NEW.estado));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_contratos_validar_transicion BEFORE UPDATE ON contratos

FOR EACH ROW

BEGIN

  DECLARE msg VARCHAR(255);

  IF NEW.estado <> OLD.estado AND NOT EXISTS (

    SELECT 1 FROM transicion_estado

     WHERE tabla = 'contratos' AND estado_origen = OLD.estado AND estado_destino = NEW.estado

  ) THEN

    SET msg = CONCAT('Transicion no permitida en contratos: ', OLD.estado, ' -> ', NEW.estado);

    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_contratos_unico_vigente_update` BEFORE UPDATE ON `contratos` FOR EACH ROW BEGIN
  DECLARE existe INT DEFAULT 0;
  IF NEW.estado = 'vigente' AND (OLD.estado <> 'vigente' OR OLD.id_servicio <> NEW.id_servicio) THEN
    SELECT COUNT(*) INTO existe FROM contratos
     WHERE id_servicio = NEW.id_servicio AND estado = 'vigente' AND id_contrato <> NEW.id_contrato;
    IF existe > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe otro contrato vigente para este servicio.';
    END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_contratos_audit_update AFTER UPDATE ON contratos FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)

  VALUES ('UPDATE','contratos',NEW.id_contrato,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_contrato',OLD.id_contrato,'id_servicio',OLD.id_servicio,

                      'fecha_inicio',OLD.fecha_inicio,'fecha_fin',OLD.fecha_fin,

                      'tipo_contrato',OLD.tipo_contrato,'estado',OLD.estado),

          JSON_OBJECT('id_contrato',NEW.id_contrato,'id_servicio',NEW.id_servicio,

                      'fecha_inicio',NEW.fecha_inicio,'fecha_fin',NEW.fecha_fin,

                      'tipo_contrato',NEW.tipo_contrato,'estado',NEW.estado));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_contratos_audit_delete AFTER DELETE ON contratos FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)

  VALUES ('DELETE','contratos',OLD.id_contrato,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_contrato',OLD.id_contrato,'id_servicio',OLD.id_servicio,

                      'fecha_inicio',OLD.fecha_inicio,'fecha_fin',OLD.fecha_fin,

                      'tipo_contrato',OLD.tipo_contrato,'estado',OLD.estado));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_log` (
  `id_email` int(11) NOT NULL AUTO_INCREMENT,
  `id_plantilla` int(11) DEFAULT NULL,
  `destinatario` varchar(120) NOT NULL,
  `asunto` varchar(150) NOT NULL,
  `cuerpo` text DEFAULT NULL,
  `estado` enum('pendiente','enviado','fallido') NOT NULL DEFAULT 'pendiente',
  `error_mensaje` varchar(255) DEFAULT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `enviado_en` datetime DEFAULT NULL,
  PRIMARY KEY (`id_email`),
  KEY `idx_email_plantilla` (`id_plantilla`),
  KEY `idx_email_cliente` (`id_cliente`),
  KEY `idx_email_usuario` (`id_usuario`),
  KEY `idx_email_estado` (`estado`),
  CONSTRAINT `fk_email_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE SET NULL,
  CONSTRAINT `fk_email_plantilla` FOREIGN KEY (`id_plantilla`) REFERENCES `email_plantillas` (`id_plantilla`) ON DELETE SET NULL,
  CONSTRAINT `fk_email_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_plantillas` (
  `id_plantilla` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(50) NOT NULL,
  `asunto` varchar(150) NOT NULL,
  `cuerpo` text NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `activa` tinyint(1) NOT NULL DEFAULT 1,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_plantilla`),
  UNIQUE KEY `uq_plantilla_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipo_movimientos` (
  `id_movimiento` int(11) NOT NULL AUTO_INCREMENT,
  `id_equipo` int(11) NOT NULL,
  `tipo` enum('alta_stock','asignacion','devolucion','baja','reparacion','reemplazo') NOT NULL,
  `estado_anterior` enum('stock','asignado','devuelto','averiado','baja') DEFAULT NULL,
  `estado_nuevo` enum('stock','asignado','devuelto','averiado','baja') NOT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `notas` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_movimiento`),
  KEY `idx_mov_equipo` (`id_equipo`),
  KEY `idx_mov_servicio` (`id_servicio`),
  KEY `idx_mov_usuario` (`id_usuario`),
  CONSTRAINT `fk_mov_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipos` (`id_equipo`) ON DELETE CASCADE,
  CONSTRAINT `fk_mov_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL,
  CONSTRAINT `fk_mov_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_equipo_movimientos_audit_insert` AFTER INSERT ON `equipo_movimientos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','equipo_movimientos',NEW.id_movimiento,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_movimiento',NEW.id_movimiento,'id_equipo',NEW.id_equipo,'tipo',NEW.tipo,
                      'estado_anterior',NEW.estado_anterior,'estado_nuevo',NEW.estado_nuevo,'id_servicio',NEW.id_servicio));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_equipo_movimientos_audit_update` AFTER UPDATE ON `equipo_movimientos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','equipo_movimientos',NEW.id_movimiento,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_movimiento',OLD.id_movimiento,'id_equipo',OLD.id_equipo,'tipo',OLD.tipo,
                      'estado_anterior',OLD.estado_anterior,'estado_nuevo',OLD.estado_nuevo,'id_servicio',OLD.id_servicio),
          JSON_OBJECT('id_movimiento',NEW.id_movimiento,'id_equipo',NEW.id_equipo,'tipo',NEW.tipo,
                      'estado_anterior',NEW.estado_anterior,'estado_nuevo',NEW.estado_nuevo,'id_servicio',NEW.id_servicio));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_equipo_movimientos_audit_delete` AFTER DELETE ON `equipo_movimientos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','equipo_movimientos',OLD.id_movimiento,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_movimiento',OLD.id_movimiento,'id_equipo',OLD.id_equipo,'tipo',OLD.tipo,
                      'estado_anterior',OLD.estado_anterior,'estado_nuevo',OLD.estado_nuevo,'id_servicio',OLD.id_servicio));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `equipos` (
  `id_equipo` int(11) NOT NULL AUTO_INCREMENT,
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
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_equipo`),
  UNIQUE KEY `direccion_mac` (`direccion_mac`),
  UNIQUE KEY `idx_nap_puerto` (`id_naps`,`num_puerto_nap`),
  UNIQUE KEY `uq_numero_serie` (`numero_serie`),
  KEY `idx_equipo_servicio` (`id_servicio`),
  KEY `idx_equipo_estado` (`estado_inventario`),
  CONSTRAINT `fk_equipo_nap` FOREIGN KEY (`id_naps`) REFERENCES `naps` (`id_nap`),
  CONSTRAINT `fk_equipo_srv` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL,
  CONSTRAINT `chk_equipo_puerto` CHECK (`num_puerto_nap` > 0),
  CONSTRAINT `chk_equipo_mac` CHECK (`direccion_mac` regexp '^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}$')
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `etiquetas` (
  `id_etiqueta` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `color` char(7) NOT NULL DEFAULT '#64748b',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_etiqueta`),
  UNIQUE KEY `uq_etiqueta_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `factura_lineas` (
  `id_linea` int(11) NOT NULL AUTO_INCREMENT,
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
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_linea`),
  KEY `fk_linea_factura` (`id_factura`),
  KEY `idx_linea_servicio` (`id_servicio`),
  CONSTRAINT `fk_linea_factura` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`) ON DELETE CASCADE,
  CONSTRAINT `fk_linea_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `facturas` (
  `id_factura` int(11) NOT NULL AUTO_INCREMENT,
  `id_servicio` int(11) NOT NULL,
  `periodo` varchar(7) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `impuesto_aplicado` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Porcentaje congelado al emitir',
  `fecha_emision` date NOT NULL,
  `fecha_vencimiento` date NOT NULL,
  `estado` enum('pendiente','pagada','parcial','vencida','anulada') DEFAULT 'pendiente',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_factura`),
  UNIQUE KEY `uq_factura_servicio_periodo` (`id_servicio`,`periodo`),
  KEY `fk_factura_servicio` (`id_servicio`),
  KEY `idx_factura_estado_vencimiento` (`estado`,`fecha_vencimiento`),
  KEY `idx_factura_periodo` (`periodo`),
  CONSTRAINT `fk_factura_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`),
  CONSTRAINT `chk_fact_monto` CHECK (`monto` >= 0),
  CONSTRAINT `chk_fact_impuesto` CHECK (`impuesto_aplicado` between 0 and 100),
  CONSTRAINT `chk_fact_fechas` CHECK (`fecha_vencimiento` >= `fecha_emision`),
  CONSTRAINT `chk_facturas_periodo` CHECK (`periodo` regexp '^[0-9]{4}-[0-9]{2}$')
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_facturas_validar_insert` BEFORE INSERT ON `facturas`

FOR EACH ROW BEGIN

  IF NEW.estado <> 'pendiente' THEN

    SIGNAL SQLSTATE '45000'

      SET MESSAGE_TEXT = 'INSERT de factura solo permite estado pendiente. Use UPDATE para transicionar.';

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_facturas_audit_insert AFTER INSERT ON facturas FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)

  VALUES ('INSERT','facturas',NEW.id_factura,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_factura',NEW.id_factura,'id_servicio',NEW.id_servicio,'periodo',NEW.periodo,

                      'monto',NEW.monto,'estado',NEW.estado));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_facturas_validar_transicion BEFORE UPDATE ON facturas

FOR EACH ROW

BEGIN

  DECLARE msg VARCHAR(255);

  IF NEW.estado <> OLD.estado AND NOT EXISTS (

    SELECT 1 FROM transicion_estado

     WHERE tabla = 'facturas' AND estado_origen = OLD.estado AND estado_destino = NEW.estado

  ) THEN

    SET msg = CONCAT('Transicion no permitida en facturas: ', OLD.estado, ' -> ', NEW.estado);

    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_facturas_audit_update AFTER UPDATE ON facturas FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)

  VALUES ('UPDATE','facturas',NEW.id_factura,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_factura',OLD.id_factura,'id_servicio',OLD.id_servicio,'periodo',OLD.periodo,

                      'monto',OLD.monto,'estado',OLD.estado),

          JSON_OBJECT('id_factura',NEW.id_factura,'id_servicio',NEW.id_servicio,'periodo',NEW.periodo,

                      'monto',NEW.monto,'estado',NEW.estado));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_facturas_audit_delete AFTER DELETE ON facturas FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)

  VALUES ('DELETE','facturas',OLD.id_factura,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_factura',OLD.id_factura,'id_servicio',OLD.id_servicio,'periodo',OLD.periodo,

                      'monto',OLD.monto,'estado',OLD.estado));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ip_asignaciones` (
  `id_asignacion` int(11) NOT NULL AUTO_INCREMENT,
  `id_servicio` int(11) NOT NULL,
  `id_pool` int(11) NOT NULL,
  `ip` varchar(45) NOT NULL,
  `tipo` enum('estatica','pppoe') NOT NULL DEFAULT 'estatica',
  `estado` enum('activa','liberada','reservada') NOT NULL DEFAULT 'activa',
  `asignada_en` datetime NOT NULL DEFAULT current_timestamp(),
  `liberada_en` datetime DEFAULT NULL,
  `notas` varchar(255) DEFAULT NULL,
  `ip_activa` varchar(45) GENERATED ALWAYS AS (case when `estado` = 'activa' then `ip` else NULL end) STORED,
  PRIMARY KEY (`id_asignacion`),
  UNIQUE KEY `uq_ip_activa` (`ip_activa`),
  KEY `fk_ip_asig_servicio` (`id_servicio`),
  KEY `fk_ip_asig_pool` (`id_pool`),
  CONSTRAINT `fk_ip_asig_pool` FOREIGN KEY (`id_pool`) REFERENCES `ip_pools` (`id_pool`),
  CONSTRAINT `fk_ip_asig_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ip_pools` (
  `id_pool` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) NOT NULL,
  `cidr` varchar(43) NOT NULL,
  `gateway` varchar(45) DEFAULT NULL,
  `vlan` smallint(6) DEFAULT NULL,
  `id_nodo` int(11) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_pool`),
  UNIQUE KEY `uq_ip_pool_cidr` (`cidr`),
  KEY `fk_ip_pool_nodo` (`id_nodo`),
  CONSTRAINT `fk_ip_pool_nodo` FOREIGN KEY (`id_nodo`) REFERENCES `nodos` (`id_nodo`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logs` (
  `id_log` bigint(20) NOT NULL AUTO_INCREMENT,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `accion` enum('INSERT','UPDATE','DELETE','LOGIN','LOGOUT','LOGIN_FALLIDO') NOT NULL,
  `tabla_afectada` varchar(50) DEFAULT NULL,
  `id_registro_afectado` int(11) DEFAULT NULL,
  `tipo_actor` enum('staff','cliente','sistema') NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_credencial` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `old_value` longtext DEFAULT NULL CHECK (json_valid(`old_value`)),
  `new_value` longtext DEFAULT NULL CHECK (json_valid(`new_value`)),
  PRIMARY KEY (`id_log`),
  KEY `fk_log_usuario` (`id_usuario`),
  KEY `idx_log_fecha` (`creado_en`),
  KEY `idx_log_tabla_registro` (`tabla_afectada`,`id_registro_afectado`),
  KEY `idx_log_accion_fecha` (`accion`,`creado_en`),
  KEY `fk_log_credencial` (`id_credencial`),
  CONSTRAINT `fk_log_credencial` FOREIGN KEY (`id_credencial`) REFERENCES `clientes_credenciales` (`id_credencial`),
  CONSTRAINT `fk_log_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `chk_log_actor` CHECK (`tipo_actor` = 'staff' and `id_usuario` is not null and `id_credencial` is null or `tipo_actor` = 'cliente' and `id_credencial` is not null and `id_usuario` is null or `tipo_actor` = 'sistema' and `id_usuario` is null and `id_credencial` is null)
) ENGINE=InnoDB AUTO_INCREMENT=1102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_logs_inmutable_update BEFORE UPDATE ON logs

FOR EACH ROW

BEGIN

  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'logs es inmutable: UPDATE bloqueado.';

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_logs_inmutable_delete BEFORE DELETE ON logs

FOR EACH ROW

BEGIN

  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'logs es inmutable: DELETE bloqueado.';

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `metodos_pago` (
  `id_metodo` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(30) NOT NULL,
  `nombre` varchar(60) NOT NULL,
  `requiere_referencia` tinyint(1) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `orden` tinyint(3) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_metodo`),
  UNIQUE KEY `uq_metodo_codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_metodos_pago_audit_insert` AFTER INSERT ON `metodos_pago` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','metodos_pago',NEW.id_metodo,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_metodo',NEW.id_metodo,'codigo',NEW.codigo,'nombre',NEW.nombre,'activo',NEW.activo));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_metodos_pago_audit_update` AFTER UPDATE ON `metodos_pago` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','metodos_pago',NEW.id_metodo,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_metodo',OLD.id_metodo,'codigo',OLD.codigo,'nombre',OLD.nombre,'activo',OLD.activo),
          JSON_OBJECT('id_metodo',NEW.id_metodo,'codigo',NEW.codigo,'nombre',NEW.nombre,'activo',NEW.activo));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_metodos_pago_audit_delete` AFTER DELETE ON `metodos_pago` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','metodos_pago',OLD.id_metodo,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_metodo',OLD.id_metodo,'codigo',OLD.codigo,'nombre',OLD.nombre,'activo',OLD.activo));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `modulos` (
  `id_modulo` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_modulo` varchar(50) NOT NULL,
  PRIMARY KEY (`id_modulo`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `naps` (
  `id_nap` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) NOT NULL,
  `cantidad_puertos_max` tinyint(4) NOT NULL DEFAULT 16,
  `ubicacion_fisica` text DEFAULT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `id_olts` int(11) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_nap`),
  UNIQUE KEY `codigo` (`codigo`),
  KEY `fk_nap_olt` (`id_olts`),
  CONSTRAINT `fk_nap_olt` FOREIGN KEY (`id_olts`) REFERENCES `olts` (`id_olt`),
  CONSTRAINT `chk_nap_lat` CHECK (`latitud` between -90 and 90),
  CONSTRAINT `chk_nap_lon` CHECK (`longitud` between -180 and 180),
  CONSTRAINT `chk_nap_puertos` CHECK (`cantidad_puertos_max` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodos` (
  `id_nodo` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `ubicacion` varchar(255) DEFAULT NULL,
  `latitud` decimal(10,8) NOT NULL,
  `longitud` decimal(11,8) NOT NULL,
  `estado` enum('activo','mantenimiento','inactivo') DEFAULT 'activo',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_nodo`),
  UNIQUE KEY `uq_nodo_nombre` (`nombre`),
  CONSTRAINT `chk_nodo_lat` CHECK (`latitud` between -90 and 90),
  CONSTRAINT `chk_nodo_lon` CHECK (`longitud` between -180 and 180)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notas_credito` (
  `id_nota` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente` int(11) NOT NULL,
  `id_factura` int(11) DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'USD',
  `motivo` varchar(255) NOT NULL,
  `estado` enum('emitida','aplicada','anulada') NOT NULL DEFAULT 'emitida',
  `id_usuario_emisor` int(11) DEFAULT NULL,
  `emitida_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `aplicada_en` datetime DEFAULT NULL,
  PRIMARY KEY (`id_nota`),
  KEY `idx_nc_cliente` (`id_cliente`),
  KEY `idx_nc_factura` (`id_factura`),
  KEY `idx_nc_emisor` (`id_usuario_emisor`),
  CONSTRAINT `fk_nc_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_nc_emisor` FOREIGN KEY (`id_usuario_emisor`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_nc_factura` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_notas_credito_audit_insert` AFTER INSERT ON `notas_credito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','notas_credito',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_factura',NEW.id_factura,
                      'monto',NEW.monto,'estado',NEW.estado));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_notas_credito_audit_update` AFTER UPDATE ON `notas_credito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','notas_credito',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_factura',OLD.id_factura,
                      'monto',OLD.monto,'estado',OLD.estado),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_factura',NEW.id_factura,
                      'monto',NEW.monto,'estado',NEW.estado));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_notas_credito_audit_delete` AFTER DELETE ON `notas_credito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','notas_credito',OLD.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_factura',OLD.id_factura,
                      'monto',OLD.monto,'estado',OLD.estado));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notas_debito` (
  `id_nota` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente` int(11) NOT NULL,
  `id_factura` int(11) DEFAULT NULL,
  `monto` decimal(10,2) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'USD',
  `motivo` varchar(255) NOT NULL,
  `estado` enum('emitida','aplicada','anulada') NOT NULL DEFAULT 'emitida',
  `id_usuario_emisor` int(11) DEFAULT NULL,
  `emitida_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `aplicada_en` datetime DEFAULT NULL,
  PRIMARY KEY (`id_nota`),
  KEY `idx_nd_cliente` (`id_cliente`),
  KEY `idx_nd_factura` (`id_factura`),
  KEY `idx_nd_emisor` (`id_usuario_emisor`),
  CONSTRAINT `fk_nd_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_nd_emisor` FOREIGN KEY (`id_usuario_emisor`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_nd_factura` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_notas_debito_audit_insert` AFTER INSERT ON `notas_debito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','notas_debito',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_factura',NEW.id_factura,
                      'monto',NEW.monto,'estado',NEW.estado));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_notas_debito_audit_update` AFTER UPDATE ON `notas_debito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','notas_debito',NEW.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_factura',OLD.id_factura,
                      'monto',OLD.monto,'estado',OLD.estado),
          JSON_OBJECT('id_nota',NEW.id_nota,'id_cliente',NEW.id_cliente,'id_factura',NEW.id_factura,
                      'monto',NEW.monto,'estado',NEW.estado));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_notas_debito_audit_delete` AFTER DELETE ON `notas_debito` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','notas_debito',OLD.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_factura',OLD.id_factura,
                      'monto',OLD.monto,'estado',OLD.estado));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones` (
  `id_notificacion` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(100) NOT NULL,
  `mensaje` varchar(255) NOT NULL,
  `fecha_envio` datetime DEFAULT current_timestamp(),
  `estado` enum('leido','no leido') DEFAULT 'no leido',
  `id_cliente` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `tipo_evento` varchar(50) DEFAULT NULL,
  `url_destino` varchar(255) DEFAULT NULL,
  `leida_en` datetime DEFAULT NULL,
  PRIMARY KEY (`id_notificacion`),
  KEY `fk_notif_cliente` (`id_cliente`),
  KEY `idx_notif_cliente_estado` (`id_cliente`,`estado`),
  KEY `fk_notif_usuario` (`id_usuario`),
  CONSTRAINT `fk_notif_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_notif_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones_staff` (
  `id_notificacion` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(100) NOT NULL,
  `mensaje` varchar(255) NOT NULL,
  `tipo_evento` varchar(50) DEFAULT NULL,
  `url_destino` varchar(255) DEFAULT NULL,
  `estado` enum('leido','no leido') NOT NULL DEFAULT 'no leido',
  `id_usuario` int(11) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `leida_en` datetime DEFAULT NULL,
  PRIMARY KEY (`id_notificacion`),
  KEY `idx_notif_staff_usuario_estado` (`id_usuario`,`estado`),
  CONSTRAINT `fk_notif_staff_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_notificaciones_staff_audit_insert` AFTER INSERT ON `notificaciones_staff` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','notificaciones_staff',NEW.id_notificacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_notificacion',NEW.id_notificacion,'titulo',NEW.titulo,'tipo_evento',NEW.tipo_evento,
                      'estado',NEW.estado,'id_usuario',NEW.id_usuario));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_notificaciones_staff_audit_update` AFTER UPDATE ON `notificaciones_staff` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','notificaciones_staff',NEW.id_notificacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_notificacion',OLD.id_notificacion,'titulo',OLD.titulo,'tipo_evento',OLD.tipo_evento,
                      'estado',OLD.estado,'id_usuario',OLD.id_usuario),
          JSON_OBJECT('id_notificacion',NEW.id_notificacion,'titulo',NEW.titulo,'tipo_evento',NEW.tipo_evento,
                      'estado',NEW.estado,'id_usuario',NEW.id_usuario));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_notificaciones_staff_audit_delete` AFTER DELETE ON `notificaciones_staff` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','notificaciones_staff',OLD.id_notificacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_notificacion',OLD.id_notificacion,'titulo',OLD.titulo,'tipo_evento',OLD.tipo_evento,
                      'estado',OLD.estado,'id_usuario',OLD.id_usuario));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `olts` (
  `id_olt` int(11) NOT NULL AUTO_INCREMENT,
  `marca_modelo` varchar(100) NOT NULL,
  `puertos_pon` tinyint(4) NOT NULL DEFAULT 16,
  `ip_gestion` varchar(45) DEFAULT NULL,
  `id_nodos` int(11) NOT NULL,
  `codigo` varchar(20) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_olt`),
  UNIQUE KEY `uq_olt_codigo` (`codigo`),
  UNIQUE KEY `uq_olt_ip_gestion` (`ip_gestion`),
  KEY `fk_olt_nodo` (`id_nodos`),
  CONSTRAINT `fk_olt_nodo` FOREIGN KEY (`id_nodos`) REFERENCES `nodos` (`id_nodo`),
  CONSTRAINT `chk_olt_puertos` CHECK (`puertos_pon` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paginas` (
  `id_pagina` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_pagina` varchar(100) NOT NULL,
  `url_pagina` varchar(255) NOT NULL,
  `id_modulo` int(11) NOT NULL,
  PRIMARY KEY (`id_pagina`),
  UNIQUE KEY `uq_pagina_modulo` (`id_pagina`,`id_modulo`),
  KEY `fk_pagina_modulo` (`id_modulo`),
  CONSTRAINT `fk_pagina_modulo` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id_modulo`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pagos` (
  `id_pago` int(11) NOT NULL AUTO_INCREMENT,
  `id_factura` int(11) DEFAULT NULL,
  `id_cliente` int(11) NOT NULL,
  `id_servicio` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `moneda_pago` enum('USD','VES') NOT NULL DEFAULT 'USD',
  `tasa_cambio` decimal(10,4) DEFAULT NULL COMMENT 'Tasa BCV al momento del pago',
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
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_pago`),
  KEY `fk_pago_factura` (`id_factura`),
  KEY `fk_pago_cliente` (`id_cliente`),
  KEY `fk_pago_servicio` (`id_servicio`),
  KEY `fk_pago_usuario` (`id_usuario_valido`),
  KEY `idx_pago_metodo` (`id_metodo`),
  KEY `idx_pago_estado` (`estado`),
  KEY `idx_pago_factura_estado` (`id_factura`,`estado`),
  KEY `idx_pago_fecha` (`fecha_pago`),
  CONSTRAINT `fk_pago_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_pago_factura` FOREIGN KEY (`id_factura`) REFERENCES `facturas` (`id_factura`),
  CONSTRAINT `fk_pago_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`),
  CONSTRAINT `fk_pago_usuario` FOREIGN KEY (`id_usuario_valido`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `fk_pago_metodo` FOREIGN KEY (`id_metodo`) REFERENCES `metodos_pago` (`id_metodo`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `chk_pago_monto` CHECK (`monto` > 0),
  CONSTRAINT `chk_pago_tasa` CHECK (`tasa_cambio` is null or `tasa_cambio` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pagos_validar_insert` BEFORE INSERT ON `pagos`

FOR EACH ROW BEGIN

  IF NEW.estado <> 'pendiente' THEN

    SIGNAL SQLSTATE '45000'

      SET MESSAGE_TEXT = 'INSERT de pago solo permite estado pendiente. Use UPDATE para transicionar.';

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_pagos_audit_insert AFTER INSERT ON pagos FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)

  VALUES ('INSERT','pagos',NEW.id_pago,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_pago',NEW.id_pago,'id_factura',NEW.id_factura,'monto',NEW.monto,

                      'estado',NEW.estado,'id_usuario_valido',NEW.id_usuario_valido));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_pagos_validar_transicion BEFORE UPDATE ON pagos

FOR EACH ROW

BEGIN

  DECLARE msg VARCHAR(255);

  IF NEW.estado <> OLD.estado AND NOT EXISTS (

    SELECT 1 FROM transicion_estado

     WHERE tabla = 'pagos' AND estado_origen = OLD.estado AND estado_destino = NEW.estado

  ) THEN

    SET msg = CONCAT('Transicion no permitida en pagos: ', OLD.estado, ' -> ', NEW.estado);

    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_pagos_audit_update AFTER UPDATE ON pagos FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)

  VALUES ('UPDATE','pagos',NEW.id_pago,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_pago',OLD.id_pago,'id_factura',OLD.id_factura,'monto',OLD.monto,

                      'estado',OLD.estado,'id_usuario_valido',OLD.id_usuario_valido),

          JSON_OBJECT('id_pago',NEW.id_pago,'id_factura',NEW.id_factura,'monto',NEW.monto,

                      'estado',NEW.estado,'id_usuario_valido',NEW.id_usuario_valido));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_pagos_audit_delete AFTER DELETE ON pagos FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)

  VALUES ('DELETE','pagos',OLD.id_pago,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_pago',OLD.id_pago,'id_factura',OLD.id_factura,'monto',OLD.monto,

                      'estado',OLD.estado,'id_usuario_valido',OLD.id_usuario_valido));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedido_asignaciones` (
  `id_asignacion` int(11) NOT NULL AUTO_INCREMENT,
  `id_pedido` int(11) NOT NULL,
  `id_tecnico` int(11) NOT NULL,
  `id_usuario_asignador` int(11) DEFAULT NULL,
  `estado` enum('activa','completada','rechazada') NOT NULL DEFAULT 'activa',
  `motivo_rechazo` varchar(255) DEFAULT NULL,
  `asignado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `cerrado_en` datetime DEFAULT NULL,
  PRIMARY KEY (`id_asignacion`),
  KEY `idx_asig_pedido` (`id_pedido`),
  KEY `idx_asig_tecnico` (`id_tecnico`),
  KEY `idx_asig_asignador` (`id_usuario_asignador`),
  CONSTRAINT `fk_asig_asignador` FOREIGN KEY (`id_usuario_asignador`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_asig_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE,
  CONSTRAINT `fk_asig_tecnico` FOREIGN KEY (`id_tecnico`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pedido_asignaciones_audit_insert` AFTER INSERT ON `pedido_asignaciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','pedido_asignaciones',NEW.id_asignacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_asignacion',NEW.id_asignacion,'id_pedido',NEW.id_pedido,'id_tecnico',NEW.id_tecnico,
                      'estado',NEW.estado));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pedido_asignaciones_audit_update` AFTER UPDATE ON `pedido_asignaciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','pedido_asignaciones',NEW.id_asignacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_asignacion',OLD.id_asignacion,'id_pedido',OLD.id_pedido,'id_tecnico',OLD.id_tecnico,
                      'estado',OLD.estado),
          JSON_OBJECT('id_asignacion',NEW.id_asignacion,'id_pedido',NEW.id_pedido,'id_tecnico',NEW.id_tecnico,
                      'estado',NEW.estado));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pedido_asignaciones_audit_delete` AFTER DELETE ON `pedido_asignaciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','pedido_asignaciones',OLD.id_asignacion,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_asignacion',OLD.id_asignacion,'id_pedido',OLD.id_pedido,'id_tecnico',OLD.id_tecnico,
                      'estado',OLD.estado));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedido_materiales` (
  `id_material` int(11) NOT NULL AUTO_INCREMENT,
  `id_pedido` int(11) NOT NULL,
  `id_equipo` int(11) DEFAULT NULL,
  `descripcion` varchar(150) NOT NULL,
  `cantidad` decimal(10,2) NOT NULL DEFAULT 1.00,
  `unidad` varchar(20) NOT NULL DEFAULT 'unidad',
  `notas` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_material`),
  KEY `idx_material_pedido` (`id_pedido`),
  KEY `idx_material_equipo` (`id_equipo`),
  CONSTRAINT `fk_material_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipos` (`id_equipo`) ON DELETE SET NULL,
  CONSTRAINT `fk_material_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pedido_materiales_audit_insert` AFTER INSERT ON `pedido_materiales` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','pedido_materiales',NEW.id_material,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_material',NEW.id_material,'id_pedido',NEW.id_pedido,'id_equipo',NEW.id_equipo,
                      'descripcion',NEW.descripcion,'cantidad',NEW.cantidad));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pedido_materiales_audit_update` AFTER UPDATE ON `pedido_materiales` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','pedido_materiales',NEW.id_material,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_material',OLD.id_material,'id_pedido',OLD.id_pedido,'id_equipo',OLD.id_equipo,
                      'descripcion',OLD.descripcion,'cantidad',OLD.cantidad),
          JSON_OBJECT('id_material',NEW.id_material,'id_pedido',NEW.id_pedido,'id_equipo',NEW.id_equipo,
                      'descripcion',NEW.descripcion,'cantidad',NEW.cantidad));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pedido_materiales_audit_delete` AFTER DELETE ON `pedido_materiales` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','pedido_materiales',OLD.id_material,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_material',OLD.id_material,'id_pedido',OLD.id_pedido,'id_equipo',OLD.id_equipo,
                      'descripcion',OLD.descripcion,'cantidad',OLD.cantidad));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedidos` (
  `id_pedido` int(11) NOT NULL AUTO_INCREMENT,
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
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_pedido`),
  KEY `idx_pedido_cliente` (`id_cliente`),
  KEY `idx_pedido_servicio` (`id_servicio`),
  KEY `idx_pedido_estado` (`estado`),
  KEY `idx_pedido_tecnico` (`id_tecnico_asignado`),
  KEY `idx_pedido_creador` (`id_usuario_creador`),
  CONSTRAINT `fk_pedido_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_pedido_creador` FOREIGN KEY (`id_usuario_creador`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL,
  CONSTRAINT `fk_pedido_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL,
  CONSTRAINT `fk_pedido_tecnico` FOREIGN KEY (`id_tecnico_asignado`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pedidos_audit_insert` AFTER INSERT ON `pedidos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','pedidos',NEW.id_pedido,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_pedido',NEW.id_pedido,'id_cliente',NEW.id_cliente,'id_servicio',NEW.id_servicio,
                      'tipo',NEW.tipo,'estado',NEW.estado,'prioridad',NEW.prioridad));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pedidos_audit_update` AFTER UPDATE ON `pedidos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','pedidos',NEW.id_pedido,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_pedido',OLD.id_pedido,'id_cliente',OLD.id_cliente,'id_servicio',OLD.id_servicio,
                      'tipo',OLD.tipo,'estado',OLD.estado,'prioridad',OLD.prioridad),
          JSON_OBJECT('id_pedido',NEW.id_pedido,'id_cliente',NEW.id_cliente,'id_servicio',NEW.id_servicio,
                      'tipo',NEW.tipo,'estado',NEW.estado,'prioridad',NEW.prioridad));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_pedidos_audit_delete` AFTER DELETE ON `pedidos` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','pedidos',OLD.id_pedido,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_pedido',OLD.id_pedido,'id_cliente',OLD.id_cliente,'id_servicio',OLD.id_servicio,
                      'tipo',OLD.tipo,'estado',OLD.estado,'prioridad',OLD.prioridad));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permisos` (
  `id_permiso` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(30) NOT NULL,
  PRIMARY KEY (`id_permiso`),
  UNIQUE KEY `uq_permiso_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plan_historial_precios` (
  `id_historial` int(11) NOT NULL AUTO_INCREMENT,
  `id_plan` int(11) NOT NULL,
  `precio_anterior` decimal(10,2) NOT NULL,
  `precio_nuevo` decimal(10,2) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'USD',
  `id_usuario` int(11) DEFAULT NULL,
  `cambiado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `motivo` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_historial`),
  KEY `idx_hist_precio_plan` (`id_plan`),
  KEY `idx_hist_precio_usuario` (`id_usuario`),
  CONSTRAINT `fk_hist_precio_plan` FOREIGN KEY (`id_plan`) REFERENCES `planes` (`id_plan`) ON DELETE CASCADE,
  CONSTRAINT `fk_hist_precio_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_plan_historial_precios_audit_insert` AFTER INSERT ON `plan_historial_precios` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','plan_historial_precios',NEW.id_historial,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_historial',NEW.id_historial,'id_plan',NEW.id_plan,'precio_anterior',NEW.precio_anterior,
                      'precio_nuevo',NEW.precio_nuevo,'id_usuario',NEW.id_usuario));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `planes` (
  `id_plan` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) NOT NULL,
  `velocidad_bajada_mbps` decimal(8,2) DEFAULT NULL,
  `velocidad_subida_mbps` decimal(8,2) DEFAULT NULL,
  `tecnologia` enum('FTTH','HFC','WISP','OTRO') NOT NULL DEFAULT 'FTTH',
  `precio_mensual` decimal(10,2) NOT NULL,
  `moneda` varchar(10) NOT NULL DEFAULT 'USD',
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_plan`),
  CONSTRAINT `chk_plan_velocidad_bajada` CHECK (`velocidad_bajada_mbps` is null or `velocidad_bajada_mbps` > 0),
  CONSTRAINT `chk_plan_velocidad_subida` CHECK (`velocidad_subida_mbps` is null or `velocidad_subida_mbps` > 0),
  CONSTRAINT `chk_plan_precio` CHECK (`precio_mensual` >= 0),
  CONSTRAINT `chk_plan_moneda` CHECK (`moneda` in ('USD','VES','COP','EUR'))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_rol` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `nombre_rol` (`nombre_rol`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rol_modulo` (
  `id_rol_modulo` int(11) NOT NULL AUTO_INCREMENT,
  `id_rol` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL,
  PRIMARY KEY (`id_rol_modulo`),
  UNIQUE KEY `uq_rol_modulo` (`id_rol`,`id_modulo`),
  UNIQUE KEY `uq_rolmodulo_modulo` (`id_rol_modulo`,`id_modulo`),
  KEY `fk_rm_rol` (`id_rol`),
  KEY `fk_rm_modulo` (`id_modulo`),
  CONSTRAINT `fk_rm_modulo` FOREIGN KEY (`id_modulo`) REFERENCES `modulos` (`id_modulo`) ON DELETE CASCADE,
  CONSTRAINT `fk_rm_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rol_modulo_pagina` (
  `id_rol_modulo_pagina` int(11) NOT NULL AUTO_INCREMENT,
  `id_rol_modulo` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL,
  `id_pagina` int(11) NOT NULL,
  PRIMARY KEY (`id_rol_modulo_pagina`),
  UNIQUE KEY `uq_rolmodulo_pagina` (`id_rol_modulo`,`id_pagina`),
  KEY `fk_rmpag_pagina` (`id_pagina`),
  CONSTRAINT `fk_rmpag_pagina` FOREIGN KEY (`id_pagina`) REFERENCES `paginas` (`id_pagina`) ON DELETE CASCADE,
  CONSTRAINT `fk_rmpag_rolmodulo` FOREIGN KEY (`id_rol_modulo`) REFERENCES `rol_modulo` (`id_rol_modulo`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1393 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rol_modulo_permiso` (
  `id_rol_modulo_permiso` int(11) NOT NULL AUTO_INCREMENT,
  `id_rol_modulo` int(11) NOT NULL,
  `id_modulo` int(11) NOT NULL,
  `id_pagina` int(11) NOT NULL,
  `id_permiso` int(11) NOT NULL,
  PRIMARY KEY (`id_rol_modulo_permiso`),
  UNIQUE KEY `uq_rm_permiso` (`id_rol_modulo`,`id_pagina`,`id_permiso`),
  KEY `fk_rmp_rolmodulo` (`id_rol_modulo`),
  KEY `fk_rmp_pagina` (`id_pagina`),
  KEY `fk_rmp_permiso` (`id_permiso`),
  KEY `fk_rmp_pagina_modulo` (`id_pagina`,`id_modulo`),
  KEY `fk_rmp_rolmodulo_modulo` (`id_rol_modulo`,`id_modulo`),
  CONSTRAINT `fk_rmp_pagina` FOREIGN KEY (`id_pagina`) REFERENCES `paginas` (`id_pagina`) ON DELETE CASCADE,
  CONSTRAINT `fk_rmp_pagina_modulo` FOREIGN KEY (`id_pagina`, `id_modulo`) REFERENCES `paginas` (`id_pagina`, `id_modulo`),
  CONSTRAINT `fk_rmp_permiso` FOREIGN KEY (`id_permiso`) REFERENCES `permisos` (`id_permiso`),
  CONSTRAINT `fk_rmp_rolmodulo` FOREIGN KEY (`id_rol_modulo`) REFERENCES `rol_modulo` (`id_rol_modulo`) ON DELETE CASCADE,
  CONSTRAINT `fk_rmp_rolmodulo_modulo` FOREIGN KEY (`id_rol_modulo`, `id_modulo`) REFERENCES `rol_modulo` (`id_rol_modulo`, `id_modulo`)
) ENGINE=InnoDB AUTO_INCREMENT=7324 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `servicios` (
  `id_servicio` int(11) NOT NULL AUTO_INCREMENT,
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
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_servicio`),
  KEY `fk_srv_cliente` (`id_cliente`),
  KEY `fk_srv_plan` (`id_plan`),
  KEY `fk_srv_nap` (`id_naps`),
  CONSTRAINT `fk_srv_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_srv_nap` FOREIGN KEY (`id_naps`) REFERENCES `naps` (`id_nap`),
  CONSTRAINT `fk_srv_plan` FOREIGN KEY (`id_plan`) REFERENCES `planes` (`id_plan`),
  CONSTRAINT `chk_serv_lat` CHECK (`latitud_instalacion` is null or `latitud_instalacion` between -90 and 90),
  CONSTRAINT `chk_serv_lon` CHECK (`longitud_instalacion` is null or `longitud_instalacion` between -180 and 180)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_servicios_validar_insert` BEFORE INSERT ON `servicios`

FOR EACH ROW BEGIN

  IF NEW.estado_comercial <> 'pendiente' THEN

    SIGNAL SQLSTATE '45000'

      SET MESSAGE_TEXT = 'INSERT de servicio solo permite estado pendiente. Use UPDATE para transicionar.';

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_servicios_audit_insert AFTER INSERT ON servicios FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)

  VALUES ('INSERT','servicios',NEW.id_servicio,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_servicio',NEW.id_servicio,'id_cliente',NEW.id_cliente,'alias',NEW.alias,

                      'estado_comercial',NEW.estado_comercial,'id_plan',NEW.id_plan,'id_naps',NEW.id_naps));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_servicios_validar_transicion BEFORE UPDATE ON servicios

FOR EACH ROW

BEGIN

  DECLARE msg VARCHAR(255);

  IF NEW.estado_comercial <> OLD.estado_comercial AND NOT EXISTS (

    SELECT 1 FROM transicion_estado

     WHERE tabla = 'servicios' AND estado_origen = OLD.estado_comercial AND estado_destino = NEW.estado_comercial

  ) THEN

    SET msg = CONCAT('Transicion no permitida en servicios: ', OLD.estado_comercial, ' -> ', NEW.estado_comercial);

    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_servicios_audit_update AFTER UPDATE ON servicios FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)

  VALUES ('UPDATE','servicios',NEW.id_servicio,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_servicio',OLD.id_servicio,'id_cliente',OLD.id_cliente,'alias',OLD.alias,

                      'estado_comercial',OLD.estado_comercial,'id_plan',OLD.id_plan,'id_naps',OLD.id_naps),

          JSON_OBJECT('id_servicio',NEW.id_servicio,'id_cliente',NEW.id_cliente,'alias',NEW.alias,

                      'estado_comercial',NEW.estado_comercial,'id_plan',NEW.id_plan,'id_naps',NEW.id_naps));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_servicios_audit_delete AFTER DELETE ON servicios FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)

  VALUES ('DELETE','servicios',OLD.id_servicio,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_servicio',OLD.id_servicio,'id_cliente',OLD.id_cliente,'alias',OLD.alias,

                      'estado_comercial',OLD.estado_comercial,'id_plan',OLD.id_plan,'id_naps',OLD.id_naps));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sesiones` (
  `id_sesion` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(64) NOT NULL,
  `tipo_usuario` enum('staff','cliente') NOT NULL DEFAULT 'staff',
  `id_usuario` int(11) DEFAULT NULL,
  `id_credencial` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `expira_en` datetime NOT NULL,
  `revocado_en` datetime DEFAULT NULL,
  `motivo_cierre` enum('logout','cambio_password','revocada_por_admin','seguridad') DEFAULT NULL,
  PRIMARY KEY (`id_sesion`),
  UNIQUE KEY `token` (`token`),
  KEY `fk_sesion_usuario` (`id_usuario`),
  KEY `fk_sesion_credencial` (`id_credencial`),
  KEY `idx_sesion_expira` (`expira_en`),
  CONSTRAINT `fk_sesion_credencial` FOREIGN KEY (`id_credencial`) REFERENCES `clientes_credenciales` (`id_credencial`),
  CONSTRAINT `fk_sesion_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `chk_sesion_revocacion` CHECK (`revocado_en` is null and `motivo_cierre` is null or `revocado_en` is not null and `motivo_cierre` is not null),
  CONSTRAINT `chk_sesiones_discriminador` CHECK (`tipo_usuario` = 'staff' and `id_usuario` is not null and `id_credencial` is null or `tipo_usuario` = 'cliente' and `id_credencial` is not null and `id_usuario` is null),
  CONSTRAINT `chk_sesion_expira` CHECK (`expira_en` > `creado_en`),
  CONSTRAINT `chk_sesiones_un_tipo` CHECK (`id_usuario` is not null and `id_credencial` is null or `id_usuario` is null and `id_credencial` is not null)
) ENGINE=InnoDB AUTO_INCREMENT=261 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_sesiones_audit_insert AFTER INSERT ON sesiones FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)

  VALUES ('INSERT','sesiones',NEW.id_sesion,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_sesion',NEW.id_sesion,'tipo_usuario',NEW.tipo_usuario,'id_usuario',NEW.id_usuario,

                      'id_credencial',NEW.id_credencial,'expira_en',NEW.expira_en));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_sesiones_audit_update AFTER UPDATE ON sesiones FOR EACH ROW

BEGIN

  IF NOT (NEW.revocado_en <=> OLD.revocado_en) THEN

    INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)

    VALUES ('UPDATE','sesiones',NEW.id_sesion,

            COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

            JSON_OBJECT('id_sesion',OLD.id_sesion,'revocado_en',OLD.revocado_en,'motivo_cierre',OLD.motivo_cierre),

            JSON_OBJECT('id_sesion',NEW.id_sesion,'revocado_en',NEW.revocado_en,'motivo_cierre',NEW.motivo_cierre));

  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_sesiones_audit_delete AFTER DELETE ON sesiones FOR EACH ROW

BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)

  VALUES ('DELETE','sesiones',OLD.id_sesion,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_sesion',OLD.id_sesion,'tipo_usuario',OLD.tipo_usuario,'id_usuario',OLD.id_usuario,

                      'id_credencial',OLD.id_credencial));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sla_definiciones` (
  `id_sla` int(11) NOT NULL AUTO_INCREMENT,
  `id_categoria` int(11) NOT NULL,
  `prioridad` enum('Alta','Media','Baja') NOT NULL,
  `horas_respuesta` smallint(5) NOT NULL,
  `horas_resolucion` smallint(5) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_sla`),
  UNIQUE KEY `uq_sla_categoria_prioridad` (`id_categoria`,`prioridad`),
  CONSTRAINT `fk_sla_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias_ticket` (`id_categoria`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_sla_definiciones_audit_insert` AFTER INSERT ON `sla_definiciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)
  VALUES ('INSERT','sla_definiciones',NEW.id_sla,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_sla',NEW.id_sla,'id_categoria',NEW.id_categoria,'prioridad',NEW.prioridad,
                      'horas_respuesta',NEW.horas_respuesta,'horas_resolucion',NEW.horas_resolucion));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_sla_definiciones_audit_update` AFTER UPDATE ON `sla_definiciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)
  VALUES ('UPDATE','sla_definiciones',NEW.id_sla,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_sla',OLD.id_sla,'id_categoria',OLD.id_categoria,'prioridad',OLD.prioridad,
                      'horas_respuesta',OLD.horas_respuesta,'horas_resolucion',OLD.horas_resolucion),
          JSON_OBJECT('id_sla',NEW.id_sla,'id_categoria',NEW.id_categoria,'prioridad',NEW.prioridad,
                      'horas_respuesta',NEW.horas_respuesta,'horas_resolucion',NEW.horas_resolucion));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_sla_definiciones_audit_delete` AFTER DELETE ON `sla_definiciones` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','sla_definiciones',OLD.id_sla,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_sla',OLD.id_sla,'id_categoria',OLD.id_categoria,'prioridad',OLD.prioridad,
                      'horas_respuesta',OLD.horas_respuesta,'horas_resolucion',OLD.horas_resolucion));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tareas` (
  `id_tarea` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `estado` enum('Pendiente','En curso','Completada') NOT NULL DEFAULT 'Pendiente',
  `prioridad` enum('Alta','Media','Baja') NOT NULL DEFAULT 'Media',
  `id_cliente` int(11) DEFAULT NULL,
  `id_ticket` int(11) DEFAULT NULL,
  `id_servicio` int(11) DEFAULT NULL,
  `id_usuario_creador` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_tarea`),
  KEY `fk_tarea_cliente` (`id_cliente`),
  KEY `fk_tarea_usuario` (`id_usuario_creador`),
  KEY `fk_tarea_servicio` (`id_servicio`),
  KEY `fk_tarea_ticket` (`id_ticket`),
  CONSTRAINT `fk_tarea_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_tarea_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`) ON DELETE SET NULL,
  CONSTRAINT `fk_tarea_ticket` FOREIGN KEY (`id_ticket`) REFERENCES `tickets` (`id_ticket`) ON DELETE SET NULL,
  CONSTRAINT `fk_tarea_usuario` FOREIGN KEY (`id_usuario_creador`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ticket_respuestas` (
  `id_respuesta` int(11) NOT NULL AUTO_INCREMENT,
  `id_ticket` int(11) NOT NULL,
  `tipo_autor` enum('staff','cliente') NOT NULL,
  `mensaje` text NOT NULL,
  `adjunto_path` varchar(255) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL COMMENT 'Si respondió el staff',
  `id_credencial` int(11) DEFAULT NULL COMMENT 'Si respondió el cliente',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_respuesta`),
  KEY `fk_respuesta_credencial` (`id_credencial`),
  KEY `fk_respuesta_ticket` (`id_ticket`),
  KEY `fk_respuesta_usuario` (`id_usuario`),
  CONSTRAINT `fk_respuesta_credencial` FOREIGN KEY (`id_credencial`) REFERENCES `clientes_credenciales` (`id_credencial`),
  CONSTRAINT `fk_respuesta_ticket` FOREIGN KEY (`id_ticket`) REFERENCES `tickets` (`id_ticket`) ON DELETE CASCADE,
  CONSTRAINT `fk_respuesta_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `chk_ticket_respuestas_discriminador` CHECK (`tipo_autor` = 'staff' and `id_usuario` is not null and `id_credencial` is null or `tipo_autor` = 'cliente' and `id_credencial` is not null and `id_usuario` is null)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tickets` (
  `id_ticket` int(11) NOT NULL AUTO_INCREMENT,
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
  `sla_vence_en` datetime DEFAULT NULL,
  PRIMARY KEY (`id_ticket`),
  KEY `fk_ticket_cliente` (`id_cliente`),
  KEY `fk_ticket_servicio` (`id_servicio`),
  KEY `fk_ticket_usuario` (`id_usuario_creador`),
  KEY `idx_tickets_estado` (`estado`),
  KEY `idx_tickets_sla` (`sla_vence_en`),
  KEY `idx_tickets_categoria` (`id_categoria`),
  CONSTRAINT `fk_ticket_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias_ticket` (`id_categoria`) ON DELETE SET NULL,
  CONSTRAINT `fk_ticket_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_ticket_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `servicios` (`id_servicio`),
  CONSTRAINT `fk_ticket_usuario` FOREIGN KEY (`id_usuario_creador`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transicion_estado` (
  `id_transicion` int(11) NOT NULL AUTO_INCREMENT,
  `tabla` varchar(50) NOT NULL,
  `estado_origen` varchar(30) NOT NULL,
  `estado_destino` varchar(30) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_transicion`),
  UNIQUE KEY `uq_transicion` (`tabla`,`estado_origen`,`estado_destino`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario_rol` (
  `id_usuario_rol` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL,
  PRIMARY KEY (`id_usuario_rol`),
  UNIQUE KEY `uq_usuario_rol` (`id_usuario`,`id_rol`),
  KEY `fk_ur_usuario` (`id_usuario`),
  KEY `fk_ur_rol` (`id_rol`),
  CONSTRAINT `fk_ur_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`),
  CONSTRAINT `fk_ur_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL DEFAULT '',
  `must_change_password` tinyint(1) NOT NULL DEFAULT 0,
  `email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `estado` enum('Activo','Inactivo','Bloqueado') NOT NULL DEFAULT 'Activo',
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0,
  `bloqueado_hasta` datetime DEFAULT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `uq_usuario_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_usuarios_audit_insert AFTER INSERT ON usuarios FOR EACH ROW BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, new_value)

  VALUES ('INSERT','usuarios',NEW.id_usuario,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_usuario',NEW.id_usuario,'username',NEW.username,'email',NEW.email,

                      'estado',NEW.estado,'email_verified',NEW.email_verified));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_usuarios_audit_update AFTER UPDATE ON usuarios FOR EACH ROW BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value, new_value)

  VALUES ('UPDATE','usuarios',NEW.id_usuario,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_usuario',OLD.id_usuario,'username',OLD.username,'email',OLD.email,

                      'estado',OLD.estado,'email_verified',OLD.email_verified,

                      'must_change_password',OLD.must_change_password),

          JSON_OBJECT('id_usuario',NEW.id_usuario,'username',NEW.username,'email',NEW.email,

                      'estado',NEW.estado,'email_verified',NEW.email_verified,

                      'must_change_password',NEW.must_change_password));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER trg_usuarios_audit_delete AFTER DELETE ON usuarios FOR EACH ROW BEGIN

  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)

  VALUES ('DELETE','usuarios',OLD.id_usuario,

          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),

          JSON_OBJECT('id_usuario',OLD.id_usuario,'username',OLD.username,'email',OLD.email,

                      'estado',OLD.estado));

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_clientes_360` AS SELECT
 1 AS `id_cliente`,
  1 AS `cliente`,
  1 AS `cedula`,
  1 AS `correo`,
  1 AS `num_telefono`,
  1 AS `fecha_registro`,
  1 AS `estado_cliente`,
  1 AS `segmento`,
  1 AS `servicios_activos`,
  1 AS `tickets_abiertos`,
  1 AS `facturas_vencidas`,
  1 AS `ultima_actividad` */;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_equipos_asignados` AS SELECT
 1 AS `id_equipo`,
  1 AS `tipo`,
  1 AS `marca`,
  1 AS `modelo`,
  1 AS `direccion_mac`,
  1 AS `num_puerto_nap`,
  1 AS `estado_fisico`,
  1 AS `estado_inventario`,
  1 AS `propiedad`,
  1 AS `nap_codigo`,
  1 AS `olt_codigo`,
  1 AS `nodo_nombre`,
  1 AS `id_servicio`,
  1 AS `servicio_alias`,
  1 AS `direccion_texto`,
  1 AS `id_cliente`,
  1 AS `cliente` */;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_estado_cuenta_cliente` AS SELECT
 1 AS `id_cliente`,
  1 AS `cliente`,
  1 AS `cedula`,
  1 AS `correo`,
  1 AS `num_telefono`,
  1 AS `saldo_pendiente`,
  1 AS `facturas_vencidas`,
  1 AS `facturas_pagadas`,
  1 AS `ultima_fecha_vencimiento` */;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_facturas_con_saldo` AS SELECT
 1 AS `id_factura`,
  1 AS `id_servicio`,
  1 AS `periodo`,
  1 AS `monto`,
  1 AS `fecha_emision`,
  1 AS `fecha_vencimiento`,
  1 AS `estado`,
  1 AS `total_pagado`,
  1 AS `saldo`,
  1 AS `servicio_alias`,
  1 AS `id_cliente`,
  1 AS `cliente`,
  1 AS `cedula` */;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_ip_asignadas` AS SELECT
 1 AS `id_asignacion`,
  1 AS `ip`,
  1 AS `tipo`,
  1 AS `estado`,
  1 AS `asignada_en`,
  1 AS `liberada_en`,
  1 AS `pool_nombre`,
  1 AS `pool_cidr`,
  1 AS `vlan`,
  1 AS `id_servicio`,
  1 AS `servicio_alias`,
  1 AS `id_cliente`,
  1 AS `cliente` */;
SET character_set_client = @saved_cs_client;
/*!50001 DROP VIEW IF EXISTS `v_clientes_360`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY INVOKER */
/*!50001 VIEW `v_clientes_360` AS select `c`.`id_cliente` AS `id_cliente`,concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente`,`c`.`cedula` AS `cedula`,`c`.`correo` AS `correo`,`c`.`num_telefono` AS `num_telefono`,`c`.`fecha_registro` AS `fecha_registro`,`c`.`estado` AS `estado_cliente`,`c`.`segmento` AS `segmento`,(select count(0) from `servicios` `s` where `s`.`id_cliente` = `c`.`id_cliente` and `s`.`estado_comercial` <> 'retirado') AS `servicios_activos`,(select count(0) from `tickets` `t` where `t`.`id_cliente` = `c`.`id_cliente` and `t`.`estado` <> 'Cerrado') AS `tickets_abiertos`,(select count(0) from (`facturas` `f` join `servicios` `s2` on(`s2`.`id_servicio` = `f`.`id_servicio`)) where `s2`.`id_cliente` = `c`.`id_cliente` and `f`.`estado` = 'vencida') AS `facturas_vencidas`,(select max(`cc`.`ultimo_acceso`) from `clientes_credenciales` `cc` where `cc`.`id_cliente` = `c`.`id_cliente`) AS `ultima_actividad` from `clientes` `c` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_equipos_asignados`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY INVOKER */
/*!50001 VIEW `v_equipos_asignados` AS select `eq`.`id_equipo` AS `id_equipo`,`eq`.`tipo` AS `tipo`,`eq`.`marca` AS `marca`,`eq`.`modelo` AS `modelo`,`eq`.`direccion_mac` AS `direccion_mac`,`eq`.`num_puerto_nap` AS `num_puerto_nap`,`eq`.`estado_fisico` AS `estado_fisico`,`eq`.`estado_inventario` AS `estado_inventario`,`eq`.`propiedad` AS `propiedad`,`na`.`codigo` AS `nap_codigo`,`o`.`codigo` AS `olt_codigo`,`n`.`nombre` AS `nodo_nombre`,`s`.`id_servicio` AS `id_servicio`,`s`.`alias` AS `servicio_alias`,`s`.`direccion_texto` AS `direccion_texto`,`c`.`id_cliente` AS `id_cliente`,concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente` from (((((`equipos` `eq` join `naps` `na` on(`na`.`id_nap` = `eq`.`id_naps`)) left join `olts` `o` on(`o`.`id_olt` = `na`.`id_olts`)) left join `nodos` `n` on(`n`.`id_nodo` = `o`.`id_nodos`)) left join `servicios` `s` on(`s`.`id_servicio` = `eq`.`id_servicio`)) left join `clientes` `c` on(`c`.`id_cliente` = `s`.`id_cliente`)) where `eq`.`estado_inventario` = 'asignado' and `eq`.`id_servicio` is not null */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_estado_cuenta_cliente`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY INVOKER */
/*!50001 VIEW `v_estado_cuenta_cliente` AS select `c`.`id_cliente` AS `id_cliente`,concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente`,`c`.`cedula` AS `cedula`,`c`.`correo` AS `correo`,`c`.`num_telefono` AS `num_telefono`,coalesce(sum(case when `f`.`estado` in ('pendiente','parcial','vencida') then `f`.`monto` else 0 end),0) AS `saldo_pendiente`,count(distinct case when `f`.`estado` = 'vencida' then `f`.`id_factura` end) AS `facturas_vencidas`,count(distinct case when `f`.`estado` = 'pagada' then `f`.`id_factura` end) AS `facturas_pagadas`,max(`f`.`fecha_vencimiento`) AS `ultima_fecha_vencimiento` from ((`clientes` `c` left join `servicios` `s` on(`s`.`id_cliente` = `c`.`id_cliente`)) left join `facturas` `f` on(`f`.`id_servicio` = `s`.`id_servicio`)) group by `c`.`id_cliente`,`c`.`nombres`,`c`.`apellidos`,`c`.`cedula`,`c`.`correo`,`c`.`num_telefono` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_facturas_con_saldo`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY INVOKER */
/*!50001 VIEW `v_facturas_con_saldo` AS select `f`.`id_factura` AS `id_factura`,`f`.`id_servicio` AS `id_servicio`,`f`.`periodo` AS `periodo`,`f`.`monto` AS `monto`,`f`.`fecha_emision` AS `fecha_emision`,`f`.`fecha_vencimiento` AS `fecha_vencimiento`,`f`.`estado` AS `estado`,coalesce((select sum(`pagos`.`monto`) from `pagos` where `pagos`.`id_factura` = `f`.`id_factura` and `pagos`.`estado` = 'validado'),0) AS `total_pagado`,greatest(`f`.`monto` - coalesce((select sum(`pagos`.`monto`) from `pagos` where `pagos`.`id_factura` = `f`.`id_factura` and `pagos`.`estado` = 'validado'),0),0) AS `saldo`,`s`.`alias` AS `servicio_alias`,`c`.`id_cliente` AS `id_cliente`,concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente`,`c`.`cedula` AS `cedula` from ((`facturas` `f` join `servicios` `s` on(`s`.`id_servicio` = `f`.`id_servicio`)) join `clientes` `c` on(`c`.`id_cliente` = `s`.`id_cliente`)) where `f`.`estado` in ('pendiente','parcial','vencida') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_ip_asignadas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY INVOKER */
/*!50001 VIEW `v_ip_asignadas` AS select `ia`.`id_asignacion` AS `id_asignacion`,`ia`.`ip` AS `ip`,`ia`.`tipo` AS `tipo`,`ia`.`estado` AS `estado`,`ia`.`asignada_en` AS `asignada_en`,`ia`.`liberada_en` AS `liberada_en`,`ip`.`nombre` AS `pool_nombre`,`ip`.`cidr` AS `pool_cidr`,`ip`.`vlan` AS `vlan`,`s`.`id_servicio` AS `id_servicio`,`s`.`alias` AS `servicio_alias`,`c`.`id_cliente` AS `id_cliente`,concat(`c`.`nombres`,' ',`c`.`apellidos`) AS `cliente` from (((`ip_asignaciones` `ia` join `ip_pools` `ip` on(`ip`.`id_pool` = `ia`.`id_pool`)) join `servicios` `s` on(`s`.`id_servicio` = `ia`.`id_servicio`)) join `clientes` `c` on(`c`.`id_cliente` = `s`.`id_cliente`)) where `ia`.`estado` = 'activa' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

