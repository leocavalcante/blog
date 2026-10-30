---
title: "What Brazil's AI bill (PL 2338) requires, bans, and still leaves open"
description: "The text the Senate approved in December 2024 classifies AI systems by use, bans some, requires documentation and impact assessments for high-risk ones, and puts the ANPD in charge of coordinating oversight. In the Chamber of Deputies, the high-risk list, copyright, and the size of the law are still in dispute."
date: "2026-10-30T08:30:00-03:00"
updated: ""
draft: false
tags:
    - ai
    - llm
    - governance
    - regulation
    - software-engineering
url: /en/marco-legal-da-ia-pl-2338/
cover: cover.jpg
cover_alt: "The Brazilian flag waving beside the twin towers of the National Congress in Brasília, with a blue sky and clouds behind."
cover_credit_name: "Marcos Oliveira/Agência Senado (CC BY 2.0, cropped)"
cover_credit_url: "https://commons.wikimedia.org/wiki/File:Abertura_dos_trabalhos_legislativos_2021_(50905847381).jpg"
---

A hypothetical example. Two teams call the same model through the same API. One uses the response to summarize support tickets; the other, to rank résumés for a job opening. Under the list in the text the Senate approved, only the second is a high-risk system (art. 14, III), with an impact assessment, documented tests, and a right to human review for the people being evaluated.

The code can be almost identical. The obligation changes with the use.

That is the design of PL 2338/2023, Brazil's proposed AI legal framework (Marco Legal da Inteligência Artificial). The text classifies systems by the context in which they are used, bans some uses, requires governance for high-risk ones, creates specific rules for general-purpose and generative models, and puts the ANPD, Brazil's data protection authority, in charge of coordinating regulators. The public disagreements concentrate on two questions: who decides what is high risk, the law or the regulator, and what model training owes to the people who produced the works used in it.

This summary is based on the text the Senate sent to the Chamber of Deputies and on coverage of the bill's progress up to October 30, 2026. Where there is a dispute, each side appears with its source.

## The text is not law yet

Senator Rodrigo Pacheco introduced the bill in May 2023, based on a draft prepared by a commission of jurists. On December 10, 2024, the Senate approved, in a symbolic vote without a roll call, the substitute text from the rapporteur, Senator Eduardo Gomes, which absorbed seven other bills, including PL 21/2020, already passed by the Chamber. Four senators recorded votes against it. One of them, Eduardo Girão, criticized the rush of the vote and said he feared censorship and obstacles to the technology's development, according to Agência Senado.

The Chamber received the text in March 2025 and set up a special committee in May, chaired by Deputy Luisa Canziani, with Deputy Aguinaldo Ribeiro as rapporteur. After the public hearings and regional seminars of 2025, the vote was announced for before Carnival 2026, then for April or May, then for June. In August, the rapporteur said it would come after the elections. As of October 30, 2026, the Chamber's open data shows the bill awaiting the rapporteur's report in the special committee.

If the deputies change the text, it goes back to the Senate (art. 65 of the Constitution). That is why the rapporteur and the Speaker of the Chamber, Hugo Motta, started talking about closing the text with the senators before voting.

## Risk depends on use, and the list can grow

The text splits systems into tiers.

**Excessive risk is banned** (art. 13). This covers systems built to induce behavior that harms health or safety, exploit vulnerabilities, predict crimes from personality traits or past behavior, and produce child sexual abuse material. Also banned: autonomous weapons, scoring of citizens by the government for access to goods, services, and policies, when illegitimate or disproportionate, and remote real-time biometric identification in public spaces. That last one has exceptions: criminal investigations with prior judicial authorization, searches for victims and missing persons, crimes caught in the act that carry sentences above two years, recapturing fugitives, and serving warrants.

**High risk is allowed, with obligations** (art. 14). The list has 12 purposes: safety of critical infrastructure, selection and evaluation of students, recruitment and decisions about workers, eligibility for essential services and benefits, prioritization of emergency calls, support for judicial decisions, autonomous vehicles, medical diagnosis, criminal analytics over large datasets, evaluation of evidence in investigations, emotion recognition, and border control. A system used as an intermediary technology that does not influence the decision, or that performs a narrow procedural task, is not high risk.

**All other systems follow the general rules.** The rights to information about interacting with AI, to privacy, and to non-discrimination apply to any system, regardless of risk (art. 5).

