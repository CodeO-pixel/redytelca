-- =================================================================
-- P4 — Refactor BD-COMPLETA: triggers de auditoría
-- Fecha: 2026-10-13
-- Autorizado por: docs/ADR/013-bd-completa-refactor.md
-- Backup previo: C:\backups\bd_redytelca_20261012_pre-refactor.sql
-- Rollback: DROP TRIGGER de los 40 triggers.
-- =================================================================

-- ============================================================
-- 1. notificaciones_staff
-- ============================================================
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

-- ============================================================
-- 2. pedidos
-- ============================================================
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

-- ============================================================
-- 3. pedido_materiales
-- ============================================================
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

-- ============================================================
-- 4. pedido_asignaciones
-- ============================================================
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

-- ============================================================
-- 5. equipo_movimientos
-- ============================================================
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

-- ============================================================
-- 6. notas_credito
-- ============================================================
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

-- ============================================================
-- 7. notas_debito
-- ============================================================
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

-- ============================================================
-- 8. cliente_etiquetas
-- ============================================================
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

DELIMITER $$
CREATE TRIGGER `trg_cliente_etiquetas_audit_delete` AFTER DELETE ON `cliente_etiquetas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','cliente_etiquetas',OLD.id_cliente_etiqueta,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_cliente_etiqueta',OLD.id_cliente_etiqueta,'id_cliente',OLD.id_cliente,'id_etiqueta',OLD.id_etiqueta));
END
$$
DELIMITER ;

-- ============================================================
-- 9. categorias_ticket
-- ============================================================
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

DELIMITER $$
CREATE TRIGGER `trg_categorias_ticket_audit_delete` AFTER DELETE ON `categorias_ticket` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','categorias_ticket',OLD.id_categoria,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_categoria',OLD.id_categoria,'nombre',OLD.nombre,'activa',OLD.activa));
END
$$
DELIMITER ;

-- ============================================================
-- 10. sla_definiciones
-- ============================================================
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

-- ============================================================
-- 11. metodos_pago
-- ============================================================
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

DELIMITER $$
CREATE TRIGGER `trg_metodos_pago_audit_delete` AFTER DELETE ON `metodos_pago` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','metodos_pago',OLD.id_metodo,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_metodo',OLD.id_metodo,'codigo',OLD.codigo,'nombre',OLD.nombre,'activo',OLD.activo));
END
$$
DELIMITER ;

-- ============================================================
-- 12. cliente_notas
-- ============================================================
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

DELIMITER $$
CREATE TRIGGER `trg_cliente_notas_audit_delete` AFTER DELETE ON `cliente_notas` FOR EACH ROW BEGIN
  INSERT INTO logs (accion, tabla_afectada, id_registro_afectado, tipo_actor, id_usuario, id_credencial, old_value)
  VALUES ('DELETE','cliente_notas',OLD.id_nota,
          COALESCE(@app_tipo_actor,'sistema'), COALESCE(@app_usuario_id,NULL), COALESCE(@app_credencial_id,NULL),
          JSON_OBJECT('id_nota',OLD.id_nota,'id_cliente',OLD.id_cliente,'id_usuario',OLD.id_usuario));
END
$$
DELIMITER ;

-- ============================================================
-- 13. cliente_contactos
-- ============================================================
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

-- ============================================================
-- 14. plan_historial_precios (solo INSERT)
-- ============================================================
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

-- =================================================================
-- Fin P4.
-- =================================================================