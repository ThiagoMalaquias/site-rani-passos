class User::Ips
  def initialize(params)
    @name = params[:name]
    @status = params[:status]
    @user_id = params[:user_id]
    @page = params[:page] || 1
    @per_page = params[:per_page]
  end

  def execute
    query = <<-SQL.squish
      #{with_ip_changes}
      #{with_recent_region_changes}
      #{with_last_access}
      #{select_users}
    SQL

    result = ActiveRecord::Base.connection.execute(query)
    result.map { |row| row }
  end

  private

  # CTE para calcular mudanças de região
  def with_ip_changes
    <<-SQL.squish
    WITH ip_changes AS (
      SELECT
        ui.user_id,
        u.name,
        ui.ip,
        ui.region,
        ui.created_at,
        ui.checked,
        LAG(ui.region) OVER (PARTITION BY ui.user_id ORDER BY ui.created_at) AS previous_region,
        CASE
          WHEN LAG(ui.region) OVER (PARTITION BY ui.user_id ORDER BY ui.created_at) IS NOT NULL
               AND LAG(ui.region) OVER (PARTITION BY ui.user_id ORDER BY ui.created_at) <> ui.region
          THEN 1
          ELSE 0
        END AS region_change
      FROM
        user_ips ui
      JOIN
        users u ON u.id = ui.user_id
    )
    SQL
  end

  # CTE para somar mudanças de região em uma janela de 3 dias
  def with_recent_region_changes
    <<-SQL.squish
    , recent_region_changes AS (
      SELECT
        user_id,
        name,
        ip,
        region,
        created_at,
        checked,
        SUM(region_change) OVER (PARTITION BY user_id ORDER BY created_at RANGE BETWEEN INTERVAL '3 days' PRECEDING AND CURRENT ROW) AS changes_in_last_3_days
      FROM
        ip_changes
    )
    SQL
  end

  # CTE para selecionar o último acesso de cada usuário
  def with_last_access
    <<-SQL.squish
    , last_access AS (
      SELECT DISTINCT ON (user_id)
        user_id,
        name,
        checked,
        ip AS last_ip,
        region AS last_region,
        changes_in_last_3_days
      FROM
        recent_region_changes
      ORDER BY
        user_id, created_at DESC
    )
    SQL
  end

  # Bloco principal da query que faz a seleção e define o status
  def select_users
    <<-SQL.squish
    SELECT
      la.user_id,
      la.name,
      la.last_ip,
      la.last_region,
      CASE
        WHEN la.changes_in_last_3_days >= 3 THEN 'bloqueado'
        WHEN la.changes_in_last_3_days > 0 THEN 'alerta'
        ELSE 'normal'
      END AS status
    FROM
      last_access la
    JOIN
      users u ON u.id = la.user_id
    WHERE
      u.validate_ip = true
      AND la.checked = false
      #{status_filter}
      #{name_filter}
      #{user_filter}
      #{paginate}
    SQL
  end

  def status_filter
    return "" if @status.blank?

    <<-SQL.squish
    AND
      CASE
        WHEN la.changes_in_last_3_days >= 3 THEN 'bloqueado'
        WHEN la.changes_in_last_3_days > 0 THEN 'alerta'
        ELSE 'normal'
      END = '#{@status}'
    SQL
  end

  def name_filter
    "AND la.name ILIKE '%#{@name}%'" if @name.present?
  end

  def user_filter
    "AND la.user_id = #{@user_id}" if @user_id.present?
  end

  def paginate
    return "" unless @per_page

    "LIMIT #{@per_page} OFFSET #{(@page.to_i - 1) * @per_page}"
  end
end
