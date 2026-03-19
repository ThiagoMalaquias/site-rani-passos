class LogChange < ApplicationRecord
  belongs_to :manager

  def self.manager_log=(manager)
    @@manager_log = manager
  end

  def self.manager_log
    @@manager_log
  rescue
    nil
  end

  def self.save_log(title, content, model = "", move = {})
    return if LogChange.manager_log.blank?

    LogChange.create(
      title: title,
      manager: LogChange.manager_log,
      content: content.to_json,
      model: model,
      move: move.to_json
    )
  end
end
