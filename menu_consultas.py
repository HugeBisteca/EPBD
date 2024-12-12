import psycopg2

# Configuração do Banco de Dados
DB_CONFIG = {
    'dbname': 'Mudancas',
    'user': 'postgres',
    'password': 'admin123',  # Altere para a sua senha
    'host': 'localhost',
    'port': '5432'
}

# Conectar ao Banco de Dados
def conectar_banco():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Erro ao conectar ao banco de dados: {e}")
        return None

# Consultas SQL
def consulta_servicos_cliente(conn):
    cliente_cpf = input("Digite o CPF do cliente: ")
    query = f"""
    SELECT s.Nome, ts.Descricao AS TipoServico
    FROM Solicitam so
    JOIN Servicos s ON so.Nome = s.Nome
    JOIN TipoServico ts ON s.ID_Tipo = ts.ID_Tipo
    WHERE so.CPF = '{cliente_cpf}'  -- CPF do cliente
      AND so.DataFim >= CURRENT_DATE - INTERVAL '1 month';
    """
    executar_consulta(conn, query, "Serviços solicitados pelo cliente no último mês")

def consulta_empresa_mais_ofereceu_servicos(conn):
    cidade = input("Digite a cidade: ")
    estado = input("Digite o estado: ")
    query = f"""
    SELECT e.Nome AS Empresa, COUNT(o.Nome) AS TotalServicos
    FROM Oferecem o
    JOIN Empresa e ON o.ID = e.ID
    JOIN Cidade c ON o.NomeCidade = c.Nome
    WHERE c.Nome = '{cidade}' AND c.Estado = '{estado}'
    GROUP BY e.Nome
    ORDER BY TotalServicos DESC
    LIMIT 1;
    """
    executar_consulta(conn, query, "Empresa que mais ofereceu serviços à cidade")

def consulta_faturamento_empresas(conn):
    query = """
    SELECT e.Nome AS Empresa, EXTRACT(MONTH FROM so.DataFim) AS Mes, SUM(so.Preco) AS Faturamento
    FROM Solicitam so
    JOIN Empresa e ON so.Nome = e.Nome
    WHERE EXTRACT(YEAR FROM so.DataFim) = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY e.Nome, Mes
    ORDER BY Mes;
    """
    executar_consulta(conn, query, "Faturamento das empresas por mês")

def consulta_servico_mais_solicitado(conn):
    query = """
    SELECT s.Nome, COUNT(so.Nome) AS QuantidadeSolicitada
    FROM Solicitam so
    JOIN Servicos s ON so.Nome = s.Nome
    WHERE so.DataFim >= CURRENT_DATE - INTERVAL '1 month'
    GROUP BY s.Nome
    ORDER BY QuantidadeSolicitada DESC
    LIMIT 1;
    """
    executar_consulta(conn, query, "Serviço mais solicitado no último mês")

def consulta_faturamento_total_empresas(conn):
    query = """
    SELECT e.Nome AS Empresa, SUM(so.Preco) AS FaturamentoTotal
    FROM Solicitam so
    JOIN Empresa e ON so.Nome = e.Nome
    GROUP BY e.Nome;
    """
    executar_consulta(conn, query, "Faturamento total das empresas")

def consulta_cidade_maior_numero_solicitacoes(conn):
    query = """
    SELECT c.Nome, COUNT(so.Nome) AS QuantidadeSolicitacoes
    FROM Solicitam so
    JOIN Cidade c ON so.CidadeOrigem = c.Nome
    GROUP BY c.Nome
    ORDER BY QuantidadeSolicitacoes DESC
    LIMIT 1;
    """
    executar_consulta(conn, query, "Cidade com maior número de solicitações")

def consulta_cidade_destino_mais_referenciada(conn):
    query = """
    SELECT c.Nome, COUNT(so.Nome) AS QuantidadePedidos
    FROM Solicitam so
    JOIN Cidade c ON so.CidadeDestino = c.Nome
    GROUP BY c.Nome
    ORDER BY QuantidadePedidos DESC
    LIMIT 1;
    """
    executar_consulta(conn, query, "Cidade destino mais referenciada nos pedidos")

