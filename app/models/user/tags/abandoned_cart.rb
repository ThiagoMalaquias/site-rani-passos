class User::Tags::AbandonedCart
  attr_accessor :user_open_cart, :course, :user, :destroying

  def initialize(user_open_cart, destroying)
    @user_open_cart = user_open_cart
    @course = user_open_cart.course
    @user = user_open_cart.user
    @destroying = destroying
  end

  def call!
    if destroying
      UserTag.find_by(user: user, tag: Tag.find_by(name: "CarrinhoAbandonado"))&.destroy
      UserTag.find_by(user: user, tag: course.tag)&.destroy if course.tag_id.present?
    elsif user_open_cart.send_whatsapp == true
      UserTag.find_or_create_by(user: user, tag: Tag.find_by(name: "CarrinhoAbandonado"))
      UserTag.find_or_create_by(user: user, tag: course.tag) if course.tag_id.present?
    end
  end
end
