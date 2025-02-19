/* CRIAÇÃO DO BANCO DE DADOS */

USE [master]
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'JogosOlimpicos')
BEGIN
    CREATE DATABASE [JogosOlimpicos]
    COLLATE SQL_Latin1_General_CP1_CI_AI
    ON PRIMARY 
    ( NAME = N'JogosOlimpicos', 
      FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\JogosOlimpicos.mdf', 
      SIZE = 8192KB, 
      MAXSIZE = UNLIMITED, 
      FILEGROWTH = 65536KB )
    LOG ON 
    ( NAME = N'JogosOlimpicos_log', 
      FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\JogosOlimpicos_log.ldf', 
      SIZE = 8192KB, 
      MAXSIZE = 2048GB, 
      FILEGROWTH = 65536KB )
END
GO

USE [JogosOlimpicos]
GO

/* CONFIGURAÇÕES DO BANCO DE DADOS */

ALTER DATABASE [JogosOlimpicos] SET COMPATIBILITY_LEVEL = 150;
ALTER DATABASE [JogosOlimpicos] SET RECOVERY SIMPLE;
ALTER DATABASE [JogosOlimpicos] SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE [JogosOlimpicos] SET MULTI_USER;
GO

/* TABELA: Comitê Olímpico Internacional */

CREATE TABLE ComiteOlimpicoInternacional (
    id_comite_olimpico INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);
GO

/* TABELA: Comitê Olímpico Nacional */

CREATE TABLE ComiteOlimpicoNacional (
    id_comite_olimpico INT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    bandeira VARCHAR(255) NULL,
    id_comite_olimpico_internacional INT NULL,
    FOREIGN KEY (id_comite_olimpico_internacional) REFERENCES ComiteOlimpicoInternacional(id_comite_olimpico)
);
GO

/* TABELA: Atleta */

CREATE TABLE Atleta (
    numero_passaporte INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    peso FLOAT CHECK (peso > 0),
    data_nascimento DATE NOT NULL,
    sexo CHAR(1) NOT NULL CHECK (sexo IN ('M', 'F')),
    tipo_sanguineo VARCHAR(4) NULL,
    altura FLOAT CHECK (altura > 0),
    id_comite_olimpico INT NOT NULL,
    FOREIGN KEY (id_comite_olimpico) REFERENCES ComiteOlimpicoNacional(id_comite_olimpico)
);
GO

/* TABELA: Árbitro */

CREATE TABLE Arbitro (
    id_arbitro INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sexo CHAR(1) NOT NULL CHECK (sexo IN ('M', 'F')),
    data_nascimento DATE NOT NULL,
    nacionalidade VARCHAR(50) NOT NULL
);
GO

/* TABELA: Esporte */

CREATE TABLE Esporte (
    id_esporte INT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    genero_masculino BIT NOT NULL
);
GO

/* TABELA: Modalidade */

CREATE TABLE Modalidade (
    id_modalidade INT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    ind_coletivo BIT NOT NULL,
    id_esporte INT NOT NULL,
    FOREIGN KEY (id_esporte) REFERENCES Esporte(id_esporte)
);
GO

/* TABELA: Estádio */

CREATE TABLE Estadio (
    id_estadio INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    capacidade INT CHECK (capacidade > 0),
    id_comite_olimpico INT NULL,
    FOREIGN KEY (id_comite_olimpico) REFERENCES ComiteOlimpicoInternacional(id_comite_olimpico)
);
GO

/* TABELA: Evento */

CREATE TABLE Evento (
    id_evento INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data DATE NOT NULL,
    horario_inicio DATETIME NOT NULL,
    horario_termino DATETIME NOT NULL,
    modalidade VARCHAR(100) NOT NULL,
    id_estadio INT NOT NULL,
    FOREIGN KEY (id_estadio) REFERENCES Estadio(id_estadio)
);
GO

/* TABELA: Arbitragem (Relaciona Árbitros e Esportes) */

CREATE TABLE Arbitragem (
    id_esporte INT NOT NULL,
    id_arbitro INT NOT NULL,
    PRIMARY KEY (id_esporte, id_arbitro),
    FOREIGN KEY (id_esporte) REFERENCES Esporte(id_esporte),
    FOREIGN KEY (id_arbitro) REFERENCES Arbitro(id_arbitro)
);
GO

