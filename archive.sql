-- Pacote PKG_ALUNO
CREATE OR REPLACE PACKAGE PKG_ALUNO IS
  PROCEDURE ExcluirAluno(p_id_aluno IN NUMBER);
  CURSOR ListarAlunosMaior18;
  CURSOR ListarAlunosPorCurso(p_id_curso IN NUMBER);
END PKG_ALUNO;
/

CREATE OR REPLACE PACKAGE BODY PKG_ALUNO IS
  PROCEDURE ExcluirAluno(p_id_aluno IN NUMBER) IS
  BEGIN
    DELETE FROM matriculas WHERE id_aluno = p_id_aluno;
    DELETE FROM alunos WHERE id_aluno = p_id_aluno;
  END ExcluirAluno;

  CURSOR ListarAlunosMaior18 IS
    SELECT nome, data_nascimento
    FROM alunos
    WHERE EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_nascimento) > 18;

  CURSOR ListarAlunosPorCurso(p_id_curso IN NUMBER) IS
    SELECT a.nome
    FROM alunos a
    JOIN matriculas m ON a.id_aluno = m.id_aluno
    WHERE m.id_curso = p_id_curso;
END PKG_ALUNO;
/

-- Pacote PKG_DISCIPLINA
CREATE OR REPLACE PACKAGE PKG_DISCIPLINA IS
  PROCEDURE CadastrarDisciplina(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_carga_horaria IN NUMBER);
  CURSOR TotalAlunosPorDisciplina;
  CURSOR MediaIdadePorDisciplina(p_id_disciplina IN NUMBER);
  PROCEDURE ListarAlunosPorDisciplina(p_id_disciplina IN NUMBER);
END PKG_DISCIPLINA;
/

CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA IS
  PROCEDURE CadastrarDisciplina(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_carga_horaria IN NUMBER) IS
  BEGIN
    INSERT INTO disciplinas (nome, descricao, carga_horaria)
    VALUES (p_nome, p_descricao, p_carga_horaria);
  END CadastrarDisciplina;

  CURSOR TotalAlunosPorDisciplina IS
    SELECT d.nome, COUNT(m.id_aluno) AS total_alunos
    FROM disciplinas d
    JOIN matriculas m ON d.id_disciplina = m.id_disciplina
    GROUP BY d.nome
    HAVING COUNT(m.id_aluno) > 10;

  CURSOR MediaIdadePorDisciplina(p_id_disciplina IN NUMBER) IS
    SELECT AVG(EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM a.data_nascimento)) AS media_idade
    FROM alunos a
    JOIN matriculas m ON a.id_aluno = m.id_aluno
    WHERE m.id_disciplina = p_id_disciplina;

  PROCEDURE ListarAlunosPorDisciplina(p_id_disciplina IN NUMBER) IS
  BEGIN
    FOR aluno IN (SELECT a.nome
                  FROM alunos a
                  JOIN matriculas m ON a.id_aluno = m.id_aluno
                  WHERE m.id_disciplina = p_id_disciplina) LOOP
      DBMS_OUTPUT.PUT_LINE(aluno.nome);
    END LOOP;
  END ListarAlunosPorDisciplina;
END PKG_DISCIPLINA;
/

-- Pacote PKG_PROFESSOR
CREATE OR REPLACE PACKAGE PKG_PROFESSOR IS
  CURSOR TotalTurmasPorProfessor;
  FUNCTION TotalTurmasProfessor(p_id_professor IN NUMBER) RETURN NUMBER;
  FUNCTION ProfessorDaDisciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2;
END PKG_PROFESSOR;
/

CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR IS
  CURSOR TotalTurmasPorProfessor IS
    SELECT p.nome, COUNT(t.id_turma) AS total_turmas
    FROM professores p
    JOIN turmas t ON p.id_professor = t.id_professor
    GROUP BY p.nome
    HAVING COUNT(t.id_turma) > 1;

  FUNCTION TotalTurmasProfessor(p_id_professor IN NUMBER) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total
    FROM turmas
    WHERE id_professor = p_id_professor;
    RETURN v_total;
  END TotalTurmasProfessor;

  FUNCTION ProfessorDaDisciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2 IS
    v_nome_professor VARCHAR2(100);
  BEGIN
    SELECT p.nome INTO v_nome_professor
    FROM professores p
    JOIN turmas t ON p.id_professor = t.id_professor
    JOIN disciplinas d ON t.id_disciplina = d.id_disciplina
    WHERE d.id_disciplina = p_id_disciplina;
    RETURN v_nome_professor;
  END ProfessorDaDisciplina;
END PKG_PROFESSOR;
/
