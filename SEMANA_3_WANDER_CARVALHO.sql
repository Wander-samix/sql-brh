--SEMANA 3

-- CARD 1 - Criar uma consulta que liste os dependentes que nasceram em abril, maio ou junho, ou tenham a letra "h" no nome.;

SELECT c.nome AS nome_colaborador, d.nome AS nome_dependente, d.data_nascimento, d.parentesco, d.cpf
FROM brh.dependente d
INNER JOIN brh.colaborador c ON d.colaborador = c.matricula
WHERE
    TO_CHAR(d.DATA_NASCIMENTO, 'MM') IN ('04', '05', '06')
    OR d.NOME LIKE '%h%'
ORDER BY c.nome ASC, d.NOME ASC;

-- CARD 2 - Criar consulta que liste nome e o sal�rio do colaborador com o maior sal�rio
    
SELECT nome, salario
FROM brh.colaborador
WHERE
salario = (
    SELECT MAX(salario)
    FROM brh.colaborador
);  
-- A subconsulta (SELECT MAX(salario) FROM BRH.colaborador encontra o maior sal�rio entre todos os colaboradores.
-- A consulta principal seleciona o nome e o salario dos colaboradores cujo sal�rio corresponde ao valor encontrado pela subconsulta. Verificar LIMIT com Order BY - desempenho da consulta.

--CARD 3 - Relat�rio de senioridade

SELECT
    matricula,
    nome,
    salario,
    CASE
        WHEN salario <= 3000 THEN 'J�nior'
        WHEN salario > 3000 AND salario <= 6000 THEN 'Pleno'
        WHEN salario > 6000 AND salario <= 20000 THEN 'S�nior'
        ELSE 'Corpo diretor'
    END AS senioridade
FROM
    brh.colaborador
    
-- CARD 4 - Listar quantidade de colaboradores em projetos

SELECT 
d.nome, 
p.nome as nome_projeto, 
COUNT(*) 
FROM brh.departamento d 
INNER JOIN brh.colaborador c on d.sigla = c.departamento 
INNER JOIN brh.atribuicao a on c.matricula = a.colaborador 
INNER JOIN brh.projeto p on a.projeto= p.id 
GROUP BY d.nome, p.nome 
ORDER BY d.nome, p.nome;

--Explica��o:
--Sele��o de Colunas:
--d.nome: Seleciona o nome do departamento da tabela departamento.
--p.nome as nome_projeto: Seleciona o nome do projeto da tabela projeto e o renomeia como nome_projeto para clareza na sa�da.

--Jun��es:
--INNER JOIN brh.colaborador c on d.sigla = c.departamento: Junta a tabela departamento com a tabela colaborador, usando a condi��o de que a sigla do departamento deve ser igual ao departamento do colaborador. Isso significa que somente os colaboradores que pertencem a um departamento espec�fico ser�o inclu�dos.
--INNER JOIN brh.atribuicao a on c.matricula = a.colaborador: Junta o resultado da jun��o anterior com a tabela atribuicao, baseando-se na condi��o de que a matr�cula do colaborador deve corresponder ao colaborador na tabela atribuicao. Isso inclui apenas as atribui��es que pertencem aos colaboradores j� filtrados.
--INNER JOIN brh.projeto p on a.projeto = p.id: Junta o resultado da jun��o anterior com a tabela projeto, onde o id do projeto em atribuicao deve corresponder ao id do projeto em projeto. Isso filtra ainda mais os dados para incluir apenas os projetos aos quais os colaboradores foram atribu�dos.

--Agrupamento:
--GROUP BY d.nome, p.nome: Agrupa os resultados pelas colunas d.nome (nome do departamento) e p.nome (nome do projeto). Isso � necess�rio para a fun��o de agrega��o COUNT(*), para contar o n�mero de registros em cada grupo �nico de departamento e projeto.

--Fun��o de Agrega��o:
--COUNT(*): Conta o n�mero total de registros em cada grupo formado pela cl�usula GROUP BY. Isso indica o n�mero de atribui��es (ou, de forma indireta, o n�mero de colaboradores) para cada combina��o de departamento e projeto.

--Ordena��o dos Resultados:
--ORDER BY d.nome, p.nome: Ordena os resultados primeiro pelo nome do departamento e depois pelo nome do projeto. Isso significa que os resultados ser�o listados de forma organizada, primeiramente agrupados por departamento e, dentro de cada departamento, ordenados pelos nomes dos projetos.


--CARD 5 - Listar colaboradores com mais dependentes

SELECT c.nome as nome_colaborador, COUNT(*) as Quantidade
FROM brh.colaborador c
INNER JOIN brh.dependente d 
on c.matricula = d.colaborador
GROUP BY c.nome
HAVING COUNT(*) >=2
ORDER BY COUNT(*) DESC, c.nome ASC;

--Explica��o:

--Sele��o de Colunas
--c.nome as nome_colaborador: Seleciona o nome do colaborador da tabela colaborador e o renomeia como nome_colaborador para a sa�da.
--COUNT(*) as qtd: Usa a fun��o de agrega��o COUNT(*) para contar o n�mero total de linhas (dependentes) que correspondem a cada colaborador, e nomeia essa contagem como qtd (quantidade) para a sa�da.

--Jun��es:
--INNER JOIN brh.dependente d on c.matricula = d.colaborador: Realiza uma jun��o interna entre as tabelas colaborador e dependente com base na condi��o de que a matr�cula do colaborador na tabela colaborador deve ser igual � coluna colaborador na tabela dependente. Isso efetivamente filtra os dados para incluir apenas os colaboradores que t�m dependentes.

--Agrupamento:
--GROUP BY c.nome: Agrupa os resultados pelo nome do colaborador. Isso � necess�rio para a fun��o de agrega��o COUNT(*), permitindo contar o n�mero de dependentes para cada colaborador individualmente.

--Filtro de Agrupamento:
--HAVING COUNT(*) >= 2: Aplica um filtro sobre os grupos criados pela cl�usula GROUP BY, selecionando apenas aqueles grupos (ou seja, colaboradores) que t�m dois ou mais dependentes associados a eles. A cl�usula HAVING � usada aqui em vez de WHERE porque estamos filtrando grupos, n�o linhas individuais.

--Ordena��o dos Resultados:
--ORDER BY COUNT(*) DESC, c.nome ASC: Ordena os resultados primeiramente pela quantidade de dependentes de forma descendente (DESC), de modo que os colaboradores com mais dependentes apare�am primeiro. Em caso de empate na quantidade de dependentes, os resultados s�o ent�o ordenados pelo nome do colaborador de forma ascendente (ASC), garantindo que a listagem seja alfab�tica dentro de cada n�vel de quantidade de dependentes.



--CARD IMPORTANTE 1 - Relat�rio anal�tico de equipes

SELECT 
    p.nome AS projeto_atual,
    c.nome AS nome_colaborador,
    COALESCE(
        LISTAGG(dep.nome || ' (' || dep.parentesco || ')', ', ') WITHIN GROUP (ORDER BY dep.nome), 
        'Nada Consta'
    ) AS dependentes,
    d.nome AS nome_departamento,
    chefe.nome AS nome_chefe,
    pa.nome AS nome_papel,
    COALESCE(tm.numero, 'Nada Consta') AS telefone_movel_colaborador,
    COALESCE(tr.numero, 'Nada Consta') AS telefone_residencial_colaborador
FROM brh.departamento d
INNER JOIN brh.colaborador c ON d.sigla = c.departamento
INNER JOIN brh.colaborador chefe ON d.chefe = chefe.matricula
INNER JOIN brh.atribuicao a ON c.matricula = a.colaborador
INNER JOIN brh.projeto p ON a.projeto = p.id
INNER JOIN brh.papel pa ON a.papel = pa.id
LEFT JOIN brh.telefone_colaborador tm ON c.matricula = tm.colaborador AND tm.tipo = 'M'
LEFT JOIN brh.telefone_colaborador tr ON c.matricula = tr.colaborador AND tr.tipo = 'R'
LEFT JOIN brh.dependente dep ON c.matricula = dep.colaborador
GROUP BY p.nome, c.nome, d.nome, chefe.nome, pa.nome, tm.numero, tr.numero
ORDER BY p.nome, c.nome;

--Explica��o
--Esta consulta SQL est� projetada para extrair informa��es detalhadas sobre colaboradores de um banco de dados de recursos humanos, incluindo informa��es sobre os departamentos aos quais est�o alocados, seus chefes, os projetos atuais em que est�o trabalhando, seus pap�is nesses projetos, at� dois n�meros de telefone para cada um, e os nomes de seus dependentes. A consulta faz uso de v�rias jun��es (INNER JOIN e LEFT JOIN) para unir as informa��es de diferentes tabelas relacionadas, e ordena os resultados por nome do projeto, nome do colaborador e nome do dependente.

--Sele��o de Campos
--d.nome AS nome_departamento: Seleciona o nome do departamento.
--chefe.nome AS nome_chefe: Seleciona o nome do chefe do departamento, que � obtido por uma jun��o da tabela departamento com a tabela colaborador.
--c.nome AS nome_colaborador: Seleciona o nome do colaborador.
--p.nome AS projeto_atual: Seleciona o nome do projeto atual no qual o colaborador est� trabalhando.
--pa.nome AS nome_papel: Seleciona o nome do papel que o colaborador desempenha no projeto.
--t1.numero AS telefone1_colaborador e t2.numero AS telefone2_colaborador: Tentam selecionar dois n�meros de telefone para o colaborador, assumindo que possam existir mais de um.
--dep.nome AS nome_dependente: Seleciona o nome dos dependentes associados ao colaborador.

--Jun��es
--Jun��es INNER JOIN: Usadas para relacionar estritamente tabelas onde a correspond�ncia de chaves � esperada, assegurando que s� ser�o retornados os registros que tenham correspond�ncia nas tabelas relacionadas.
--brh.departamento com brh.colaborador (para chefe e colaboradores): Para relacionar colaboradores aos seus departamentos e identificar o chefe de cada departamento.
--brh.atribuicao com brh.colaborador: Para ligar colaboradores �s suas atribui��es de projetos.
--brh.projeto com brh.atribuicao: Para conectar as atribui��es aos projetos espec�ficos.
--brh.papel com brh.atribuicao: Para identificar o papel desempenhado pelo colaborador no projeto.
--Jun��es LEFT JOIN: Usadas para incluir todos os registros da tabela � esquerda (brh.colaborador), mesmo se n�o houver correspond�ncia na tabela � direita (brh.telefone_colaborador, brh.dependente). Isso � �til para casos em que alguns colaboradores podem n�o ter telefones registrados ou dependentes.
--brh.telefone_colaborador (duas vezes): Para tentar obter dois n�meros de telefone por colaborador. No entanto, como destacado anteriormente, sem crit�rios adicionais para distinguir t1 de t2, esta abordagem pode n�o funcionar como esperado.
--brh.dependente: Para listar dependentes associados a cada colaborador.

--Ordena��o
--A consulta ordena os resultados primeiro pelo nome do projeto, depois pelo nome do colaborador, e finalmente pelo nome do dependente. Isso organiza os dados de uma maneira que agrupa colaboradores pelo projeto em que est�o trabalhando e, dentro de cada projeto, ordena-os alfabeticamente, juntamente com seus dependentes, tamb�m em ordem alfab�tica.

--Fun��o LISTAGG
--LISTAGG � uma fun��o de agrega��o em Oracle SQL que concatena valores de v�rias linhas de uma coluna em uma �nica string, separada por um delimitador definido pelo usu�rio. Neste caso, usamos LISTAGG para juntar os nomes dos dependentes e seus parentescos em uma coluna dependentes.
--Dentro do LISTAGG, usamos a concatena��o de strings (||) para unir o nome do dependente (dep.nome) e seu parentesco (dep.parentesco), separados por par�nteses. Esses pares nome-parentesco s�o ent�o separados uns dos outros por v�rgulas na string resultante.

--Tratamento de NULL com CASE
--Como LISTAGG retorna NULL se n�o houver linhas para agrupar (ou seja, se um colaborador n�o tiver dependentes), utilizamos uma express�o CASE para verificar o resultado de LISTAGG. Se for NULL, substitu�mos por "Nada Consta" para tornar a sa�da mais amig�vel.

--Jun��es (JOIN)
--A consulta faz v�rias jun��es internas (INNER JOIN) para relacionar colaboradores aos seus departamentos, atribui��es, projetos atuais e pap�is. Isso garante que s� sejam considerados na consulta os colaboradores que possuem um departamento, projeto e papel definidos.
--Usamos jun��es � esquerda (LEFT JOIN) para os telefones m�veis e residenciais e para os dependentes. Isso permite incluir colaboradores mesmo que eles n�o tenham n�meros de telefone ou dependentes registrados. Os valores NULL resultantes para telefones s�o tratados com COALESCE, substituindo-os por "Nada Consta".

--COALESCE
--COALESCE � usada para substituir valores NULL nos n�meros de telefone m�vel e residencial, fornecendo um valor padr�o "Nada Consta" caso n�o exista um n�mero registrado.

--Agrupamento e Ordena��o
--A cl�usula GROUP BY agrupa os resultados pelas chaves �nicas dos colaboradores e outras colunas selecionadas, preparando o terreno para a agrega��o feita por LISTAGG.
--ORDER BY ordena os resultados primeiro pelo nome do projeto (projeto_atual), depois pelo nome do colaborador (nome_colaborador), garantindo que a sa�da seja organizada e f�cil de navegar.



--CARD IMPORTANTE 2 - Relat�rio anal�tico de equipes

SELECT 
c.matricula AS matricula_colaborador,
dep.nome AS nome_dependente,
dep.cpf AS cpf_dependente,
TO_CHAR(dep.data_nascimento, 'DD/MM/YYYY') AS data_nascimento,
dep.parentesco,
    EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM dep.data_nascimento) - (CASE WHEN TO_CHAR(SYSDATE, 'MMDD') < TO_CHAR(dep.data_nascimento, 'MMDD') 
    THEN 1 ELSE 0 END) AS idade_dependente,
    CASE 
        WHEN EXTRACT(YEAR FROM SYSDATE) -  EXTRACT(YEAR FROM dep.data_nascimento) - (CASE WHEN TO_CHAR(SYSDATE, 'MMDD') < TO_CHAR(dep.data_nascimento, 'MMDD') 
        THEN 1 ELSE 0 END) < 18 THEN 'Menor de idade'
        ELSE 'Maior de idade'
    END AS faixa_etaria
