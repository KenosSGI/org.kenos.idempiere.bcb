# LEIA-ME

Integração com o site do **Banco Central do Brasil** (BCB) para obter as taxas de conversão/cotações de moeda do dia. A integração é feita por download do arquivo CSV que é disponibilizado pelo site.

## COMO INSTALAR

Baixe o plugin no formato **JAR** e instale no seu ambiente. 

[Clique aqui para fazer o Download.](https://bitbucket.org/kenos/org.kenos.idempiere.bcb/downloads/) Com o plugin instalado e ativo a criação dos dados no Banco de Dados é feita automaticamente via **2Pack**.

Veja mais detalhes sobre como instalar [clicando aqui.](http://wiki.idempiere.org/en/Developing_Plug-Ins_-_Get_your_Plug-In_running)

## COMO USAR

Com plugin ativo, basta acessar o menu Análise de Desempenho -> Regras Contábeis -> **Obter Conversões de Moeda** e preecher os parâmetros:

 - **Data da Transação**: Indica a qual data a taxa de conversão se refere
 - **Moeda**: Para a pesquisa de uma única moeda, selecione-a neste campo
 - **Código da Moeda**: Para a pesquisa de múltiplas moedas coloque o código ISO das moedas separado por vírgula. Ex: USD,EUR,JPY irá adicionar as cotações para Dólar Americano, Euro e Yene Japonês.

As taxas de conversão são exibidas na tela para o usuário e também são salvas no sistema com validade de 7 dias.

## COMO CONTRIBUIR

Faça um fork deste projeto e proponha que as mudanças desejadas sejam integradas neste projeto.

## FALE COM O DESENVOLVEDOR

Para entrar em contato com os desenvolvedores [deixe sua mensagem aqui.](https://talk.kenos.com.br/)