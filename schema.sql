DROP TABLE IF EXISTS Possui_categoria, Disponivel_em, Exige, Avaliacao, Conquistas, Jogo, Requisito_Hardware, Usuario, Publicadoras, Plataforma, Categoria, Desenvolvedora CASCADE;

CREATE TABLE Desenvolvedora (
    Id_desenvolvedora INT PRIMARY KEY,
    Nome_desenvolvedora VARCHAR(100) NOT NULL,
    Pais_origem VARCHAR(50)
);

CREATE TABLE Categoria (
    Id_categoria INT PRIMARY KEY,
    Genero VARCHAR(50) NOT NULL
);

CREATE TABLE Plataforma (
    Id_Plataforma INT PRIMARY KEY,
    Nome_plataforma VARCHAR(50) NOT NULL
);

CREATE TABLE Publicadoras (
    Id_publicadora INT PRIMARY KEY,
    Nome_publicadora VARCHAR(100) NOT NULL,
    Pais_origem VARCHAR(50)
);

CREATE TABLE Usuario (
    Id_usuario INT PRIMARY KEY,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Data_cadastro DATE NOT NULL,
    Nickname VARCHAR(50) NOT NULL
);

CREATE TABLE Requisito_Hardware (
    Id_hardware INT PRIMARY KEY,
    Configuracao_minima TEXT,
    Configuracao_recomendada TEXT,
    Espaco_disco INT
);

CREATE TABLE Jogo (
    Id_Jogos INT PRIMARY KEY,
    Id_desenvolvedora INT NOT NULL,
    Id_publicadora INT NOT NULL,
    Data_Lancamento DATE,
    preco DECIMAL(10, 2) NOT NULL,
    Classificacao_Indicativa INT,
    Titulo VARCHAR(100) NOT NULL,
    FOREIGN KEY (Id_desenvolvedora) REFERENCES Desenvolvedora (Id_desenvolvedora),
    FOREIGN KEY (Id_publicadora) REFERENCES Publicadoras (Id_publicadora)
);

CREATE TABLE Conquistas (
    Id_conquista INT PRIMARY KEY,
    Id_Jogos INT NOT NULL,
    Nivel_raridade VARCHAR(30),
    Descricao TEXT,
    Nome_conquista VARCHAR(100) NOT NULL,
    FOREIGN KEY (Id_Jogos) REFERENCES Jogo (Id_Jogos) ON DELETE CASCADE
);