FROM 
brh.dependente dep
INNER JOIN 
brh.colaborador c ON dep.colaborador = c.matricula
ORDER BY 
c.matricula, dep.nome;
    
--Explica��o:
--Esta consulta SQL foi projetada para ser executada em um ambiente Oracle, focando em extrair informa��es detalhadas sobre os dependentes de colaboradores. A consulta seleciona v�rias informa��es relevantes, calcula a idade de cada dependente, determina sua faixa et�ria com base nessa idade e ordena os resultados pela matr�cula do colaborador e pelo nome do dependente.

--Sele��o de Campos
--c.matricula AS matricula_colaborador: Retorna a matr�cula do colaborador associado ao dependente. Isso identifica unicamente cada colaborador dentro da organiza��o.
--dep.nome AS nome_dependente: Mostra o nome do dependente, fornecendo uma identifica��o humana leg�vel para cada entrada de dependente na lista.
--dep.cpf AS cpf_dependente: Exibe o CPF (Cadastro de Pessoas F�sicas) do dependente, que � um identificador �nico para cidad�os no Brasil.

--TO_CHAR(dep.data_nascimento, 'DD/MM/YYYY') AS data_nascimento: Converte a data de nascimento do dependente para o formato de data brasileiro (dia/m�s/ano), tornando a data mais compreens�vel para usu�rios acostumados com esse formato.

