
--Na aula de revisão do Papine (turma 2022) ele fala que as procedures são a evolução dos Triggers, mas analizando, no meu entendimento, 
--Nesse caso específico, seria melhbor usar o trigger, sendo que o objetivo do trigger é atualizar automaticamente o vencedor da partida após uma atualização na tabela de jogos. 
--tem mais automatizada tendo em vista q  o trigger é acionado sempre que uma atualização é feita na tabela JOGO, sem a necessidade de chamar uma procedure 
--após cada atualização
USE CampeonatoFutebol

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'Ganhador')
    DROP TRIGGER Ganhador
GO
--coloquei esse IF/DROP porque estava dando o erro: Mensagem 111, Nível 15, Estado 1, Linha 3
--'CREATE TRIGGER' must be the first statement in a query batch.
--depois descobri que era só colocar o "GO" no final .... 
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
    -- Verificar se o resultado da partida já foi definido
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
            -- Se o time visitante marcou mais gols, ele é o vencedor
            UPDATE JogoFutebol SET @Vencedor = @TimeDaCasa WHERE Partida = @Partida
        END
        ELSE
        BEGIN
            -- Se houve empate, não há vencedor
            UPDATE JogoFutebol SET @Vencedor = NULL WHERE Partida = @Partida
        END
    END
END;


