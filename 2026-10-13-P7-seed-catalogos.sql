-- =================================================================
-- P7 — Refactor BD-COMPLETA: seed de catálogos
-- Fecha: 2026-10-13
-- Autorizado por: docs/ADR/013-bd-completa-refactor.md
-- Backup previo: C:\backups\bd_redytelca_20261012_pre-refactor.sql
-- Rollback: DELETE de los catálogos por código/nombre.
-- =================================================================

-- 1. categorias_ticket (4 filas)
INSERT INTO categorias_ticket (nombre, descripcion, color) VALUES
('Soporte técnico', 'Problemas de conectividad, velocidad o hardware', '#104aa8'),
('Facturación', 'Consultas y reclamos de facturación o pagos', '#f59e0b'),
('Instalación', 'Solicitudes de nueva instalación o traslado', '#16a34a'),
('Baja de servicio', 'Solicitudes de cancelación o suspensión', '#dc2626');

-- 2. sla_definiciones (3 filas)
INSERT INTO sla_definiciones (id_categoria, prioridad, horas_respuesta, horas_resolucion, descripcion) VALUES
(1, 'Alta', 1, 4, 'SLA de soporte técnico — prioridad alta'),
(1, 'Media', 4, 24, 'SLA de soporte técnico — prioridad media'),
(2, 'Alta', 2, 8, 'SLA de facturación — prioridad alta');

-- 3. metodos_pago (4 filas)
INSERT INTO metodos_pago (codigo, nombre, requiere_referencia, activo, orden) VALUES
('transferencia', 'Transferencia bancaria', 1, 1, 1),
('pago_movil', 'Pago móvil', 1, 1, 2),
('zelle', 'Zelle', 1, 1, 3),
('efectivo', 'Efectivo', 0, 1, 4);

-- 4. etiquetas (5 filas)
INSERT INTO etiquetas (nombre, color) VALUES
('VIP', '#f59e0b'),
('Moroso', '#dc2626'),
('Nuevo', '#16a34a'),
('Empresarial', '#104aa8'),
('Residencial', '#64748b');

-- 5. email_plantillas (6 filas)
INSERT INTO email_plantillas (codigo, asunto, cuerpo, descripcion) VALUES
('bienvenida', 'Bienvenido a REDYTELCA', 'Estimado cliente,\n\nGracias por confiar en nosotros.\n\nSaludos,\nREDYTELCA', 'Email de bienvenida al dar de alta un cliente'),
('factura_emitida', 'Nueva factura disponible', 'Estimado cliente,\n\nSu factura del periodo {periodo} ha sido emitida.\n\nSaldo: {monto}\nVencimiento: {vencimiento}', 'Notificación de nueva factura'),
('factura_vencida', 'Factura vencida', 'Estimado cliente,\n\nSu factura del periodo {periodo} está vencida.\n\nRegularice su pago para evitar la suspensión.', 'Recordatorio de factura vencida'),
('pago_confirmado', 'Pago confirmado', 'Estimado cliente,\n\nSu pago de {monto} ha sido validado correctamente.', 'Confirmación de pago validado'),
('ticket_cerrado', 'Ticket cerrado', 'Su ticket "{asunto}" ha sido cerrado.\n\nDetalle: {detalle}', 'Cierre de ticket'),
('recuperar_password', 'Recuperar contraseña', 'Use el siguiente enlace para recuperar su contraseña: {link}', 'Recuperación de contraseña');

-- =================================================================
-- Fin P7.
-- =================================================================