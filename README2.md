
# Projeto Terraform - Infraestrutura na AWS

Este repositório contém um código Terraform para provisionamento de uma infraestrutura básica na AWS. O ambiente cria uma instância EC2 Debian, automatiza a instalação do servidor web Nginx, implementa medidas de segurança adicionais, habilita monitoramento e cria backups automáticos de volumes EBS.

## Recursos Criados

- **VPC**: Cria uma Virtual Private Cloud (VPC) personalizada.
- **Sub-rede**: Provisiona uma sub-rede pública dentro da VPC.
- **Internet Gateway**: Conecta a VPC à internet.
- **Tabela de Rotas**: Define as rotas para o tráfego de entrada e saída da VPC.
- **Instância EC2**: Cria uma instância Debian na AWS, automatizando a instalação e inicialização do servidor Nginx.
- **Security Group**: Define regras de firewall permitindo SSH apenas de um IP autorizado e todo o tráfego de saída.
- **Par de Chaves SSH**: Gera um par de chaves SSH para acessar a instância EC2.
- **VPC Flow Logs**: Captura o tráfego de rede da VPC e envia para o CloudWatch Logs para análise e monitoramento.
- **Monitoramento com CloudWatch**: Implementa um alarme no CloudWatch para monitorar a utilização da CPU da instância EC2.
- **Backup de Volumes EBS**: Cria um plano de backup automático para volumes EBS, com exclusão após 30 dias.

## Pré-requisitos

- Terraform instalado em sua máquina: [Terraform Installation](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Conta AWS configurada com credenciais apropriadas.

## Variáveis

O código utiliza variáveis que podem ser personalizadas para adequar o ambiente às suas necessidades:

- `projeto`: Nome do projeto (default: `VExpenses`).
- `candidato`: Nome do candidato (default: `SeuNome`).
- `allowed_ssh_ip`: Endereço IP autorizado para conexão via SSH (default: `0.0.0.0/0`, altere para maior segurança).
- `vpc_cidr`: Bloco CIDR para a VPC (default: `10.0.0.0/16`).
- `subnet_cidr`: Bloco CIDR para a Sub-rede (default: `10.0.1.0/24`).

## Melhorias Implementadas

### Segurança

- **Acesso SSH Restrito**: O acesso SSH à instância EC2 foi limitado ao IP configurado na variável `allowed_ssh_ip`. Isso garante que apenas o IP autorizado possa se conectar via SSH à instância.
- **EBS Criptografado**: O volume da instância EC2 é criptografado por padrão, aumentando a segurança dos dados armazenados.

### Automação

- **Instalação do Nginx**: O servidor Nginx é instalado e iniciado automaticamente após a criação da instância EC2 por meio de um script `user_data`.
  
### Monitoramento e Logs

- **CloudWatch Metrics e Alarmes**: Um alarme de CloudWatch é configurado para monitorar o uso da CPU da instância EC2, disparando uma ação quando a utilização ultrapassa 80%.
- **VPC Flow Logs**: Captura o tráfego de rede da VPC e envia para o CloudWatch Logs para auditoria e monitoramento.

### Backup de Volumes EBS

- **Backups Automáticos**: Um plano de backup diário é configurado para os volumes EBS, com retenção dos backups por 30 dias.

## Como Usar

1. Clone o repositório:
   ```bash
   git clone https://github.com/seu-usuario/seu-repositorio.git
   cd seu-repositorio
   ```

2. Inicialize o Terraform:
   ```bash
   terraform init
   ```

3. Execute o plano de execução:
   ```bash
   terraform plan
   ```

4. Aplique as mudanças:
   ```bash
   terraform apply
   ```

   Durante a aplicação, você será solicitado a confirmar a execução.

## Saídas

Após a execução bem-sucedida, o Terraform exibirá duas saídas importantes:

- `private_key`: Chave privada para acessar a instância EC2 via SSH.
- `ec2_public_ip`: Endereço IP público da instância EC2, utilizado para acessar o servidor web.

## Limpeza de Recursos

Para remover todos os recursos criados, execute o comando:
```bash
terraform destroy
```

Isso vai destruir todos os recursos provisionados na AWS.

## Considerações Finais

Este código foi desenvolvido com foco em segurança, automação e monitoramento. Além de provisionar os recursos essenciais para a execução de uma aplicação na AWS, ele também garante que a infraestrutura esteja segura e monitorada.

---

**Autor**: Vanessa Bezerra  
**Contato**: vanessaoliveirayu@gmail.com
