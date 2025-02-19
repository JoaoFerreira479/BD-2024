/* CRIAÇÃO DE ÍNDICES */

-- Índice para otimizar buscas por nome do atleta

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_nome_atleta' AND object_id = OBJECT_ID('Atleta'))
CREATE INDEX idx_nome_atleta ON Atleta(nome);
GO

-- Índice para otimizar consultas por estádio nos eventos

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_evento_id_estadio' AND object_id = OBJECT_ID('Evento'))
CREATE INDEX idx_evento_id_estadio ON Evento(id_estadio);
GO

-- Índice adicional para otimizar consultas por Comitê Olímpico dos atletas

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_comite_olimpico' AND object_id = OBJECT_ID('Atleta'))
CREATE INDEX idx_comite_olimpico ON Atleta(id_comite_olimpico);
GO

-- Índice para otimizar consultas por modalidade nos eventos

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_modalidade_evento' AND object_id = OBJECT_ID('Evento'))
CREATE INDEX idx_modalidade_evento ON Evento(modalidade);
GO

-- Índice para otimizar consultas de ingressos por evento (MELHORIA)

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_ingresso_evento' AND object_id = OBJECT_ID('Ingresso'))
CREATE INDEX idx_ingresso_evento ON Ingresso(id_evento);
GO

/* CRIAÇÃO DE VIEWS PARA FACILITAR CONSULTAS */

-- View para obter informações dos atletas e seus respectivos Comitês Olímpicos Nacionais

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

-- View para listar os eventos e seus respectivos estádios

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

-- View adicional para exibir informações detalhadas sobre os eventos e os Comitês Olímpicos Internacionais responsáveis pelos estádios

IF OBJECT_ID('dbo.v_Eventos_ComiteInternacional', 'V') IS NOT NULL
DROP VIEW dbo.v_Eventos_ComiteInternacional;
GO

CREATE VIEW v_Eventos_ComiteInternacional  
WITH SCHEMABINDING  
AS  
SELECT E.nome AS nome_evento, 
       E.data, 
       E.horario_inicio, 
       E.horario_termino, 
       E.modalidade, 
       S.nome AS nome_estadio, 
       S.capacidade, 
       COI.nome AS nome_comite_internacional  
FROM dbo.Evento E  
JOIN dbo.Estadio S  
ON E.id_estadio = S.id_estadio  
JOIN dbo.ComiteOlimpicoInternacional COI  
ON S.id_comite_olimpico = COI.id_comite_olimpico;
GO
