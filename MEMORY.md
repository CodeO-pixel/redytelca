# MEMORY.md — REDYTELCA

Estado operativo entre sesiones. **Único documento de estado del proyecto.**

- Qué spec existe y en qué estado → `docs/ROADMAP.md`.
- Hallazgos canónicos → `docs/AUDITORIA_2026.md`.
- Cómo está construido → `docs/ARQUITECTURA.md`.
- Esquema → `bd_redytelca.sql`.
- Estándares, frases de defensa, industria descartada → `docs/REFERENCIA.md`.
- Reglas del ecosistema documental → `docs/GOBERNANZA.md`.

---

## Estado actual

- Fases 0, 1, 2.5, 3, 7: completas.
- **Migración 001a (RBAC Core N:M):** aplicada y verificada.
- **Spec 019 (auditoría logs):** cerrada.
- **Grupo E (Config Admin-only, Diseño B.3):** cerrado en UI y en backend.
- **Bloque 17 (RBAC dos niveles):** cerrado.
- **Bloque 18 (RBAC-02: SoD Configuración en backend):** cerrado.
- **Grupo C (RBAC nivel 2 en endpoints CRUD):** cerrado. 11/11 endpoints, 44 gates.
- **Rediseño del módulo Servicios:** cerrado. Página `servicios` como entrada propia del sidebar. Página `registro` (duplicado) eliminada. Modal compartido entre ficha de cliente y módulo global.
- **Grupo F (api_facturas + api_contratos):** cerrado. B08 (UPDATE fuera del GET → POST dedicados), B10 parcial (mensajes genéricos en los 3 endpoints), B12 (UNIQUE `(id_servicio, periodo)` capturado).
- **Revisión de coherencia cruzada (2026-10-11):** 5 hallazgos operativos detectados (CODE-01, CODE-02, RBAC-03, DB-01, DOC-03). Todos resueltos en la misma sesión.
- **Consolidación documental (2026-10-12):** creado `docs/REFERENCIA.md`. `ARQUITECTURA.md`, `BD.md` y `AUDITORIA_2026.md` recortados a su rol único. `GOBERNANZA.md` y `METODOLOGIA_DESARROLLO_IA.md` sin duplicación. `ROADMAP.md` con conteo cuadrado. `INFORME DE CONTINUIDAD` eliminado como documento vivo.
- **Spec 021 (put-idempotencia + absorbidos):** cerrada el 2026-10-12. Absorbe B06 (idempotencia PUT en 5 endpoints), CODE-03 a CODE-09 (7 hallazgos operativos de validación/consistencia entre métodos) y DOC-03 + UI-01 + UI-02 (frontend). 9 archivos modificados (6 backend + 3 frontend). Verificada end-to-end con curl y navegador.
- **Spec 024 (proteger-api-empresa + branding público):** cerrada el 2026-10-12. Cierra B09. Introduce endpoint público `api_empresa_publica.php` + protege el GET de `api_empresa.php` con `requirePageAccess('empresa')`. Crea `branding.css.php` (stylesheet render-blocking con `--accent` desde BD) para eliminar el FOUC del branding pre-login. ADR 009 (branding público separado). 3 archivos nuevos, 2 backend modificados, 2 frontend modificados, 1 ADR nuevo.

**Score global post-reauditoría:** ver `docs/AUDITORIA_2026.md`. Fecha de corte: 2026-10-11.

