
use CampeonatoFutebol

CREATE TABLE CampeonatoFutebol
(
    Id INT NOT NULL IDENTITY (1,1),
	Ano INT NOT NULL,
	Nome VARCHAR (30) NOT NULL,
	VencedorC VARCHAR (40),
	
	CONSTRAINT pk_Campeonato PRIMARY KEY (Id),
	CONSTRAINT un_Campeonato UNIQUE (Ano, Nome),
	--FezmaisGols, 
	--TomouMaisGols
);
GO

CREATE TABLE TimeFutebol
(
	Nome VARCHAR (40) NOT NULL,
	Apelido VARCHAR (20) NOT NULL, 
	DataDeCriacao DATE NOT NULL,

	CONSTRAINT pk_Time PRIMARY KEY (Nome),
	CONSTRAINT un_Time UNIQUE (APELIDO),
);
GO

-- Procedure para cadastrar um time de futebol
CREATE OR ALTER PROCEDURE CriarTimeFutebol
    @Nome VARCHAR(50),
    @Apelido VARCHAR(30),
    @DataCriacao DATE
AS
BEGIN
    INSERT INTO TimeFutebol (Nome, Apelido, DataDeCriacao)
    VALUES (@Nome, @Apelido, @DataCriacao);
END;
GO

  --Tratativa para requisito de maximo de 5 times
    DECLARE @QtdTimes INT;
    SET @QtdTimes = (SELECT COUNT(*) FROM TimeFutebol);
    
    IF @QtdTimes >= 5
    BEGIN
        PRINT 'Não é possível cadastrar mais times, limite maximo de equipes foi atingido.';
        RETURN;
    END;


IF OBJECT_ID('JogoFutebol', 'U') IS NOT NULL
BEGIN
    DROP TABLE JogoFutebol;
END
GO

CREATE TABLE JogoFutebol
(
	Partida INT NOT NULL IDENTITY (1,1),
	TimeDaCasa VARCHAR (40),
	TimeVisitante VARCHAR (40),
	GolsTimeDaCacasa INT, 
	GolsTimeVisitante INT,
	VencedorJogo VARCHAR (40) NULL,
    Campeonato INT NOT NULL,
	ResultadoDoJogo INT, -- criar uma procedure para fazer resultado dos times ex: palmeiras 3 Sào Paulo 0 

	CONSTRAINT pkPartida PRIMARY KEY (Partida),
	CONSTRAINT UnTimeVisitante UNIQUE (TimeVisitante),
	CONSTRAINT UnTimeDaCasa UNIQUE (TimeDaCasa),

    CONSTRAINT FKTimeDaCasa FOREIGN KEY (TimeDaCasa) REFERENCES TimeFutebol (NOME),
    CONSTRAINT FKTimeVisitante FOREIGN KEY (TimeVisitante) REFERENCES TimeFutebol (NOME),
    CONSTRAINT FKVencedorJogo FOREIGN KEY (VencedorJogo) REFERENCES TimeFutebol (NOME),
    CONSTRAINT FKCampeonato FOREIGN KEY (Campeonato) REFERENCES CampeonatoFutebol (ID)
);
GO
	
CREATE TABLE Classificacao 
(
    NomeTime VARCHAR(40) NOT NULL,
    Pontos INT NOT NULL DEFAULT(0),
    GolsMarcados INT NOT NULL DEFAULT (0),
    GolsRecebidos INT NOT NULL DEFAULT (0),
    PartidasVencidas INT NOT NULL DEFAULT (0),
    Empates INT NOT NULL DEFAULT(0),
	SaldoDeGols INT NOT NULL DEFAULT(0),
    
    CONSTRAINT PKClassificacao PRIMARY KEY ([NomeTime]),
    CONSTRAINT FKClassificacaoTime FOREIGN KEY ([NomeTime]) REFERENCES [TimeFutebol] ([Nome])
)
GO

--INSERT INTO CampeonatoFutebol
--VALUES 
--	(DEFAULT, '2024','Mundial', 'NULL');
--SELECT * FROM CampeonatoFutebol;

CREATE or ALTER PROC InserirCampeonato 
    @ANO INT,
    @NOME VARCHAR (20),
    @VencedorC VARCHAR (40) 

