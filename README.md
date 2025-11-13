# User-blocking-in-SAP
# Bloqueio Automático de Usuários SAP

O programa **ZBASES_BLOCK_USER** realiza o **bloqueio automático de usuários SAP** cujo **último acesso** ultrapassa a quantidade de dias definida na variável `Z_DIAS_INATIVO` da transação **STVARVC**.  
Essa automação garante a conformidade com as políticas de segurança da empresa e evita acessos indevidos de usuários inativos.

---

## Configuração

O comportamento do programa é controlado por variáveis configuradas na **STVARVC**:

| Variável | Descrição | Exemplo de Valor |
|-----------|------------|------------------|
| `Z_DIAS_INATIVO` | Quantidade máxima de dias de inatividade antes do bloqueio. | `30` |
| `Z_USERS_NOT_BLOCKED` | Lista de usuários que **nunca devem ser bloqueados**. | `SAP*;DDIC;USR_ADMIN` |

---

## 🧩 Funcionalidades

- Bloqueio automático de usuários inativos conforme o limite configurado.  
- Exclusão de usuários “mestres” definidos na variável `Z_USERS_NOT_BLOCKED`.  
- Parametrização simples via **STVARVC** (sem transporte de código).  
- Log e controle via **SM37** (monitoramento de jobs).  

---

## Agendamento Automático 

O programa **ZBASES_BLOCK_USER** foi agendado para execução automática a cada **15 dias** através da transação **SM36**.  
Recomenda-se que o job rode fora do horário comercial, com um usuário técnico e apropriadas autorizações.

### Exemplo de agendamento:
- **Transação:** SM36  
- **Programa:** ZBASES_BLOCK_USER  
- **Periodicidade:** A cada 15 dias  
- **Usuário técnico:** `BATCH_ADMIN` (exemplo)

---

## Observações

- Teste em ambiente de homologação antes de ativar em produção.  
- Mantenha a lista de exceções (`Z_USERS_NOT_BLOCKED`) sempre atualizada.  
- Registre alterações no controle de versões do repositório.  

---

## Licença

Projeto interno de automação SAP.  
Pode ser ajustado conforme as políticas e necessidades de cada empresa.