--dep.parentesco: Informa o tipo de rela��o de parentesco entre o dependente e o colaborador (como filho(a), c�njuge, etc.).

--C�lculo da Idade e Faixa Et�ria dependente

--EXTRACT(YEAR FROM SYSDATE):
--Esta express�o extrai o ano atual do sistema. SYSDATE � uma fun��o no Oracle que retorna a data e hora atuais do sistema. Portanto, EXTRACT(YEAR FROM SYSDATE) retorna apenas o componente do ano da data atual.

--EXTRACT(YEAR FROM dep.data_nascimento):
--Semelhante � express�o acima, mas esta extrai o ano de nascimento do dependente da coluna data_nascimento na tabela dependente.

--Subtra��o dos Anos:
--A idade preliminar � calculada pela subtra��o do ano atual (obtido na etapa 1) pelo ano de nascimento do dependente (etapa 2).

--Ajuste baseado no M�s e Dia:
--A parte final da express�o ajusta a idade preliminar com base no m�s e no dia atual em rela��o ao m�s e dia de nascimento. Se o dia e m�s atuais forem antes do dia e m�s de nascimento do dependente, isso significa que o dependente ainda n�o fez anivers�rio no ano atual, ent�o 1 ano � subtra�do da idade preliminar.
--TO_CHAR(SYSDATE, 'MMDD') < TO_CHAR(dep.data_nascimento, 'MMDD'): Esta compara��o verifica se a combina��o de m�s e dia atuais (convertidos em uma string MMDD para f�cil compara��o) � menor que a combina��o de m�s e dia de nascimento do dependente. Se verdadeiro (ou seja, o dependente ainda n�o fez anivers�rio no ano corrente), ent�o 1 � subtra�do da idade calculada.

