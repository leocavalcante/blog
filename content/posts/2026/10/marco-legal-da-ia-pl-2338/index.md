---
title: "O que o Marco Legal da IA (PL 2338) exige, proíbe e ainda deixa em aberto"
description: "O texto aprovado pelo Senado em dezembro de 2024 classifica sistemas de IA pelo uso, proíbe alguns, cobra documentação e avaliação de impacto dos de alto risco e põe a ANPD para coordenar a fiscalização. Na Câmara, a lista de alto risco, o direito autoral e o tamanho da lei seguem em disputa."
date: "2026-10-30T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - governance
    - regulation
    - software-engineering
url: /marco-legal-da-ia-pl-2338/
cover: cover.jpg
cover_alt: "Bandeira do Brasil tremulando ao lado das duas torres do Congresso Nacional, em Brasília, com céu azul e nuvens ao fundo."
cover_credit_name: "Marcos Oliveira/Agência Senado (CC BY 2.0, recortada)"
cover_credit_url: "https://commons.wikimedia.org/wiki/File:Abertura_dos_trabalhos_legislativos_2021_(50905847381).jpg"
---

Um exemplo hipotético. Dois times chamam o mesmo modelo, pela mesma API. Um usa a resposta para resumir tickets de suporte; o outro, para ordenar currículos de candidatos a uma vaga. Pela lista do texto que o Senado aprovou, só o segundo é um sistema de alto risco (art. 14, III), com avaliação de impacto, testes documentados e direito a revisão humana para quem for avaliado.

O código pode ser quase igual. A obrigação muda com o uso.

Esse é o desenho do PL 2338/2023, o Marco Legal da Inteligência Artificial. O texto classifica sistemas pelo contexto em que são usados, proíbe alguns usos, cobra governança dos de alto risco, cria regras próprias para modelos de propósito geral e generativos e põe a ANPD para coordenar os reguladores. As divergências públicas se concentram em duas perguntas: quem decide o que é alto risco, a lei ou o regulador, e o que o treino de modelos deve a quem produziu as obras usadas nele.

Este resumo parte do texto que o Senado enviou à Câmara e da cobertura da tramitação até 30 de outubro de 2026. Onde há disputa, cada lado aparece com a sua fonte.

## O texto ainda não é lei

O senador Rodrigo Pacheco apresentou o projeto em maio de 2023, a partir de um anteprojeto elaborado por uma comissão de juristas. Em 10 de dezembro de 2024, o Senado aprovou em votação simbólica o substitutivo do relator, senador Eduardo Gomes, que absorveu outras sete propostas, entre elas o PL 21/2020, já aprovado pela Câmara. Quatro senadores registraram voto contrário. Um deles, Eduardo Girão, criticou a pressa da votação e disse temer censura e entraves ao desenvolvimento da tecnologia, segundo a Agência Senado.

A Câmara recebeu o texto em março de 2025 e instalou em maio uma comissão especial, presidida pela deputada Luisa Canziani, com o deputado Aguinaldo Ribeiro na relatoria. Depois das audiências públicas e dos seminários regionais de 2025, a votação foi anunciada para antes do Carnaval de 2026, depois para abril ou maio, depois para junho. Em agosto, o relator disse que ela ficaria para depois das eleições. Em 30 de outubro de 2026, os dados abertos da Câmara mostram o projeto aguardando parecer na comissão especial.

Se os deputados mudarem o texto, ele volta ao Senado (art. 65 da Constituição). Por isso o relator e o presidente da Câmara, Hugo Motta, passaram a falar em fechar o texto com os senadores antes de votar.

## O risco depende do uso, e a lista pode crescer

O texto separa os sistemas em faixas.

**Risco excessivo é proibido** (art. 13). Entram sistemas feitos para induzir comportamento que cause dano à saúde ou à segurança, explorar vulnerabilidades, prever crimes a partir de traços de personalidade ou de comportamento passado e produzir material de abuso sexual infantil. Também ficam proibidas as armas autônomas, a pontuação de cidadãos pelo poder público para acesso a bens, serviços e políticas, quando ilegítima ou desproporcional, e a identificação biométrica à distância, em tempo real, em espaço público. Essa última tem exceções: inquérito com autorização judicial prévia, busca de vítimas e desaparecidos, flagrante de crime com pena acima de dois anos, recaptura e cumprimento de mandados.

