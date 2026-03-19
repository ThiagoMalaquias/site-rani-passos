module Admin::QuestionsHelper
  def render_alternative_field(alternative, number)
    "<div class='col-md-12 mb-3'>
      <div class='row'>
        <div class='col-md-8'>
          <label class='form-control-label'>#{number}º Alt.</label>
          <input name='question[alternatives_attributes][][title]' class='form-control' value='#{alternative&.title}' type='text'>
        </div>
        <div class='col-md-4'>
          <label class='form-control-label'>Resposta Correta?</label>
          <select class='form-control' name='question[alternatives_attributes][][correct]'>
            <option value=''></option>
            <option value='false' #{alternative&.correct == false ? 'selected' : ''}>Não</option>
            <option value='true' #{alternative&.correct == true ? 'selected' : ''}>Sim</option>
          </select>
        </div>
      </div>
    </div> "
  end
end