--Determina��o da Faixa Et�ria (faixa_etaria)
--A express�o CASE subsequente utiliza o mesmo c�lculo de idade para classificar o dependente como 'Menor de idade' se tiver menos de 18 anos, ou 'Maior de idade' caso contr�rio. Essa verifica��o � feita comparando a idade calculada com 18 anos.

--Ordena��o dos Resultados
--ORDER BY c.matricula, dep.nome: Os resultados s�o ordenados primeiro pela matr�cula do colaborador e, em seguida, pelo nome do dependente. Esta ordena��o facilita a busca e an�lise dos dados, agrupando todos os dependentes sob o respectivo colaborador de forma alfab�tica.


-- CARD IMPORTANTE 3 - Paginar listagem de colaboradores
SELECT 
    c.nome AS nome_colaborador
FROM 
    brh.colaborador c
ORDER BY 
    c.nome
OFFSET 10 ROWS -- Pula os primeiros 10 registros, correspondendo � primeira p�gina
FETCH NEXT 10 ROWS ONLY; -- Obt�m os pr�ximos 10 registros, correspondendo � segunda p�gina


-- Explica��o:
--ORDER BY c.nome: Ordena os colaboradores pelo nome. Isso garante que a pagina��o seja consistente e previs�vel, baseando-se na ordem alfab�tica dos nomes dos colaboradores.

