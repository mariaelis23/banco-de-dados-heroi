# banco-de-dados-heroi


# *************************************
# DOCUMENTAÇÃO DO SISTEMA DE GERENCIAMENTO DE HERÓIS
# *************************************

# Visão Geral:
# Este sistema permite cadastrar e gerenciar heróis, incluindo informações como nome,
# descrição, missão, popularidade e status. A aplicação usa FastAPI para criar uma API,
# SQLAlchemy para interagir com o banco de dados PostgreSQL, e um frontend simples com HTML, CSS e JavaScript.
#
# A estrutura do projeto é composta por:
# - Backend: API com FastAPI, banco de dados com PostgreSQL e SQLAlchemy.
# - Frontend: Interface com HTML, CSS e JavaScript para interação com a API.
#
# Tecnologias utilizadas:
# Backend:
#   - FastAPI: Framework para criar APIs de forma rápida.
#   - SQLAlchemy: ORM (Object-Relational Mapper) para interação com o banco de dados.
#   - PostgreSQL: Banco de dados relacional para armazenar os dados dos heróis.
# Frontend:
#   - HTML5 e CSS3: Para estruturação e estilização da página.
#   - JavaScript: Para interação com a API e manipulação dos dados no frontend.

# Estrutura de Pastas:
# O sistema está organizado em duas pastas principais:
# 1. backend/
#    - database.py: Configuração do banco de dados.
#    - models.py: Definição dos modelos de dados (como a tabela de heróis).
#    - main.py: Arquivo principal que define as rotas da API.
# 2. frontend/
#    - index.html: Página principal com a interface de usuário.
#    - js/index.js: Funções JavaScript para enviar e exibir dados.
#    - css/index.css: Estilos da página.

# *************************************
# BACKEND (FastAPI)
# *************************************

# 1. models.py:
# Este arquivo define a tabela de heróis no banco de dados. A tabela contém as seguintes colunas:
# - id: Identificador único para cada herói.
# - name: Nome do herói.
# - description: Descrição do herói (opcional).
# - missao: Missão do herói (opcional).
# - popularidade: Nível de popularidade (padrão 0).
# A tabela será gerada no banco de dados quando o sistema for inicializado.

from sqlalchemy import Column, Integer, String
from database import Base

class Heroi(Base):
    __tablename__ = "herois"

    id = Column(Integer, primary_key=True, index=True)  # ID único do herói
    name = Column(String, index=True)  # Nome do herói
    description = Column(String, nullable=True)  # Descrição do herói (opcional)
    missao = Column(String, nullable=True)  # Missão do herói (opcional)
    popularidade = Column(Integer, default=0)  # Popularidade do herói (padrão 0)

# 2. main.py:
# O arquivo principal define as rotas da API para as operações CRUD:
# - POST: Cria um novo herói.
# - GET: Busca os heróis cadastrados ou um herói específico.
# - PUT: Atualiza os dados de um herói.
# - DELETE: Exclui um herói do banco de dados.

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db, engine, Base
from models import Heroi
from pydantic import BaseModel

app = FastAPI()

# Criação das tabelas no banco de dados
Base.metadata.create_all(bind=engine)

# Modelos Pydantic para validação dos dados
class HeroiCreate(BaseModel):
    name: str
    description: str | None = None
    missao: str | None = None
    popularidade: int | None = 0

class HeroiResponse(HeroiCreate):
    id: int

    class Config:
        orm_mode = True

# Rota POST para criar um herói
@app.post("/herois/", response_model=HeroiResponse)
def create_heroi(heroi: HeroiCreate, db: Session = Depends(get_db)):
    db_heroi = Heroi(
        name=heroi.name,
        description=heroi.description,
        missao=heroi.missao,
        popularidade=heroi.popularidade,
    )
    db.add(db_heroi)  # Adiciona o herói à sessão
    db.commit()  # Salva as alterações no banco
    db.refresh(db_heroi)  # Atualiza o herói com os dados do banco
    return db_heroi

# 3. database.py:
# Este arquivo configura a conexão com o banco de dados PostgreSQL.
# Ele cria a sessão do banco e oferece uma função para obter a conexão.

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Configuração do banco de dados PostgreSQL
DATABASE_URL = "postgresql://usuario:senha@localhost:5432/heroi-db"

# Criação da engine de conexão com o banco de dados PostgreSQL
engine = create_engine(DATABASE_URL)  # Conexão com o banco de dados PostgreSQL
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base para definir os modelos de dados (como a tabela de heróis)
Base = declarative_base()

# Função para obter uma sessão do banco de dados
def get_db():
    db = SessionLocal()  # Cria uma nova sessão com o banco
    try:
        yield db  # Retorna a sessão para ser utilizada nas rotas
    finally:
        db.close()  # Fecha a sessão após o uso

# *************************************
# FRONTEND (HTML, CSS, JavaScript)
# *************************************

# 1. index.html:
# A página HTML exibe um formulário para cadastrar heróis e uma tabela para mostrar
# os heróis cadastrados. O frontend também permite buscar e filtrar os heróis por nome, 
# status e popularidade.

<h1>Heróis</h1>
<button id="btn-new-hero">Cadastrar herói</button> <br>

<!-- Filtros para pesquisa -->
<label for="search-name">Buscar por nome:</label>
<input type="text" id="search-name" oni

