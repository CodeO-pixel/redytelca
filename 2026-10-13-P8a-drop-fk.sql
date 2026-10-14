-- =================================================================
-- P8a — Refactor BD-COMPLETA: DROP de las 78 FK
-- Fecha: 2026-10-13
-- Autorizado por: docs/ADR/013-bd-completa-refactor.md
-- Backup previo OBLIGATORIO: C:\backups\bd_redytelca_20261012_pre-refactor.sql
-- Siguiente paso: P8b (collation), P8c (ADD FK). NO PARAR entre P8a y P8c.
-- =================================================================

ALTER TABLE clientes_credenciales DROP FOREIGN KEY fk_credencial_cliente;
ALTER TABLE cliente_contactos DROP FOREIGN KEY fk_contacto_cliente;
ALTER TABLE cliente_etiquetas DROP FOREIGN KEY fk_ce_cliente;
ALTER TABLE cliente_etiquetas DROP FOREIGN KEY fk_ce_etiqueta;
ALTER TABLE cliente_notas DROP FOREIGN KEY fk_nota_cliente;
ALTER TABLE cliente_notas DROP FOREIGN KEY fk_nota_usuario;
ALTER TABLE contratos DROP FOREIGN KEY fk_contrato_servicio;
ALTER TABLE email_log DROP FOREIGN KEY fk_email_cliente;
ALTER TABLE email_log DROP FOREIGN KEY fk_email_plantilla;
ALTER TABLE email_log DROP FOREIGN KEY fk_email_usuario;
ALTER TABLE equipos DROP FOREIGN KEY fk_equipo_nap;
ALTER TABLE equipos DROP FOREIGN KEY fk_equipo_srv;
ALTER TABLE equipo_movimientos DROP FOREIGN KEY fk_mov_equipo;
ALTER TABLE equipo_movimientos DROP FOREIGN KEY fk_mov_servicio;
ALTER TABLE equipo_movimientos DROP FOREIGN KEY fk_mov_usuario;
ALTER TABLE facturas DROP FOREIGN KEY fk_factura_servicio;
ALTER TABLE factura_lineas DROP FOREIGN KEY fk_linea_factura;
ALTER TABLE factura_lineas DROP FOREIGN KEY fk_linea_servicio;
ALTER TABLE ip_asignaciones DROP FOREIGN KEY fk_ip_asig_pool;
ALTER TABLE ip_asignaciones DROP FOREIGN KEY fk_ip_asig_servicio;
ALTER TABLE ip_pools DROP FOREIGN KEY fk_ip_pool_nodo;
ALTER TABLE logs DROP FOREIGN KEY fk_log_credencial;
ALTER TABLE logs DROP FOREIGN KEY fk_log_usuario;
ALTER TABLE naps DROP FOREIGN KEY fk_nap_olt;
ALTER TABLE notas_credito DROP FOREIGN KEY fk_nc_cliente;
ALTER TABLE notas_credito DROP FOREIGN KEY fk_nc_emisor;
ALTER TABLE notas_credito DROP FOREIGN KEY fk_nc_factura;
ALTER TABLE notas_debito DROP FOREIGN KEY fk_nd_cliente;
ALTER TABLE notas_debito DROP FOREIGN KEY fk_nd_emisor;
ALTER TABLE notas_debito DROP FOREIGN KEY fk_nd_factura;
ALTER TABLE notificaciones DROP FOREIGN KEY fk_notif_cliente;
ALTER TABLE notificaciones DROP FOREIGN KEY fk_notif_usuario;
ALTER TABLE notificaciones_staff DROP FOREIGN KEY fk_notif_staff_usuario;
ALTER TABLE olts DROP FOREIGN KEY fk_olt_nodo;
ALTER TABLE paginas DROP FOREIGN KEY fk_pagina_modulo;
ALTER TABLE pagos DROP FOREIGN KEY fk_pago_cliente;
ALTER TABLE pagos DROP FOREIGN KEY fk_pago_factura;
ALTER TABLE pagos DROP FOREIGN KEY fk_pago_servicio;
ALTER TABLE pagos DROP FOREIGN KEY fk_pago_usuario;
ALTER TABLE pedidos DROP FOREIGN KEY fk_pedido_cliente;
ALTER TABLE pedidos DROP FOREIGN KEY fk_pedido_creador;
ALTER TABLE pedidos DROP FOREIGN KEY fk_pedido_servicio;
ALTER TABLE pedidos DROP FOREIGN KEY fk_pedido_tecnico;
ALTER TABLE pedido_asignaciones DROP FOREIGN KEY fk_asig_asignador;
ALTER TABLE pedido_asignaciones DROP FOREIGN KEY fk_asig_pedido;
ALTER TABLE pedido_asignaciones DROP FOREIGN KEY fk_asig_tecnico;
ALTER TABLE pedido_materiales DROP FOREIGN KEY fk_material_equipo;
ALTER TABLE pedido_materiales DROP FOREIGN KEY fk_material_pedido;
ALTER TABLE plan_historial_precios DROP FOREIGN KEY fk_hist_precio_plan;
ALTER TABLE plan_historial_precios DROP FOREIGN KEY fk_hist_precio_usuario;
ALTER TABLE rol_modulo DROP FOREIGN KEY fk_rm_modulo;
ALTER TABLE rol_modulo DROP FOREIGN KEY fk_rm_rol;
ALTER TABLE rol_modulo_pagina DROP FOREIGN KEY fk_rmpag_pagina;
ALTER TABLE rol_modulo_pagina DROP FOREIGN KEY fk_rmpag_rolmodulo;
ALTER TABLE rol_modulo_permiso DROP FOREIGN KEY fk_rmp_pagina;
ALTER TABLE rol_modulo_permiso DROP FOREIGN KEY fk_rmp_pagina_modulo;
ALTER TABLE rol_modulo_permiso DROP FOREIGN KEY fk_rmp_permiso;
ALTER TABLE rol_modulo_permiso DROP FOREIGN KEY fk_rmp_rolmodulo;
ALTER TABLE rol_modulo_permiso DROP FOREIGN KEY fk_rmp_rolmodulo_modulo;
ALTER TABLE servicios DROP FOREIGN KEY fk_srv_cliente;
ALTER TABLE servicios DROP FOREIGN KEY fk_srv_nap;
ALTER TABLE servicios DROP FOREIGN KEY fk_srv_plan;
ALTER TABLE sesiones DROP FOREIGN KEY fk_sesion_credencial;
ALTER TABLE sesiones DROP FOREIGN KEY fk_sesion_usuario;
ALTER TABLE sla_definiciones DROP FOREIGN KEY fk_sla_categoria;
ALTER TABLE tareas DROP FOREIGN KEY fk_tarea_cliente;
ALTER TABLE tareas DROP FOREIGN KEY fk_tarea_servicio;
ALTER TABLE tareas DROP FOREIGN KEY fk_tarea_ticket;
ALTER TABLE tareas DROP FOREIGN KEY fk_tarea_usuario;
ALTER TABLE tickets DROP FOREIGN KEY fk_ticket_categoria;
ALTER TABLE tickets DROP FOREIGN KEY fk_ticket_cliente;
ALTER TABLE tickets DROP FOREIGN KEY fk_ticket_servicio;
ALTER TABLE tickets DROP FOREIGN KEY fk_ticket_usuario;
ALTER TABLE ticket_respuestas DROP FOREIGN KEY fk_respuesta_credencial;
ALTER TABLE ticket_respuestas DROP FOREIGN KEY fk_respuesta_ticket;
ALTER TABLE ticket_respuestas DROP FOREIGN KEY fk_respuesta_usuario;
ALTER TABLE usuario_rol DROP FOREIGN KEY fk_ur_rol;
ALTER TABLE usuario_rol DROP FOREIGN KEY fk_ur_usuario;

-- =================================================================
-- Fin P8a. Continúa con P8b inmediatamente.
-- =================================================================