def consulta_servico_mais_solicitado_entre_empresas(conn):
    query = """
    SELECT s.Nome, COUNT(so.Nome) AS QuantidadeSolicitada
    FROM Solicitam so
    JOIN Servicos s ON so.Nome = s.Nome
    WHERE so.DataFim >= CURRENT_DATE - INTERVAL '1 month'
    GROUP BY s.Nome
    ORDER BY QuantidadeSolicitada DESC
    LIMIT 1;
    """
    executar_consulta(conn, query, "Serviço mais solicitado no último mês entre todas as empresas")

def consulta_faturamento_total_por_empresa(conn):
    query = """
    SELECT e.Nome AS Empresa, SUM(so.Preco) AS FaturamentoTotal
    FROM Solicitam so
    JOIN Empresa e ON so.Nome = e.Nome
    GROUP BY e.Nome;
    """
    executar_consulta(conn, query, "Faturamento total para cada empresa")

def consulta_solicitacoes_ultimo_ano(conn):
    query = """
    SELECT so.Nome, c.NomeCompl AS Cliente, so.TempoHoraDurac, so.Preco, 
           so.DataFim, e.Nome AS Empresa, ci1.Nome AS CidadeOrigem, ci2.Nome AS CidadeDestino
    FROM Solicitam so
    JOIN Clientes c ON so.CPF = c.CPF
    JOIN Empresa e ON so.Nome = e.Nome
    LEFT JOIN Cidade ci1 ON so.CidadeOrigem = ci1.Nome
    LEFT JOIN Cidade ci2 ON so.CidadeDestino = ci2.Nome
    WHERE so.DataFim >= CURRENT_DATE - INTERVAL '1 year';
    """
    executar_consulta(conn, query, "Solicitações feitas no último ano com detalhes")



# Função Genérica para Executar Consultas
def executar_consulta(conn, query, titulo):
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        resultados = cursor.fetchall()
        colunas = [desc[0] for desc in cursor.description]

        print(f"\n--- {titulo} ---")
        print(" | ".join(colunas))
        for linha in resultados:
            print(" | ".join(map(str, linha)))

        cursor.close()
    except Exception as e:
        print(f"Erro ao executar a consulta: {e}")

# Menu Principal
def menu_principal():
    conn = conectar_banco()
    if not conn:
        return

    while True:
        print("\n--- Menu de Consultas ---")
        print("1. Que tipo de serviços um determinado cliente X solicitou no último mês.")
        print("2. Qual é a empresa que mais ofereceu mais serviços à cidade Y no estado de Z.")
        print("3. Listar o faturamento das empresas por mês.")
        print("4. Verificar qual o serviço mais solicitado no último mês entre todas as empresas.")
        print("5. Listar para cada empresa o seu faturamento total.")
        print("6. Verificar em qual a cidade houve o maior número de solicitações.")
        print("7. Verificar qual a cidade destino que é mais referenciada nos pedidos e a sua quantidade de pedidos.")
        print("8. Verificar qual o serviço mais solicitado no último mês entre todas as empresas.")
        print("9. Listar para cada empresa o seu faturamento total.")
        print("10. Listar as solicitações feitas no último ano, nome do cliente que as realizou, municípios de origem e destino (se houver) e preço total de cada solicitação.")
        print("11. Sair")
        
        opcao = input("Escolha uma opção: ")
        
        if opcao == '1':
            consulta_servicos_cliente(conn)
        elif opcao == '2':
            consulta_empresa_mais_ofereceu_servicos(conn)
        elif opcao == '3':
            consulta_faturamento_empresas(conn)
        elif opcao == '4':
            consulta_servico_mais_solicitado(conn)
        elif opcao == '5':
            consulta_faturamento_total_empresas(conn)
        elif opcao == '6':
            consulta_cidade_maior_numero_solicitacoes(conn)
        elif opcao == '7':
            consulta_cidade_destino_mais_referenciada(conn)
        elif opcao == '8':
            consulta_servico_mais_solicitado_entre_empresas(conn)
        elif opcao == '9':
            consulta_faturamento_total_por_empresa(conn)
        elif opcao == '10':
            consulta_solicitacoes_ultimo_ano(conn)
        elif opcao == '11':
            print("Encerrando o programa.")
            break
        else:
            print("Opção inválida. Tente novamente.")
    
    conn.close()
#Executa o menu principal
menu_principal()
