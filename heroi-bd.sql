-- Banco de Dados Herói

--Criando as tabelas principais:



CREATE TABLE Poderes (
	Poderes_PK SERIAL PRIMARY KEY,
	Poder VARCHAR(100) NOT NULL
);

CREATE TABLE Historico_de_batalhas (
	Historico_de_batalhas_PK SERIAL PRIMARY KEY,
	Descricao TEXT NOT NULL
);

CREATE TABLE Heroi (
	Nome_heroi VARCHAR(100) PRIMARY KEY,
	Altura FLOAT NOT NULL,
	Sexo VARCHAR(10) NOT NULL,
	Peso FLOAT NOT NULL,
	Data_Nascimento DATE NOT NULL,
	Nome_real VARCHAR(100) UNIQUE NOT NULL,
	Local_Nascimento VARCHAR(100) NOT NULL,
	fk_Poderes_Poderes_PK INT NOT NULL,
	Nivel_de_forca INT NOT NULL,
	Status VARCHAR(50) NOT NULL,
	fk_Historico_de_batalhas_PK INT,

	CONSTRAINT fk_heroi_poder FOREIGN KEY (fk_Poderes_Poderes_PK)
		REFERENCES Poderes (Poderes_PK) ON DELETE CASCADE,
	CONSTRAINT fk_heroi_historico FOREIGN KEY (fk_Historico_de_batalhas_PK)
		REFERENCES Historico_de_batalhas (Historico_de_batalhas_PK) ON DELETE SET NULL
);

CREATE TABLE Crimes (
	Crime_PK SERIAL PRIMARY KEY,
	Nome_crime VARCHAR(255) NOT NULL,
	Data_crime DATE NOT NULL,
	Descricao_crime VARCHAR(255) NOT NULL,
	Severidade INT NOT NULL,
	fk_Heroi_Nome_real VARCHAR(100) NOT NULL
);


CREATE TABLE Missao (
	Missao_PK SERIAL PRIMARY KEY,
	Nome_missao VARCHAR(255) NOT NULL,
	Descricao_missao VARCHAR(255) NOT NULL,
	Recompensa INT NOT NULL,
	Dificuldade INT NOT NULL,
	Resultado_Sucesso_Fracasso BOOLEAN NOT NULL,
	fk_Heroi_Nome_heroi VARCHAR(100) NOT NULL,

	CONSTRAINT fk_missao_heroi FOREIGN KEY (fk_Heroi_Nome_heroi)
		REFERENCES Heroi (Nome_heroi) ON DELETE CASCADE
);

CREATE TABLE Participa (
	fk_Missao_Pk INT NOT NULL,
	fk_Heroi_Nome_heroi VARCHAR(100) NOT NULL,
	PRIMARY KEY (fk_Missao_PK, fk_Heroi_Nome_heroi),

	CONSTRAINT fk_participa_missao FOREIGN KEY (fk_Missao_PK)
		REFERENCES Missao (Missao_PK) ON DELETE CASCADE,
	CONSTRAINT fk_participa_heroi FOREIGN KEY (fk_Heroi_Nome_Heroi)
		REFERENCES Heroi (Nome_heroi) ON DELETE CASCADE
);


--Trigger para alterar o status do herói de acordo com a popularidade dele
CREATE OR REPLACE FUNCTION atualizar_status_heroi()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.Nivel_de_forca < 20 THEN
		NEW.Status := 'Banned';
	ELSIF NEW.Nivel_de_forca < 50 THEN
		NEW.Status := 'Low Popularity';
	ELSE
		NEW.Status := 'Active';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_status
BEFORE INSERT OR UPDATE ON Heroi
FOR EACH ROW
EXECUTE FUNCTION atualizar_status_heroi();

--Trigger para reduzir a popularidade de acordo com os crimes
CREATE OR REPLACE FUNCTION ajustar_popularidade_por_crimes()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.Severidade >= 8 THEN
		UPDATE Heroi SET Nivel_de_forca = Nivel_de_forca - 10 WHERE Nome_heroi = NEW.fk_Heroi_Nome_heroi;
	ELSIF NEW.Severidade >= 5 THEN
		UPDATE Heroi SET Nivel_de_forca = Nivel_de_forca - 5 WHERE Nome_heroi = NEW.fk_Heroi_Nome_heroi;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_crimes
AFTER INSERT ON Crimes
FOR EACH ROW
EXECUTE FUNCTION ajustar_popularidade_por_crimes();

--Trigger para atribuir as missões baseadas na força do heroi
CREATE OR REPLACE FUNCTION distribuir_missoes()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.Dificuldade >= 8 THEN
		IF NEW.fk_Heroi_Nome_heroi IN (SELECT Nome_heroi FROM Heroi WHERE Nivel_de_forca >= 80) THEN
			RAISE NOTICE 'Missão difícil atribuída ao herói %.', NEW.fk_Heroi_Nome_heroi;
		ELSE
			RAISE EXCEPTION 'Herói % não tem força suficiente para a missão.', NEW.fk_Heroi_Nome_heroi;
		END IF;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_missao
BEFORE INSERT ON Missao
FOR EACH ROW
EXECUTE FUNCTION distribuir_missoes();


--Consultas de exemplo para teste
--buscar os herois de acordo com seu status
SELECT * FROM Heroi WHERE Status = 'Active';


--Buscar missões de acordo com dificuldade
SELECT * FROM Missao WHERE Dificuldade >= 8;