--OFFSET 10 ROWS: Pula os primeiros 10 registros, pois cada p�gina tem 10 registros, voc� pula a primeira p�gina de registros para come�ar na segunda p�gina.

--FETCH NEXT 10 ROWS ONLY: Ap�s pular os primeiros 10 registros, essa cl�usula especifica que apenas os pr�ximos 10 registros devem ser retornados, correspondendo aos registros de 11 a 20, que formam a segunda p�gina.


--OU solu��o 2

SELECT * FROM (
  SELECT
    temp.*,
    ROWNUM AS rn
  FROM (
    SELECT
      c.nome AS nome_colaborador
    FROM
      brh.colaborador c
    ORDER BY
      c.nome
  ) temp
) WHERE rn BETWEEN 11 AND 20;

--Subconsulta Interna (temp):
--Primeiro, selecionamos os colaboradores e ordenamos pelo nome para garantir que a ordem seja consistente. Essa subconsulta � essencial porque ROWNUM � atribu�do �s linhas conforme elas s�o retornadas, o que significa que voc� precisa ordenar os resultados antes de aplicar ROWNUM.

--Subconsulta Externa:
--Em seguida, na subconsulta externa, atribu�mos ROWNUM a cada linha resultante da subconsulta interna. Isso � feito na subconsulta externa para garantir que ROWNUM seja aplicado ap�s os resultados j� estarem ordenados.

--Sele��o Final:
--Por fim, na consulta mais externa, filtramos as linhas baseadas no valor de rn (que representa o ROWNUM da subconsulta externa), selecionando as linhas de 11 a 20, que correspondem � segunda p�gina de 10 registros.



