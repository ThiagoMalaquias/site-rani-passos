module Admin::EducationsHelper
  def categories_most_purchased(categories)
    return "nunhuma" if categories.count.zero?

    titles = categories.map(&:title)
    titles.detect { |e| titles.count(e) > 1 } || titles.first
  end
end