AS BEGIN
    INSERT INTO CampeonatoFutebol
        ([Ano],[Nome], [VencedorC])
    VALUES
        (
            @ANO,
            @NOME,
            @VencedorC
        )
END;

INSERT INTO TimeFutebol
 ([Nome], Apelido, DataDeCriacao)
	VALUES ('Palmeiras', 'Palestra', '1914-08-26');

INSERT INTO TimeFutebol
	 ([Nome], Apelido, DataDeCriacao)
	VALUES ('Sao Paulo', 'Tricolor', '1554-0125');

INSERT INTO TimeFutebol	
	([Nome], Apelido, DataDeCriacao)
	VALUES ('Ferroviaria', 'Ferrinha', '1950-04-12');
GO

--INSERT INTO JogoFutebol
	
--VALUES
--	(DEFAULT,'Palmeiras', '7','1' );
--SELECT * FROM TimeFutebol;
--GO
	
CREATE OR ALTER PROCEDURE InserirJogo
    @TimeDaCasa VARCHAR(40),
    @TimeVisitante VARCHAR(40),
    @GolsTimeDaCasa INT,
    @GolsTimeVisitante INT,
    @ResultadoDoJogo INT
AS 
BEGIN
    INSERT INTO JogoFutebol
        ([TimeDaCasa], [TimeVisitante], [GolsTimeDaCacasa], [GolsTimeVisitante], [ResultadoDoJogo])
    VALUES
        (@TimeDaCasa, @TimeVisitante, @GolsTimeDaCasa, @GolsTimeVisitante, @ResultadoDoJogo)
END;
GO


CREATE OR ALTER PROC AtualizaGols
    @GolsTimeCasa INT,
    @GolsTimeVisitante INT,
    @Partida INT
AS
BEGIN
    UPDATE JogoFutebol
     SET 
        GolsTimeDaCacasa = @GolsTimeCasa, 
        GolsTimeVisitante = @GolsTimeVisitante

    WHERE Partida = @Partida
END;
GO

--CREATE OR ALTER TRIGGER Ganhador ON JogoFutebol AFTER UPDATE
--AS
--BEGIN
--    DECLARE 
--        @Partida INT,
--        @TimeDaCasa VARCHAR(40), 
--        @TimeVisitante VARCHAR(40),
--        @GolsTimeDaCasa INT, 
--        @GolsTimeVisitante INT,
--        @Vencedor VARCHAR(40)

--    -- Obter dados atualizados da partida
--    SELECT

--		Partida = @Partida,
--		TimeDaCasa = @TimeDaCasa,
--		TimeVisitante = @TimeVisitante,
--		GolsTimeDaCaca = @GolsTimeDaCasa,
--		GolsTimeVisitante = @GolsTimeVisitante,
--        ResultadoDoJogo = @Vencedor
        
--    FROM INSERTED 
--    -- Verificar se o resultado da partida já foi definido
--    IF (@Vencedor IS NULL)
--    BEGIN
--        -- Verificar quem venceu ou se houve empate
--        IF (@GolsTimeDaCasa > @GolsTimeVisitante)
--        BEGIN
--        -- Se o time da casa marcou mais gols ele vence
--            UPDATE JogoFutebol SET @Vencedor = @TimeDaCasa WHERE Partida = @Partida
--        END
--        ELSE IF (@GolsTimeVisitante > @GolsTimeDaCasa)
--        BEGIN
--            -- Se o time visitante marcou mais gols, ele é o vencedor
--            UPDATE JogoFutebol SET @Vencedor = @TimeDaCasa WHERE Partida = @Partida
--        END
--        ELSE
--        BEGIN
--            -- Se houve empate, não há vencedor
--            UPDATE JogoFutebol SET @Vencedor = NULL WHERE Partida = @Partida
--        END
--    END
--END;


CREATE OR ALTER PROC AlterarClassificacao 
	@Time VARCHAR(40),    --time q será modificado na tabela d classificação
	@Gols INT,            --gols marcados ou sofridos pelo time modificafo
	@GolsRecebidos INT,   --Quantidade de gols sofridos pelo time
	@Posicao VARCHAR(9),  --se jogou em casa ou visitante
	@Situacao CHAR(7)     --mostra se é inserção ou remoção d resultado d um jogo e só recebe INSERIR ou REMOVER

