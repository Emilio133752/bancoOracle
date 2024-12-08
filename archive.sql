--TABELAS

CREATE TABLE alunos (
    id_aluno NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    data_nascimento DATE
);

CREATE TABLE matriculas (
    id_matricula NUMBER PRIMARY KEY,
    id_aluno NUMBER,
    id_curso NUMBER,
    id_disciplina NUMBER,
    FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno)
);

CREATE TABLE disciplinas (
  id_disciplina NUMBER PRIMARY KEY,
  nome VARCHAR2(100),
  descricao VARCHAR2(255),
  carga_horaria NUMBER
);


CREATE TABLE professores (
  id_professor NUMBER PRIMARY KEY,
  nome VARCHAR2(100)
);

CREATE TABLE turmas (
  id_turma NUMBER PRIMARY KEY,
  id_disciplina NUMBER,
  id_professor NUMBER,
  FOREIGN KEY (id_disciplina) REFERENCES disciplinas(id_disciplina),
  FOREIGN KEY (id_professor) REFERENCES professores(id_professor)
);


-- Pacote PKG_ALUNO

CREATE OR REPLACE PACKAGE PKG_ALUNO IS
  PROCEDURE ExcluirAluno(p_id_aluno IN NUMBER);
  PROCEDURE ListarAlunosMaior18;
  PROCEDURE ListarAlunosPorCurso(p_id_curso IN NUMBER);
END PKG_ALUNO;
/
CREATE OR REPLACE PACKAGE BODY PKG_ALUNO IS
  PROCEDURE ExcluirAluno(p_id_aluno IN NUMBER) IS
  BEGIN
    DELETE FROM matriculas WHERE id_aluno = p_id_aluno;
    DELETE FROM alunos WHERE id_aluno = p_id_aluno;
  END ExcluirAluno;

  PROCEDURE ListarAlunosMaior18 IS
    CURSOR c_alunos IS
      SELECT nome, data_nascimento
      FROM alunos
      WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, data_nascimento) / 12) > 18;
  BEGIN
    FOR r_aluno IN c_alunos LOOP
      DBMS_OUTPUT.PUT_LINE('Nome: ' || r_aluno.nome || ', Data de Nascimento: ' || r_aluno.data_nascimento);
    END LOOP;
  END ListarAlunosMaior18;

  PROCEDURE ListarAlunosPorCurso(p_id_curso IN NUMBER) IS
    CURSOR c_alunos IS
      SELECT a.nome
      FROM alunos a
      JOIN matriculas m ON a.id_aluno = m.id_aluno
      WHERE m.id_curso = p_id_curso;
  BEGIN
    FOR r_aluno IN c_alunos LOOP
      DBMS_OUTPUT.PUT_LINE('Nome: ' || r_aluno.nome);
    END LOOP;
  END ListarAlunosPorCurso;
END PKG_ALUNO;
/

-- Pacote PKG_DISCIPLINA
CREATE OR REPLACE PACKAGE PKG_DISCIPLINA IS
  PROCEDURE CadastrarDisciplina(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_carga_horaria IN NUMBER);
  PROCEDURE TotalAlunosPorDisciplina;
  PROCEDURE MediaIdadePorDisciplina(p_id_disciplina IN NUMBER);
  PROCEDURE ListarAlunosPorDisciplina(p_id_disciplina IN NUMBER);
END PKG_DISCIPLINA;
/

CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA IS
  PROCEDURE CadastrarDisciplina(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_carga_horaria IN NUMBER) IS
  BEGIN
    INSERT INTO disciplinas (nome, descricao, carga_horaria) VALUES (p_nome, p_descricao, p_carga_horaria);
  END CadastrarDisciplina;

  PROCEDURE TotalAlunosPorDisciplina IS
    CURSOR c_disciplinas IS
      SELECT d.nome, COUNT(m.id_aluno) AS total_alunos
      FROM disciplinas d
      JOIN matriculas m ON d.id_disciplina = m.id_disciplina
      GROUP BY d.nome
      HAVING COUNT(m.id_aluno) > 10;
  BEGIN
    FOR r_disciplina IN c_disciplinas LOOP
      DBMS_OUTPUT.PUT_LINE('Disciplina: ' || r_disciplina.nome || ', Total de Alunos: ' || r_disciplina.total_alunos);
    END LOOP;
  END TotalAlunosPorDisciplina;

  PROCEDURE MediaIdadePorDisciplina(p_id_disciplina IN NUMBER) IS
    CURSOR c_media_idade IS
      SELECT AVG(TRUNC(MONTHS_BETWEEN(SYSDATE, a.data_nascimento) / 12)) AS media_idade
      FROM alunos a
      JOIN matriculas m ON a.id_aluno = m.id_aluno
      WHERE m.id_disciplina = p_id_disciplina;
  BEGIN
    FOR r_media IN c_media_idade LOOP
      DBMS_OUTPUT.PUT_LINE('Média de Idade: ' || r_media.media_idade);
    END LOOP;
  END MediaIdadePorDisciplina;

  PROCEDURE ListarAlunosPorDisciplina(p_id_disciplina IN NUMBER) IS
    CURSOR c_alunos IS
      SELECT a.nome
      FROM alunos a
      JOIN matriculas m ON a.id_aluno = m.id_aluno
      WHERE m.id_disciplina = p_id_disciplina;
  BEGIN
    FOR r_aluno IN c_alunos LOOP
      DBMS_OUTPUT.PUT_LINE('Nome do Aluno: ' || r_aluno.nome);
    END LOOP;
  END ListarAlunosPorDisciplina;
