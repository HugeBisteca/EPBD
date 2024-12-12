-- Tabela TipoServico
CREATE TABLE TipoServico (
    ID_Tipo INT PRIMARY KEY,
    Descricao VARCHAR(50)
);

-- Tabela Servicos
CREATE TABLE Servicos (
    Nome VARCHAR(100) PRIMARY KEY,
    TempoDurac INT CHECK (TempoDurac >= 0),
    Preco DECIMAL(10, 2) CHECK (Preco >= 0),
    ID_Tipo INT NOT NULL,
    FOREIGN KEY (ID_Tipo) REFERENCES TipoServico(ID_Tipo)
);

-- Tabela Clientes
CREATE TABLE Clientes (
    Codigo INT PRIMARY KEY,
    CPF CHAR(11) UNIQUE,
    RG VARCHAR(20) UNIQUE,
    NomeCompl VARCHAR(100),
    Endereco VARCHAR(200)
);

-- Tabela Pedido
CREATE TABLE Pedido (
    Codigo INT PRIMARY KEY,
    id_cliente INT NOT NULL,
    PrecoTotal DECIMAL(10, 2) DEFAULT 0 CHECK (PrecoTotal >= 0),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(Codigo) ON DELETE CASCADE
);

-- Tabela Solicitam
CREATE TABLE Solicitam (
    Nome VARCHAR(100),
    Codigo INT,
    CPF CHAR(11),
    TempoHoraDurac INT CHECK (TempoHoraDurac >= 0),
    Preco DECIMAL(10, 2),
    DataFim DATE,
    PRIMARY KEY (Nome, Codigo, CPF),
    FOREIGN KEY (Nome) REFERENCES Servicos(Nome) ON DELETE CASCADE,
    FOREIGN KEY (Codigo) REFERENCES Pedido(Codigo) ON DELETE CASCADE,
    FOREIGN KEY (CPF) REFERENCES Clientes(CPF) ON DELETE CASCADE
);

-- Tabela Empresa
CREATE TABLE Empresa (
    ID INT PRIMARY KEY,
    Nome VARCHAR(100),
    Endereco VARCHAR(200)
);

-- Tabela Cidade
CREATE TABLE Cidade (
    Nome VARCHAR(100) PRIMARY KEY,
    Estado CHAR(2)
);

-- Tabela Oferecem
CREATE TABLE Oferecem (
    ID INT,
    Nome VARCHAR(100),
    NomeCidade VARCHAR(100),
    PrecoHoraSe DECIMAL(10, 2),
    PRIMARY KEY (ID, Nome, NomeCidade),
    FOREIGN KEY (ID) REFERENCES Empresa(ID) ON DELETE CASCADE,
    FOREIGN KEY (Nome) REFERENCES Servicos(Nome) ON DELETE CASCADE,
    FOREIGN KEY (NomeCidade) REFERENCES Cidade(Nome) ON DELETE CASCADE
);

-- Trigger para Atualizar PrecoTotal no Pedido
CREATE OR REPLACE FUNCTION atualizar_preco_total()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar o Preco de cada solicitação na tabela Solicitam
    UPDATE Solicitam
    SET Preco = (
        SELECT o.PrecoHoraSe * NEW.TempoHoraDurac
        FROM Oferecem o
        WHERE o.Nome = NEW.Nome AND o.NomeCidade IN (
            SELECT c.Nome
            FROM Cidade c
            WHERE c.Nome = o.NomeCidade
        )
    )
    WHERE Nome = NEW.Nome AND Codigo = NEW.Codigo;

    -- Atualizar o PrecoTotal do Pedido
    UPDATE Pedido
    SET PrecoTotal = (
        SELECT SUM(s.Preco)
        FROM Solicitam s
        WHERE s.Codigo = NEW.Codigo
    )
    WHERE Codigo = NEW.Codigo;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para disparar a função após inserções ou atualizações na tabela Solicitam
CREATE TRIGGER trg_atualizar_preco_total
AFTER INSERT OR UPDATE ON Solicitam
FOR EACH ROW EXECUTE FUNCTION atualizar_preco_total();

-- Inserção de Dados: TipoServico
INSERT INTO TipoServico (ID_Tipo, Descricao) VALUES
(1, 'Transporte'),
(2, 'Guindaste'),
(3, 'Montagem'),
(4, 'Desmontagem');

-- Inserção de Dados: Servicos
INSERT INTO Servicos (Nome, TempoDurac, Preco, ID_Tipo) VALUES
('Transporte A', 5, 150.00, 1),
('Transporte B', 3, 100.00, 1),
('Guindaste C', 2, 300.00, 2),
('Guindaste D', 4, 400.00, 2),
('Montagem E', 6, 200.00, 3),
('Montagem F', 2, 250.00, 3),
('Desmontagem G', 4, 250.00, 4),
('Desmontagem H', 3, 150.00, 4),
('Transporte I', 5, 120.00, 1),
('Transporte J', 3, 110.00, 1);

