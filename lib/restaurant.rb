require_relative './menu'
require_relative './order'
require 'time'
require 'twilio-ruby'

class Restaurant
  attr_reader :menu
  attr_reader :category_array
  attr_reader :bank_account
  attr_reader :client

  INITIAL_CASH_AMOUNT = 100

  ERROR_MESSAGES = {
    category_does_not_exist: 'Sorry, the caregory you are trying to choose does not exist',
    dish_does_not_exist: 'Sorry, the dish you are trying to choose does not exist',
    invalid_dish_count: 'Sorry, dish count can be 1 or more'
  }.freeze

  def initialize(menu = Menu.new, twilio_client = nil, bank_account = INITIAL_CASH_AMOUNT)
    @menu = menu
    @category_array = ['pizza', 'paste', 'side', 'salde']
    @bank_account = bank_account
    @client = twilio_client
  end

  def client
    account_sid = ENV['TAKE_AWAY_TWILIO_ACCOUNT_SID']
    auth_token = ENV['TAKE_AWAY_TWILIO_AUTH_TOKEN']
    @client ||= Twilio::REST::Client.new account_sid, auth_token
  end

  def show_menu
    @menu.print_menu
  end

  def take_an_order
    order = create_an_order
    if verify_an_order(order)
      puts "Please pay your order"
      return order
    else
      puts "Thanks for visiting us!"
      return nil
    end
  end

  def receive_money(amount, customer)
    @bank_account += amount
    send_message(customer)
  end

  def send_message(customer)
    current_time = Time.now
    delivery_time = current_time + 3600
    message = "Thank you! Your order was placed and will be
    delivered before #{delivery_time.hour}:#{minutes(delivery_time)}"
    client.messages.create(
      from: ENV['TAKE_AWAY_TWILIO_NUMBER'],
      to: customer.telephone,
      body: message
    )
  end

  private

  def minutes(delivery_time)
    if delivery_time.min < 10
      return "0 #{delivery_time.min}"
    else
      return "#{delivery_time.min}"
    end
  end

  def create_an_order
    new_order = Order.new
    while true do
      puts 'From which category do you want to choose?'
      category_chosen = gets.chomp.downcase
      raise ERROR_MESSAGES[:category_does_not_exist] unless @category_array.include?(category_chosen)
      puts 'Which dish do you want to choose?'
      dish_name = gets.chomp
      puts 'How many do you want?'
      dish_count = gets.chomp.to_i
      raise ERROR_MESSAGES[:invalid_dish_count] if dish_count <= 0
      dish = @menu.menu[category_chosen.to_sym].select { |n|
        n.name == dish_name
      }.first
      raise ERROR_MESSAGES[:dish_does_not_exist] if dish.nil?
      new_order.add(DishOrder.new(dish, dish_count))
      break unless continue_order?
    end
    return new_order
  end

  def continue_order?
    puts 'Do you want to order anything else (yes/no)?'
    user_input = gets.chomp.downcase
    while user_input != 'yes' && user_input != 'no'
      puts 'Do you want to order anything else (yes/no)?'
      user_input = gets.chomp.downcase
    end
    return user_input == 'yes'
  end

  def verify_an_order(order)
    order.print_order
    puts "Please, confirm the order: (yes/no)"
    user_confirmation = gets.chomp.downcase
    return user_confirmation == 'yes'
  end
end