--Desafio Relat�rio de plano de sa�de

SELECT
    c.nome_colaborador, -- Seleciona o nome do colaborador da subconsulta 'c'.
    'R$ ' || TO_CHAR(c.salario, 'FM999G999G999G990D00') AS salario, -- Formata o sal�rio do colaborador como valor monet�rio em reais.
    c.senioridade, -- Seleciona a senioridade do colaborador da subconsulta 'c'.
    'R$ ' || TO_CHAR(NVL(SUM(d.valor_dependente), 0) + c.valor_porcentagem_senioridade, 'FM999G999G999G990D00') AS valor_mensalidade_total, -- Calcula e formata o valor total da mensalidade, somando os valores dos dependentes (ou 0 se n�o houver dependentes) com o valor adicional da senioridade.
    c.descricao_senioridade || '; ' || COALESCE(LISTAGG(d.descricao_dependente, '; ') WITHIN GROUP (ORDER BY d.nome_dependente), 'Sem dependentes') AS detalhes_calculo_mensalidade -- Concatena a descri��o da senioridade com as descri��es dos dependentes (ou 'Sem dependentes' se n�o houver).
FROM (
    SELECT
        matricula, -- Seleciona a matr�cula do colaborador.
        nome AS nome_colaborador, -- Seleciona o nome do colaborador.
        salario, -- Seleciona o sal�rio do colaborador.
        CASE -- Inicia um bloco CASE para determinar o valor adicional baseado na senioridade.
            WHEN salario <= 3000 THEN 0.01 -- Se o sal�rio for at� 3000, o adicional � 1% do sal�rio.
            WHEN salario > 3000 AND salario <= 6000 THEN 0.02 -- Se o sal�rio estiver entre 3001 e 6000, o adicional � 2% do sal�rio.
            WHEN salario > 6000 AND salario <= 20000 THEN 0.03 -- Se o sal�rio estiver entre 6001 e 20000, o adicional � 3% do sal�rio.
            ELSE 0.05 -- Para sal�rios acima de 20000, o adicional � 5% do sal�rio.
        END * salario AS valor_porcentagem_senioridade, -- Calcula o valor adicional da senioridade multiplicando o percentual pelo sal�rio.
        CASE -- Inicia outro bloco CASE para determinar a categoria de senioridade baseada no sal�rio.
            WHEN salario <= 3000 THEN 'J�nior'
            WHEN salario > 3000 AND salario <= 6000 THEN 'Pleno'
            WHEN salario > 6000 AND salario <= 20000 THEN 'S�nior'
            ELSE 'Corpo diretor'
        END AS senioridade, -- Atribui a categoria de senioridade baseada no sal�rio.
        'Senioridade (' || CASE -- Concatena a descri��o da senioridade, incluindo a categoria e o percentual aplicado.
            WHEN salario <= 3000 THEN 'J�nior - 1%'
            WHEN salario > 3000 AND salario <= 6000 THEN 'Pleno - 2%'
            WHEN salario > 6000 AND salario <= 20000 THEN 'S�nior - 3%'
            ELSE 'Corpo diretor - 5%'
        END || '): R$ ' || TO_CHAR(CASE -- Inclui tamb�m o valor monet�rio resultante da aplica��o do percentual ao sal�rio.
            WHEN salario <= 3000 THEN 0.01
            WHEN salario > 3000 AND salario <= 6000 THEN 0.02
            WHEN salario > 6000 AND salario <= 20000 THEN 0.03
            ELSE 0.05
        END * salario, 'FM999G999G999G990D00') AS descricao_senioridade -- Formata esse valor monet�rio como reais.
    FROM
        brh.colaborador -- Da tabela de colaboradores.
) c
LEFT JOIN ( -- Realiza um JOIN com a subconsulta 'd' para incluir informa��es dos dependentes.
    SELECT
        colaborador, -- Seleciona a matr�cula do colaborador a quem o dependente est� associado.
        nome AS nome_dependente, -- Seleciona o nome do dependente.
        parentesco, -- Seleciona o tipo de parentesco do dependente com o colaborador.
        data_nascimento, -- Seleciona a data de nascimento do dependente.
        CASE -- Determina o valor adicional baseado na idade do dependente.
            WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_nascimento) >= 18 THEN 50 -- Se o dependente for maior de idade, adiciona R$50.
            ELSE 25 -- Se o dependente for menor de idade, adiciona R$25.
        END AS valor_dependente, -- Calcula o valor adicional do dependente.
        nome || ' (' || parentesco || ', ' ||  -- Concatena a descri��o do dependente, incluindo nome, parentesco e se � maior ou menor de idade.
        CASE
            WHEN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_nascimento) < 18 THEN 'menor de idade: R$ 25'
            ELSE 'maior de idade: R$ 50'
        END || ')' AS descricao_dependente -- Inclui o valor monet�rio correspondente.
    FROM
        brh.dependente -- Da tabela de dependentes.
) d ON c.matricula = d.colaborador -- Faz a liga��o dos dependentes com os respectivos colaboradores.
GROUP BY
    c.nome_colaborador, c.salario, c.senioridade, c.valor_porcentagem_senioridade, c.descricao_senioridade -- Agrupa os resultados por colaborador para permitir a agrega��o.