END PKG_DISCIPLINA;
/


-- Pacote PKG_PROFESSOR
-- Adiciona a coluna id_professor na tabela disciplinas
ALTER TABLE disciplinas ADD (id_professor NUMBER);

-- Cria a relação entre disciplinas e professores
ALTER TABLE disciplinas
  ADD CONSTRAINT fk_disciplinas_professor
  FOREIGN KEY (id_professor) REFERENCES professores(id_professor);

-- Criação do pacote PKG_PROFESSOR
CREATE OR REPLACE PACKAGE PKG_PROFESSOR IS
  FUNCTION TotalTurmasProfessor(p_id_professor IN NUMBER) RETURN NUMBER;
  FUNCTION ProfessorDeUmaDisciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2;
  PROCEDURE ListarProfessoresComMaisDeUmaTurma;
END PKG_PROFESSOR;
/

-- Corpo do pacote PKG_PROFESSOR
CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR IS

  FUNCTION TotalTurmasProfessor(p_id_professor IN NUMBER) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total
    FROM turmas
    WHERE id_professor = p_id_professor;
    RETURN v_total;
  END TotalTurmasProfessor;

  FUNCTION ProfessorDeUmaDisciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2 IS
    v_nome_professor VARCHAR2(100);
  BEGIN
    SELECT p.nome
    INTO v_nome_professor
    FROM disciplinas d
    JOIN professores p ON d.id_professor = p.id_professor
    WHERE d.id_disciplina = p_id_disciplina;
    RETURN v_nome_professor;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'Professor não encontrado.';
    WHEN OTHERS THEN
      RETURN 'Erro ao buscar o professor.';
  END ProfessorDeUmaDisciplina;

  PROCEDURE ListarProfessoresComMaisDeUmaTurma IS
    CURSOR c_professores IS
      SELECT p.nome, COUNT(t.id_turma) AS total_turmas
      FROM professores p
      JOIN turmas t ON p.id_professor = t.id_professor
      GROUP BY p.nome
      HAVING COUNT(t.id_turma) > 1;
  BEGIN
    FOR r_professor IN c_professores LOOP
      DBMS_OUTPUT.PUT_LINE('Nome: ' || r_professor.nome || ', Total de Turmas: ' || r_professor.total_turmas);
    END LOOP;
  END ListarProfessoresComMaisDeUmaTurma;

END PKG_PROFESSOR;
/




CREATE OR REPLACE PACKAGE PKG_PROFESSOR IS
  PROCEDURE TotalTurmasPorProfessor;
  FUNCTION TotalTurmasDeUmProfessor(p_id_professor IN NUMBER) RETURN NUMBER;
  FUNCTION ProfessorDeUmaDisciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2;
END PKG_PROFESSOR;
/

CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR IS
  PROCEDURE TotalTurmasPorProfessor IS
    CURSOR c_professores IS
      SELECT p.nome, COUNT(t.id_turma) AS total_turmas
      FROM professores p
      JOIN turmas t ON p.id_professor = t.id_professor
      GROUP BY p.nome
      HAVING COUNT(t.id_turma) > 1;
  BEGIN
    FOR r_professor IN c_professores LOOP
      DBMS_OUTPUT.PUT_LINE('Professor: ' || r_professor.nome || ', Total de Turmas: ' || r_professor.total_turmas);
    END LOOP;
  END TotalTurmasPorProfessor;

  FUNCTION TotalTurmasDeUmProfessor(p_id_professor IN NUMBER) RETURN NUMBER IS
    v_total_turmas NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total_turmas
    FROM turmas
    WHERE id_professor = p_id_professor;
    RETURN v_total_turmas;
  END TotalTurmasDeUmProfessor;

  FUNCTION ProfessorDeUmaDisciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2 IS
    v_nome_professor VARCHAR2(100);
  BEGIN
    SELECT p.nome INTO v_nome_professor
    FROM professores p
    JOIN disciplinas d ON p.id_professor = d.id_professor
    WHERE d.id_disciplina = p_id_disciplina;
    RETURN v_nome_professor;
  END ProfessorDeUmaDisciplina;
END PKG_PROFESSOR;
/
