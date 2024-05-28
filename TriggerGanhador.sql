
--Na aula de revis�o do Papine (turma 2022) ele fala que as procedures s�o a evolu��o dos Triggers, mas analizando, no meu entendimento, 
--Nesse caso espec�fico, seria melhbor usar o trigger, sendo que o objetivo do trigger � atualizar automaticamente o vencedor da partida ap�s uma atualiza��o na tabela de jogos. 
--tem mais automatizada tendo em vista q  o trigger � acionado sempre que uma atualiza��o � feita na tabela JOGO, sem a necessidade de chamar uma procedure 
--ap�s cada atualiza��o
USE CampeonatoFutebol

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'Ganhador')
    DROP TRIGGER Ganhador
GO
--coloquei esse IF/DROP porque estava dando o erro: Mensagem 111, N�vel 15, Estado 1, Linha 3
--'CREATE TRIGGER' must be the first statement in a query batch.
--depois descobri que era s� colocar o "GO" no final .... 
CREATE OR ALTER TRIGGER Ganhador ON JogoFutebol AFTER UPDATE
AS
BEGIN
    DECLARE 
        @Partida INT,
        @TimeDaCasa VARCHAR(40), 
        @TimeVisitante VARCHAR(40),
        @GolsTimeDaCasa INT, 
        @GolsTimeVisitante INT,
        @Vencedor VARCHAR(40)

    -- Obter dados atualizados da partida
    SELECT

		Partida = @Partida,
		TimeDaCasa = @TimeDaCasa,
		TimeVisitante = @TimeVisitante,
		GolsTimeDaCaca = @GolsTimeDaCasa,
		GolsTimeVisitante = @GolsTimeVisitante,
        ResultadoDoJogo = @Vencedor
        
    FROM INSERTED 
    -- Verificar se o resultado da partida j� foi definido
    IF (@Vencedor IS NULL)
    BEGIN
        -- Verificar quem venceu ou se houve empate
        IF (@GolsTimeDaCasa > @GolsTimeVisitante)
        BEGIN
        -- Se o time da casa marcou mais gols ele vence
            UPDATE JogoFutebol SET @Vencedor = @TimeDaCasa WHERE Partida = @Partida
        END
        ELSE IF (@GolsTimeVisitante > @GolsTimeDaCasa)
        BEGIN
            -- Se o time visitante marcou mais gols, ele � o vencedor
            UPDATE JogoFutebol SET @Vencedor = @TimeDaCasa WHERE Partida = @Partida
        END
        ELSE
        BEGIN
            -- Se houve empate, n�o h� vencedor
            UPDATE JogoFutebol SET @Vencedor = NULL WHERE Partida = @Partida
        END
    END
END;


