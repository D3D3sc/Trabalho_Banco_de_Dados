import streamlit as st
import psycopg2
import pandas as pd
from google import genai

# --- CONFIGURAÇÃO DO BANCO (PostgreSQL) ---
DB_CONFIG = {
    "host": "localhost",
    "database": "gamevault",
    "user": "postgres",
    "password": "souzasoares"
}

def get_conn():
    return psycopg2.connect(**DB_CONFIG)

def run_query(query, params=None, fetch=False):
    conn = get_conn()
    cur = conn.cursor()
    cur.execute(query, params)
    data = cur.fetchall() if fetch else None
    cols = [desc[0] for desc in cur.description] if fetch and cur.description else []
    conn.commit()
    cur.close()
    conn.close()
    return pd.DataFrame(data, columns=cols) if fetch else None

# --- INTERFACE STREAMLIT ---
st.set_page_config(page_title="GameVault", layout="wide")
st.title("🎮 GameVault - Sistema de Catálogo de Jogos")

# Sidebar: Manutenção do Banco (Item 7.e) e Chave da IA
with st.sidebar:
    st.header("⚙️ Manutenção & IA")
    gemini_key = st.text_input("Gemini API Key:", type="password")
    
    if st.button("🔄 Resetar e Popular Banco"):
        with open("schema.sql", "r", encoding="utf-8") as f:
            sql_script = f.read()
        run_query(sql_script)
        st.success("Banco recriado e populado com sucesso!")

aba1, aba2, aba3, aba4 = st.tabs([
    "1. CRUD Jogos (Dependências)", 
    "2. Avaliações & N:N", 
    "3. Relatórios & Gráficos", 
    "4. Recomendação IA"
])


# ABA 1: CRUD COMPLETO COM DEPENDÊNCIAS (FKs)
with aba1:
    st.subheader("Gerenciar Jogos")
    
    # Carregar FKs para os Selectboxes
    devs = run_query("SELECT Id_desenvolvedora, Nome_desenvolvedora FROM Desenvolvedora", fetch=True)
    pubs = run_query("SELECT Id_publicadora, Nome_publicadora FROM Publicadoras", fetch=True)
    
    dev_dict = dict(zip(devs["nome_desenvolvedora"], devs["id_desenvolvedora"]))
    pub_dict = dict(zip(pubs["nome_publicadora"], pubs["id_publicadora"]))

    with st.form("form_jogo"):
        col1, col2, col3 = st.columns(3)
        id_jogo = col1.number_input("ID do Jogo", min_value=1, step=1)
        titulo = col2.text_input("Título")
        preco = col3.number_input("Preço (R$)", min_value=0.0, format="%.2f")
        
        col4, col5, col6 = st.columns(3)
        data_lanc = col4.date_input("Data de Lançamento")
        classif = col5.number_input("Classificação Indicativa", min_value=0, max_value=18, step=2)
        dev_sel = col6.selectbox("Desenvolvedora (FK)", list(dev_dict.keys()))
        pub_sel = st.selectbox("Publicadora (FK)", list(pub_dict.keys()))
        
        c_btn1, c_btn2 = st.columns(2)
        if c_btn1.form_submit_button("➕ Inserir Jogo"):
            run_query(
                "INSERT INTO Jogo VALUES (%s, %s, %s, %s, %s, %s, %s)",
                (id_jogo, dev_dict[dev_sel], pub_dict[pub_sel], data_lanc, preco, classif, titulo)
            )
            st.success("Jogo inserido!")
            
        if c_btn2.form_submit_button("✏️ Atualizar Preço/Título pelo ID"):
            run_query(
                "UPDATE Jogo SET Titulo=%s, preco=%s, Id_desenvolvedora=%s WHERE Id_Jogos=%s",
                (titulo, preco, dev_dict[dev_sel], id_jogo)
            )
            st.info("Jogo atualizado!")

    # Listagem e Exclusão
    df_jogos = run_query("""
        SELECT j.Id_Jogos, j.Titulo, j.preco, j.Data_Lancamento, d.Nome_desenvolvedora, p.Nome_publicadora
        FROM Jogo j
        JOIN Desenvolvedora d ON j.Id_desenvolvedora = d.Id_desenvolvedora
        JOIN Publicadoras p ON j.Id_publicadora = p.Id_publicadora
        ORDER BY j.Id_Jogos
    """, fetch=True)
    st.dataframe(df_jogos, use_container_width=True)

    id_del = st.number_input("ID do Jogo para Excluir:", min_value=1, step=1)
    if st.button("🗑️ Deletar Jogo"):
        run_query("DELETE FROM Jogo WHERE Id_Jogos = %s", (id_del,))
        st.warning(f"Jogo {id_del} removido!")
        st.rerun()

