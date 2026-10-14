-- =================================================================
-- P8c — Refactor BD-COMPLETA: recrear las 78 FK
-- Fecha: 2026-10-13
-- Requiere: P8a + P8b ejecutados.
-- Todas las FK van con ON UPDATE RESTRICT explícito (ADR 013 §P3).
-- ON DELETE preserva el original de cada FK.
-- =================================================================

ALTER TABLE clientes_credenciales ADD CONSTRAINT fk_credencial_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE cliente_contactos ADD CONSTRAINT fk_contacto_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE cliente_etiquetas ADD CONSTRAINT fk_ce_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE cliente_etiquetas ADD CONSTRAINT fk_ce_etiqueta FOREIGN KEY (id_etiqueta) REFERENCES etiquetas (id_etiqueta) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE cliente_notas ADD CONSTRAINT fk_nota_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE cliente_notas ADD CONSTRAINT fk_nota_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE contratos ADD CONSTRAINT fk_contrato_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE email_log ADD CONSTRAINT fk_email_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE email_log ADD CONSTRAINT fk_email_plantilla FOREIGN KEY (id_plantilla) REFERENCES email_plantillas (id_plantilla) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE email_log ADD CONSTRAINT fk_email_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE equipos ADD CONSTRAINT fk_equipo_nap FOREIGN KEY (id_naps) REFERENCES naps (id_nap) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE equipos ADD CONSTRAINT fk_equipo_srv FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE equipo_movimientos ADD CONSTRAINT fk_mov_equipo FOREIGN KEY (id_equipo) REFERENCES equipos (id_equipo) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE equipo_movimientos ADD CONSTRAINT fk_mov_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE equipo_movimientos ADD CONSTRAINT fk_mov_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE facturas ADD CONSTRAINT fk_factura_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE factura_lineas ADD CONSTRAINT fk_linea_factura FOREIGN KEY (id_factura) REFERENCES facturas (id_factura) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE factura_lineas ADD CONSTRAINT fk_linea_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE ip_asignaciones ADD CONSTRAINT fk_ip_asig_pool FOREIGN KEY (id_pool) REFERENCES ip_pools (id_pool) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE ip_asignaciones ADD CONSTRAINT fk_ip_asig_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE ip_pools ADD CONSTRAINT fk_ip_pool_nodo FOREIGN KEY (id_nodo) REFERENCES nodos (id_nodo) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE logs ADD CONSTRAINT fk_log_credencial FOREIGN KEY (id_credencial) REFERENCES clientes_credenciales (id_credencial) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE logs ADD CONSTRAINT fk_log_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE naps ADD CONSTRAINT fk_nap_olt FOREIGN KEY (id_olts) REFERENCES olts (id_olt) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE notas_credito ADD CONSTRAINT fk_nc_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE notas_credito ADD CONSTRAINT fk_nc_emisor FOREIGN KEY (id_usuario_emisor) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE notas_credito ADD CONSTRAINT fk_nc_factura FOREIGN KEY (id_factura) REFERENCES facturas (id_factura) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE notas_debito ADD CONSTRAINT fk_nd_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE notas_debito ADD CONSTRAINT fk_nd_emisor FOREIGN KEY (id_usuario_emisor) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE notas_debito ADD CONSTRAINT fk_nd_factura FOREIGN KEY (id_factura) REFERENCES facturas (id_factura) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE notificaciones ADD CONSTRAINT fk_notif_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE notificaciones ADD CONSTRAINT fk_notif_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE notificaciones_staff ADD CONSTRAINT fk_notif_staff_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE olts ADD CONSTRAINT fk_olt_nodo FOREIGN KEY (id_nodos) REFERENCES nodos (id_nodo) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE paginas ADD CONSTRAINT fk_pagina_modulo FOREIGN KEY (id_modulo) REFERENCES modulos (id_modulo) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE pagos ADD CONSTRAINT fk_pago_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE pagos ADD CONSTRAINT fk_pago_factura FOREIGN KEY (id_factura) REFERENCES facturas (id_factura) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE pagos ADD CONSTRAINT fk_pago_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE pagos ADD CONSTRAINT fk_pago_usuario FOREIGN KEY (id_usuario_valido) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE pedidos ADD CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE pedidos ADD CONSTRAINT fk_pedido_creador FOREIGN KEY (id_usuario_creador) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE pedidos ADD CONSTRAINT fk_pedido_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE pedidos ADD CONSTRAINT fk_pedido_tecnico FOREIGN KEY (id_tecnico_asignado) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE pedido_asignaciones ADD CONSTRAINT fk_asig_asignador FOREIGN KEY (id_usuario_asignador) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE pedido_asignaciones ADD CONSTRAINT fk_asig_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE pedido_asignaciones ADD CONSTRAINT fk_asig_tecnico FOREIGN KEY (id_tecnico) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE pedido_materiales ADD CONSTRAINT fk_material_equipo FOREIGN KEY (id_equipo) REFERENCES equipos (id_equipo) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE pedido_materiales ADD CONSTRAINT fk_material_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE plan_historial_precios ADD CONSTRAINT fk_hist_precio_plan FOREIGN KEY (id_plan) REFERENCES planes (id_plan) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE plan_historial_precios ADD CONSTRAINT fk_hist_precio_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE rol_modulo ADD CONSTRAINT fk_rm_modulo FOREIGN KEY (id_modulo) REFERENCES modulos (id_modulo) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE rol_modulo ADD CONSTRAINT fk_rm_rol FOREIGN KEY (id_rol) REFERENCES rol (id_rol) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE rol_modulo_pagina ADD CONSTRAINT fk_rmpag_pagina FOREIGN KEY (id_pagina) REFERENCES paginas (id_pagina) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE rol_modulo_pagina ADD CONSTRAINT fk_rmpag_rolmodulo FOREIGN KEY (id_rol_modulo) REFERENCES rol_modulo (id_rol_modulo) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE rol_modulo_permiso ADD CONSTRAINT fk_rmp_pagina FOREIGN KEY (id_pagina) REFERENCES paginas (id_pagina) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE rol_modulo_permiso ADD CONSTRAINT fk_rmp_pagina_modulo FOREIGN KEY (id_pagina,id_modulo) REFERENCES paginas (id_pagina,id_modulo) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE rol_modulo_permiso ADD CONSTRAINT fk_rmp_permiso FOREIGN KEY (id_permiso) REFERENCES permisos (id_permiso) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE rol_modulo_permiso ADD CONSTRAINT fk_rmp_rolmodulo FOREIGN KEY (id_rol_modulo) REFERENCES rol_modulo (id_rol_modulo) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE rol_modulo_permiso ADD CONSTRAINT fk_rmp_rolmodulo_modulo FOREIGN KEY (id_rol_modulo,id_modulo) REFERENCES rol_modulo (id_rol_modulo,id_modulo) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE servicios ADD CONSTRAINT fk_srv_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE servicios ADD CONSTRAINT fk_srv_nap FOREIGN KEY (id_naps) REFERENCES naps (id_nap) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE servicios ADD CONSTRAINT fk_srv_plan FOREIGN KEY (id_plan) REFERENCES planes (id_plan) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE sesiones ADD CONSTRAINT fk_sesion_credencial FOREIGN KEY (id_credencial) REFERENCES clientes_credenciales (id_credencial) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE sesiones ADD CONSTRAINT fk_sesion_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE sla_definiciones ADD CONSTRAINT fk_sla_categoria FOREIGN KEY (id_categoria) REFERENCES categorias_ticket (id_categoria) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE tareas ADD CONSTRAINT fk_tarea_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE tareas ADD CONSTRAINT fk_tarea_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE tareas ADD CONSTRAINT fk_tarea_ticket FOREIGN KEY (id_ticket) REFERENCES tickets (id_ticket) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE tareas ADD CONSTRAINT fk_tarea_usuario FOREIGN KEY (id_usuario_creador) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE tickets ADD CONSTRAINT fk_ticket_categoria FOREIGN KEY (id_categoria) REFERENCES categorias_ticket (id_categoria) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE tickets ADD CONSTRAINT fk_ticket_cliente FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE tickets ADD CONSTRAINT fk_ticket_servicio FOREIGN KEY (id_servicio) REFERENCES servicios (id_servicio) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE tickets ADD CONSTRAINT fk_ticket_usuario FOREIGN KEY (id_usuario_creador) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE ticket_respuestas ADD CONSTRAINT fk_respuesta_credencial FOREIGN KEY (id_credencial) REFERENCES clientes_credenciales (id_credencial) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE ticket_respuestas ADD CONSTRAINT fk_respuesta_ticket FOREIGN KEY (id_ticket) REFERENCES tickets (id_ticket) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE ticket_respuestas ADD CONSTRAINT fk_respuesta_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE usuario_rol ADD CONSTRAINT fk_ur_rol FOREIGN KEY (id_rol) REFERENCES rol (id_rol) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE usuario_rol ADD CONSTRAINT fk_ur_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario) ON DELETE CASCADE ON UPDATE RESTRICT;

-- =================================================================
-- Fin P8c. Refactor completo.
-- =================================================================