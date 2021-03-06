require_relative './dish'

class Menu
  attr_reader :menu

  SET_MENU = 3

  def initialize(menu = {
    pizza: [],
    paste: [],
    side: [],
    salade: []
  })
    @menu = menu
  end

  def menu_generator
    SET_MENU.times {
      @menu[:pizza] << Dish.rand_pizza_dish
      @menu[:paste] << Dish.rand_paste_dish
      @menu[:side] << Dish.rand_side_dish
      @menu[:salade] << Dish.rand_salade_dish
    }
    return @menu
  end

  def print_menu
    puts "Menue PizzaVolf".center(25, "*")
    puts "Pizza: #{@menu[:pizza]}".center(25)
    puts "Paste: #{@menu[:paste]}".center(25)
    puts "Side: #{@menu[:side]}".center(25)
    puts "Salade: #{@menu[:salade]}".center(25)
    puts "end".center(25, "*")
  end
end