AS
BEGIN
        DECLARE 
		@Pontos INT, 
		@SaldoDeGols INT

        SET 
		@SaldoDeGols = @Gols - @GolsRecebidos
        
        --Atualiza tabela classificaçao, gols marcados e recebidos são adicionados na tabela. 
        UPDATE Classificacao
		SET 
		    GolsMarcados = GolsMarcados + @Gols,
			GolsRecebidos = GolsRecebidos + @GolsRecebidos,
			SaldoDeGols = (GolsMarcados + @Gols) - (GolsRecebidos + @GolsRecebidos)
		WHERE NomeTime = @Time

        --condicional p/ verificar se é inserção, se foi empate ou vitoria
        IF (@Situacao = 'Inserir')
		
		BEGIN
        IF (@Gols > @GolsRecebidos)
            UPDATE [Classificacao] SET PartidasVencidas = ISNULL(PartidasVencidas, 0) + 1 WHERE NomeTime = @Time
        ELSE IF (@Gols = @GolsRecebidos)
            UPDATE [Classificacao] SET Empates = ISNULL(Empates, 0) + 1 WHERE NomeTime = @Time
        ELSE
            UPDATE [Classificacao] SET GolsRecebidos = ISNULL(GolsRecebidos, 0) + 1 WHERE NomeTime = @Time
    END
    ELSE IF (@Situacao = 'Remover')
    BEGIN
        IF (@Gols > @GolsRecebidos)
            UPDATE [Classificacao] SET PartidasVencidas = ISNULL(PartidasVencidas, 0) - 1 WHERE NomeTime = @Time
        ELSE IF (@Gols = @GolsRecebidos)
            UPDATE [Classificacao] SET Empates = ISNULL(Empates, 0) - 1 WHERE NomeTime = @Time
        ELSE
            UPDATE [Classificacao] SET GolsRecebidos = ISNULL(GolsRecebidos, 0) - 1 WHERE NomeTime = @Time
    END
END --OBS: Utilizei ISNULL p/ evitar a ocorrência d valores NULL nas atualizações do jogo
GO


CREATE OR ALTER PROCEDURE RealizarJogosIdaVolta
AS
BEGIN
    DECLARE @NumeroTotalTimes INT
    DECLARE @Contador INT
    DECLARE @TimeDaCasa VARCHAR(40)
    DECLARE @TimeVisitante VARCHAR(40)
    DECLARE @Rodada INT

    --Limpa tabela JogoFutebol antes d inserir novos jogos p/ evitar duplicação d dados ou a mistura d jogos antigos c/ novos
    TRUNCATE TABLE JogoFutebol

    -- select c/ contador do SQL,  pra usar na tratativa de permitir apenas 5 times 
    SELECT @NumeroTotalTimes = COUNT(*) FROM TimeFutebol

    -- Inicia contagem das rodadas
    SET @Rodada = 1

    -- Gerar jogos de ida e volta
    WHILE @Rodada <= (@NumeroTotalTimes - 1)
    BEGIN

       
    --iterar sobre os times para definir os jogos da rodada
    SET @Contador = 1
    WHILE @Contador <= @NumeroTotalTimes
    BEGIN

    --seleciona time da casa p/ o jogo
    SELECT @TimeDaCasa = Nome FROM TimeFutebol WHERE Nome = @Contador

   --seleciona time visitante p/ jogo
    SELECT @TimeVisitante = Nome FROM TimeFutebol WHERE Nome = ((@Contador + @Rodada - 1) % @NumeroTotalTimes) + 1

   --insere jogo na tabela JogoFutebol ( na "ida")
    INSERT INTO JogoFutebol (TimeDaCasa, TimeVisitante, GolsTimeDaCacasa, GolsTimeVisitante, ResultadoDoJogo) 
    VALUES (@TimeDaCasa, @TimeVisitante, NULL, NULL, NULL)

    --inserir o jogo na tabela JogoFutebol (na "volta")
    INSERT INTO JogoFutebol (TimeDaCasa, TimeVisitante, GolsTimeDaCacasa, GolsTimeVisitante, ResultadoDoJogo) 
    VALUES (@TimeVisitante, @NumeroTotalTimes, NULL, NULL, NULL)

    SET @Contador = @Contador + 1
    END

    SET @Rodada = @Rodada + 1
    END
END;
GO

