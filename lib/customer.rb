require_relative './bank'
require_relative './restraurant'
require_relative './order'

class Customer

  attr_reader :bank_account

  ERROR_MESSAGES = {
    not_enough_money_for_order: 'Sorry, you do not have enough money to pay for order'
  }.freeze

  INITIAL_CASH_AMOUNT = 100

  def initialize(status = false, bank_account = INITIAL_CASH_AMOUNT, telephone = +447502223960)
    @status = status
    @wallet = wallet
    @bank_account = bank_account
  end

  def hungry?
    @status = true
  end

  def place_an_order(restaurant)
    order = restaurant.take_an_order
    if order == nil
      puts "Order is not placed"
      return
    else
      pay_an_order(order, restaurant)
    end
  end

  def pay_an_order(order, restaurant)
    raise ERROR_MESSAGES[:not_enough_money_for_order] if order.total_price > bank_account
    @bank_account -= order.total_price
    restaurant.receive_money(order.total_price)
  end
end
