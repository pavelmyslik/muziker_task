class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order

    mail to: order.email, subject: default_i18n_subject(id: order.id)
  end
end
