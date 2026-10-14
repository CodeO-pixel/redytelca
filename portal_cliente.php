<?php
header('Content-Type: text/html; charset=utf-8');
$portalBase = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
if ($portalBase === '.' || $portalBase === '/') {
    $portalBase = '';
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#173b35">
    <title>Portal de clientes | REDYTELCA</title>
    <style>
        :root {
            color-scheme: light;
            --ink: #18342f;
            --muted: #64756f;
            --paper: #f4f7f3;
            --surface: #fff;
            --line: #dbe4dc;
            --green: #176b52;
            --green-dark: #173b35;
            --lime: #d8ed6d;
            --red: #a4362b;
        }
        * { box-sizing: border-box; }
        body { margin: 0; color: var(--ink); background: var(--paper); font: 16px/1.5 "Trebuchet MS", sans-serif; }
        button, input, select { font: inherit; }
        button { cursor: pointer; }
        .topbar { display: flex; align-items: center; justify-content: space-between; gap: 16px; min-height: 72px; padding: 12px max(20px, calc((100vw - 1120px) / 2)); color: white; background: var(--green-dark); }
        .brand { display: flex; align-items: center; gap: 12px; font-weight: 800; }
        .brand-mark { display: grid; place-items: center; width: 38px; height: 38px; border-radius: 11px; color: var(--green-dark); background: var(--lime); font: 700 18px Georgia, serif; }
        .brand small { display: block; color: #c9d8d1; font-size: 12px; font-weight: 400; }
        .topbar button { padding: 8px 12px; border: 1px solid #6c8b7e; border-radius: 7px; color: white; background: transparent; }
        main { width: min(1120px, calc(100% - 32px)); margin: 32px auto 64px; }
        h1, h2, h3, p { margin-top: 0; }
        h1 { margin-bottom: 6px; font: 600 34px/1.15 Georgia, serif; letter-spacing: 0; }
        h2 { margin-bottom: 14px; font: 600 24px/1.2 Georgia, serif; letter-spacing: 0; }
        .eyebrow { margin-bottom: 7px; color: var(--green); font-size: 12px; font-weight: 700; text-transform: uppercase; }
        .muted { color: var(--muted); }
        .login-layout { display: grid; grid-template-columns: minmax(0, 1fr) minmax(280px, .8fr); gap: 48px; align-items: center; min-height: 470px; }
        .login-intro { max-width: 480px; }
        .login-intro p { color: var(--muted); font-size: 17px; }
        .form-panel { padding: 26px; border: 1px solid var(--line); border-top: 4px solid var(--green); border-radius: 8px; background: var(--surface); }
        .form-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
        .field { display: grid; gap: 5px; min-width: 0; }
        .field.full { grid-column: 1 / -1; }
        label { font-size: 13px; font-weight: 700; }
        input, select { width: 100%; min-height: 42px; padding: 9px 11px; border: 1px solid #b9c9bf; border-radius: 6px; color: var(--ink); background: white; }
        input:focus, select:focus, button:focus-visible { outline: 3px solid #a8d68b; outline-offset: 2px; }
        .primary { min-height: 43px; padding: 9px 16px; border: 0; border-radius: 6px; color: white; background: var(--green); font-weight: 700; }
        .primary:hover { background: #0f563f; }
        .wide { width: 100%; }
        .notice { min-height: 24px; margin: 10px 0 0; color: var(--red); font-size: 14px; }
        .account-head { display: flex; justify-content: space-between; align-items: end; gap: 16px; padding-bottom: 22px; border-bottom: 1px solid var(--line); }
        .balance-band { display: grid; grid-template-columns: 1.1fr 1fr 1fr; margin: 22px 0 34px; border: 1px solid var(--line); border-radius: 8px; background: var(--surface); }
        .metric { min-height: 104px; padding: 18px 22px; border-right: 1px solid var(--line); }
        .metric:last-child { border-right: 0; }
        .metric span { display: block; color: var(--muted); font-size: 13px; }
        .metric strong { display: block; margin-top: 4px; font: 600 27px/1.2 Georgia, serif; }
        .metric:first-child { color: white; background: var(--green); border-radius: 7px 0 0 7px; }
        .metric:first-child span { color: #d4e7dc; }
        .section { margin-top: 32px; padding-top: 24px; border-top: 1px solid var(--line); }
        .service-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 10px; }
        .service-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 14px; border: 1px solid var(--line); border-radius: 7px; background: var(--surface); }
        .service-row strong, .service-row span { display: block; }
        .service-row small { color: var(--muted); }
        .status { white-space: nowrap; color: var(--green); font-size: 12px; font-weight: 700; }
        .table-wrap { overflow-x: auto; border: 1px solid var(--line); border-radius: 7px; background: var(--surface); }
        table { width: 100%; border-collapse: collapse; min-width: 640px; text-align: left; }
        th, td { padding: 11px 13px; border-bottom: 1px solid var(--line); }
        th { color: var(--muted); background: #eef3ed; font-size: 12px; text-transform: uppercase; }
        tr:last-child td { border-bottom: 0; }
        .payment-layout { display: grid; grid-template-columns: minmax(0, 1fr) minmax(260px, .75fr); gap: 28px; align-items: start; }
        .help { margin: 12px 0 0; color: var(--muted); font-size: 13px; }
        .empty { padding: 18px 0; color: var(--muted); }
        [hidden] { display: none !important; }
        @media (max-width: 720px) {
            .topbar { min-height: 62px; }
            main { margin-top: 22px; }
            .login-layout, .payment-layout { grid-template-columns: 1fr; gap: 22px; }
            .login-layout { min-height: 0; }
            .login-intro { padding-top: 10px; }
            h1 { font-size: 29px; }
            .balance-band { grid-template-columns: 1fr; }
            .metric { min-height: 80px; border-right: 0; border-bottom: 1px solid var(--line); }
            .metric:last-child { border-bottom: 0; }
            .metric:first-child { border-radius: 7px 7px 0 0; }
            .account-head { align-items: start; flex-direction: column; }
            .form-panel { padding: 18px; }
        }
        @media (max-width: 420px) {
            .form-grid { grid-template-columns: 1fr; }
            .field.full { grid-column: auto; }
            .brand small { display: none; }
        }
    </style>
</head>
<body>
    <header class="topbar">
        <div class="brand"><span class="brand-mark" aria-hidden="true">R</span><span>REDYTELCA<small>Portal de clientes</small></span></div>
        <button id="logout-button" type="button" hidden>Cerrar sesión</button>
    </header>

    <main>
        <section id="login-panel" class="login-layout">
            <div class="login-intro">
                <p class="eyebrow">Atención en línea</p>
                <h1>Tu cuenta, al día.</h1>
                <p>Consulta tus servicios y facturas, revisa pagos y envía comprobantes para validación.</p>
            </div>
            <form id="login-form" class="form-panel">
                <h2>Ingresar</h2>
                <div class="form-grid">
                    <div class="field full">
                        <label for="login-cedula">Cédula</label>
                        <input id="login-cedula" name="cedula" autocomplete="username" placeholder="V-12345678" required>
                    </div>
                    <div class="field full">
                        <label for="login-password">Contraseña</label>
                        <input id="login-password" name="password" type="password" autocomplete="current-password" required>
                    </div>
                    <div class="field full">
                        <button class="primary wide" type="submit">Entrar</button>
                    </div>
                </div>
                <p id="login-message" class="notice" role="status" aria-live="polite"></p>
            </form>
        </section>

        <section id="account-panel" hidden>
            <div class="account-head" data-account-content>
                <div><p class="eyebrow">Resumen de cuenta</p><h1 id="client-name">Cliente</h1><p class="muted" id="client-document"></p></div>
            </div>
            <div class="balance-band" data-account-content>
                <div class="metric"><span>Saldo pendiente</span><strong id="client-balance">$0.00</strong></div>
                <div class="metric"><span>Próximo vencimiento</span><strong id="client-due">—</strong></div>
                <div class="metric"><span>Servicios activos</span><strong id="client-service-count">0</strong></div>
            </div>

            <section id="password-change-section" class="section" hidden>
                <h2>Cambia tu contraseña</h2>
                <form id="password-form" class="form-panel">
                    <div class="form-grid">
                        <div class="field"><label for="current-password">Contraseña actual</label><input id="current-password" name="actual" type="password" autocomplete="current-password" required></div>
                        <div class="field"><label for="new-password">Nueva contraseña</label><input id="new-password" name="nueva" type="password" minlength="15" maxlength="128" autocomplete="new-password" required></div>
                        <div class="field full"><button class="primary" type="submit">Actualizar contraseña</button></div>
                    </div>
                    <p id="password-message" class="notice" role="status" aria-live="polite"></p>
                </form>
            </section>

            <section class="section" data-account-content>
                <h2>Mis servicios</h2>
                <div id="services-list" class="service-list"></div>
            </section>

            <section class="section" data-account-content>
                <h2>Facturas</h2>
                <div class="table-wrap"><table>
                    <thead><tr><th>Período</th><th>Servicio</th><th>Estado</th><th>Total</th><th>Pagado</th><th>Saldo</th></tr></thead>
                    <tbody id="invoices-list"></tbody>
                </table></div>
            </section>

            <section class="section payment-layout" data-account-content>
                <div>
                    <p class="eyebrow">Pago</p><h2>Reportar un pago</h2>
                    <form id="payment-form" class="form-panel" enctype="multipart/form-data">
                        <div class="form-grid">
                            <div class="field full"><label for="payment-invoice">Factura</label><select id="payment-invoice" name="id_factura" required></select></div>
                            <div class="field"><label for="payment-amount">Monto de referencia (USD)</label><input id="payment-amount" name="monto" type="number" min="0.01" step="0.01" required></div>
                            <div class="field"><label for="payment-method">Método</label><select id="payment-method" name="id_metodo" required></select></div>
                            <div class="field"><label for="payment-currency">Moneda del pago</label><select id="payment-currency" name="moneda_pago"><option value="USD">USD</option><option value="VES">VES</option></select></div>
                            <div class="field" id="rate-field" hidden><label for="payment-rate">Tasa BCV (Bs/USD)</label><input id="payment-rate" name="tasa_cambio" type="number" min="0.0001" step="0.0001"></div>
                            <div class="field full"><label for="payment-reference">Referencia</label><input id="payment-reference" name="referencia" maxlength="255"></div>
                            <div class="field full"><label for="payment-proof">Comprobante (PDF, JPG o PNG; máx. 5 MB)</label><input id="payment-proof" name="comprobante" type="file" accept="application/pdf,image/jpeg,image/png" required></div>
                            <div class="field full"><button id="payment-submit" class="primary" type="submit">Enviar para validación</button></div>
                        </div>
                        <p id="payment-message" class="notice" role="status" aria-live="polite"></p>
                    </form>
                </div>
                <div>
                    <p class="eyebrow">Actividad</p><h2>Pagos recientes</h2>
                    <div class="table-wrap"><table>
                        <thead><tr><th>Fecha</th><th>Método</th><th>Monto USD</th><th>Estado</th></tr></thead>
                        <tbody id="payments-list"></tbody>
                    </table></div>
                    <p class="help">Los pagos reportados quedan pendientes hasta que el equipo los valide.</p>
                </div>
            </section>
        </section>
    </main>

    <script>
        const API_URL = <?= json_encode($portalBase . '/portal_api.php', JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;
        const TOKEN_KEY = 'redytelca_portal_token';
        let sessionToken = sessionStorage.getItem(TOKEN_KEY) || '';
        let accountData = null;

        const escapeHtml = value => String(value ?? '').replace(/[&<>"']/g, character => ({
            '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
        })[character]);
        const formatUsd = value => '$' + Number(value || 0).toLocaleString('es-VE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        const showMessage = (id, message, success = false) => {
            const element = document.getElementById(id);
            element.textContent = message;
            element.style.color = success ? 'var(--green)' : 'var(--red)';
        };

        async function requestApi(action, options = {}) {
            const headers = { ...(options.headers || {}) };
            if (sessionToken) headers['X-Session-Token'] = sessionToken;
            const response = await fetch(`${API_URL}?action=${encodeURIComponent(action)}`, {
                method: options.method || 'GET', headers, body: options.body
            });
            const data = await response.json().catch(() => ({}));
            if (response.status === 403 && data.must_change_password) {
                showPasswordChangeOnly();
                return data;
            }
            if (!response.ok || data.status !== 'success') {
                if (response.status === 401 && action !== 'login') logout(false);
                throw new Error(data.message || 'No se pudo completar la solicitud.');
            }
            return data;
        }

        function setAuthenticated(authenticated) {
            document.getElementById('login-panel').hidden = authenticated;
            document.getElementById('account-panel').hidden = !authenticated;
            document.getElementById('logout-button').hidden = !authenticated;
        }

        function showPasswordChangeOnly() {
            document.querySelectorAll('[data-account-content]').forEach(element => { element.hidden = true; });
            document.getElementById('password-change-section').hidden = false;
            setAuthenticated(true);
        }

        async function login(event) {
            event.preventDefault();
            showMessage('login-message', '');
            const form = new FormData(event.currentTarget);
            try {
                const data = await requestApi('login', { method: 'POST', body: JSON.stringify(Object.fromEntries(form)), headers: { 'Content-Type': 'application/json' } });
                sessionToken = data.token;
                sessionStorage.setItem(TOKEN_KEY, sessionToken);
                if (data.must_change_password) {
                    showPasswordChangeOnly();
                    return;
                }
                await loadAccount();
            } catch (error) {
                showMessage('login-message', error.message);
            }
        }

        function renderAccount(data) {
            accountData = data;
            document.querySelectorAll('[data-account-content]').forEach(element => { element.hidden = false; });
            document.getElementById('client-name').textContent = `${data.cliente.nombres} ${data.cliente.apellidos}`.trim();
            document.getElementById('client-document').textContent = data.cliente.cedula;
            document.getElementById('client-balance').textContent = formatUsd(data.saldo_pendiente);
            document.getElementById('client-due').textContent = data.proximo_vencimiento || '—';
            document.getElementById('client-service-count').textContent = data.servicios.length;
            document.getElementById('password-change-section').hidden = !data.must_change_password;

            const services = document.getElementById('services-list');
            services.innerHTML = data.servicios.length ? data.servicios.map(service => {
                const down = service.velocidad_bajada_mbps ? `${Number(service.velocidad_bajada_mbps)} Mbps` : 'Velocidad no disponible';
                const up = service.velocidad_subida_mbps ? `${Number(service.velocidad_subida_mbps)} Mbps subida` : '';
                return `<article class="service-row"><div><strong>${escapeHtml(service.alias || service.plan)}</strong><small>${escapeHtml(service.plan)} · ${escapeHtml(down)} ${escapeHtml(up)}</small></div><span class="status">${escapeHtml(service.estado_comercial)}</span></article>`;
            }).join('') : '<p class="empty">No tienes servicios registrados.</p>';

            const invoices = document.getElementById('invoices-list');
            invoices.innerHTML = data.facturas.length ? data.facturas.map(invoice => `
                <tr><td>${escapeHtml(invoice.periodo)}</td><td>${escapeHtml(invoice.alias || 'Servicio')}</td><td>${escapeHtml(invoice.estado)}</td><td>${formatUsd(invoice.monto)}</td><td>${formatUsd(invoice.pagado)}</td><td>${formatUsd(invoice.saldo)}</td></tr>
            `).join('') : '<tr><td colspan="6">No hay facturas.</td></tr>';

            const payableInvoices = data.facturas.filter(invoice => Number(invoice.saldo) > 0 && !['pagada', 'anulada'].includes(invoice.estado));
            const invoiceSelect = document.getElementById('payment-invoice');
            invoiceSelect.innerHTML = payableInvoices.length
                ? payableInvoices.map(invoice => `<option value="${escapeHtml(invoice.id_factura)}" data-balance="${Number(invoice.saldo)}">${escapeHtml(invoice.periodo)} · ${escapeHtml(invoice.alias || 'Servicio')} · saldo ${formatUsd(invoice.saldo)}</option>`).join('')
                : '<option value="">No hay facturas con saldo</option>';
            document.getElementById('payment-submit').disabled = payableInvoices.length === 0;
            if (payableInvoices.length) document.getElementById('payment-amount').value = Number(payableInvoices[0].saldo).toFixed(2);

            const methods = document.getElementById('payment-method');
            methods.innerHTML = data.metodos_pago.length
                ? data.metodos_pago.map(method => `<option value="${escapeHtml(method.id_metodo)}" data-reference="${Number(method.requiere_referencia)}">${escapeHtml(method.nombre)}</option>`).join('')
                : '<option value="">No hay métodos disponibles</option>';
            document.getElementById('payment-submit').disabled = payableInvoices.length === 0 || data.metodos_pago.length === 0;

            const payments = document.getElementById('payments-list');
            payments.innerHTML = data.pagos.length ? data.pagos.map(payment => `
                <tr><td>${escapeHtml(payment.fecha_pago)}</td><td>${escapeHtml(payment.metodo_nombre || '—')}</td><td>${formatUsd(payment.monto)}</td><td>${escapeHtml(payment.estado)}</td></tr>
            `).join('') : '<tr><td colspan="4">Aún no tienes pagos reportados.</td></tr>';
            setAuthenticated(true);
        }

        async function loadAccount() {
            const data = await requestApi('resumen');
            if (data.must_change_password) return;
            renderAccount(data);
        }

        async function logout(callApi = true) {
            const oldToken = sessionToken;
            sessionStorage.removeItem(TOKEN_KEY);
            sessionToken = '';
            setAuthenticated(false);
            if (callApi && oldToken) {
                try {
                    await fetch(`${API_URL}?action=logout`, { method: 'POST', headers: { 'X-Session-Token': oldToken } });
                } catch (error) {
                    // El token local ya fue retirado; la sesión del servidor caduca por expiración.
                }
            }
        }

        document.getElementById('login-form').addEventListener('submit', login);
        document.getElementById('logout-button').addEventListener('click', () => logout());
        document.getElementById('payment-invoice').addEventListener('change', event => {
            const option = event.currentTarget.selectedOptions[0];
            if (option?.dataset.balance) document.getElementById('payment-amount').value = Number(option.dataset.balance).toFixed(2);
        });
        document.getElementById('payment-method').addEventListener('change', event => {
            const required = event.currentTarget.selectedOptions[0]?.dataset.reference === '1';
            document.getElementById('payment-reference').required = required;
        });
        document.getElementById('payment-currency').addEventListener('change', event => {
            const isBolivares = event.currentTarget.value === 'VES';
            document.getElementById('rate-field').hidden = !isBolivares;
            document.getElementById('payment-rate').required = isBolivares;
        });
        document.getElementById('payment-form').addEventListener('submit', async event => {
            event.preventDefault();
            showMessage('payment-message', '');
            const button = document.getElementById('payment-submit');
            button.disabled = true;
            try {
                const data = await requestApi('pago', { method: 'POST', body: new FormData(event.currentTarget) });
                showMessage('payment-message', data.message, true);
                event.currentTarget.reset();
                await loadAccount();
            } catch (error) {
                showMessage('payment-message', error.message);
            } finally {
                button.disabled = false;
            }
        });
        document.getElementById('password-form').addEventListener('submit', async event => {
            event.preventDefault();
            showMessage('password-message', '');
            const form = new FormData(event.currentTarget);
            try {
                const data = await requestApi('password', { method: 'POST', body: JSON.stringify(Object.fromEntries(form)), headers: { 'Content-Type': 'application/json' } });
                showMessage('password-message', data.message, true);
                event.currentTarget.reset();
                await loadAccount();
            } catch (error) {
                showMessage('password-message', error.message);
            }
        });

        if (sessionToken) {
            loadAccount().catch(error => showMessage('login-message', error.message));
        }
    </script>
</body>
</html>
