json.extract! course, :id, :title, :slug, :description, :value_cash

if course.image.attached?
  json.image rails_blob_url(course.image)
else
  json.image '/site/assets/ranipassos/img/assinatura.jpg'
end
