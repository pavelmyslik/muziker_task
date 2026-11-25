# Hudební e-shop

Jednoduchý e-shop v Ruby on Rails: zákazník si vybere produkty, objedná je bez registrace
a dostane potvrzení e-mailem. Objednávku může zrušit, nezaplacená objednávka po čase propadne.

## Požadavky

- Ruby 3.4.13 (`.ruby-version`, `.tool-versions`)
- PostgreSQL
- Bundler

## Spuštění

```sh
bundle install
bin/rails db:prepare   # vytvoří DB, spustí migrace a nahraje seed produkty
bin/rails server
```

- E-shop: http://localhost:3000
- Odeslané e-maily (jen development): http://localhost:3000/letter_opener

Seeds jdou spustit opakovaně (`bin/rails db:seed`) a vrátí produkty na výchozí sklad.
Obsahují i vyprodaný produkt (ukulele, 0 ks) a produkt s posledním kusem (bicí, 1 ks).

## Testy

```sh
bundle exec rspec
bin/rubocop
```

## Co aplikace umí

- Katalog produktů s cenou a dostupností (počet kusů skladem).
- Objednávka více produktů jedním formulářem, bez registrace.
- Potvrzovací stránka objednávky a potvrzovací e-mail.
- Zrušení objednávky zákazníkem s vrácením zboží na sklad a e-mailem o zrušení.
- Automatická expirace nezaplacených objednávek (job) s vrácením zboží na sklad.

## Předpoklady

**Peníze**
- Jedna měna (CZK), bez DPH, slev a dopravného.
- Nulová cena produktu i objednávky je povolená, zakázaná je jen záporná.
- Cena se při objednávce kopíruje do `line_items.unit_price` a `orders.total`,
  takže pozdější změna ceny produktu nemění historické objednávky.

**Zákazník a doručení**
- Nákup bez registrace: jméno, e-mail, telefon, ulice s číslem, město, PSČ a země.
- Doručení jen do Česka a na Slovensko. PSČ = 5 číslic, telefon = 9–15 číslic
  s volitelnou předvolbou (+ nebo 00). Mezery se odstraňují.

**Objednávka**
- Bez košíku: produkty se vybírají jedním formulářem s množstvím u každého produktu.
- Stejný produkt vícekrát v jednom požadavku se sečte do jedné položky. Nulová množství se ignorují.
- Sklad se odečítá při vytvoření objednávky, atomicky. Rezervace během vyplňování formuláře neexistuje.
- Dvojí odeslání formuláře nevytvoří dvě objednávky (`idempotency_key` s unikátním indexem).
- Objednávka je dostupná jen přes náhodný token v URL, ne přes ID.

**Stavy objednávky**
- `pending` = čeká na zaplacení. Platební brána není implementovaná.
- Zrušit objednávku může kdokoli s odkazem (token), dokud je `pending`. Zboží se vrátí na sklad.
- Nezaplacená objednávka po 14 dnech propadne (`expired`) a zboží se vrátí na sklad.
  Dobu jde změnit proměnnou `ORDER_PENDING_EXPIRATION_DAYS`. Job běží každou hodinu
  (Solid Queue, jen produkce). Ručně: `bin/rails runner "Orders::ExpirePendingJob.perform_now"`.

**Produkty**
- Název produktu je unikátní bez ohledu na velikost písmen a slouží jako identifikátor
  (v produkci by to bylo např. SKU).
- Produkt, který je v nějaké objednávce, nejde smazat. Deaktivace produktů není.

**UI a e-maily**
- UI je česky. Názvy atributů ve validačních hláškách zůstávají anglicky.
- Potvrzení i zrušení objednávky posílá e-mail (`deliver_later`). V developmentu je
  vidět na `/letter_opener`.
