# Capture um novo backup do Heroku
heroku pg:backups:capture --app ead-tecnology

# Verifique se o diretório existe, e crie-o se não existir
DIRECTORY="$HOME/Downloads/Bancos"
if [ ! -d "$DIRECTORY" ]; then
    mkdir -p "$DIRECTORY"  # Cria o diretório completo se ele não existir
fi

# Defina o caminho completo do arquivo
FILE="$DIRECTORY/ead"

# Cria o arquivo se ele não existir
if [ ! -f "$FILE" ]; then
    touch "$FILE"
fi

# Baixe o backup e mova-o para o local especificado
heroku pg:backups:download --app ead-tecnology
mv latest.dump "$FILE"

# Reinicie o serviço PostgreSQL (macOS)
brew services restart postgresql@17 2>/dev/null || brew services restart postgresql 2>/dev/null || echo "PostgreSQL já está rodando"

# Execute as tarefas do Rails e restaure o banco de dados
rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1 db:create
pg_restore --verbose --clean -U "$USER" -d ead_technology_development "$FILE"

# Inicie o servidor Rails na porta 3001
rails s -p 3001
