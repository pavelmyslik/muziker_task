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