ORDER BY
    c.nome_colaborador; -- Ordena os resultados pelo nome do colaborador.

--Observa��o: A formata��o 'FM999G999G999G990D00' usada na fun��o TO_CHAR do Oracle SQL � um modelo de formata��o num�rica que define como um n�mero deve ser convertido em texto.
--FM: O modificador FM (Fill Mode) na frente do modelo de formata��o remove qualquer espa�o em branco que normalmente seria inclu�do no in�cio ou no final do texto formatado. Isso garante que o resultado seja uma string compacta, sem espa�os extras antes do primeiro d�gito ou depois do �ltimo.

--999G999G999G990D00:

--999: Representa os d�gitos do n�mero, onde cada 9 indica que o d�gito naquela posi��o pode ser substitu�do por um n�mero, se houver um n�mero para exibir. Se n�o houver n�mero suficiente para preencher todas as posi��es 9, o Oracle n�o exibe espa�os extras (devido ao FM), nem zeros � esquerda. Isso permite que o n�mero seja exibido no formato correto sem preenchimento desnecess�rio.
--G: Representa o separador de grupo (normalmente conhecido como separador de milhar). Em muitos pa�ses, incluindo o Brasil, esse separador � uma v�rgula (,), mas pode ser um ponto (.) em sistemas configurados para usar padr�es de outros pa�ses. O caracter G ser� substitu�do pelo s�mbolo apropriado de acordo com as configura��es locais (NLS) do banco de dados.
--990: Similar aos 9s anteriores, mas aqui especificamente para assegurar a presen�a de pelo menos um d�gito antes do separador decimal, se houver algum n�mero a ser exibido.
--D: Representa o separador decimal. Como o G, o s�mbolo que substitui o D depende das configura��es locais do banco de dados. Em muitas configura��es, � uma v�rgula (,), mas pode ser um ponto (.) dependendo da localidade.
--00: Ap�s o D, esses zeros garantem que sempre haver� dois d�gitos ap�s o separador decimal, assegurando a formata��o padr�o para valores monet�rios, onde centavos s�o importantes. Se o n�mero original tiver menos de duas casas decimais, zeros ser�o adicionados para preencher.
--Portanto, a formata��o 'FM999G999G999G990D00' � usada para formatar n�meros de forma que sejam exibidos como valores monet�rios, com separadores de milhar e duas casas decimais, adaptando-se �s configura��es locais de idioma e regi�o do banco de dados, e removendo espa�os em branco desnecess�rios.

 
 
 --  Desafio Listar colaboradores que participaram de todos os projetos
 
SELECT 
    a.colaborador,
    COUNT(DISTINCT a.projeto) AS projetos_do_colaborador,
    (SELECT nome FROM brh.colaborador WHERE matricula = a.colaborador) AS nome_colaborador
FROM 
    brh.atribuicao a
GROUP BY 
    a.colaborador
HAVING 
    COUNT(DISTINCT a.projeto) = (SELECT COUNT(*) FROM brh.projeto);