- **P13 (facturas y pagos multi-moneda Opción B):** cerrado el 2026-10-13. Semántica alineada con industria ISP venezolana (SENIAT/CANTV/Netuno): `monto` siempre en USD, `moneda`/`moneda_pago` indica divisa de presentación, `tasa_cambio` convierte a Bs. si VES. 4 archivos modificados (`api_facturas.php`, `api_pagos.php`, `app.js`, `index.html`) + 2 SQL (P13, P13b). Verificado end-to-end: factura VES con tasa muestra `Bs. monto×tasa` + `(USD monto)`; pago VES idem; rechazo VES sin tasa funciona.
- **P1-P15 aplicados (2026-10-13).** SQL + código + triggers + vistas completos. Verificado contra dump 23:45.
- **P15 (pagos-metodo-fk):** aplicado el 2026-10-13. `pagos.metodo_pago` ENUM → FK a `metodos_pago`. Incluye PASO 6 que repone `v_facturas_con_saldo` con `GREATEST(...,0)` (cierra DB-15).
- **Hotfix instalación limpia (2026-10-14):** Compose usa `bd_redytelca_schema.sql` + `bd_redytelca_seed.sql`; `conexion.php` lee `DB_*`; `crear_admin_inicial.php` crea el primer admin solo por CLI, sin contraseña predeterminada. Importación real pendiente: Docker Desktop no estaba activo durante la validación.
- **Seguridad login portal (2026-10-14):** `portal_api.php` rechaza cédulas malformadas/ambiguas, exige credencial provisionada y verifica `password_verify()` antes de crear sesión. El aprovisionamiento staff envía contraseña temporal aleatoria por SMTP, conserva solo el hash y fuerza cambio antes de liberar datos; la API no devuelve la clave. Verificado por HTTP el bloqueo de resumen y su liberación tras cambiarla en `redytelca_clean_20261014`. Entrega real pendiente: XAMPP no tiene `vendor/autoload.php` ni variables SMTP.
- **Cambio obligatorio de contraseña staff (2026-10-14):** `requireStaffAuth()` admite una excepción opt-in solo para `cambiar_password.php`; mientras `must_change_password=1`, el endpoint prohíbe resetear credenciales de terceros y exige la contraseña actual para el auto-cambio. Validado por HTTP: login autorizado, perfil 403, reset de tercero 403, auto-cambio 200 y perfil 200 después. Clave y flag del Admin de prueba restaurados; harness 9/9.
- **Creación y fortaleza de credenciales staff (2026-10-14):** retirada la contraseña global `Redytelca123!` y su devolución. El alta genera una clave única, persiste solo el hash, exige cambio inicial y envía invitación TLS/SSL sin exponer el secreto en JSON. Sin Composer/SMTP, la prueba HTTP dio 503 genérico, rollback y cero usuario creado; envío real pendiente. B14 ahora exige 15–128 caracteres en backend; probado por HTTP: 14 rechazados, 15 aceptados.
- **Portal pagos (2026-10-14):** se conectó `portal_cliente.php` con resumen/facturas, métodos P7 y reporte multipart con comprobante privado; el backoffice descarga el comprobante con RBAC. Lint PHP/JS y GET local `/cliente` pasan. Falta validar con MySQL activo el resumen, INSERT, descarga y cliente provisionado.
- **P15 (restaurar-checks-perdidos):** aplicado el 2026-10-13. Repone 6 CHECK constraints (`chk_equipo_mac`, `chk_equipo_puerto`, `chk_log_actor`, `chk_sesiones_un_tipo`, `chk_sesion_revocacion`, `chk_sesiones_discriminador`) que P8b descartó al reconstruir las tablas con `CONVERT TO CHARACTER SET`. Hallazgo operativo DB-14 (falso positivo: los CHECKs siempre existieron en la BD; phpMyAdmin no los exporta).
- **F13 (spec 076, filterBySearch-acentos):** cerrado el 2026-10-13.
- **UI-03:** cerrado el 2026-10-13.
- **UI-04 (nuevo, 2026-10-13):** bug UX. Los triggers de transición disparan `SIGNAL SQLSTATE '45000'` (MySQL error 1644) con mensaje de negocio; los endpoints lo capturan en la rama genérica del `else` y devuelven "Contacta al administrador si persiste". 5 endpoints afectados: `api_facturas.php` PUT, `api_pagos.php` PUT, `api_contratos.php` POST+PUT, `api_servicios.php` POST+PUT. Fix pendiente: añadir rama `elseif ($sqlCode === 1644)` que exponga `$e->errorInfo[2]`.
- **Hueco detectado:** 8 tablas críticas sin triggers de auditoría (`clientes`, `clientes_credenciales`, `equipos`, `tickets`, `tareas`, `configuracion_empresa`, `usuario_rol`, `rol_modulo_permiso`). A cubrir por P16.

---

## Bloque activo

**BLOQUE BD-COMPLETA** — activo desde 2026-10-12.

Refactor consolidado de `bd_redytelca.sql`. Autorizado por ADR 013. Es prerequisito de los Bloques 19–27. Alcance:
- Correcciones a 13 tablas existentes (hallazgos D02, D03, D08, D13, D16, D19, D21).
- 17 tablas nuevas (pedidos, notificaciones_staff, equipo_movimientos, notas crédito/débito, categorías, SLA, contactos, notas, etiquetas, email).
- 13 sets de triggers de auditoría.
- 5 vistas para reportes y estado de cuenta.
- 4 catálogos con seed.