--Atualiza os pontos dos times c/ base nos resultados dos jogos
CREATE OR ALTER PROCEDURE CalcularPontuacao
AS
BEGIN

    --atualizar pontuação p/ vitória em casa
	--vi q é boa pratica o uso de aliases 
    UPDATE Classificacao
    SET Pontos = Pontos + 3
    FROM Classificacao C
    INNER JOIN JogoFutebol J ON C.NomeTime = J.TimeDaCasa
    WHERE J.ResultadoDoJogo = 1;
    
    --atualizar pontuação p vitória fora d casa
    UPDATE Classificacao
    SET Pontos = Pontos + 5
    FROM Classificacao C
    INNER JOIN JogoFutebol J ON C.NomeTime = J.TimeVisitante
    WHERE J.ResultadoDoJogo = 2;
    
    --atualizar pontuação p/ o empate
    UPDATE Classificacao
    SET Pontos = Pontos + 1
    FROM Classificacao C
    INNER JOIN JogoFutebol J ON C.NomeTime = J.TimeDaCasa
    WHERE J.ResultadoDoJogo = 0
        OR (J.ResultadoDoJogo = 0 AND C.NomeTime = J.TimeVisitante);
END;
GO

--determina o campeão do campeonato
CREATE OR ALTER PROCEDURE DeterminarCampeao
AS
BEGIN
    --selecionar time c/ mais pontos
    SELECT TOP 1 NomeTime, Pontos
    FROM Classificacao
    ORDER BY Pontos DESC;
END;

GO


--visualiza os 5 primeiros times do campeonato
CREATE OR ALTER PROCEDURE VisualizarTop5
AS
BEGIN
    --Seleiona os cinco primeiros times de acordo com a pontuaçao
    SELECT TOP 5 NomeTime, Pontos
    FROM Classificacao
    ORDER BY Pontos DESC; --Se não colocasse o DESC (descrescente) a ordenação seria por padrão em ordem crescente (ASC)
END;

GO

--time q fez + gols
CREATE OR ALTER PROCEDURE TimeMaisFezGols
AS
BEGIN
    SELECT TOP 1
        NomeTime,
        SUM(GolsMarcados) AS TotalDeGols
    FROM Classificacao
    GROUP BY NomeTime
    ORDER BY TotalDeGols DESC;
END;
GO

--time q recebeu + gols
CREATE OR ALTER PROCEDURE TimeRecebeuMaisGols
AS
BEGIN
    SELECT TOP 1
        NomeTime,
        SUM(GolsRecebidos) AS TotalDeGolsrecebido
    FROM Classificacao
    GROUP BY NomeTime
    ORDER BY TotalDeGolsrecebido DESC;
END;
GO

--Jogo c/ + Gols
CREATE OR ALTER PROCEDURE JogoComMaisGols
AS
BEGIN
    SELECT TOP 1
        Partida,
        TimeDaCasa,
        TimeVisitante,
        GolsTimeDaCacasa + GolsTimeVisitante AS TotalDeGols
    FROM JogoFutebol
    ORDER BY TotalDeGols DESC;
END;
GO

--a lógica dessa procedure nào ta certa, quase 3 da amnhà e nào consigo arrumar 
   CREATE OR ALTER PROCEDURE BuscarMaiorNumerodeGolsPorTimeUnicoJogo
    @Campeonato INT
AS
BEGIN
    --cláusula WITH TIES é útil em situações onde há empates e desejamos que todos os registros que empatam sejam retornados
    SELECT TOP 1 WITH TIES  
 
        MAX(GolsMarcados) AS TotalGols,
        Time AS NomeTime,
        @Campeonato AS IdCampeonato
    FROM 
    (
       SELECT 
            TimeDaCasa AS Time,
            SUM(GolsTimeDaCacasa) AS GolsMarcados
        FROM JogoFutebol
        WHERE Campeonato = @Campeonato -- Filtro pelo campeonato
        GROUP BY TimeDaCasa
        
        UNION ALL
        
        SELECT 
            TimeVisitante AS Time,
            SUM(GolsTimeVisitante) AS GolsMarcados
        FROM JogoFutebol
        WHERE Campeonato = @Campeonato -- Filtro pelo campeonato
        GROUP BY TimeVisitante
    ) AS GolsPorTime
    GROUP BY Time
    ORDER BY TotalGols DESC;
END;