The preliminary assessment, in which the agent itself classifies the risk of its system, is optional and counts as good practice (art. 12). It is mandatory only for general-purpose and generative models (art. 29). The list is not closed either: the National AI Regulation and Governance System (SIA) can add new cases based on criteria such as the effect on vulnerable groups and the reversibility of harm, with public participation and regulatory impact analysis (arts. 15 and 16). The Senate rapporteur described the list as "open and illustrative" ("aberto-exemplificativa").

## For builders, high risk becomes an engineering checklist

Article 18 is the most concrete part for people who write software. Whoever deploys a high-risk system documents its life cycle, monitors outputs to measure accuracy, robustness, and discrimination, documents reliability and safety tests, records the degree of human oversight, and adopts measures against bias. Whoever develops it keeps a record of governance measures, keeps operation logs, runs safety tests, and provides enough information to interpret the results.

Three points affect the daily work of anyone who puts a model into production:

- Whoever makes a substantial modification to a system, or changes its purpose, is treated as a developer (art. 18, § 5). The text does not say what substantial means. Does fine-tuning count?
- The algorithmic impact assessment is mandatory for high risk: it comes before launch, follows the life cycle, and its conclusions are public, subject to trade secrets (arts. 25 to 28). When the LGPD, Brazil's data protection law, requires a data protection impact report, the two can be done together.
- A serious incident must be reported to the sector authority, within the deadline that authority sets (art. 42).

For a person affected by a high-risk system, the text guarantees the right to an explanation, to contest, and to request human review (art. 6). Human oversight can be waived when it is demonstrably impossible or requires disproportionate effort, as long as there is an effective alternative measure (art. 8).

Sanctions range from a warning to suspension of the system, with a fine of up to 2% of gross revenue in Brazil, capped at R$ 50 million per violation (art. 50). For civil liability, the Consumer Defense Code and the Civil Code still apply, and the judge reverses the burden of proof when the victim is the weaker party or when the way the system works makes proof excessively burdensome for them (arts. 35 to 37).

## General-purpose models come in through another door

General-purpose and generative models have their own section (arts. 29 to 33). The developer always performs the preliminary assessment. If the model has systemic risk, before making it available for commercial purposes the developer must describe it, document tests and remaining risks, use only data processed in accordance with the law, publish a summary of the training data, pursue energy efficiency, and deliver technical documentation to integrators.

The rule applies to a model distributed on its own, embedded in a product, offered as a service, or under an open license (art. 30, § 1). Whoever offers a model through an API must cooperate with whoever builds on top of it (art. 32). Synthetic content must carry a provenance identifier, according to the state of the art and the context of use; in artistic works with no risk of disinformation, the mark can go in the credits or the metadata (art. 19).

This section takes effect 180 days after publication. Most of the law, after 730 (art. 80).

Under the EU AI Act, a general-purpose model is presumed to have systemic risk when its training exceeds 10²⁵ floating-point operations. PL 2338 defines systemic risk by the adverse effect on fundamental rights (art. 4, XXX), with no technical threshold.

## Copyright: does whoever trains pay?

The copyright section (arts. 62 to 66) has four pieces:

- whoever develops AI with protected content publishes a summary of what was used (art. 62, effective immediately);
- text and data mining by scientific, research, and educational institutions, museums, public archives, and libraries does not infringe copyright, as long as it is non-commercial and access is lawful (art. 63); the exception does not apply to institutions tied to a company that provides AI;
- outside that exception, rights holders can prohibit the use of their works (art. 64);
- whoever uses protected content to mine, train, or develop systems must pay the rights holders, through collective or direct negotiation, taking into account the size of the agent and the competitive effect of the output on the original works (art. 65). Payment is owed to rights holders domiciled in Brazil or in countries that guarantee reciprocity.

During the Senate vote, artists followed the session on the floor. "If there are companies making billions from this, those companies need to bear the consequences," said singer Marina Sena, according to Agência Senado. For Senator Humberto Costa, creativity is the main input of AI, and whoever runs an economic activity pays for its inputs.

The opposing argument appears in an opinion piece by Felipe Matos in Exame, in June 2026. He argues that large models were trained on volumes of internet text in which there is no way to guarantee, sentence by sentence, the absence of copyright protection. Because of that, he says, the bill's rules could make it unfeasible to use models trained on protected works in Brazil, push the country toward outdated versions, and weigh more heavily on startups. The same piece notes that more than 50 cultural sector organizations resist any rollback. In March 2026, the Chamber rapporteur said copyright, AI crimes, and data centers should leave the framework and go into specific laws.

