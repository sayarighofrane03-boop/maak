const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');

test('serves a multilingual MAAK landing page with a guarded Android APK download', () => {
  const html = fs.readFileSync(path.join(__dirname, '..', 'public', 'index.html'), 'utf8');

  assert.match(html, /<html lang="fr">/);
  assert.match(html, /data-language="ar" aria-label="العربية التونسية"/);
  assert.match(html, /data-language="en" aria-label="English"/);
  assert.match(html, /class="language-switch" role="group"/);
  assert.doesNotMatch(html, /<select\b/);
  assert.match(html, /data-language="fr" aria-label="Français" aria-pressed="true"/);
  assert.match(html, /radial-gradient\(ellipse at 4% 38%/);
  assert.match(html, /\.card:nth-child\(2\) \{ background: var\(--peach\); \}/);
  assert.match(html, /linear-gradient\(118deg, #f3d9d1 0%, #f8e7c7 48%, #dcece3 100%\)/);
  assert.match(html, /<nav class="primary-nav"/);
  assert.match(html, /<footer class="site-footer">/);
  assert.match(html, /class="footer-main"/);
  assert.match(html, /class="footer-bottom"/);
  assert.match(html, /footer_cta_button:/);
  assert.match(html, /copyright: "© \{year\}/);
  assert.match(html, /replace\("\{year\}", new Date\(\)\.getFullYear\(\)\)/);
  assert.match(html, /href="#download" data-i18n="download_android">Télécharger l'application Android<\/a>/);
  assert.match(html, /localStorage\.setItem\("maak-language"/);
  assert.match(html, /<video class="hero-video" autoplay muted loop playsinline/);
  assert.match(html, /<source src="hero\.mp4" type="video\/mp4">/);
  assert.match(html, /\.hero-video \{[\s\S]*z-index: 0;[\s\S]*object-fit: cover;/);
  assert.doesNotMatch(html, /\.hero-video \{ display: none; \}/);
  assert.equal(fs.existsSync(path.join(__dirname, '..', 'public', 'hero.mp4')), true);
  assert.match(html, /href="\/app\.html"/);
  assert.match(html, /href="\/downloads\/maak\.apk" aria-disabled="true"/);
  assert.match(html, /fetch\("\/downloads\/maak\.apk", \{ method: "HEAD" \}\)/);
});

test('web app offers French, Tunisian Arabic and English with RTL Arabic layout', () => {
  const html = fs.readFileSync(path.join(__dirname, '..', 'public', 'app.html'), 'utf8');

  assert.match(html, /value="fr"[^>]*>Français/);
  assert.match(html, /value="ar"[^>]*>العربية \(تونسي\)/);
  assert.match(html, /value="en"[^>]*>English/);
  assert.match(html, /document\.documentElement\.dir=LANGUAGE=="ar"\?"rtl":"ltr"/);
  assert.match(html, /localStorage\.setItem\("maak-language",LANGUAGE\)/);
});

test('escapes tutor city, session mode and availability in web markup', () => {
  const html = fs.readFileSync(path.join(__dirname, '..', 'public', 'app.html'), 'utf8');
  const script = html.slice(html.indexOf('<script>') + 8, html.lastIndexOf('</script>'));
  let markup = '';
  const root = {
    set innerHTML(value) { markup = value; },
    get innerHTML() { return markup; },
  };
  const document = {
    querySelector: () => root,
    addEventListener: () => {},
  };
  const render = new Function('document', 'setTimeout', 'location', `${script}
    T = [{
      id: 1, n: 'Tutor', u: 'University', c: '<svg onload=alert(1)>',
      m: ['Maths'], l: ['Lycée'], p: 15, r: 0, rv: 0,
      md: ['<svg onload=alert(1)>'], s: ['<svg onload=alert(1)>'], b: 'Bio'
    }];
    S.role = 'e';
    S.tab = 'x';
    S.sel = 1;
    render();
    return document.querySelector('#app').innerHTML;
  `);

  markup = render(document, () => {}, { hostname: 'localhost' });

  assert.match(markup, /&lt;svg onload=alert\(1\)&gt;/);
  assert.doesNotMatch(markup, /<svg onload=alert\(1\)>/);
});