**Siguiente spec tras cerrar BD-COMPLETA:** 096a (portal-cliente-auth), primera sub-spec del Bloque 19.

**Estado real de ejecución al 2026-10-13** (verificado contra el dump generado 2026-10-13 23:45):

*Aplicados:*
- **P1 / P1-bis** — ALTERs a 13 tablas existentes (`clientes`, `pagos`, `nodos`, `olts`, `naps`, `equipos`, `facturas`, `sesiones`, `configuracion_empresa`, `logs`, `tickets`, `notificaciones`, `ip_asignaciones`, `servicios`, `planes`, `contratos`).
- **P2** — 8 tablas nuevas sin FK cross (`categorias_ticket`, `sla_definiciones`, `metodos_pago`, `etiquetas`, `email_plantillas`, `cliente_notas`, `cliente_contactos`, `plan_historial_precios`).
- **P3** — 9 tablas nuevas con FK + `tickets.id_categoria` (`notificaciones_staff`, `pedidos`, `pedido_materiales`, `pedido_asignaciones`, `equipo_movimientos`, `notas_credito`, `notas_debito`, `cliente_etiquetas`, `email_log`).
- **P4** — 40 triggers de auditoría (14 tablas × 3 − excepciones).
- **P5** — Triggers especiales + cambios estructurales (`rol` id=4 eliminado; `equipos.num_puerto_nap` a `smallint(5)`; `factura_lineas.id_servicio` + FK + índice; `servicios.ip_asignada` marcada DEPRECATED).
- **P6** — 5 vistas (`v_estado_cuenta_cliente`, `v_clientes_360`, `v_equipos_asignados`, `v_ip_asignadas`, `v_facturas_con_saldo`).
- **P7** — Seed de catálogos (4 categorías, 3 SLA, 4 métodos, 5 etiquetas, 6 plantillas).
- **P8a/P8b/P8c** — Drop 78 FK → collation `utf8mb4_unicode_ci` → Add 78 FK con `ON UPDATE RESTRICT`.
- **P9** — Fix UTC `sesiones` (`creado_en` a `datetime` + `chk_sesion_expira` re-añadido).
- **P10** — `v_estado_cuenta_cliente` con `GREATEST` + `LEFT JOIN` a subquery de pagos validados.
- **P11** — Limpieza de datos (equipos en stock con servicio → NULL; longitud positiva → negativa).
- **P12** — `chk_equipo_estado_servicio` + triggers SLA (`trg_tickets_sla_insert`, `trg_tickets_sla_update`).
- **P13 / P13b** — `facturas.moneda`/`tasa_cambio` + COMMENTs semánticos. Código en `api_facturas.php`, `api_pagos.php`, `app.js`, `index.html`.
- **P14** — `planes.velocidad_bajada_mbps`/`velocidad_subida_mbps`/`tecnologia`; `DROP COLUMN velocidad`. Código en `api_planes.php`, `app.js`, `index.html`.
- **P14-bis** — `chk_plan_velocidad_bajada` + `chk_plan_velocidad_subida`.
- **P15 (pagos-metodo-fk)** — `pagos.metodo_pago` ENUM → FK a `metodos_pago` + PASO 6 repone `v_facturas_con_saldo` con `GREATEST(...,0)`. Código en `api_pagos.php`, `app.js`.
- **P15 (restaurar-checks-perdidos)** — 6 CHECKs repuestos.

*Pendientes:*
- **P16** — Audit triggers en 8 tablas sin cobertura (`clientes`, `clientes_credenciales`, `equipos`, `tickets`, `tareas`, `configuracion_empresa`, `usuario_rol`, `rol_modulo_permiso`). Próximo paso.
- **P17** — Charset de triggers + limpieza de mojibake en `logs` (ids 1061-1079).
- **P18-P29** — Resto del plan maestro.

---

## Próximos pasos

El orden vigente está en `docs/ROADMAP.md` **§0 — Prioridad para defensa**.

