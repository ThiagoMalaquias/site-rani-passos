module CartHelper
	def apply_discount(discount, course)
		if discount.present?
			return "
				<div class='input-group'>
					<input type='text' class='form-control' value='#{discount}' disabled>
					<button type='submit' class='btn btn-primary btn-contact-send' id='btnApply' disabled>Aplicar</button>
				</div>
			"
		end

		"<div class='input-group'>
				<input type='hidden' class='form-control' name='course_id' value='#{course.id}'>
				<input type='text' class='form-control' name='discount' placeholder='Digite o Código'>
				<button type='submit' class='btn btn-primary btn-contact-send' id='btnApply'>Aplicar</button>
			</div>"
	end
end
  