CREATE TABLE Avaliacao (
    Id_avaliacao INT PRIMARY KEY,
    Id_usuario INT NOT NULL,
    Id_Jogos INT NOT NULL,
    Comentarios TEXT,
    Nota_avaliacao INT CHECK (Nota_avaliacao BETWEEN 1 AND 5),
    FOREIGN KEY (Id_usuario) REFERENCES Usuario (Id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (Id_Jogos) REFERENCES Jogo (Id_Jogos) ON DELETE CASCADE
);

CREATE TABLE Exige (
    Id_hardware INT NOT NULL,
    Id_Jogos INT NOT NULL,
    PRIMARY KEY (Id_hardware, Id_Jogos),
    FOREIGN KEY (Id_hardware) REFERENCES Requisito_Hardware (Id_hardware) ON DELETE CASCADE,
    FOREIGN KEY (Id_Jogos) REFERENCES Jogo (Id_Jogos) ON DELETE CASCADE
);

CREATE TABLE Disponivel_em (
    Id_Jogos INT NOT NULL,
    Id_Plataforma INT NOT NULL,
    PRIMARY KEY (Id_Jogos, Id_Plataforma),
    FOREIGN KEY (Id_Jogos) REFERENCES Jogo (Id_Jogos) ON DELETE CASCADE,
    FOREIGN KEY (Id_Plataforma) REFERENCES Plataforma (Id_Plataforma) ON DELETE CASCADE
);

CREATE TABLE Possui_categoria (
    Id_categoria INT NOT NULL,
    Id_Jogos INT NOT NULL,
    PRIMARY KEY (Id_categoria, Id_Jogos),
    FOREIGN KEY (Id_categoria) REFERENCES Categoria (Id_categoria) ON DELETE CASCADE,
    FOREIGN KEY (Id_Jogos) REFERENCES Jogo (Id_Jogos) ON DELETE CASCADE
);

-- Dados Iniciais para Teste
INSERT INTO Desenvolvedora VALUES 
(1, 'CD Projekt Red', 'Polônia'),
(2, 'FromSoftware', 'Japão'),
(3, 'Valve', 'Estados Unidos'),
(4, 'Rockstar North', 'Reino Unido'),
(5, 'Santa Monica Studio', 'Estados Unidos'),
(6, 'Larian Studios', 'Bélgica'),
(7, 'Team Cherry', 'Austrália'),
(8, 'Nintendo EPD', 'Japão'),
(9, 'Supergiant Games', 'Estados Unidos'),
(10, 'Mojang Studios', 'Suécia'),
(11, 'Naughty Dog', 'Estados Unidos'),
(12, 'Capcom', 'Japão'),
(13, 'Bethesda Game Studios', 'Estados Unidos'),
(14, 'ConcernedApe', 'Estados Unidos'),
(15, 'Remedy Entertainment', 'Finlândia');

INSERT INTO Publicadoras VALUES 
(1, 'CD Projekt', 'Polônia'),
(2, 'Bandai Namco Entertainment', 'Japão'),
(3, 'Valve Corporation', 'Estados Unidos'),
(4, 'Rockstar Games', 'Estados Unidos'),
(5, 'Sony Interactive Entertainment', 'Estados Unidos'),
(6, 'Larian Studios', 'Bélgica'),
(7, 'Team Cherry', 'Austrália'),
(8, 'Nintendo', 'Japão'),
(9, 'Supergiant Games', 'Estados Unidos'),
(10, 'Xbox Game Studios', 'Estados Unidos'),
(11, 'Capcom', 'Japão'),
(12, 'Bethesda Softworks', 'Estados Unidos'),
(13, 'ConcernedApe', 'Estados Unidos'),
(14, 'Epic Games Publishing', 'Estados Unidos');

INSERT INTO Categoria VALUES 
(1, 'RPG'),
(2, 'Ação'),
(3, 'FPS'),
(4, 'Mundo Aberto'),
(5, 'Soulslike'),
(6, 'Indie'),
(7, 'Metroidvania'),
(8, 'Aventura'),
(9, 'Roguelike'),
(10, 'Sandbox'),
(11, 'Terror'),
(12, 'Simulação');

INSERT INTO Plataforma VALUES (1, 'PC'),(2, 'PlayStation 5'),(3, 'Xbox Series X/S'),(4, 'Nintendo Switch'),(5, 'PlayStation 4');

INSERT INTO Requisito_Hardware (Id_hardware, Configuracao_minima, Configuracao_recomendada, Espaco_disco) VALUES
(1, 'Intel Core i5-2500K, 8GB RAM, GTX 770', 'Intel Core i7-3770, 16GB RAM, RTX 2060', 50),
(2, 'Intel Core i5-8400, 12GB RAM, GTX 1060', 'Intel Core i7-8700K, 16GB RAM, GTX 1070', 60),
(3, 'Intel Core i5-750, 8GB RAM, GTX 660', 'Intel Core i5-9400F, 16GB RAM, GTX 1660', 85),
(4, 'Intel Core i5-2500K, 8GB RAM, GTX 770', 'Intel Core i7-4770K, 12GB RAM, GTX 1060', 150),
(5, 'Intel Core i5-2500K, 8GB RAM, GTX 960', 'Intel Core i7-4770K, 8GB RAM, GTX 1060', 70),
(6, 'Intel Core i5-4690, 8GB RAM, GTX 970', 'Intel Core i7-8700K, 16GB RAM, RTX 2060 Super', 150),
(7, 'Intel Core 2 Duo E5200, 4GB RAM, GeForce 9800GTX', 'Intel Core i5, 8GB RAM, GTX 560', 9),
(8, 'Dual Core 2.4 GHz, 4GB RAM, GeForce GTX 950', 'Quad Core 3.0 GHz, 8GB RAM, RTX 2060', 15),
(9, 'Intel Core i3-3210, 4GB RAM, Intel HD 4000', 'Intel Core i5-4690, 8GB RAM, GeForce 700 Series', 4),
(10, 'Intel Core i7-6700, 12GB RAM, GTX 1060', 'Intel Core i7-12700, 16GB RAM, RTX 3060', 70),
(11, 'Intel Core i5-7500, 8GB RAM, GTX 1050 Ti', 'Intel Core i7-8700, 16GB RAM, GTX 1070', 67),
(12, 'Intel Core i5-4790, 16GB RAM, GTX 970', 'Intel Core i7-8700, 16GB RAM, RTX 3060', 100),
(13, '2 GHz Dual Core, 2GB RAM, 256MB Video Memory', '2.5 GHz Quad Core, 4GB RAM, 512MB Video Memory', 1),
(14, 'Intel Core i5-7600K, 16GB RAM, RTX 2060', 'Ryzen 7 3700X, 16GB RAM, RTX 3070', 90);

INSERT INTO Usuario VALUES 
(1, 'lucas.silva@ufsc.br', '2026-01-10', 'LucasGamer'),
(2, 'mariana.costa@ufsc.br', '2026-01-15', 'MariRPG'),
(3, 'pedro.almeida@gmail.com', '2026-02-02', 'PedroSouls'),
(4, 'ana.souza@hotmail.com', '2026-02-20', 'AnaIndie'),
(5, 'gabriel.lima@ufsc.br', '2026-03-05', 'GabiFPS'),
(6, 'carla.mendes@gmail.com', '2026-03-18', 'CarlaHorror');

INSERT INTO Jogo VALUES 
(1, 1, 1, '2015-05-19', 99.90, 18, 'The Witcher 3: Wild Hunt'),
(2, 1, 1, '2020-12-10', 199.90, 18, 'Cyberpunk 2077'),
(3, 2, 2, '2022-02-25', 249.90, 16, 'Elden Ring'),
(4, 2, 2, '2016-04-12', 159.90, 16, 'Dark Souls III'),
(5, 3, 3, '2023-09-27', 0.00, 16, 'Counter-Strike 2'),
(6, 3, 3, '2011-04-19', 32.99, 10, 'Portal 2'),
(7, 4, 4, '2018-10-26', 249.90, 18, 'Red Dead Redemption 2'),
(8, 4, 4, '2013-09-17', 89.90, 18, 'Grand Theft Auto V'),
(9, 5, 5, '2018-04-20', 199.90, 18, 'God of War'),
(10, 5, 5, '2022-11-09', 299.90, 18, 'God of War Ragnarök'),
(11, 6, 6, '2023-08-03', 199.99, 18, 'Baldur''s Gate 3'),
(12, 7, 7, '2017-02-24', 46.99, 10, 'Hollow Knight'),
(13, 8, 8, '2017-03-03', 299.00, 10, 'The Legend of Zelda: Breath of the Wild'),
(14, 9, 9, '2020-09-17', 73.99, 14, 'Hades'),
(15, 10, 10, '2011-11-18', 99.00, 0, 'Minecraft'),
(16, 11, 5, '2013-06-14', 199.90, 18, 'The Last of Us Part I'),
(17, 11, 5, '2020-06-19', 249.90, 18, 'The Last of Us Part II'),
(18, 12, 11, '2023-03-24', 199.00, 18, 'Resident Evil 4 Remake'),
(19, 12, 11, '2018-01-26', 99.90, 14, 'Monster Hunter: World'),
(20, 13, 12, '2011-11-11', 149.00, 16, 'The Elder Scrolls V: Skyrim'),
(21, 13, 12, '2015-11-10', 79.90, 18, 'Fallout 4'),
(22, 14, 13, '2016-02-26', 24.99, 0, 'Stardew Valley'),
(23, 15, 14, '2023-10-27', 225.00, 18, 'Alan Wake 2'),
(24, 2, 5, '2015-03-24', 99.50, 16, 'Bloodborne'),
(25, 8, 8, '2023-05-12', 349.00, 10, 'The Legend of Zelda: Tears of the Kingdom');

-- 8. CONQUISTAS
INSERT INTO Conquistas (Id_conquista, Id_Jogos, Nivel_raridade, Descricao, Nome_conquista) VALUES
(1, 1, 'Ouro', 'Conclua o jogo na dificuldade Marcha da Morte.', 'Andou pelo Caminho'),
(2, 1, 'Bronze', 'Derrote um grifo em Pomar Branco.', 'A Fera de Pomar Branco'),
(3, 3, 'Platina', 'Obtenha todas as conquistas de Elden Ring.', 'Príncipe Pristino'),
(4, 3, 'Ouro', 'Derrote Malenia, a Espada de Miquella.', 'Portadora de Fragmento Malenia'),
(5, 7, 'Ouro', 'Alcance 100% de conclusão no modo história.', 'O Melhor do Oeste'),
(6, 11, 'Prata', 'Salve todos os refugiados Tieflings.', 'Deixar Ninguém Para Trás'),
(7, 12, 'Ouro', 'Conclua o Panteão de Hallownest.', 'Abraçar o Vazio'),
(8, 14, 'Prata', 'Escape do Submundo pela primeira vez.', 'Será que Há Escapatória?'),
(9, 16, 'Ouro', 'Encontre todos os pingentes dos Vaga-lumes.', 'Procure a Luz'),
(10, 18, 'Ouro', 'Conclua a história principal no modo Profissional com Rank S+.', 'Agente S+'),
(11, 20, 'Prata', 'Absorva 20 almas de dragão.', 'Mestre das Almas'),
(12, 22, 'Ouro', 'Alcance a perfeição total no vale.', 'Perfeição'),
(13, 24, 'Platina', 'Obtenha todos os troféus de Yharnam.', 'Yharnam, Rainha Pthumeriana');

INSERT INTO Possui_categoria (Id_categoria, Id_Jogos) VALUES
(1, 1), (4, 1),             -- The Witcher 3
(1, 2), (2, 2), (4, 2),     -- Cyberpunk 2077
(1, 3), (5, 3), (4, 3),     -- Elden Ring
(1, 4), (5, 4),             -- Dark Souls III
(3, 5), (2, 5),             -- CS 2
(8, 6),                     -- Portal 2
(2, 7), (4, 7), (8, 7),     -- RDR 2
(2, 8), (4, 8),             -- GTA V
(2, 9), (8, 9),             -- God of War
(2, 10), (8, 10),           -- God of War Ragnarok
(1, 11), (8, 11),           -- Baldur's Gate 3
(6, 12), (7, 12),           -- Hollow Knight
(4, 13), (8, 13),           -- Zelda BOTW
(6, 14), (9, 14), (2, 14),  -- Hades
(10, 15), (8, 15),          -- Minecraft
(2, 16), (8, 16), (11, 16), -- The Last of Us Part I
(2, 17), (8, 17), (11, 17), -- The Last of Us Part II
(2, 18), (11, 18),          -- Resident Evil 4 Remake
(1, 19), (2, 19),           -- Monster Hunter World
(1, 20), (4, 20), (8, 20),  -- Skyrim
(1, 21), (3, 21), (4, 21),  -- Fallout 4
(1, 22), (6, 22), (12, 22), -- Stardew Valley
(8, 23), (11, 23),          -- Alan Wake 2
(1, 24), (5, 24), (11, 24), -- Bloodborne
(4, 25), (8, 25);           -- Zelda TOTK

INSERT INTO Disponivel_em (Id_Jogos, Id_Plataforma) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), -- The Witcher 3
(2, 1), (2, 2), (2, 3),                 -- Cyberpunk 2077
(3, 1), (3, 2), (3, 3), (3, 5),         -- Elden Ring
(4, 1), (4, 5),                         -- Dark Souls III
(5, 1),                                 -- CS 2
(6, 1), (6, 4),                         -- Portal 2
(7, 1), (7, 5),                         -- RDR 2
(8, 1), (8, 2), (8, 3), (8, 5),         -- GTA V
(9, 1), (9, 5),                         -- God of War
(10, 1), (10, 2), (10, 5),              -- God of War Ragnarok
(11, 1), (11, 2), (11, 3),              -- Baldur's Gate 3
(12, 1), (12, 4), (12, 5),              -- Hollow Knight
(13, 4),                                -- Zelda BOTW
(14, 1), (14, 2), (14, 3), (14, 4),     -- Hades
(15, 1), (15, 2), (15, 3), (15, 4), (15, 5), -- Minecraft
(16, 1), (16, 2),                       -- The Last of Us Part I
(17, 2), (17, 5),                       -- The Last of Us Part II
(18, 1), (18, 2), (18, 3), (18, 5),     -- Resident Evil 4 Remake
(19, 1), (19, 5),                       -- Monster Hunter World
(20, 1), (20, 2), (20, 3), (20, 4), (20, 5), -- Skyrim
(21, 1), (21, 2), (21, 3), (21, 5),     -- Fallout 4
(22, 1), (22, 4), (22, 5),              -- Stardew Valley
(23, 1), (23, 2), (23, 3),              -- Alan Wake 2
(24, 5),                                -- Bloodborne (Exclusivo PS4)
(25, 4);                                -- Zelda TOTK (Exclusivo Switch)