**Conteo (fuente única: `docs/ROADMAP.md` §0):**
- Specs totales: 128.
- Cerradas: 43.
- En progreso: 5 (025, 028, 035, 039, 053).
- Pendientes: 75.
- Diferidas: 5 (065, 066, 067, 096, 098).
- **Activas: 80.**

**Fases de prioridad para defensa:**
- FASE A (crítica): 12 specs.
- BLOQUE 19 (Portal cliente): 6 specs.
- BLOQUE 20 (Notificaciones): 4 specs.
- BLOQUE 21 (Reconexión admin): 4 specs.
- BLOQUE 22 (IPAM): 3 specs.
- BLOQUE 23 (Pedidos): 4 specs.
- BLOQUE 24 (Email): 4 specs.
- BLOQUE 25 (Autoservicio): 3 specs.
- BLOQUE 26 (Backups/monitoreo): 3 specs.
- BLOQUE 27 (Assurance/Billing): 11 specs.
- FASE B (media): 22 specs.
- FASE C (baja): 37 specs post-defensa.

**Decisión de alcance 2026-10-12:** el portal de cliente y las notificaciones son obligatorios para la defensa. Se incorporan como Bloques 19 y 20. Validado contra industria (Splynx, Sonar, SmartOLT, ISP Gestión). Ver `docs/ADR/010`, `011` y `012`.

**Decisión de refactor BD 2026-10-12:** se ejecuta un refactor consolidado de `bd_redytelca.sql` antes de continuar con backend/frontend, para la revisión inminente de BD. Autorizado por `docs/ADR/013`.

---

## Hallazgos operativos

Hallazgos detectados en revisiones puntuales. **No entran a `docs/AUDITORIA_2026.md`** (canónico reservado a auditoría general, ver `docs/GOBERNANZA.md` §1).

**Prefijos de ID operativo:** `RBAC-NN`, `PLAN-NN`, `DOC-NN`, `CODE-NN`, `DB-NN`, `MAP-NN`, `EST-NN`, `UI-NN`, `UX-NN`.

### Abiertos

| ID | Sev | Descripción | Decisión |
|---|---|---|---|
| **F08 reforzado** | Medio | Cachés `window.*Cache` no se limpian al logout. El backend rechaza con 403 pero el frontend muestra datos viejos. | Spec 039 (Bloque 3). |
| **MAP-01** | Medio | La página `mapa` no tiene endpoint propio. Checkboxes de operación huérfanos. | Bloque 13. Modelo de permisos por página. |
| **EST-01** | Medio | Páginas sin CRUD propio (`dash`, `mapa`, `reportes`, `notificaciones`, `password`). | Bloque 13. Modelo de permisos por página. |
| **UX-01** | Bajo | El `<select id="contrato-estado">` del modal "Nuevo contrato" ofrece `vencido` y `rescindido`, pero el backend siempre fuerza `vigente` (correcto por `trg_contratos_validar_insert`). Confunde al usuario: elige vencido y aparece vigente. | Se absorbe en spec 084 (mejoras-tablas) del Bloque 13. Patrón Salesforce/ServiceNow: no ofrecer estado en creación. |
| **UI-04** | Bajo | Mensajes genéricos cuando un trigger de transición dispara SIGNAL 45000 (MySQL error 1644). 5 endpoints afectados: `api_facturas.php` PUT, `api_pagos.php` PUT, `api_contratos.php` POST+PUT, `api_servicios.php` POST+PUT. El usuario ve "Contacta al administrador si persiste" en lugar de "Transición no permitida: anulada → pagada". | Fix pendiente: añadir rama `elseif ($sqlCode === 1644)` que exponga `$e->errorInfo[2]` (mensaje de negocio del SIGNAL, sin PII). |
| **DOC-04** | Media | `ARQUITECTURA.md` y `BD.md` documentan `utf8mb4_general_ci` cuando la BD real es `utf8mb4_unicode_ci`. P8b no documentado. | Actualizar ambos docs. |
| **DOC-05** | Media | `ARQUITECTURA.md` y `BD.md` no listan las 17 tablas nuevas del refactor. | Actualizar ambos docs. |
| **DOC-06** | Media | `MEMORY.md` decía "BD-COMPLETA pendiente de ejecución" cuando P1–P8, P11, P13, P14 ya corrieron. | Resuelto al actualizar este doc. |
| **DOC-07** | Media | `ROADMAP.md` lista 14 specs absorbidas por BD-COMPLETA como `pendiente` cuando ya están aplicadas. | Actualizar `ROADMAP.md`. |
| **DOC-08** | Baja | `ADR 013` dice que `notificaciones_staff` no tendría triggers de auditoría; P4 sí los creó. | Desviación consciente del ADR. Registrar en ADR 013 o en nuevo ADR. |
| **EST-02** | Media | `sla_definiciones` con cobertura parcial: 3 de 8 combinaciones categoría×prioridad (falta categoría 3 Instalación y 4 Baja de servicio). | Seed incompleto. Documentar como deuda. |
| **EST-03** | Baja | `email_plantillas` con cobertura parcial: 6 de ~9 eventos de negocio (falta `ticket_creado`, `pago_pendiente`, `pago_rechazado`). | Seed incompleto. Documentar como deuda. |

