
# Infraestrutura como Código (IaC) com Terraform - Projeto VExpenses

Este projeto provisiona uma infraestrutura básica na AWS utilizando **Terraform**, uma ferramenta de infraestrutura como código (IaC). A infraestrutura é composta por uma instância EC2 rodando Debian 12, com uma VPC personalizada, sub-rede, gateway de internet, e um grupo de segurança configurado para permitir conexões SSH.

## Recursos Utilizados

### 1. **Provedor AWS**
   - A infraestrutura é provisionada na região **us-east-1** (Leste dos EUA).

### 2. **Parâmetros de Configuração**
   - **Projeto**: Nome do projeto, configurável via variável `projeto` (padrão: `VExpenses`).
   - **Candidato**: Nome do candidato, configurável via variável `candidato` (padrão: `SeuNome`).

### 3. **Chaves SSH**
   - Uma chave privada é gerada localmente para acessar a instância EC2.
   - Um par de chaves é criado na AWS com a chave pública correspondente.

### 4. **Rede**
   - **VPC (Virtual Private Cloud)**: Rede isolada com o bloco CIDR `10.0.0.0/16`.
   - **Sub-rede**: Sub-rede com o bloco CIDR `10.0.1.0/24` na zona de disponibilidade `us-east-1a`.
   - **Gateway de Internet**: Permite comunicação da VPC com a internet pública.
   - **Tabela de Rotas**: Rota configurada para permitir o tráfego de saída para a internet.

### 5. **Grupo de Segurança**
   - **Regras de Entrada (Ingress)**: Permite conexões SSH (porta 22) de qualquer endereço IP (`0.0.0.0/0`).
   - **Regras de Saída (Egress)**: Permite todo o tráfego de saída.

### 6. **Instância EC2**
   - **AMI**: A imagem mais recente do Debian 12 é utilizada.
   - **Tipo de Instância**: `t2.micro` (coberto pelo nível gratuito da AWS).
   - **Disco Root**: Volume de 20 GB configurado como `gp2`.
   - **User Data**: Script executado na inicialização para atualização automática de pacotes:

   \`\`\`bash
   #!/bin/bash
   apt-get update -y
   apt-get upgrade -y
   \`\`\`

## Saídas (Outputs)

- **Chave Privada**: A chave privada gerada localmente para acessar a instância EC2.
- **Endereço IP Público da Instância**: O IP público para acessar a instância via SSH.

## Pré-requisitos

- Terraform instalado ([Guia de instalação](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)).
- Conta AWS com permissões adequadas para provisionar recursos (EC2, VPC, etc.).
- Configuração do AWS CLI (opcional).

## Como Usar

1. Clone este repositório:

   \`\`\`bash
   git clone https://github.com/seu-usuario/projeto-vexpenses.git
   cd projeto-vexpenses
   \`\`\`

2. Inicialize o Terraform:

   \`\`\`bash
   terraform init
   \`\`\`

3. Revise as mudanças que serão aplicadas:

   \`\`\`bash
   terraform plan
   \`\`\`

4. Aplique a configuração para provisionar a infraestrutura:

   \`\`\`bash
   terraform apply
   \`\`\`

5. Após a execução bem-sucedida, o endereço IP público da instância será exibido. Use o seguinte comando para acessar via SSH:

   \`\`\`bash
   ssh -i path/to/private_key.pem ec2-user@<IP_PUBLICO>
   \`\`\`

## Observações de Segurança

- **Atenção**: As regras de segurança permitem acesso SSH de qualquer IP (0.0.0.0/0). Para ambientes de produção, recomenda-se restringir o acesso a IPs específicos.
  
## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).
