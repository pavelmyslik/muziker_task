module ProductsHelper
  def availability_badge(product)
    if product.stock.positive?
      tag.span("Skladem #{product.stock} ks", class: "badge badge--in-stock")
    else
      tag.span("Vyprodáno", class: "badge badge--sold-out")
    end
  end
end