### Cerrados

| ID | Sev | Descripción | Resuelto con |
|---|---|---|---|
| **RBAC-01** | Bajo | Plan RBAC 099 desactualizado. | Corregido en `PLAN-RBAC-DOS-NIVELES.md`. |
| **RBAC-02** | Crítico | SoD de Configuración solo en UI. | Bloque 18. |
| **RBAC-03** | Medio | Endpoints de clientes sin RBAC nivel 2. | Fase 2 del Rediseño de Servicios. |
| **CODE-01** | Alto | `registrar_cliente.php` insertaba `'activo'` violando el trigger de transición. | Cambio a `'pendiente'`. |
| **CODE-02** | Medio | `api_equipos.php` asumía UNIQUE obsoleto. Mensaje engañoso. | Retiro de `es_principal`/`es_principal_unico` del DDL. Mensaje corregido. |
| **DB-01** | Bajo | UNIQUE redundante en `sesiones`. | `DROP INDEX uq_sesion_usuario`. |
| **CODE-03** | Alto | GET `api_empresa.php` con side-effect: INSERT si no existe fila singleton. | Spec 021. Verificado con curl (config:null sin INSERT). |
| **CODE-04** | Medio | PUT `api_facturas.php` sin validar formato de `periodo` ni capturar UNIQUE 1062. | Spec 021. Verificado con curl (200 con error de formato + 409 duplicado). |
| **CODE-05** | Medio | POST `api_contratos.php` aceptaba estados que el trigger rechazaba con SIGNAL 45000. | Spec 021. Verificado con curl + UI (contrato nace vigente). |
| **CODE-06** | Medio | PUT `api_naps.php` no exigía lat/lon (viola NOT NULL). | Spec 021. Verificado con curl. |
| **CODE-07** | Medio | PUT `api_nodos.php` no exigía `nombre` no vacío (viola NOT NULL + UNIQUE). | Spec 021. Verificado con curl. |
| **CODE-08** | Medio | PUT `api_olts.php` no exigía `marca_modelo` ni `id_nodos > 0`. | Spec 021. Verificado con curl. |
| **CODE-09** | Medio | PUT `api_nodos.php` no exigía lat/lon (asimetría con `api_naps.php`). | Spec 021. Verificado con curl. |
| **DOC-03** | Bajo | Color de marca `#104aa8` inconsistente: `index.html`, `app.js` (3 sitios), `styles.css` usaban `#2563eb` (azul tailwind viejo). | Spec 021. Verificado en navegador (DevTools, Dashboard, color picker). |
| **UI-01** | Bajo | Header de `clientes-table` decía "NAP / OLT" pero el render muestra `N servicio(s)`. | Spec 021. Verificado en navegador. |
| **UI-02** | Bajo | Header de `contratos-table` tenía 5 columnas, el render emitía 6 `<td>`. Faltaba columna "Servicio". | Spec 021. Verificado en navegador. |
| **UI-03** | Bajo | (Cerrado 2026-10-13.) | Fix aplicado. |
| **CODE-12** | Medio | `api_pagos.php` POST tenía `'status' => 'ok'` (string literal) en vez de `$ok` (variable). El frontend siempre recibía `status: success` incluso en errores. | Corregido en P13 Tanda 2. |
| **DB-08** | Medio | Confusión semántica `monto`+`moneda`+`tasa_cambio`: Opción A (monto en moneda de presentación) vs Opción B (monto siempre en USD). Opción A era incorrecta para Venezuela. | P13b + UI: Opción B con COMMENTs en BD + texto de ayuda + placeholders + render `Bs. monto × tasa`. |
| **DB-09** | — | `v_estado_cuenta_cliente` calculaba saldo incorrecto (no restaba pagos validados). | Resuelto por P10. |
| **DB-10** | — | `tickets.sla_vence_en` nunca se poblaba. | Resuelto por P12 (trigger insert). |
| **DB-11** | Alta | `equipos` sin `chk_equipo_estado_servicio`. | Resuelto por P12. |
| **DB-12** | Media | `planes` sin CHECKs de velocidad. | Resuelto por P14-bis. |
| **DB-13** | Baja | `sesiones.creado_en` no era `datetime` + `chk_sesion_expira` faltaba. | Resuelto por P9. |
| **DB-14** | Alta | P8b (`CONVERT TO CHARACTER SET`) habría descartado 6 CHECKs: `chk_equipo_mac`, `chk_equipo_puerto`, `chk_log_actor`, `chk_sesiones_un_tipo`, `chk_sesion_revocacion`, `chk_sesiones_discriminador`. | **Falso positivo.** Verificado con `information_schema.CHECK_CONSTRAINTS`: los 6 CHECKs existen. phpMyAdmin no los exporta en el dump, pero están en la BD. P15 (restaurar-checks-perdidos) los repuso de todos modos por seguridad. |
| **DB-15** | Baja | `v_facturas_con_saldo` sin `GREATEST(...,0)`. Podía devolver `saldo` negativo. | Resuelto por P15 (pagos-metodo-fk) PASO 6. |

