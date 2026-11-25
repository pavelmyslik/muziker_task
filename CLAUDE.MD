# Konvence projektu

## Stack
Ruby on Rails, PostgreSQL, RSpec, FactoryBot, WebMock. Sidekiq jen pokud bude potřeba.

## Architektura
- Tenké controllery: jen parametry, zavolání služby, odpověď.
- Business logika v service objektech: app/services/<namespace>/<sloveso>.rb, jedna veřejná metoda `call`.
- Externí API v app/clients/, s timeouty a vlastními výjimkami (TransientError / PermanentError).
- Joby tenké, jen volají service. Argumenty jen ID a JSON typy. Joby musí být idempotentní.
- Žádné vedlejší efekty (API, e-maily, joby) v model callbacích.
- Nepřidávej gemy ani vrstvy, které zadání nepotřebuje. Jednoduché řešení má přednost.

## Databáze
- Migrace: null: false, cizí klíče, unikátní indexy, decimal pro peníze.
- Integritu hlídá DB (constrainty), validace v modelu jsou navíc.
- Bez N+1 (includes). Velká data po dávkách (find_each, in_batches, upsert_all), soubory streamovaně.
- Operace přes víc záznamů v transakci, v transakci vždy metody s `!`.
- Souběh řeš atomickými UPDATE / unikátními indexy.

## Testy
- RSpec. Každá service má spec: hlavní případ + okrajové případy + chyby.
- Externí HTTP jen přes WebMock nebo instance_double, nikdy skutečná síť.
- Po každé změně spusť `bundle exec rspec`.

## Styl práce
- Pracuj po malých krocích. Před větší změnou navrhni plán a počkej na schválení.
- Necommituj sám.
