INSERT INTO brh.departamento (sigla, nome, chefe, departamento_superior) 
VALUES ('BI', 'Especialista de Neg�cios', 'I123', 'DEPTI');


INSERT INTO brh.endereco (cep, uf, cidade, bairro) 
VALUES ('12237800', 'SP', 'S�o Jos� dos Campos', 'Palmeiras de S�o Jos�');


INSERT INTO brh.colaborador (
matricula, nome, cpf, salario, 
departamento, cep, logradouro, complemento_endereco) 
VALUES (
'AA123', 'Fulano de Tal', '123.456.789-01', '10000', 'BI', 
'12237800', 'Avenida do Verd�o', 'Casa do Mundial');

INSERT INTO brh.telefone_colaborador (colaborador, numero, tipo) --CELULAR (M�VEL)
VALUES ('AA123', '(61) 9 9999-9999', 'M'); 

INSERT INTO brh.telefone_colaborador (colaborador, numero, tipo) --RESIDENCIAL
VALUES ('AA123', '(61) 3030-4040', 'R');

INSERT INTO brh.email_colaborador (colaborador, email, tipo) -- E-MAIL PESSOAL
VALUES ('AA123', 'fulano@email.com', 'P');

INSERT INTO brh.email_colaborador (colaborador, email, tipo) --E-MAIL CORPORATIVO
VALUES ('AA123', 'fulano.tal@brh.com', 'C');

INSERT INTO brh.dependente (cpf, colaborador, nome, parentesco, data_nascimento) --FILHA
VALUES ('253.361.502-60', 'AA123', 'Beltrana de Tal', 'Filho(a)', to_date('2018-01-01', 'yyyy-mm-dd'));

INSERT INTO brh.dependente (cpf, colaborador, nome, parentesco, data_nascimento) --ESPOSA
VALUES ('143.361.552-67', 'AA123', 'Cicrana de Tal', 'Cônjuge', to_date('2000-01-01', 'yyyy-mm-dd'));

SELECT * FROM brh.dependente where colaborador = 'AA123';

UPDATE brh.colaborador 
set nome = 'Maria Mendon�a'
where matricula = 'M123';

Select * from brh.colaborador where matricula = 'M123';

-- com adapta��es do ChatGPT--hehe --consulta que lista matr�cula do colaborador; nome do dependente e data de nascimento do dependente que s�o conjuge.   
SELECT 
    c.matricula AS matricula,
    d.nome AS nome_dependente,
    d.data_nascimento AS data_nascimento
FROM 
    brh.colaborador c
INNER JOIN 
    brh.dependente d ON c.matricula = d.colaborador
WHERE 
    d.parentesco = 'Cônjuge';
    
    
SELECT 
    c.matricula AS matricula,
    t.numero AS telefone_colaborador
FROM 
    brh.colaborador c
INNER JOIN 
    brh.telefone_colaborador t ON c.matricula = t.colaborador
WHERE 
    t.tipo IN ('M', 'R')
ORDER BY 
    c.matricula, t.numero;
    
-- Remover dependentes associados aos colaboradores do departamento SECAP
DELETE FROM brh.dependente
WHERE colaborador IN (SELECT matricula FROM brh.colaborador WHERE departamento = 'SECAP');

-- remover da tabela e-mail
DELETE FROM brh.email_colaborador
WHERE colaborador IN (SELECT matricula FROM brh.colaborador WHERE departamento = 'SECAP');

-- remover da tabela telefone
DELETE FROM brh.telefone_colaborador
WHERE colaborador IN (SELECT matricula FROM brh.colaborador WHERE departamento = 'SECAP');

-- remover os colaboradores do departamento SECAP
DELETE FROM brh.colaborador
WHERE departamento = 'SECAP';

-- remover o departamento SECAP da tabela de departamentos
DELETE FROM brh.departamento
WHERE sigla = 'SECAP';

SELECT * FROM brh.departamento where sigla = 'SECAP';

--seleciona a sigla e o nome do departamento dos colaboradores que moram no CEP 71777-700 e trabalham nos departamentos SECAP ou SESEG, ordenados pelo nome do departamento.
SELECT 
    d.sigla,d.nome 
FROM 
    brh.colaborador c