INSERT INTO Avaliacao (Id_avaliacao, Id_usuario, Id_Jogos, Comentarios, Nota_avaliacao) VALUES
(1, 1, 1, 'Narrativa espetacular e missões secundárias memoráveis.', 5),
(2, 2, 1, 'Um dos melhores RPGs já feitos na história.', 5),
(3, 3, 3, 'Exploração incrível e chefes desafiadores.', 5),
(4, 1, 3, 'Difícil no começo, mas viciante.', 3),
(5, 5, 5, 'Ótimo para jogar competitivo com amigos.', 4),
(6, 1, 7, 'Gráficos realistas e história emocionante.', 5),
(7, 2, 11, 'Liberdade absurda de escolhas no combate e diálogos.', 5),
(8, 4, 12, 'Arte linda, trilha sonora perfeita e preço super justo.', 5),
(9, 4, 14, 'Jogabilidade rápida e muito divertida.', 5),
(10, 3, 2, 'Melhorou muito após as atualizações e expansão.', 4),
(11, 2, 13, 'Revolucionou os jogos de mundo aberto.', 5),
(12, 5, 8, 'Clássico indispensável, modo online muito ativo.', 4),
(13, 6, 16, 'História emocionante do início ao fim.', 5),
(14, 6, 18, 'Remake impecável, mantém a tensão do original.', 5),
(15, 2, 20, 'Infinitas horas de conteúdo e exploração.', 5),
(16, 4, 22, 'Relaxante e muito viciante, perfeito para jogar sem pressa.', 5),
(17, 6, 23, 'Atmosfera sombria e narrativa cinematográfica incrível.', 5),
(18, 3, 24, 'Combate rápido e estética gótica inigualável.', 5),
(19, 1, 10, 'Final épico para a saga nórdica.', 5),
(20, 2, 25, 'Criatividade sem limites na construção de veículos e armas.', 5);

INSERT INTO Exige (Id_hardware, Id_Jogos) VALUES
(1, 1), (10, 2), (2, 3), (1, 4), (3, 5),
(7, 6), (4, 7), (5, 8), (5, 9), (10, 10),
(6, 11), (7, 12), (8, 14), (9, 15), (12, 16),
(11, 18), (1, 19), (7, 20), (1, 21), (13, 22),
(14, 23);