**Alto risco é permitido, com obrigações** (art. 14). A lista tem 12 finalidades: segurança de infraestrutura crítica, seleção e avaliação de estudantes, recrutamento e decisões sobre trabalhadores, elegibilidade para serviços essenciais e benefícios, priorização de chamadas de emergência, apoio a decisões judiciais, veículos autônomos, diagnóstico médico, análise criminal sobre grandes bases, avaliação de prova em investigação, reconhecimento de emoções e controle de fronteiras. Não é alto risco o sistema usado como tecnologia intermediária, que não influencia a decisão, ou que executa uma tarefa processual restrita.

**Os demais sistemas seguem as regras gerais.** Os direitos à informação sobre a interação com IA, à privacidade e à não discriminação valem para qualquer sistema, independentemente do risco (art. 5º).

A avaliação preliminar, em que o próprio agente classifica o risco do seu sistema, é facultativa e conta como boa prática (art. 12). Ela só é obrigatória para modelos de propósito geral e generativos (art. 29). A lista também não é fechada: o Sistema Nacional de Regulação e Governança de IA (SIA) pode incluir novas hipóteses com base em critérios como efeito sobre grupos vulneráveis e reversibilidade do dano, com participação social e análise de impacto regulatório (arts. 15 e 16). O relator no Senado descreveu a lista como "aberto-exemplificativa".

## Para quem constrói, alto risco vira checklist de engenharia

O art. 18 é o trecho mais concreto para quem escreve software. Quem aplica um sistema de alto risco documenta o ciclo de vida, monitora resultados para medir acurácia, robustez e discriminação, documenta testes de confiabilidade e segurança, registra o grau de supervisão humana e adota medidas contra viés. Quem desenvolve mantém registro das medidas de governança, guarda log de operação, testa segurança e entrega informação suficiente para interpretar os resultados.

Três pontos mexem com o dia a dia de quem coloca modelo em produção:

- Quem faz modificação substancial num sistema, ou muda a finalidade dele, passa a responder como desenvolvedor (art. 18, § 5º). O texto não diz o que é substancial. Um fine-tuning conta?
- A avaliação de impacto algorítmico é obrigatória no alto risco: vem antes do lançamento, acompanha o ciclo de vida e tem conclusões públicas, ressalvado o segredo comercial (arts. 25 a 28). Quando a LGPD exigir relatório de impacto, os dois podem ser feitos juntos.
- Incidente grave precisa ser comunicado à autoridade setorial, no prazo que ela definir (art. 42).

Para a pessoa afetada por um sistema de alto risco, o texto garante direito a explicação, a contestar e a pedir revisão humana (art. 6º). A supervisão humana pode ser dispensada quando for comprovadamente impossível ou exigir esforço desproporcional, desde que haja medida alternativa eficaz (art. 8º).

As sanções vão de advertência a suspensão do sistema, com multa de até 2% do faturamento bruto no Brasil, limitada a R$ 50 milhões por infração (art. 50). Na responsabilidade civil, continuam valendo o Código de Defesa do Consumidor e o Código Civil, e o juiz inverte o ônus da prova quando a vítima for hipossuficiente ou quando o funcionamento do sistema tornar a prova excessivamente onerosa para ela (arts. 35 a 37).

## Modelos de propósito geral entram por outra porta

Modelos de propósito geral e generativos têm seção própria (arts. 29 a 33). O desenvolvedor sempre faz a avaliação preliminar. Se o modelo tiver risco sistêmico, antes de disponibilizá-lo para fins comerciais o desenvolvedor precisa descrevê-lo, documentar testes e riscos remanescentes, usar apenas dados tratados conforme a lei, publicar um resumo dos dados de treino, buscar eficiência energética e entregar documentação técnica a quem integra.

A regra vale para modelo distribuído sozinho, embutido em produto, oferecido como serviço ou sob licença aberta (art. 30, § 1º). Quem oferece modelo por API tem de cooperar com quem constrói em cima dele (art. 32). Conteúdo sintético deve carregar um identificador de proveniência, conforme o estado da arte e o contexto de uso; em obra artística sem risco de desinformação, a marca pode ir nos créditos ou nos metadados (art. 19).