-- Inserção de Dados: Empresas
INSERT INTO Empresa (ID, Nome, Endereco) VALUES
(1, 'Mudanças XYZ', 'Av. Principal, 456'),
(2, 'Mudanças ABC', 'Rua Secundária, 789');

-- Inserção de Dados: Cidades
INSERT INTO Cidade (Nome, Estado) VALUES
('São Paulo', 'SP'),
('Rio de Janeiro', 'RJ'),
('Belo Horizonte', 'MG');

-- Inserção de Dados: Clientes 
INSERT INTO Clientes (Codigo, CPF, RG, NomeCompl, Endereco) VALUES
(1, '12345678901', '123456789', 'João Silva', 'Rua A, 123'),
(2, '98765432100', '234567890', 'Maria Oliveira', 'Rua B, 456'),
(3, '23456789012', '345678901', 'Carlos Souza', 'Av. Central, 789'),
(4, '34567890123', '456789012', 'Ana Costa', 'Rua D, 101'),
(5, '45678901234', '567890123', 'Pedro Almeida', 'Rua E, 202'),
(6, '56789012345', '678901234', 'Luana Ferreira', 'Av. Norte, 303'),
(7, '67890123456', '789012345', 'Felipe Martins', 'Rua F, 404'),
(8, '78901234567', '890123456', 'Cláudia Ramos', 'Av. Sul, 505'),
(9, '89012345678', '901234567', 'Ricardo Lima', 'Rua G, 606'),
(10, '90123456789', '012345678', 'Mariana Pinto', 'Av. Oeste, 707'),
(11, '01234567890', '112233445', 'Fernanda Rocha', 'Rua H, 808'),
(12, '11223344556', '223344556', 'Giovanni Silva', 'Rua I, 909'),
(13, '22334455667', '334455667', 'Isabela Costa', 'Rua J, 1010'),
(14, '33445566778', '445566778', 'Eduardo Souza', 'Rua K, 1111'),
(15, '44556677889', '556677889', 'Marcos Oliveira', 'Rua L, 1212'),
(16, '55667788990', '667788990', 'Gabriela Almeida', 'Rua M, 1313'),
(17, '66778899001', '778899001', 'Renato Pereira', 'Rua N, 1414'),
(18, '77889900112', '889900112', 'Sandra Lima', 'Rua O, 1515'),
(19, '88990011223', '990011223', 'Flávio Costa', 'Rua P, 1616'),
(20, '99001122334', '001122334', 'Fernanda Alves', 'Rua Q, 1717');


-- Inserção de Dados: Pedidos
INSERT INTO Pedido (Codigo, id_cliente, PrecoTotal) VALUES
(1, 1, 750.00),
(2, 2, 1200.00),
(3, 3, 1000.00),
(4, 4, 300.00),
(5, 5, 200.00),
(6, 1, 850.00),
(7, 2, 950.00),
(8, 3, 1200.00),
(9, 4, 700.00),
(10, 5, 900.00);


-- Inserção de Dados: Solicitações
INSERT INTO Solicitam (Nome, Codigo, CPF, TempoHoraDurac, Preco, DataFim) VALUES
('Transporte A', 1, '12345678901', 5, 750.00, '2024-01-10'),
('Guindaste C', 1, '12345678901', 2, 600.00, '2024-01-12'),
('Montagem E', 2, '98765432100', 6, 1200.00, '2024-01-15'),
('Desmontagem G', 3, '23456789012', 4, 1000.00, '2024-01-20'),
('Transporte B', 4, '34567890123', 3, 300.00, '2024-01-25'),
('Guindaste D', 5, '45678901234', 3, 900.00, '2024-02-01'),
('Montagem F', 6, '56789012345', 4, 1000.00, '2024-02-05'),
('Desmontagem H', 7, '67890123456', 5, 1200.00, '2024-02-10'),
('Transporte C', 8, '78901234567', 3, 350.00, '2024-02-15'),
('Guindaste E', 9, '89012345678', 2, 600.00, '2024-02-20'),
('Montagem G', 10, '90123456789', 5, 1050.00, '2024-02-25'),
('Transporte D', 11, '01234567890', 4, 600.00, '2024-03-01'),
('Guindaste F', 12, '11223344556', 3, 650.00, '2024-03-05'),
('Montagem H', 13, '22334455667', 5, 1000.00, '2024-03-10'),
('Desmontagem I', 14, '33445566778', 4, 850.00, '2024-03-15'),
('Transporte E', 15, '44556677889', 3, 500.00, '2024-03-20'),
('Guindaste G', 16, '55667788990', 4, 700.00, '2024-03-25'),
('Montagem I', 17, '66778899001', 6, 1200.00, '2024-04-01'),
('Desmontagem J', 18, '77889900112', 5, 1100.00, '2024-04-05'),
('Transporte F', 19, '88990011223', 4, 450.00, '2024-04-10'),
('Guindaste H', 20, '99001122334', 5, 750.00, '2024-04-15');