**Decisión aprobada para Bloque 13:** modelo de permisos por página según naturaleza del artefacto. Fundamento: Salesforce, ServiceNow, AWS QuickSight, SAP, Azure, Odoo. Detalle en `docs/ROADMAP.md` Bloque 13.

---

## Decisiones de proceso vigentes

### Frameworks — `[PENDIENTE]`

El docente podría haber mencionado frameworks como permitidos a un compañero. **No hay confirmación directa.** Si se confirma: evaluar reescritura vs. mantener monolito modular. **Recomendación:** NO reescribir. El sistema está demasiado avanzado y auditado. Documentar como decisión de alcance.

### Reasignación de cliente en un servicio — fuera de alcance

El cliente de un servicio NO se puede cambiar desde el formulario de edición. La reasignación es una operación administrativa separada (patrón Splynx "Migrate services"), con su propio permiso y auditoría. Deuda técnica consciente para spec futura.

### ADRs pendientes

Dos decisiones arquitectónicas implementadas sin ADR formal:
- Servicio como entidad de primer nivel en la UI. Fundamento: Splynx, Omnitouch, PortaOne, TM Forum SID.
- GET sin side-effects vía endpoint POST dedicado. Fundamento: CWE-650, RFC 7231, Google Cloud Scheduler, AWS EventBridge.

---

## Aprendizajes recientes