Essa seção entra em vigor 180 dias depois da publicação. A maior parte da lei, em 730 (art. 80).

No AI Act europeu, presume-se que um modelo de propósito geral tem risco sistêmico quando o treino passa de 10²⁵ operações de ponto flutuante. O PL 2338 define risco sistêmico pelo efeito adverso sobre direitos fundamentais (art. 4º, XXX), sem limiar técnico.

## Direito autoral: quem treina paga?

A seção de direitos de autor (arts. 62 a 66) tem quatro peças:

- quem desenvolve IA com conteúdo protegido publica um resumo do que usou (art. 62, com vigência imediata);
- a mineração de textos e dados por instituições científicas, de pesquisa e de ensino, museus, arquivos públicos e bibliotecas não ofende direito autoral, desde que sem fins comerciais e com acesso lícito (art. 63); a exceção não vale para instituição ligada a empresa que fornece IA;
- fora dessa exceção, o titular pode proibir o uso das suas obras (art. 64);
- quem usa conteúdo protegido para minerar, treinar ou desenvolver sistemas deve remunerar os titulares, em negociação coletiva ou direta, considerando o porte do agente e o efeito concorrencial do resultado sobre as obras originais (art. 65). A cobrança vale para titulares domiciliados no Brasil ou em países que garantam reciprocidade.

Na votação do Senado, artistas acompanharam a sessão no plenário. "Se há empresas ganhando bilhões com isso, essas empresas precisam arcar com as consequências", disse a cantora Marina Sena, segundo a Agência Senado. Para o senador Humberto Costa, a criatividade é o principal insumo da IA, e quem explora uma atividade econômica paga pelos seus insumos.

O argumento contrário aparece num artigo de opinião de Felipe Matos na Exame, em junho de 2026. Ele argumenta que os grandes modelos foram treinados com volumes de texto da internet em que não dá para garantir, frase a frase, a ausência de proteção autoral. Por isso, diz, as regras do PL podem inviabilizar no Brasil o uso de modelos treinados com obras protegidas, empurrar o país para versões defasadas e pesar mais sobre startups. O mesmo artigo registra que mais de 50 entidades do setor cultural resistem a qualquer recuo. Em março de 2026, o relator na Câmara disse que direito autoral, crimes com IA e data centers deveriam sair do marco e ir para leis específicas.

## Quem fiscaliza: ANPD no centro, agências nas pontas

O texto faz da ANPD a autoridade competente e a coordenadora do SIA (art. 45). Ela edita normas gerais, faz auditorias e regula sozinha as atividades sem regulador setorial (arts. 46, 47 e 49). As agências setoriais mantêm a regulação, a fiscalização e as sanções nos seus mercados (art. 48). Completam o sistema um conselho de cooperação regulatória (Cria) e um comitê de especialistas e cientistas (Cecia). Em investigação concorrencial, o Cade pode mandar o desenvolvedor dar acesso aos dados de treino, validação e teste de sistemas de alto risco (art. 52).

Criar órgão federal é atribuição privativa do Executivo. Por isso o Senado aprovou uma emenda do senador Esperidião Amin que apenas "autoriza" o Executivo a estabelecer o SIA. Em dezembro de 2025, o governo enviou o PL 6237/2025, que institui um sistema de governança de IA com um conselho formado pela ANPD e até cinco ministérios, segundo o Convergência Digital. O relator disse que o envio saiu de um diálogo com o governo para resolver esse vício de iniciativa, e o projeto passou a tramitar junto com o PL 2338. O próprio PL 2338 dá ao Executivo dois anos para prover os recursos de que a ANPD vai precisar (art. 74).

Laura Schertel, professora da UnB e do IDP, defende o arranjo: alguém com visão do ecossistema coordenando, e as agências com a última palavra em cada mercado. Lucas Costa dos Anjos, superintendente de inovação tecnológica da ANPD, disse na Febraban Tech que o risco de um sistema é contextual, que o detalhamento das ferramentas deve caber ao regulador e que uma lei traria mais segurança jurídica.