# ABA 2: OUTRAS ENTIDADES (Avaliação & N:N)
with aba2:
    col_a, col_b = st.columns(2)
    
    with col_a:
        st.subheader("Nova Avaliação")
        jogos_df = run_query("SELECT Id_Jogos, Titulo FROM Jogo", fetch=True)
        users_df = run_query("SELECT Id_usuario, Nickname FROM Usuario", fetch=True)
        
        jogo_map = dict(zip(jogos_df["titulo"], jogos_df["id_jogos"]))
        user_map = dict(zip(users_df["nickname"], users_df["id_usuario"]))
        
        with st.form("form_aval"):
            id_av = st.number_input("ID Avaliação", min_value=1, step=1)
            u_sel = st.selectbox("Usuário", list(user_map.keys()))
            j_sel = st.selectbox("Jogo", list(jogo_map.keys()))
            nota = st.slider("Nota", 1, 5, 5)
            coment = st.text_input("Comentário")
            if st.form_submit_button("Salvar Avaliação"):
                run_query("INSERT INTO Avaliacao VALUES (%s, %s, %s, %s, %s)",
                          (id_av, user_map[u_sel], jogo_map[j_sel], coment, nota))
                st.success("Avaliação registrada!")

    with col_b:
        st.subheader("Vincular Categoria a Jogo (N:N)")
        cats_df = run_query("SELECT Id_categoria, Genero FROM Categoria", fetch=True)
        cat_map = dict(zip(cats_df["genero"], cats_df["id_categoria"]))
        
        with st.form("form_nn"):
            j_nn = st.selectbox("Selecione o Jogo", list(jogo_map.keys()))
            c_nn = st.selectbox("Selecione a Categoria", list(cat_map.keys()))
            if st.form_submit_button("Vincular Categoria"):
                run_query("INSERT INTO Possui_categoria VALUES (%s, %s)",
                          (cat_map[c_nn], jogo_map[j_nn]))
                st.success("Vínculo N:N criado!")

    st.dataframe(run_query("SELECT * FROM Avaliacao", fetch=True), use_container_width=True)

    st.divider()
    st.subheader("🏆 Gerenciar Conquistas dos Jogos (1:N)")
    
    col_c1, col_c2 = st.columns([1, 2])
    
    with col_c1:
        with st.form("form_conquista"):
            id_conq = st.number_input("ID da Conquista", min_value=1, step=1)
            jogo_conq = st.selectbox("Jogo Associado (FK)", list(jogo_map.keys()), key="sel_jogo_conq")
            nome_conq = st.text_input("Nome da Conquista")
            raridade = st.selectbox("Nível de Raridade", ["Comum", "Incomum", "Rara", "Épica", "Lendária"])
            desc_conq = st.text_area("Descrição do Desafio")
            
            if st.form_submit_button("➕ Adicionar Conquista"):
                run_query(
                    "INSERT INTO Conquistas (Id_conquista, Id_Jogos, Nivel_raridade, Descricao, Nome_conquista) VALUES (%s, %s, %s, %s, %s)",
                    (id_conq, jogo_map[jogo_conq], raridade, desc_conq, nome_conq)
                )
                st.success("Conquista cadastrada!")
                st.rerun()

    with col_c2:
        # Filtro opcional por jogo para facilitar na apresentação
        filtro_jogo = st.selectbox("Filtrar conquistas por jogo:", ["Todos"] + list(jogo_map.keys()))
        
        if filtro_jogo == "Todos":
            df_conq = run_query("""
                SELECT c.Id_conquista, j.Titulo AS Jogo, c.Nome_conquista, c.Nivel_raridade, c.Descricao
                FROM Conquistas c
                JOIN Jogo j ON c.Id_Jogos = j.Id_Jogos
                ORDER BY j.Titulo, c.Id_conquista
            """, fetch=True)
        else:
            df_conq = run_query("""
                SELECT c.Id_conquista, j.Titulo AS Jogo, c.Nome_conquista, c.Nivel_raridade, c.Descricao
                FROM Conquistas c
                JOIN Jogo j ON c.Id_Jogos = j.Id_Jogos
                WHERE j.Id_Jogos = %s
                ORDER BY c.Id_conquista
            """, (jogo_map[filtro_jogo],), fetch=True)
            
        st.dataframe(df_conq, use_container_width=True)
        
        # Exclusão rápida de conquista
        id_del_conq = st.number_input("ID da Conquista para remover:", min_value=1, step=1, key="del_conq")
        if st.button("🗑️ Remover Conquista"):
            run_query("DELETE FROM Conquistas WHERE Id_conquista = %s", (id_del_conq,))
            st.warning(f"Conquista {id_del_conq} removida!")
            st.rerun()