## Who enforces it: the ANPD at the center, agencies at the edges

The text makes the ANPD the competent authority and the coordinator of the SIA (art. 45). It issues general rules, conducts audits, and regulates on its own the activities that have no sector regulator (arts. 46, 47, and 49). Sector agencies keep regulation, enforcement, and sanctions in their markets (art. 48). A regulatory cooperation council (Cria) and a committee of experts and scientists (Cecia) complete the system. In competition investigations, Cade, the antitrust authority, can order the developer to grant access to the training, validation, and test data of high-risk systems (art. 52).

Creating a federal body is the exclusive prerogative of the Executive. That is why the Senate approved an amendment by Senator Esperidião Amin that only "authorizes" the Executive to establish the SIA. In December 2025, the government sent PL 6237/2025, which creates an AI governance system with a council formed by the ANPD and up to five ministries, according to Convergência Digital. The rapporteur said the bill came out of a dialogue with the government to fix this initiative defect ("vício de iniciativa"), and it began moving jointly with PL 2338. PL 2338 itself gives the Executive two years to provide the resources the ANPD will need (art. 74).

Laura Schertel, a professor at UnB and IDP, defends the arrangement: someone with a view of the whole ecosystem coordinating, and the agencies having the final say in each market. Lucas Costa dos Anjos, the ANPD's superintendent of technological innovation, said at Febraban Tech that a system's risk is contextual, that detailing the tools should be up to the regulator, and that a law would bring more legal certainty.

## What was left out

Some absences help read the text:

- **Social media recommendation algorithms** were removed from the high-risk list in the Senate, at the request of opposition senators. The rapporteur considered the provision "excessively generic." Article 77 says that regulating the circulation of online content, including AI moderation and recommendation, requires specific legislation.
- **Information integrity** stopped being a criterion for classifying new high-risk systems, with no agreement between government and opposition senators. For the opposition, the article could serve to control freedom of expression.
- **Credit.** The original 2023 text listed the assessment of borrowing capacity and credit scoring as high risk. The approved text does not. The EU AI Act does, with an exception for fraud detection. The SIA can add the case later (art. 15).
- **Scope.** The law does not apply to personal, non-economic use, to systems used exclusively for national defense, to research, development, and testing before a system reaches the market (testing in real conditions, however, must comply with the law), or to providers that only store and transmit data (art. 1).

## In the Chamber, the dispute is over what gets written into the law

In 2026, one disagreement stood out around the Chamber report: whether to keep the list of high-risk uses in the law.

The rapporteur, Aguinaldo Ribeiro, argues for a "living law." "The law cannot have to go through Congress every time it needs to reclassify the high risk of some item," he told Convergência Digital in May. In March, he already described the priority as a simple law focused on governance, with the ANPD updating the specific rules as the technology changes.

The Coalizão Direitos na Rede, a digital rights coalition, reacted in June to the possibility of removing the risk classification from the text. Without an explicit list of high-risk uses, the statement says, the law loses normative force and pushes to future disputes what should already be defined; the coalition notes that the list is already illustrative. Laura Schertel took the same line and pointed to the risk of sectors obtaining exceptions if the list ceases to exist.

Hugo Motta said in May that the absence of rules makes everyone lose and that excess "straitjackets" the field and ends up ineffective. Deputy Adriana Ventura, the committee's vice chair, argued in October for principle-based regulation proportional to risk: "We need to be careful, so that we also don't end up with a law that only large companies can comply with." At Febraban Tech, the legal director of Febraban, the Brazilian banking federation, Vicente De Chiara, framed the choice as a question: "Should regulation be more open and foster innovation, or more intrusive, protecting more rights and delaying innovation?"

Even with the list, the Senate text already leaves a lot for later. "Regulamento" (regulation) and words from the same family appear 36 times in the official text sent to the Chamber; "estado da arte" (state of the art), 12.

## Open questions

Some questions the text leaves for debate:

- List in the law or in regulation: how much is gained in speed of adjustment, and how much is lost in predictability for those who develop and for those who are affected?
- With an optional preliminary assessment, what leads a high-risk system to recognize itself as such before a regulator reclassifies it?
- With no technical threshold, how does a developer know whether their model has systemic risk?
- Payment for training: how is it calculated, who negotiates, and how does it apply to models trained outside the country?
- Credit off the list and content recommendation deferred to another law: calibration or gap?
- Will the ANPD have the structure to coordinate the system within the deadline the text itself sets?

