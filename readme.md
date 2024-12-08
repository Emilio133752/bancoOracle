# Sistema de Gerenciamento de Alunos, Disciplinas e Professores

Este projeto implementa pacotes em PL/SQL que realizam operações relacionadas às entidades Aluno, Disciplina e Professor no banco de dados Oracle.

## **Como Executar o Script**

1. Faça login no Oracle SQL*Plus ou uma ferramenta como SQL Developer.
2. Execute o script `pacotes.sql` para criar os pacotes.
3. Use os comandos adequados para chamar as procedures e functions.

## **Resumo das Funcionalidades**

### **PKG_ALUNO**
- **ExcluirAluno**: Remove um aluno e suas matrículas.
- **ListarAlunosMaior18**: Lista alunos maiores de 18 anos.
- **ListarAlunosPorCurso**: Lista alunos de um curso específico.

### **PKG_DISCIPLINA**
- **CadastrarDisciplina**: Cadastra uma nova disciplina.
- **TotalAlunosPorDisciplina**: Exibe disciplinas com mais de 10 alunos.
- **MediaIdadePorDisciplina**: Calcula a média de idade dos alunos de uma disciplina.
- **ListarAlunosPorDisciplina**: Lista alunos de uma disciplina.

### **PKG_PROFESSOR**
- **TotalTurmasPorProfessor**: Lista professores com mais de uma turma.
- **TotalTurmasProfessor**: Retorna o total de turmas de um professor.
- **ProfessorDaDisciplina**: Retorna o professor de uma disciplina.

## **Estrutura do Banco de Dados**
As tabelas envolvidas são:
- `alunos(id_aluno, nome, data_nascimento, ...)`
- `disciplinas(id_disciplina, nome, descricao, carga_horaria, ...)`
- `professores(id_professor, nome, ...)`
- `matriculas(id_aluno, id_disciplina, ...)`
- `turmas(id_turma, id_professor, id_disciplina, ...)`

---

**Autor:** Emilio
