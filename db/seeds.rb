# Idempotentní: produkty se hledají podle názvu, opakované spuštění nevytvoří duplicity
# a vrátí cenu, popis i sklad na výchozí hodnoty.
products = [
  { name: "Akustická kytara Dreadnought", price: "4990.00", stock: 8,
    description: "Celomasivní smrkový vršek, mahagonové boky a luby. Vhodná pro začátečníky i pokročilé." },
  { name: "Elektrická kytara Stratocaster", price: "15990.00", stock: 3,
    description: "Tři single-coil snímače, olšové tělo, javorový krk." },
  { name: "Baskytara Jazz Bass", price: "18490.00", stock: 2,
    description: "Čtyřstrunná baskytara se dvěma snímači a palisandrovým hmatníkem." },
  { name: "Digitální piano 88 kláves", price: "12990.00", stock: 5,
    description: "Vážená kladívková mechanika, 10 zvuků, sluchátkový výstup." },
  { name: "Bicí souprava Fusion", price: "21990.00", stock: 1,
    description: "Poslední kus! Pětidílná sada včetně činelů a stoliček." },
  { name: "Kombo pro kytaru 20 W", price: "2990.00", stock: 12,
    description: "Kompaktní zesilovač s efektem overdrive a vstupem AUX." },
  { name: "Struny na akustickou kytaru 12–53", price: "249.00", stock: 150,
    description: "Bronzové struny se střední tenzí." },
  { name: "Ukulele koncertní", price: "1490.00", stock: 0,
    description: "Momentálně vyprodáno." }
]

products.each do |attributes|
  Product.find_or_initialize_by(name: attributes[:name]).update!(attributes)
end

puts "Seeds: #{Product.count} produktů."