## O que ficou de fora

Algumas ausências ajudam a ler o texto:

- **Algoritmos de recomendação das redes sociais** saíram da lista de alto risco no Senado, a pedido de senadores da oposição. O relator considerou a previsão "excessivamente genérica". O art. 77 diz que regular a circulação de conteúdo online, inclusive moderação e recomendação por IA, depende de legislação específica.
- **Integridade da informação** deixou de ser critério para classificar novos sistemas de alto risco, sem acordo entre governistas e oposicionistas. Para a oposição, o artigo poderia servir ao controle da liberdade de expressão.
- **Crédito.** O texto original de 2023 listava como alto risco a avaliação da capacidade de endividamento e a classificação de crédito. O aprovado não lista. O AI Act europeu lista, com exceção para detecção de fraude. O SIA pode incluir a hipótese depois (art. 15).
- **Escopo.** A lei não se aplica a uso pessoal e não econômico, a sistemas exclusivamente de defesa nacional, à pesquisa, ao desenvolvimento e aos testes antes de o sistema chegar ao mercado (testes em condições reais, porém, devem observar a lei) e a quem só fornece armazenamento e transporte de dados (art. 1º).

## Na Câmara, a disputa é sobre o que fica escrito na lei

Em 2026, uma divergência ganhou destaque em torno do relatório da Câmara: manter ou não na lei a lista de usos de alto risco.

O relator Aguinaldo Ribeiro defende uma "lei viva". "A lei não pode ter que tramitar no Congresso toda vez que precisar reclassificar o alto risco de algum item", disse em maio ao Convergência Digital. Em março, já descrevia a prioridade como uma lei simples, focada em governança, com a ANPD atualizando as regras específicas conforme a tecnologia muda.

A Coalizão Direitos na Rede reagiu em junho à possibilidade de tirar a classificação de riscos do texto. Sem a indicação expressa dos usos de alto risco, diz a nota, a lei perde força normativa e transfere para disputas futuras o que deveria estar definido; a coalizão lembra que a lista já é exemplificativa. Laura Schertel foi na mesma direção e apontou o risco de setores conseguirem exceções se a lista deixar de existir.

Hugo Motta disse em maio que a ausência de regras faz todos perderem e que o excesso "engessa" e acaba inócuo. A deputada Adriana Ventura, vice-presidente da comissão, defendeu em outubro uma regulação principiológica e proporcional ao risco: "Precisamos ser cautelosos, para que também não tenhamos uma lei que apenas grandes empresas podem cumprir". Na Febraban Tech, o diretor jurídico da Febraban, Vicente De Chiara, pôs a escolha em forma de pergunta: "Uma regulação tem que ser mais aberta, e fomentar a inovação, ou ser mais intrusiva, resguardando mais direitos e atrasando a inovação?"

Mesmo com a lista, o texto do Senado já deixa bastante para depois. "Regulamento" e palavras da mesma família aparecem 36 vezes no autógrafo enviado à Câmara; "estado da arte", 12.

## Perguntas em aberto

Algumas perguntas que o texto deixa para o debate:

- Lista na lei ou no regulamento: quanto se ganha em velocidade de ajuste, e quanto se perde em previsibilidade para quem desenvolve e para quem é afetado?
- Com avaliação preliminar facultativa, o que leva um sistema de alto risco a se reconhecer como tal antes de um regulador reclassificá-lo?
- Sem limiar técnico, como um desenvolvedor sabe se o seu modelo tem risco sistêmico?
- Remuneração por treino: como se calcula, quem negocia e como se aplica a modelos treinados fora do país?
- Crédito fora da lista e recomendação de conteúdo remetida a outra lei: calibragem ou lacuna?
- A ANPD terá estrutura para coordenar o sistema no prazo que o próprio texto prevê?

> O que você quer ver escrito na lei, e o que aceitaria deixar para um regulador decidir depois?

## Fontes

