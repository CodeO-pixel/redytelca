<?php
// Portal del cliente REDYTELCA: login, saldo real, facturas, reporte de pagos y soporte.
// Los datos salen de portal_api.php (base de datos real).
header('Content-Type: text/html; charset=utf-8');
?>
<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>Portal del Cliente · REDYTELCA</title>
<link rel="icon" href="/Logos/logo_transparent.png">
<style>
:root{--brand:#1453db;--brand-2:#0ea5e9;--ink:#0f172a;--muted:#64748b;--bg:#f1f5fb;--card:#fff;--line:#e2e8f0;--ok:#16a34a;--warn:#d97706;--bad:#dc2626;--r:18px}
*{box-sizing:border-box}
html,body{margin:0;min-height:100%}
body{font-family:Inter,system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;color:var(--ink);background:var(--bg);-webkit-font-smoothing:antialiased}
img{max-width:100%}
button,input,select,textarea{font:inherit}
.hidden{display:none!important}

/* ---------- Login ---------- */
.login{min-height:100vh;display:grid;grid-template-columns:1.1fr 1fr}
.login-hero{position:relative;overflow:hidden;color:#fff;padding:48px;display:flex;flex-direction:column;justify-content:space-between;background:linear-gradient(140deg,#0b2a7a 0%,var(--brand) 50%,var(--brand-2) 100%)}
.login-hero::before,.login-hero::after{content:"";position:absolute;border-radius:50%;background:rgba(255,255,255,.08)}
.login-hero::before{width:420px;height:420px;right:-120px;top:-100px}
.login-hero::after{width:300px;height:300px;left:-80px;bottom:-90px}
.login-hero>*{position:relative;z-index:1}
.logo-chip{display:inline-flex;align-items:center;gap:12px;background:rgba(255,255,255,.95);padding:10px 16px;border-radius:14px;width:max-content;max-width:100%}
.logo-chip img{height:38px;width:auto;display:block}
.login-hero h1{font-size:clamp(28px,4vw,44px);line-height:1.1;margin:0 0 14px}
.login-hero p{margin:0;opacity:.9;max-width:460px;font-size:17px;line-height:1.5}
.perks{display:flex;gap:10px;flex-wrap:wrap;margin-top:22px}
.perks span{background:rgba(255,255,255,.16);padding:8px 14px;border-radius:999px;font-size:14px}
.login-panel{display:flex;align-items:center;justify-content:center;padding:32px;background:#fff}
.login-box{width:100%;max-width:400px}
.login-box h2{margin:0 0 6px;font-size:28px}
.login-box .sub{color:var(--muted);margin:0 0 24px}
.field{margin-bottom:16px}
.field label{display:block;font-size:13px;font-weight:600;margin-bottom:6px;color:#334155}
.field input,.field select,.field textarea{width:100%;padding:13px 14px;border:1.5px solid var(--line);border-radius:12px;background:#fff;transition:.15s}
.field input:focus,.field select:focus,.field textarea:focus{outline:none;border-color:var(--brand);box-shadow:0 0 0 4px rgba(20,83,219,.12)}
.btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;border:0;cursor:pointer;padding:13px 20px;border-radius:12px;font-weight:600;color:#fff;background:linear-gradient(135deg,var(--brand),#2f6cf0);box-shadow:0 8px 20px rgba(20,83,219,.28);transition:.15s}
.btn:hover{transform:translateY(-1px)}
.btn:disabled{opacity:.6;cursor:wait;transform:none}
.btn.block{width:100%}
.btn.ghost{background:#fff;color:var(--brand);box-shadow:none;border:1.5px solid var(--line)}
.btn.small{padding:8px 14px;font-size:14px;border-radius:10px}
.msg{margin-top:14px;font-size:14px;min-height:20px}
.msg.err{color:var(--bad)}.msg.ok{color:var(--ok)}
.hint{margin-top:18px;font-size:13px;color:var(--muted);line-height:1.5;background:var(--bg);padding:12px 14px;border-radius:12px}

/* ---------- App ---------- */
.topbar{position:sticky;top:0;z-index:20;background:rgba(255,255,255,.92);backdrop-filter:blur(10px);border-bottom:1px solid var(--line);padding-top:env(safe-area-inset-top)}
.topbar-in{max-width:1100px;margin:0 auto;padding:12px 20px;display:flex;align-items:center;justify-content:space-between;gap:12px}
.topbar img{height:34px;display:block}
.who{display:flex;align-items:center;gap:10px;min-width:0}
.avatar{width:38px;height:38px;border-radius:50%;background:linear-gradient(135deg,var(--brand),var(--brand-2));color:#fff;display:grid;place-items:center;font-weight:700;flex:none}
.who-name{font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:180px}
.wrap{max-width:1100px;margin:0 auto;padding:22px 20px 110px}
.hero{border-radius:24px;color:#fff;padding:28px;background:linear-gradient(135deg,#0b2a7a,var(--brand) 55%,var(--brand-2));box-shadow:0 20px 40px rgba(20,83,219,.25);display:flex;flex-wrap:wrap;gap:20px;align-items:center;justify-content:space-between}
.hero h1{margin:0 0 4px;font-size:clamp(22px,3.4vw,32px)}
.hero p{margin:0;opacity:.9}
.balance{background:rgba(255,255,255,.16);border-radius:18px;padding:16px 22px;min-width:220px}
.balance small{display:block;opacity:.85}
.balance strong{font-size:34px;line-height:1.2}
.grid{display:grid;gap:16px;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));margin-top:18px}
.card{background:var(--card);border:1px solid var(--line);border-radius:var(--r);padding:20px;box-shadow:0 6px 20px rgba(15,23,42,.05)}
.card h3{margin:0 0 12px;font-size:17px}
.stat .label{color:var(--muted);font-size:13px}
.stat .value{font-size:26px;font-weight:700;margin-top:4px}
.tabs{display:flex;gap:6px;margin:22px 0 16px;overflow-x:auto;padding-bottom:4px;scrollbar-width:none}
.tabs::-webkit-scrollbar{display:none}
.tab{border:0;background:#fff;border:1px solid var(--line);color:#334155;padding:10px 18px;border-radius:999px;cursor:pointer;font-weight:600;white-space:nowrap}
.tab.active{background:var(--brand);border-color:var(--brand);color:#fff}
.list{display:grid;gap:12px}
.item{display:flex;flex-wrap:wrap;gap:10px 16px;align-items:center;justify-content:space-between;background:#fff;border:1px solid var(--line);border-radius:14px;padding:14px 16px}
.item b{display:block}
.item span.sub{color:var(--muted);font-size:13px}
.badge{display:inline-block;padding:4px 11px;border-radius:999px;font-size:12px;font-weight:700;text-transform:capitalize}
.b-ok{background:#dcfce7;color:#166534}.b-warn{background:#fef3c7;color:#92400e}.b-bad{background:#fee2e2;color:#991b1b}.b-info{background:#dbeafe;color:#1e40af}.b-gray{background:#e2e8f0;color:#334155}
.empty{text-align:center;color:var(--muted);padding:34px 10px}
.two{display:grid;grid-template-columns:1fr 1fr;gap:16px}
.banner{background:#fef3c7;color:#92400e;border-radius:14px;padding:14px 16px;margin-bottom:16px;font-size:14px}
.modal{position:fixed;inset:0;background:rgba(15,23,42,.5);display:grid;place-items:center;padding:16px;z-index:50}
.modal .card{width:100%;max-width:440px;max-height:90vh;overflow:auto}
.nav-bottom{display:none}

@media (max-width:860px){
  .login{grid-template-columns:1fr}
  .login-hero{padding:28px 24px 34px;gap:26px}
  .login-panel{padding:26px 20px 40px}
  .two{grid-template-columns:1fr}
  .who-name{display:none}
  .wrap{padding:16px 14px 110px}
  .hero{padding:22px}
  .balance{width:100%}
  .tabs{display:none}
  .nav-bottom{display:flex;position:fixed;bottom:0;left:0;right:0;z-index:30;background:#fff;border-top:1px solid var(--line);padding:6px 6px calc(6px + env(safe-area-inset-bottom));justify-content:space-around}
  .nav-bottom button{flex:1;border:0;background:none;padding:8px 2px;font-size:11px;color:var(--muted);display:flex;flex-direction:column;align-items:center;gap:2px;cursor:pointer}
  .nav-bottom button span.ic{font-size:20px}
  .nav-bottom button.active{color:var(--brand);font-weight:700}
}
</style>
</head>
<body>

<!-- ============ LOGIN ============ -->
<section id="login" class="login">
  <div class="login-hero">
    <div class="logo-chip"><img src="/Logos/logo_transparent.png" alt="REDYTELCA"></div>
    <div>
      <h1>Tu internet,<br>siempre a la mano.</h1>
      <p>Consulta tu saldo, reporta tus pagos y solicita soporte en un solo lugar, desde tu celular o computadora.</p>
      <div class="perks"><span>💳 Reporta pagos</span><span>🧾 Tus facturas</span><span>🛠️ Soporte</span></div>
    </div>
    <small style="opacity:.75">© REDYTELCA</small>
  </div>
  <div class="login-panel">
    <form class="login-box" id="login-form" autocomplete="on">
      <h2>Bienvenido</h2>
      <p class="sub">Ingresa con tu cédula para ver tu cuenta.</p>
      <div class="field"><label for="cedula">Cédula</label><input id="cedula" name="cedula" placeholder="Ej. V-12345678" autocomplete="username" required></div>
      <div class="field"><label for="password">Contraseña</label><input id="password" name="password" type="password" placeholder="••••••••" autocomplete="current-password" required></div>
      <button class="btn block" id="login-btn" type="submit">Ingresar</button>
      <div class="msg" id="login-msg" role="alert"></div>
      <div class="hint">¿Primera vez? Tu contraseña inicial es tu cédula. Te pediremos cambiarla al entrar.</div>
    </form>
  </div>
</section>

<!-- ============ APP ============ -->
<div id="app" class="hidden">
  <header class="topbar"><div class="topbar-in">
    <img src="/Logos/logo_transparent.png" alt="REDYTELCA">
    <div class="who"><div class="avatar" id="avatar">U</div><span class="who-name" id="who-name"></span>
      <button class="btn ghost small" id="logout-btn" type="button">Salir</button></div>
  </div></header>

  <main class="wrap">
    <div id="pw-banner" class="banner hidden">🔒 Por seguridad, cambia tu contraseña inicial en la pestaña <b>Mi cuenta</b>.</div>
    <section class="hero">
      <div><h1 id="hello">Hola</h1><p id="hello-sub">Este es el resumen de tu cuenta.</p></div>
      <div class="balance"><small>Saldo pendiente</small><strong id="saldo">$0.00</strong><small id="proximo"></small></div>
    </section>

    <div class="grid" id="stats"></div>

    <nav class="tabs" id="tabs"></nav>
    <div id="view"></div>
  </main>

  <nav class="nav-bottom" id="nav-bottom"></nav>
</div>

<!-- Modal de pago -->
<div id="pay-modal" class="modal hidden">
  <form class="card" id="pay-form">
    <h3>Reportar pago</h3>
    <input type="hidden" name="id_factura">
    <div class="field"><label>Factura</label><input id="pay-fact" disabled></div>
    <div class="field"><label>Método</label>
      <select name="metodo"><option value="pago_movil">Pago móvil</option><option value="transferencia">Transferencia</option><option value="zelle">Zelle</option><option value="efectivo">Efectivo</option></select></div>
    <div class="field"><label>Referencia</label><input name="referencia" placeholder="Nº de referencia"></div>
    <div class="field"><label>Monto (USD)</label><input name="monto" type="number" step="0.01" min="0.01" required></div>
    <div style="display:flex;gap:10px"><button class="btn ghost" type="button" id="pay-cancel" style="flex:1">Cancelar</button><button class="btn" style="flex:1" type="submit">Enviar</button></div>
    <div class="msg" id="pay-msg"></div>
  </form>
</div>

<script>
const API = '/portal_api.php';
const $ = s => document.querySelector(s);
const esc = v => String(v ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const money = n => '$' + Number(n || 0).toLocaleString('es-VE', {minimumFractionDigits: 2, maximumFractionDigits: 2});
const fdate = d => d ? new Date(String(d).replace(' ', 'T')).toLocaleDateString('es-VE', {day:'2-digit', month:'short', year:'numeric'}) : '—';
const badgeClass = e => ({pagada:'b-ok',validado:'b-ok',activo:'b-ok',Cerrado:'b-ok',pendiente:'b-warn',parcial:'b-warn','En proceso':'b-info',Abierto:'b-info',vencida:'b-bad',rechazado:'b-bad',suspendido:'b-bad'}[e] || 'b-gray');
let token = localStorage.getItem('portal_token') || '';
let data = null, tab = 'resumen';
const TABS = [['resumen','🏠','Resumen'],['facturas','🧾','Facturas'],['pagos','💳','Pagos'],['soporte','🛠️','Soporte'],['cuenta','👤','Mi cuenta']];

async function api(action, body, method) {
  const opt = {headers: {'Content-Type': 'application/json', 'X-Session-Token': token}};
  let url = API + '?action=' + action;
  if (body) { opt.method = 'POST'; opt.body = JSON.stringify(body); } else if (method) opt.method = method;
  const res = await fetch(url, opt);
  const json = await res.json().catch(() => ({status: 'error', message: 'Respuesta inválida del servidor.'}));
  if (res.status === 401 && action !== 'login') { logoutLocal(); }
  return json;
}
function logoutLocal() { token = ''; localStorage.removeItem('portal_token'); data = null; $('#app').classList.add('hidden'); $('#login').classList.remove('hidden'); }

$('#login-form').addEventListener('submit', async e => {
  e.preventDefault();
  const btn = $('#login-btn'), msg = $('#login-msg');
  btn.disabled = true; msg.textContent = ''; msg.className = 'msg';
  const r = await api('login', {cedula: $('#cedula').value.trim(), password: $('#password').value});
  btn.disabled = false;
  if (r.status === 'success') { token = r.token; localStorage.setItem('portal_token', token); if (r.must_change_password) tab = 'cuenta'; await load(); }
  else { msg.textContent = r.message || 'No se pudo iniciar sesión.'; msg.classList.add('err'); }
});
$('#logout-btn').onclick = async () => { await api('logout', {}); logoutLocal(); };

async function load() {
  const r = await api('resumen');
  if (r.status !== 'success') { logoutLocal(); return; }
  data = r;
  $('#login').classList.add('hidden'); $('#app').classList.remove('hidden');
  const nombre = r.cliente.nombres + ' ' + r.cliente.apellidos;
  $('#avatar').textContent = (r.cliente.nombres[0] || 'U').toUpperCase();
  $('#who-name').textContent = nombre;
  $('#hello').textContent = 'Hola, ' + r.cliente.nombres + ' 👋';
  $('#saldo').textContent = money(r.saldo_pendiente);
  $('#proximo').textContent = r.proximo_vencimiento ? 'Próximo vencimiento: ' + fdate(r.proximo_vencimiento) : 'Estás al día ✅';
  $('#pw-banner').classList.toggle('hidden', !r.must_change_password);
  const activos = r.servicios.filter(s => s.estado_comercial === 'activo').length;
  const abiertos = r.tickets.filter(t => t.estado !== 'Cerrado').length;
  $('#stats').innerHTML = [
    ['Servicios activos', activos + ' / ' + r.servicios.length],
    ['Facturas por pagar', r.facturas.filter(f => ['pendiente','vencida','parcial'].includes(f.estado)).length],
    ['Pagos en revisión', r.pagos.filter(p => p.estado === 'pendiente').length],
    ['Tickets abiertos', abiertos]
  ].map(([l, v]) => `<div class="card stat"><div class="label">${l}</div><div class="value">${v}</div></div>`).join('');
  render();
}

function nav() {
  const active = t => t === tab ? ' active' : '';
  $('#tabs').innerHTML = TABS.map(([k,,l]) => `<button class="tab${active(k)}" data-t="${k}">${l}</button>`).join('');
  $('#nav-bottom').innerHTML = TABS.map(([k,i,l]) => `<button class="${active(k).trim()}" data-t="${k}"><span class="ic">${i}</span>${l}</button>`).join('');
  document.querySelectorAll('[data-t]').forEach(b => b.onclick = () => { tab = b.dataset.t; render(); window.scrollTo({top: 0, behavior: 'smooth'}); });
}

function facturaItem(f) {
  const puede = ['pendiente','vencida','parcial'].includes(f.estado) && f.saldo > 0 && !f.pago_en_revision;
  return `<div class="item"><div><b>Factura ${esc(f.periodo)} · ${esc(f.alias || 'Servicio')}</b><span class="sub">Vence ${fdate(f.fecha_vencimiento)} · Total ${money(f.monto)}${f.saldo !== Number(f.monto) ? ' · Saldo ' + money(f.saldo) : ''}</span></div>
    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap"><span class="badge ${badgeClass(f.estado)}">${esc(f.estado)}</span>${f.pago_en_revision ? '<span class="badge b-info">Pago en revisión</span>' : ''}${puede ? `<button class="btn small" data-pay="${f.id_factura}">Reportar pago</button>` : ''}</div></div>`;
}

function render() {
  nav();
  const v = $('#view');
  if (tab === 'resumen') {
    const pend = data.facturas.filter(f => ['pendiente','vencida','parcial'].includes(f.estado));
    v.innerHTML = `<div class="two"><div class="card"><h3>Mis servicios</h3><div class="list">${data.servicios.map(s => `<div class="item"><div><b>${esc(s.alias || 'Servicio ' + s.id_servicio)}</b><span class="sub">${esc(s.plan)} · ${esc(s.velocidad)} · ${money(s.precio_mensual)}/mes<br>${esc(s.direccion_texto)}</span></div><span class="badge ${badgeClass(s.estado_comercial)}">${esc(s.estado_comercial)}</span></div>`).join('') || '<div class="empty">Aún no tienes servicios.</div>'}</div></div>
      <div class="card"><h3>Por pagar</h3><div class="list">${pend.map(facturaItem).join('') || '<div class="empty">🎉 No tienes facturas pendientes.</div>'}</div></div></div>`;
  } else if (tab === 'facturas') {
    v.innerHTML = `<div class="list">${data.facturas.map(facturaItem).join('') || '<div class="empty">Sin facturas todavía.</div>'}</div>`;
  } else if (tab === 'pagos') {
    v.innerHTML = `<div class="list">${data.pagos.map(p => `<div class="item"><div><b>${money(p.monto)} · ${esc((p.metodo_pago || '').replace('_', ' '))}</b><span class="sub">${fdate(p.fecha_pago)}${p.referencia_bancaria ? ' · Ref. ' + esc(p.referencia_bancaria) : ''}</span></div><span class="badge ${badgeClass(p.estado)}">${esc(p.estado)}</span></div>`).join('') || '<div class="empty">Aún no has reportado pagos.</div>'}</div>`;
  } else if (tab === 'soporte') {
    v.innerHTML = `<div class="two"><form class="card" id="ticket-form"><h3>Nuevo ticket de soporte</h3>
      <div class="field"><label>Servicio</label><select name="id_servicio"><option value="">General</option>${data.servicios.map(s => `<option value="${s.id_servicio}">${esc(s.alias || 'Servicio ' + s.id_servicio)}</option>`).join('')}</select></div>
      <div class="field"><label>Asunto</label><input name="asunto" maxlength="150" required></div>
      <div class="field"><label>¿Qué está pasando?</label><textarea name="descripcion" rows="4" required></textarea></div>
      <button class="btn block" type="submit">Enviar ticket</button><div class="msg" id="ticket-msg"></div></form>
      <div class="card"><h3>Mis tickets</h3><div class="list">${data.tickets.map(t => `<div class="item"><div><b>${esc(t.asunto)}</b><span class="sub">${fdate(t.creado_en)}</span></div><span class="badge ${badgeClass(t.estado)}">${esc(t.estado)}</span></div>`).join('') || '<div class="empty">No tienes tickets.</div>'}</div></div></div>`;
    $('#ticket-form').onsubmit = async e => {
      e.preventDefault(); const f = Object.fromEntries(new FormData(e.target));
      const r = await api('ticket', f); const m = $('#ticket-msg');
      m.textContent = r.message; m.className = 'msg ' + (r.status === 'success' ? 'ok' : 'err');
      if (r.status === 'success') setTimeout(load, 700);
    };
  } else {
    const c = data.cliente;
    v.innerHTML = `<div class="two"><div class="card"><h3>Mis datos</h3><div class="list">
      <div class="item"><b>Nombre</b><span>${esc(c.nombres)} ${esc(c.apellidos)}</span></div>
      <div class="item"><b>Cédula</b><span>${esc(c.cedula)}</span></div>
      <div class="item"><b>Teléfono</b><span>${esc(c.num_telefono)}</span></div>
      <div class="item"><b>Correo</b><span>${esc(c.correo)}</span></div></div></div>
      <form class="card" id="pw-form"><h3>Cambiar contraseña</h3>
      <div class="field"><label>Contraseña actual</label><input name="actual" type="password" autocomplete="current-password" required></div>
      <div class="field"><label>Nueva contraseña (mín. 6)</label><input name="nueva" type="password" minlength="6" autocomplete="new-password" required></div>
      <button class="btn block" type="submit">Actualizar</button><div class="msg" id="pw-msg"></div></form></div>`;
    $('#pw-form').onsubmit = async e => {
      e.preventDefault(); const r = await api('password', Object.fromEntries(new FormData(e.target))); const m = $('#pw-msg');
      m.textContent = r.message; m.className = 'msg ' + (r.status === 'success' ? 'ok' : 'err');
      if (r.status === 'success') { e.target.reset(); setTimeout(load, 700); }
    };
  }
  document.querySelectorAll('[data-pay]').forEach(b => b.onclick = () => openPay(Number(b.dataset.pay)));
}

function openPay(id) {
  const f = data.facturas.find(x => x.id_factura === id); if (!f) return;
  const form = $('#pay-form'); form.reset();
  form.id_factura.value = id; $('#pay-fact').value = 'Factura ' + f.periodo + ' · saldo ' + money(f.saldo);
  form.monto.value = f.saldo.toFixed(2); $('#pay-msg').textContent = '';
  $('#pay-modal').classList.remove('hidden');
}
$('#pay-cancel').onclick = () => $('#pay-modal').classList.add('hidden');
$('#pay-modal').addEventListener('click', e => { if (e.target.id === 'pay-modal') e.target.classList.add('hidden'); });
$('#pay-form').addEventListener('submit', async e => {
  e.preventDefault(); const r = await api('pago', Object.fromEntries(new FormData(e.target))); const m = $('#pay-msg');
  m.textContent = r.message; m.className = 'msg ' + (r.status === 'success' ? 'ok' : 'err');
  if (r.status === 'success') setTimeout(() => { $('#pay-modal').classList.add('hidden'); load(); }, 900);
});

if (token) load();
</script>
</body>
</html>