# ABA 3: RELATÓRIOS CONSOLIDADOS (JOIN + GRÁFICOS)
with aba3:
    st.subheader("📊 Relatórios Analíticos (3+ Tabelas com Agregação)")
    
    # Consulta 1: Média de notas e total de avaliações por Jogo e Desenvolvedora (3 tabelas)
    sql_rel1 = """
        SELECT j.Titulo AS Jogo, d.Nome_desenvolvedora AS Desenvolvedora, 
               COUNT(a.Id_avaliacao) AS Total_Avaliacoes, 
               COALESCE(ROUND(AVG(a.Nota_avaliacao), 2), 0)::FLOAT AS Media_Nota
        FROM Jogo j
        JOIN Desenvolvedora d ON j.Id_desenvolvedora = d.Id_desenvolvedora
        LEFT JOIN Avaliacao a ON j.Id_Jogos = a.Id_Jogos
        GROUP BY j.Titulo, d.Nome_desenvolvedora
        ORDER BY Media_Nota DESC
    """
    df_rel1 = run_query(sql_rel1, fetch=True)
    df_rel1["media_nota"] = pd.to_numeric(df_rel1["media_nota"])
    
    st.write("**1. Desempenho dos Jogos por Desenvolvedora:**")
    st.dataframe(df_rel1, use_container_width=True)
    if not df_rel1.empty:
        st.bar_chart(df_rel1.set_index("jogo")["media_nota"])

    # Consulta 2: Preço médio e quantidade de jogos por Categoria (3 tabelas)
    sql_rel2 = """
        SELECT c.Genero AS Categoria, COUNT(j.Id_Jogos) AS Qtd_Jogos, 
               ROUND(AVG(j.preco), 2) AS Preco_Medio
        FROM Categoria c
        JOIN Possui_categoria pc ON c.Id_categoria = pc.Id_categoria
        JOIN Jogo j ON pc.Id_Jogos = j.Id_Jogos
        GROUP BY c.Genero
    """
    df_rel2 = run_query(sql_rel2, fetch=True)
    st.write("**2. Quantidade de Jogos por Categoria:**")
    st.dataframe(df_rel2, use_container_width=True)
    if not df_rel2.empty:
        st.bar_chart(df_rel2.set_index("categoria")["qtd_jogos"])


    # Consulta 3: Jogos e soma de valores por Plataforma (3 tabelas)
    sql_rel3 = """
        SELECT p.Nome_plataforma AS Plataforma, COUNT(j.Id_Jogos) AS Total_Jogos, 
               SUM(j.preco) AS Valor_Total_Catalogo
        FROM Plataforma p
        JOIN Disponivel_em de ON p.Id_Plataforma = de.Id_Plataforma
        JOIN Jogo j ON de.Id_Jogos = j.Id_Jogos
        GROUP BY p.Nome_plataforma
    """
    df_rel3 = run_query(sql_rel3, fetch=True)
    st.write("**3. Disponibilidade de Jogos por Plataforma:**")
    st.dataframe(df_rel3, use_container_width=True)
    if not df_rel3.empty:
        st.bar_chart(df_rel3.set_index("plataforma")["total_jogos"])


# ABA 4: DIFERENCIAL IA GENERATIVA
with aba4:
    st.subheader("🤖 Assistente de Recomendação GameVault (Gemini)")
    pedido_usuario = st.text_input("Descreva que tipo de jogo você procura (ex: 'Quero um RPG difícil ou barato'):")
    
    if st.button("Buscar Recomendação com IA"):
        if not gemini_key:
            st.error("Insira sua Gemini API Key na barra lateral!")
        else:
            # Busca o catálogo atual do banco para dar contexto à IA (RAG simples)
            catalogo = run_query("""
                SELECT j.Titulo, j.preco, d.Nome_desenvolvedora,
                       STRING_AGG(DISTINCT c.Genero, ', ') AS Categorias,
                       STRING_AGG(DISTINCT cq.Nome_conquista || ' (' || cq.Nivel_raridade || ')', '; ') AS Conquistas,
                       MAX(rh.Configuracao_minima) AS Req_Minimo,
                       MAX(rh.Configuracao_recomendada) AS Req_Recomendado,
                       MAX(rh.Espaco_disco) AS Espaco_GB
                FROM Jogo j
                JOIN Desenvolvedora d ON j.Id_desenvolvedora = d.Id_desenvolvedora
                LEFT JOIN Possui_categoria pc ON j.Id_Jogos = pc.Id_Jogos
                LEFT JOIN Categoria c ON pc.Id_categoria = c.Id_categoria
                LEFT JOIN Conquistas cq ON j.Id_Jogos = cq.Id_Jogos
                LEFT JOIN Exige e ON j.Id_Jogos = e.Id_Jogos
                LEFT JOIN Requisito_Hardware rh ON e.Id_hardware = rh.Id_hardware
                GROUP BY j.Id_Jogos, j.Titulo, j.preco, d.Nome_desenvolvedora
            """, fetch=True).to_string()
            
            client = genai.Client(api_key=gemini_key)
            prompt = f"Com base APENAS neste catálogo do banco de dados:\n{catalogo}\n\nResponda ao pedido do usuário: {pedido_usuario}"
            resposta = client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
            st.info(resposta.text)