#!/bin/bash
#
# ==============================================================================
# SCRIPT: run.sh
# DESCRIÇÃO: Script interativo para simplificar a inicialização do ambiente
#            TOTVS-Protheus-in-Docker. Guia o usuário na escolha do banco
#            de dados e do perfil de execução.
# AUTOR: Julian de Almeida Santos
# DATA: 2025-10-20
# REPOSITÓRIO: github.com
# USO: ./run.sh
# ==============================================================================

# --- Configuração de Robustez (Boas Práticas Bash) ---
# -e: Sai imediatamente se um comando falhar.
# -u: Trata variáveis não definidas como erro.
# -o pipefail: Garante que um pipeline (ex: cat | tar) falhe se qualquer comando falhar.
set -euo pipefail

# --- Funções ---

# Função para exibir cabeçalhos de seção
print_header() {
    echo
    echo "--- $1 ---"
}

# --- Fluxo Principal ---

echo "###################################################"
echo "🚀 Bem-vindo ao Assistente de Inicialização do Protheus Docker"
echo "💡 DICA: Você também pode usar nosso gerador web para criar seu"
echo "   arquivo customizado de forma visual e rápida:"
echo "   👉 github.io"
echo "###################################################"

# 1. Escolha do Banco de Dados
print_header "1. Escolha do Banco de Dados"
echo "Qual banco de dados você gostaria de usar?"
select db_choice in "PostgreSQL (Recomendado)" "Microsoft SQL Server" "Oracle Database"; do
    case $db_choice in
        "PostgreSQL (Recomendado)")
            COMPOSE_FILE="docker-compose-postgresql.yaml"
            break
            ;;
        "Microsoft SQL Server")
            COMPOSE_FILE="docker-compose-mssql.yaml"
            break
            ;;
        "Oracle Database")
            COMPOSE_FILE="docker-compose-oracle.yaml"
            break
            ;;
        *)
            echo "Opção inválida. Por favor, digite 1, 2 ou 3."
            ;;
    esac
done

# 2. Escolha do Perfil de Execução
print_header "2. Escolha o Perfil de Inicialização"
echo "Selecione quais serviços adicionais deseja carregar:"
select profile_choice in "Apenas API REST (with-rest)" "API REST + SmartView (full)" "Apenas SmartView (with-smartview)" "Nenhum (Apenas AppServer Padrão)"; do
    case $profile_choice in
        "Apenas API REST (with-rest)")
            PROFILE_ARG="--profile with-rest"
            break
            ;;
        "API REST + SmartView (full)")
            PROFILE_ARG="--profile full"
            break
            ;;
        "Apenas SmartView (with-smartview)")
            PROFILE_ARG="--profile with-smartview"
            break
            ;;
        "Nenhum (Apenas AppServer Padrão)")
            PROFILE_ARG=""
            break
            ;;
        *)
            echo "Opção inválida. Por favor, digite 1, 2, 3 ou 4."
            ;;
    esac
done

# 3. Verificação do arquivo .env
print_header "3. Verificação de Configuração"
if [ ! -f .env ]; then
    echo "⚠️  Aviso: O arquivo '.env' não foi encontrado."
    echo "Copiando '.env.example' para '.env'. Por favor, revise as senhas se necessário."
    cp .env.example .env
else
    echo "✅ Arquivo '.env' encontrado."
fi


# 4. Confirmação e Execução
print_header "4. Confirmação e Execução"
# Constrói o comando final sem o argumento '--build' para usar imagens prontas
final_command="docker compose -f ${COMPOSE_FILE} -p totvs ${PROFILE_ARG} up -d"

echo "O seguinte comando será executado:"
echo
echo "   $final_command"
echo

read -p "Deseja continuar? (s/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "🛑 Operação cancelada pelo usuário."
    exit 0
fi

# Executa o comando
echo
echo "🚀 Executando o comando... Por favor, aguarde."
if eval "$final_command"; then
    echo
    echo "🎉 Ambiente iniciado com sucesso!"
    echo "Você pode monitorar os logs com o comando: docker compose -p totvs logs -f"
else
    echo
    echo "❌ Falha ao iniciar o ambiente. Verifique os logs acima." >&2
    exit 1
fi