/* TABELA: Competição (Relaciona Atletas e Modalidades) */

CREATE TABLE Competicao (
    numero_passaporte_atleta INT NOT NULL,
    indice_olimpico DECIMAL(10,2) NOT NULL,
    id_modalidade INT NOT NULL,
    PRIMARY KEY (numero_passaporte_atleta, id_modalidade),
    FOREIGN KEY (numero_passaporte_atleta) REFERENCES Atleta(numero_passaporte),
    FOREIGN KEY (id_modalidade) REFERENCES Modalidade(id_modalidade)
);
GO

/* TABELA: Torcedor */

CREATE TABLE Torcedor (
    passaporte INT PRIMARY KEY,
    pais VARCHAR(20) NOT NULL,
    num_cartao_credito VARCHAR(16) NULL,
    endereco_residencial VARCHAR(200) NULL
);
GO

/* TABELA: Ingresso */

CREATE TABLE Ingresso (
    id_ingresso INT IDENTITY(1,1) PRIMARY KEY,
    preco FLOAT CHECK (preco > 0),
    setor_assento VARCHAR(50) NULL,
    numero_assento INT CHECK (numero_assento > 0),
    passaporte_torcedor INT NOT NULL,
    id_evento INT NOT NULL,
    FOREIGN KEY (id_evento) REFERENCES Evento(id_evento),
    FOREIGN KEY (passaporte_torcedor) REFERENCES Torcedor(passaporte)
);
GO

/* TABELA: Telefone (Relaciona Comitês Olímpicos) */

CREATE TABLE Telefone (
    id_telefone INT PRIMARY KEY,
    numero VARCHAR(20) NOT NULL,
    id_comite_olimpico INT NOT NULL,
    FOREIGN KEY (id_comite_olimpico) REFERENCES ComiteOlimpicoInternacional(id_comite_olimpico)
);
GO

/* CRIAÇÃO DE ÍNDICES */

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_nome_atleta' AND object_id = OBJECT_ID('Atleta'))
CREATE INDEX idx_nome_atleta ON Atleta(nome);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_evento_id_estadio' AND object_id = OBJECT_ID('Evento'))
CREATE INDEX idx_evento_id_estadio ON Evento(id_estadio);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_comite_olimpico' AND object_id = OBJECT_ID('Atleta'))
CREATE INDEX idx_comite_olimpico ON Atleta(id_comite_olimpico);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_modalidade_evento' AND object_id = OBJECT_ID('Evento'))
CREATE INDEX idx_modalidade_evento ON Evento(modalidade);
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_ingresso_evento' AND object_id = OBJECT_ID('Ingresso'))
CREATE INDEX idx_ingresso_evento ON Ingresso(id_evento);
GO

/* CRIAÇÃO DE VIEWS PARA FACILITAR CONSULTAS */

IF OBJECT_ID('dbo.v_Atletas_ComiteNacional', 'V') IS NOT NULL
DROP VIEW dbo.v_Atletas_ComiteNacional;
GO

CREATE VIEW v_Atletas_ComiteNacional  
WITH SCHEMABINDING  
AS  
SELECT A.nome AS nome_atleta, 
       A.sexo, 
       A.data_nascimento, 
       A.peso, 
       A.altura, 
       CN.nome AS nome_comite_nacional  
FROM dbo.Atleta A  
JOIN dbo.ComiteOlimpicoNacional CN  
ON A.id_comite_olimpico = CN.id_comite_olimpico;
GO

IF OBJECT_ID('dbo.v_Eventos_Estadio', 'V') IS NOT NULL
DROP VIEW dbo.v_Eventos_Estadio;
GO

CREATE VIEW v_Eventos_Estadio  
WITH SCHEMABINDING  
AS  
SELECT E.nome AS nome_evento, 
       E.data, 
       E.horario_inicio, 
       E.horario_termino, 
       E.modalidade, 
       S.nome AS nome_estadio, 
       S.endereco, 
       S.capacidade  
FROM dbo.Evento E  
JOIN dbo.Estadio S  
ON E.id_estadio = S.id_estadio;
GO

/* AJUSTES FINAIS */

ALTER DATABASE [JogosOlimpicos] SET  READ_WRITE;
GO