> What do you want written into the law, and what would you accept leaving for a regulator to decide later?

## Sources

- [PL 2338/2023 at the Federal Senate](https://www25.senado.leg.br/web/atividade/materias/-/materia/157233)
- [Original text of PL 2338/2023 (Senate, May 2023)](https://legis.senado.gov.br/sdleg-getter/dadosabertos/documento/93266fb1-dcee-4ba9-9318-41101088a2a3)
- [Official text sent to the Chamber (as approved by the Senate)](https://www.camara.leg.br/proposicoesWeb/prop_mostrarintegra?codteor=2868197)
- [PL 2338/2023 at the Chamber of Deputies](https://www.camara.leg.br/propostas-legislativas/2487262)
- [Special Committee on Artificial Intelligence (PL 2338/23)](https://www2.camara.leg.br/atividade-legislativa/comissoes/comissoes-temporarias/especiais/57a-legislatura/comissao-especial-sobre-inteligencia-artificial-pl-2338-23)
- [PL 6237/2025 at the Chamber of Deputies](https://www.camara.leg.br/propostas-legislativas/2594000)
- [Brazilian Federal Constitution, art. 65](https://www.planalto.gov.br/ccivil_03/constituicao/constituicao.htm)
- [Agência Senado: Senate approves AI regulation; text goes to the Chamber](https://www12.senado.leg.br/noticias/materias/2024/12/10/senado-aprova-regulamentacao-da-inteligencia-artificial-texto-vai-a-camara)
- [Convergência Digital: government bill was coordinated with the rapporteur and joins PL 2338/23](https://convergenciadigital.com.br/governo/inteligencia-artificial-projeto-do-governo-foi-articulado-com-relator-e-entra-no-pl-2338-23/)
- [Veja: the agreement reached in Motta's office on AI regulation](https://veja.abril.com.br/politica/o-acordo-fechado-na-sala-de-motta-sobre-regulacao-da-inteligencia-artificial/)
- [Veja: AI regulation is "90% addressed" and should be voted in April, says rapporteur](https://veja.abril.com.br/brasil/regulacao-da-ia-esta-90-enderecada-e-deve-ser-votada-na-camara-em-abril-diz-relator/)
- [Convergência Digital: rapporteur wants a "living law" for the AI framework](https://convergenciadigital.com.br/governo/relator-quer-uma-lei-viva-para-o-marco-legal-da-inteligencia-artificial/)
- [TeleSíntese: Hugo Motta expects the AI report in the Chamber on June 9](https://telesintese.com.br/hugo-motta-preve-relatorio-da-ia-na-camara-em-9-de-junho/)
- [Convergência Digital: Motta says the vote depends on alignment with the Senate](https://convergenciadigital.com.br/governo/pl-da-inteligencia-artificial-hugo-motta-agora-diz-que-votacao-depende-de-alinhamento-com-o-senado/)
- [Convergência Digital: Coalizão Direitos na Rede criticizes removing the risk list](https://convergenciadigital.com.br/governo/marco-legal-da-inteligencia-artificial-retirar-rol-de-riscos-do-texto-e-retrocesso-e-erro-grave/)
- [Convergência Digital: Laura Schertel on the risk list](https://convergenciadigital.com.br/governo/laura-schertel-sem-lista-de-riscos-e-melhor-nao-ter-marco-de-inteligencia-artificial/)
- [Exame: Felipe Matos opinion piece on copyright in the bill](https://exame.com/negocios/opiniao-chatgpt-gemini-e-claude-podem-emburrecer-no-brasil-e-a-culpa-e-dos-politicos/)
- [Convergência Digital: AI framework will only be voted after the elections](https://convergenciadigital.com.br/governo/marco-legal-de-inteligencia-artificial-so-vota-depois-das-eleicoes/)
- [Convergência Digital: ANPD defends quick approval of the AI framework](https://convergenciadigital.com.br/governo/anpd-sai-em-defesa-da-aprovacao-rapida-do-marco-legal-de-ia/)
- [Mobile Time: ABES Summit panel on sovereignty and AI regulation](https://www.mobiletime.com.br/noticias/27/10/2026/consenso-sobre-soberania/)
- [EU AI Act, Annex III](https://artificialintelligenceact.eu/annex/3/)
- [EU AI Act, Article 51](https://artificialintelligenceact.eu/article/51/)
