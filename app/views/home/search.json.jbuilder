json.array!(@courses) do |course|
  json.extract! course, :id, :title, :slug, :description, :value_cash
  
  json.image  course.image.attached? ? rails_blob_url(course.image) : '/site/assets/ranipassos/img/assinatura.jpg'
end