-- cl�usula JOIN em SQL � usada para combinar linhas de duas ou mais tabelas com base em uma condi��o especificada. No seu caso, voc� est� usando um JOIN entre as tabelas colaborador (abreviada como c) e departamento (abreviada como d).
--A express�o ON c.departamento = d.sigla � a condi��o de jun��o. Isso significa que voc� est� combinando as linhas das tabelas onde o valor da coluna departamento na tabela colaborador � igual ao valor da coluna sigla na tabela departamento.
--Essa jun��o � �til quando voc� precisa buscar informa��es de uma tabela com base nos relacionamentos definidos em outra tabela. No seu caso, voc� est� relacionando os colaboradores aos departamentos em que trabalham, utilizando a sigla do departamento como chave de relacionamento.
JOIN 
    brh.departamento d ON c.departamento = d.sigla 
WHERE 
    (c.cep = '71777-700' AND d.sigla IN ('SECAP', 'SESEG'))
ORDER BY 
    d.nome;
    
   
SELECT 
    c.matricula, 
    d.nome AS nome_dependente,
    FLOOR(MONTHS_BETWEEN(SYSDATE, d.data_nascimento) / 12) AS idade_dependente
FROM 
    brh.colaborador c
JOIN 
    brh.dependente d ON c.matricula = d.colaborador
WHERE 
    FLOOR(MONTHS_BETWEEN(SYSDATE, d.data_nascimento) / 12) < 18;
    
FROM brh.colaborador c JOIN brh.dependente d ON c.matricula = d.matricula: Aqui, voc� est� especificando as tabelas das quais voc� est� selecionando os dados (colaborador abreviado como c e dependente abreviado como d). Est� sendo usado um JOIN para combinar as linhas dessas tabelas onde a matr�cula do colaborador na tabela colaborador � igual � matr�cula do dependente na tabela dependente.

WHERE FLOOR(MONTHS_BETWEEN(SYSDATE, d.data_nascimento) / 12) < 18: Esta cl�usula WHERE filtra os resultados. Ela garante que apenas as linhas cuja idade do dependente, calculada anteriormente, seja menor que 18 anos sejam inclu�das no resultado. Isso significa que apenas os dependentes menores de 18 anos em rela��o � data atual ser�o listados.

--SELECT c.matricula, d.nome AS nome_dependente, FLOOR(MONTHS_BETWEEN(SYSDATE, d.data_nascimento) / 12) AS idade_dependente: Esta parte da consulta � a sele��o das colunas que ser�o exibidas no resultado. Voc� est� selecionando a matr�cula do colaborador (c.matricula), o nome do dependente (d.nome renomeado como nome_dependente) e calculando a idade do dependente. O c�lculo � realizado usando a fun��o MONTHS_BETWEEN, que retorna o n�mero de meses entre duas datas (a data atual, SYSDATE, e a data de nascimento do dependente, d.data_nascimento). Depois, dividimos esse valor por 12 e usamos a fun��o FLOOR para arredondar o resultado para baixo, obtendo a idade em anos.
--SYSDATE: Esta fun��o retorna a data e hora atuais do sistema no formato padr�o do banco de dados. No contexto do Oracle, SYSDATE retorna a data e hora atuais.
--MONTHS_BETWEEN(SYSDATE, d.data_nascimento): A fun��o MONTHS_BETWEEN calcula o n�mero de meses entre duas datas. Neste caso, estamos calculando a diferen�a em meses entre a data atual (SYSDATE) e a data de nascimento do dependente (d.data_nascimento).
--FLOOR(...): Esta fun��o arredonda um n�mero para baixo, retornando o maior n�mero inteiro menor ou igual ao n�mero especificado. Aqui, estamos usando FLOOR para garantir que obtenhamos apenas a parte inteira do resultado da divis�o.
--/ 12: Estamos dividindo o n�mero de meses entre a data atual e a data de nascimento do dependente por 12 para converter essa diferen�a de meses em anos.
--Ent�o, no final, FLOOR(MONTHS_BETWEEN(SYSDATE, d.data_nascimento) / 12) nos fornece a idade do dependente em anos, calculada com base na diferen�a entre a data atual e a data de nascimento do dependente. Este valor � atribu�do � coluna idade_dependente na consulta.