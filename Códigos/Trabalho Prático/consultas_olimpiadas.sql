/* A) Apresente os nomes dos estádios, os nomes dos eventos que ocorrerão nesses estádios 
   e os nomes dos comitês olímpicos nacionais associados a esses estádios, ordenados pela 
   capacidade do estádio em ordem decrescente. */

SELECT 
    es.nome AS Estádio, 
    ev.nome AS Evento, 
    con.nome AS Comitê
FROM Estadio es
JOIN Evento ev ON es.id_estadio = ev.id_estadio
JOIN ComiteOlimpicoNacional con ON es.id_comite_olimpico = con.id_comite_olimpico
ORDER BY es.capacidade DESC;

/* B) Liste os nomes dos árbitros, os nomes dos esportes e as modalidades em que arbitram, 
   para árbitros de nacionalidade espanhola, ordenados por nome do árbitro. */

SELECT 
    ar.nome AS Arbitro, 
    es.nome AS Esporte, 
    mo.nome AS Modalidade
FROM Arbitro ar
JOIN Arbitragem arb ON ar.id_arbitro = arb.id_arbitro
JOIN Esporte es ON arb.id_esporte = es.id_esporte
JOIN Modalidade mo ON mo.id_modalidade = arb.id_modalidade
WHERE ar.nacionalidade = 'Espanha' 
ORDER BY ar.nome;

/* C) Liste todos os eventos que ocorrem em estádios cujo nome contém a palavra 'Olímpico' 
   e que estão programados entre 15 e 31 de julho de 2024. */

SELECT 
    ev.id_evento, 
    ev.nome AS nome_evento, 
    es.nome AS nome_estadio, 
    ev.data, 
    coi.nome AS nome_comite
FROM Evento ev
JOIN Estadio es ON ev.id_estadio = es.id_estadio
JOIN ComiteOlimpicoInternacional coi ON es.id_comite_olimpico = coi.id_comite_olimpico
WHERE es.nome LIKE '%Olímpico%'
  AND ev.data BETWEEN '2024-07-15' AND '2024-07-31';

/* D) Liste todos os atletas que competem em modalidades específicas (IDs 1, 2 ou 3) 
   e que possuem um tipo sanguíneo definido (não nulo). */

SELECT 
    at.numero_passaporte, 
    at.nome AS nome_atleta, 
    mo.nome AS nome_modalidade, 
    co.indice_olimpico
FROM Atleta at
JOIN Competicao co ON at.numero_passaporte = co.numero_passaporte_atleta
JOIN Modalidade mo ON co.id_modalidade = mo.id_modalidade
WHERE mo.id_modalidade IN (1, 2, 3)
  AND at.tipo_sanguineo IS NOT NULL;

/* E) Retorne o nome de cada Comitê Olímpico Nacional e a quantidade de atletas associados 
   a cada comitê, ordenados em ordem alfabética. */

SELECT 
    con.nome AS NomeComite,
    COUNT(at.numero_passaporte) AS NumeroDeAtletas
FROM ComiteOlimpicoNacional con
JOIN Atleta at ON con.id_comite_olimpico = at.id_comite_olimpico
GROUP BY con.nome
ORDER BY con.nome;

/* F) Retorne o nome de cada evento e a média de preços dos ingressos para eventos cuja 
   média de preço seja maior que 50. */

SELECT 
    ev.nome AS NomeEvento,
    AVG(ing.preco) AS MediaPrecoIngressos
FROM Evento ev
JOIN Ingresso ing ON ev.id_evento = ing.id_evento
GROUP BY ev.nome
HAVING AVG(ing.preco) > 50
ORDER BY ev.nome;

/* G) Subselect sem correlação que calcula a média de capacidade dos estádios 
   e mostra quais estão acima dessa média. */

SELECT 
    id_estadio, 
    nome, 
    capacidade
FROM Estadio
WHERE capacidade > (SELECT AVG(capacidade) FROM Estadio);

/* H) Subselect com correlação otimizado */

SELECT 
    con.nome, 
    COUNT(at.numero_passaporte) AS total_atletas
FROM ComiteOlimpicoNacional con
LEFT JOIN Atleta at ON at.id_comite_olimpico = con.id_comite_olimpico
GROUP BY con.nome;

/* I) Subselect com EXISTS que retorne o nome de todos os comitês olímpicos nacionais 
   que possuem pelo menos um atleta associado. */

SELECT COALESCE(con.nome, 'Sem Comitê') AS NomeComite
FROM ComiteOlimpicoNacional con
WHERE EXISTS (
    SELECT 1
    FROM Atleta at
    WHERE at.id_comite_olimpico = con.id_comite_olimpico
);

/* J) Retorne o nome dos estádios, o nome dos comitês olímpicos associados 
   e o total de eventos realizados nesses estádios. Apenas estádios com capacidade > 50.000. */

SELECT 
    es.nome AS NomeEstadio, 
    coi.nome AS NomeComite, 
    COUNT(ev.id_evento) AS TotalEventos
FROM Evento ev
JOIN Estadio es ON ev.id_estadio = es.id_estadio
JOIN ComiteOlimpicoInternacional coi ON es.id_comite_olimpico = coi.id_comite_olimpico
WHERE es.capacidade > 50000  
GROUP BY es.nome, coi.nome
HAVING COUNT(ev.id_evento) > 0;