- **UI ≠ backend.** Verificar ambas capas por separado.
- **El guard SoD va en `requirePageAccess`, no en `requireOperation`.**
- **Verificar el ciclo completo logout → login → cambio de rol.** La sesión fresca no expone bugs de caché.
- **Abrir DevTools → Network** durante verificaciones end-to-end.
- **Verificar que el dominio de la página tiene endpoint propio** antes de aplicar un gate de nivel 2.
- **Los triggers BEFORE INSERT son trampa para INSERTs directos desde endpoints de flujo compuesto** (CODE-01).
- **Los generados + UNIQUE en MySQL no restringen si la columna generada queda NULL** (CODE-02).
- **Al probar un endpoint aislado, cerrar todas las pestañas de la app.** `initApp()` dispara cargas que interfieren. Usar `curl`.
- **El GET sin side-effect se prueba con `curl` y la app cerrada.**
- **Las revisiones de coherencia cruzada detectan bugs que una lectura lineal no ve.**
- **Un prompt genérico sirve para N archivos** cuando el cambio es idéntico.
- **Auditoría uno por uno > auditoría en lote.**
- **Un número que el dump ya contiene no se replica en un doc.**
- **Un documento híbrido (hallazgos + estado) miente desde el día siguiente.**
- **Un solo carácter puede romper todo el layout.** El `*` (selector universal) faltante en `styles.css` tumbó `box-sizing: border-box` para todos los elementos. VS Code lo marcó en rojo; el navegador descuadró la UI en silencio. Lección añadida a `docs/VERIFICACION.md` §2.4.
- **Los cambios de color requieren barrido de TODAS las representaciones.** `#2563eb` no es la única forma del azul viejo: también está como `2563eb`, `37, 99, 235`, `37,99,235`, `rgba(37, 99, 235, ...)`. El prompt 7.2 original no los cubrió todos; hizo falta 7.2c.
- **La UX debe reflejar la máquina de estados real.** Si el backend fuerza `vigente` en INSERT, el frontend no debe ofrecer otros estados en creación. Patrón Salesforce/ServiceNow.
- **En CSS, a igual especificidad, gana el archivo que aparece último.** El orden de `<link rel="stylesheet">` importa: el archivo que debe imponer su valor va al final, no al principio. Invertir el orden anula el override silenciosamente.
- **Un `//` se come toda la línea física.** Un comentario seguido de código en la misma línea deja la sentencia fuera de ejecución sin error de sintaxis. Los editores/IA que unen líneas al pegar pueden introducir el bug sin avisar.
- **Los headers `Cache-Control: no-store` son obligatorios en endpoints que devuelven datos mutables.** Sin ellos, el navegador puede servir respuestas obsoletas por heurística y la UI muestra datos viejos sin fallar el request.
- **Un bloque de refactor de BD se puede ejecutar a medias.** El dump del 2026-10-13 probó que P1–P8, P11, P13, P14 corrieron pero P9, P10, P12, P14-bis no.
- **phpMyAdmin no exporta CHECK constraints.** Para auditar CHECKs, usar `information_schema.CHECK_CONSTRAINTS` o `mysqldump` desde CLI. Lección completa en `AGENTS.md` §"Trampas conocidas del dominio" y `docs/VERIFICACION.md` §2.6.
- **El mensaje del SIGNAL 45000 (MySQL error 1644) es texto de negocio, no PII.** Exponerlo vía `$e->errorInfo[2]` es seguro y mejora la UX. El catch genérico no debe tragárselo.

Aprendizajes completos: `docs/REFERENCIA.md` §4.
Lecciones de verificación: `docs/VERIFICACION.md`.

---

## Documentación clave (referencia rápida)

- `docs/GOBERNANZA.md` — mapa del ecosistema documental.
- `docs/constitution.md` — principios innegociables.
- `AGENTS.md` — reglas operativas del agente.
- `docs/METODOLOGIA_DESARROLLO_IA.md` — ciclo de trabajo.
- `docs/METODOLOGIA_AUDITORIA_IA.md` — marco de auditoría.
- `docs/AUDITORIA_2026.md` — hallazgos canónicos (foto al 2026-10-11).
- `docs/ROADMAP.md` — plan por bloques y estado de specs.
- `docs/ARQUITECTURA.md` — cómo está construido.
- `docs/BD.md` — esquema de base de datos.
- `docs/REFERENCIA.md` — estándares, frases de defensa, industria descartada.
- `docs/VERIFICACION.md` — lecciones de verificación.
- `docs/ADR/` — decisiones arquitectónicas (001–009).

---

## Infraestructura

- **Tests:** `php tests/run.php`. Smoke + auditoría.
- **Backup:** `C:\backups\` + `app.js.bak` en raíz.
- **Entorno de desarrollo:** XAMPP (Apache 2.4.58 + PHP 8.2.12 + MariaDB 10.4.32). `http://127.0.0.1/redytelca/`.
- **Skills disponibles:** `sdd`, `redytelca-bd`, `redytelca-auth`, `redytelca-auditoria`.

---

## Refactor BD en curso (2026-10-12)

**Motivo:** revisión de BD inminente.

**Alcance:** ver `docs/ADR/013-bd-completa-refactor.md`.

**Backup previo obligatorio:** `C:\backups\bd_redytelca_20261012_pre-refactor.sql`.

**Rollback:** restaurar el backup. Documentado en ADR 013.

**Excepción autorizada a `constitution.md` §3:** sí. Autorizada por ADR 013.

**Estado:** P1-P15 aplicados al 100% (SQL + código + triggers + vistas). Pendientes: P16, P17, P18-P29. Backup previo para continuar: `C:\backups\bd_redytelca_20261013_pre-p16.sql`.