- [PL 2338/2023 no Senado Federal](https://www25.senado.leg.br/web/atividade/materias/-/materia/157233)
- [Texto original do PL 2338/2023 (Senado, maio de 2023)](https://legis.senado.gov.br/sdleg-getter/dadosabertos/documento/93266fb1-dcee-4ba9-9318-41101088a2a3)
- [Autógrafo enviado à Câmara (texto aprovado pelo Senado)](https://www.camara.leg.br/proposicoesWeb/prop_mostrarintegra?codteor=2868197)
- [PL 2338/2023 na Câmara dos Deputados](https://www.camara.leg.br/propostas-legislativas/2487262)
- [Comissão Especial sobre Inteligência Artificial (PL 2338/23)](https://www2.camara.leg.br/atividade-legislativa/comissoes/comissoes-temporarias/especiais/57a-legislatura/comissao-especial-sobre-inteligencia-artificial-pl-2338-23)
- [PL 6237/2025 na Câmara dos Deputados](https://www.camara.leg.br/propostas-legislativas/2594000)
- [Constituição Federal, art. 65](https://www.planalto.gov.br/ccivil_03/constituicao/constituicao.htm)
- [Agência Senado: Senado aprova regulamentação da inteligência artificial; texto vai à Câmara](https://www12.senado.leg.br/noticias/materias/2024/12/10/senado-aprova-regulamentacao-da-inteligencia-artificial-texto-vai-a-camara)
- [Convergência Digital: projeto do governo foi articulado com relator e entra no PL 2338/23](https://convergenciadigital.com.br/governo/inteligencia-artificial-projeto-do-governo-foi-articulado-com-relator-e-entra-no-pl-2338-23/)
- [Veja: o acordo fechado na sala de Motta sobre regulação da inteligência artificial](https://veja.abril.com.br/politica/o-acordo-fechado-na-sala-de-motta-sobre-regulacao-da-inteligencia-artificial/)
- [Veja: regulação da IA está "90% endereçada" e deve ser votada em abril, diz relator](https://veja.abril.com.br/brasil/regulacao-da-ia-esta-90-enderecada-e-deve-ser-votada-na-camara-em-abril-diz-relator/)
- [Convergência Digital: relator quer uma "lei viva" para o Marco Legal da IA](https://convergenciadigital.com.br/governo/relator-quer-uma-lei-viva-para-o-marco-legal-da-inteligencia-artificial/)
- [TeleSíntese: Hugo Motta prevê relatório da IA na Câmara em 9 de junho](https://telesintese.com.br/hugo-motta-preve-relatorio-da-ia-na-camara-em-9-de-junho/)
- [Convergência Digital: Motta diz que votação depende de alinhamento com o Senado](https://convergenciadigital.com.br/governo/pl-da-inteligencia-artificial-hugo-motta-agora-diz-que-votacao-depende-de-alinhamento-com-o-senado/)
- [Convergência Digital: Coalizão Direitos na Rede critica retirada do rol de riscos](https://convergenciadigital.com.br/governo/marco-legal-da-inteligencia-artificial-retirar-rol-de-riscos-do-texto-e-retrocesso-e-erro-grave/)
- [Convergência Digital: Laura Schertel sobre a lista de riscos](https://convergenciadigital.com.br/governo/laura-schertel-sem-lista-de-riscos-e-melhor-nao-ter-marco-de-inteligencia-artificial/)
- [Exame: artigo de opinião de Felipe Matos sobre direitos autorais no PL](https://exame.com/negocios/opiniao-chatgpt-gemini-e-claude-podem-emburrecer-no-brasil-e-a-culpa-e-dos-politicos/)
- [Convergência Digital: Marco Legal de IA só vota depois das eleições](https://convergenciadigital.com.br/governo/marco-legal-de-inteligencia-artificial-so-vota-depois-das-eleicoes/)
- [Convergência Digital: ANPD defende aprovação rápida do Marco Legal de IA](https://convergenciadigital.com.br/governo/anpd-sai-em-defesa-da-aprovacao-rapida-do-marco-legal-de-ia/)
- [Mobile Time: painel da ABES Summit sobre soberania e regulação de IA](https://www.mobiletime.com.br/noticias/27/10/2026/consenso-sobre-soberania/)
- [AI Act da União Europeia, Anexo III](https://artificialintelligenceact.eu/annex/3/)
- [AI Act da União Europeia, artigo 51](https://artificialintelligenceact.eu/article/51/)
