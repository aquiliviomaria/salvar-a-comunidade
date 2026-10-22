# Salvar a Comunidade

**Salvar a Comunidade** e um jogo 3D de exploracao e cooperacao feito em **Godot 4**. O
jogador escolhe uma personagem e entra numa comunidade mocambicana onde fala com os
habitantes, aceita missoes, recolhe recursos, cuida da unidade sanitaria, protege a
floresta e melhora as condicoes de vida da aldeia.

O objectivo e simples: manter a comunidade viva e a crescer. Cada accao (recolher agua,
cortar madeira, entregar alimentos, construir estruturas) tem impacto real nos recursos e
no progresso da comunidade.

---

## Indice

- [Visao geral](#visao-geral)
- [Requisitos](#requisitos)
- [Como instalar o Godot](#como-instalar-o-godot)
- [Como executar o projecto](#como-executar-o-projecto)
- [Validar sem abrir a janela](#validar-sem-abrir-a-janela)
- [Controlos](#controlos)
- [Personagens](#personagens)
- [Menu inicial](#menu-inicial)
- [Ferramentas (tecla F)](#ferramentas-tecla-f)
- [Recursos e inventario](#recursos-e-inventario)
- [Mecanicas do mundo](#mecanicas-do-mundo)
- [Construcao](#construcao)
- [Loja do mercado](#loja-do-mercado)
- [Missoes](#missoes)
- [Habitantes da comunidade](#habitantes-da-comunidade)
- [Animais](#animais)
- [Progresso da comunidade](#progresso-da-comunidade)
- [Pausa e menus](#pausa-e-menus)
- [Guardar e carregar](#guardar-e-carregar)
- [Interface e escalonamento](#interface-e-escalonamento)
- [Estrutura do projecto](#estrutura-do-projecto)
- [Sistemas globais (autoloads)](#sistemas-globais-autoloads)
- [Testes automaticos](#testes-automaticos)
- [Limitacoes conhecidas](#limitacoes-conhecidas)

---

## Visao geral

- Mundo 3D construido com primitivas do Godot (sem assets externos nem pagos).
- Aldeia com casas, centro comunitario, unidade sanitaria, escola, mercado, armazem,
  horta, jardim, floresta, rio/fontes de agua, pocos, pastos, praia e estradas.
- 3 personagens jogaveis, com aparencia propria (Maica e a predefinida).
- 13 habitantes (NPCs) com profissao, casa, estado, dialogo e missao associada.
- 8 missoes comunitarias com objectivos, entregas, recompensas em MT/XP e impacto real.
- Sistema de recursos: dinheiro, agua, alimento, medicamentos, madeira e mudas.
- 5 ferramentas com funcoes reais (machado, martelo, serrote, recolha, primeiros socorros).
- Sistemas ambientais: corte de arvores com regeneracao, fontes de agua e pocos com
  recuperacao, construcao validada no espaco livre.
- Pausa real, menu de ferramentas, guardar/carregar e HUD em portugues.

---

## Requisitos

- **Godot 4.x**
  - Recomendado: Godot 4.2 ou superior.
  - Testado localmente com Godot `4.5.1`.
- Sistema operativo: Linux, Windows ou macOS.
- Nao e necessario instalar bibliotecas externas ou assets pagos.

---

## Como instalar o Godot

### Linux Fedora

```bash
sudo dnf install godot
```

### Linux Ubuntu/Debian

Se o pacote estiver disponivel:

```bash
sudo apt install godot4
```

Caso contrario, baixa a versao oficial em:

```text
https://godotengine.org/download
```

### Windows ou macOS

1. Acede a `https://godotengine.org/download`.
2. Baixa Godot 4 para o teu sistema.
3. Extrai/instala o programa.
4. Abre o Godot e importa o ficheiro `project.godot`.

---

## Como executar o projecto

Na pasta do projecto, executa:

```bash
godot --path .
```

Se no teu sistema o comando for `godot4`, usa:

```bash
godot4 --path .
```

Tambem podes abrir pelo editor:

1. Abre o Godot.
2. Clica em **Import**.
3. Selecciona o ficheiro `project.godot`.
4. Abre o projecto.
5. Clica no botao **Run Project**.

A cena inicial e o menu (`res://scenes/title_screen.tscn`). Ao clicar em **JOGAR** e
aberta a cena principal do mundo (`res://scenes/main.tscn`).

---

## Validar sem abrir a janela

Para verificar se o projecto carrega sem abrir a janela do jogo:

```bash
godot --headless --path . --quit
```

Para validar apenas a cena principal:

```bash
godot --headless --path . scenes/main.tscn --quit
```

Para correr a bateria de testes automaticos (ver [Testes automaticos](#testes-automaticos)):

```bash
godot --headless --path . res://tests/smoke_test.tscn
```

---

## Controlos

| Tecla            | Accao                                                                 |
| ---------------- | --------------------------------------------------------------------- |
| `W` `A` `S` `D`  | Mover a personagem.                                                    |
| Rato             | Rodar/controlar a camara.                                              |
| `E`              | Interagir com o objecto em frente (NPC, casa, arvore, agua, missao).   |
| `F`              | Abrir/fechar o menu de ferramentas.                                    |
| `1` a `5`        | Escolher rapidamente uma ferramenta.                                   |
| `B`              | Abrir o menu de construcao (requer o martelo).                         |
| `T`              | Plantar uma arvore (custa 1 muda e 1 agua).                            |
| `C`              | Abrir/fechar a loja do mercado.                                        |
| `Esc`            | Abrir/fechar a pausa e fechar menus abertos.                           |
| `F5`             | Guardar o jogo.                                                        |
| `F9`             | Carregar o jogo guardado.                                              |

A interaccao (`E`) prioriza o objecto apontado pela camara (raycast). Se nao houver nada
apontado, usa o objecto interactivo mais proximo dentro do raio de interaccao.

A personagem predefinida e a **Maica**. A troca de personagem faz-se no menu
**PERSONAGENS** do menu inicial.

---

## Personagens

| Id         | Nome     | Sexo   | Descricao                                                     |
| ---------- | -------- | ------ | ------------------------------------------------------------- |
| `joaquim`  | Joaquim  | Homem  | Cabelo curto, barba e roupa informal.                         |
| `maica`    | Maica    | Mulher | Cabelo longo, capulana e roupa tradicional/informal. **(predefinida)** |
| `gibrity`  | Gibrity  | Mulher | Cabelo longo, capulana colorida e roupa informal.             |

- A escolha muda o visual do jogador no mundo 3D.
- A seleccao e mantida ao iniciar uma nova partida.
- O avatar e o nome no menu actualizam-se logo apos a seleccao.
- A personagem escolhida aparece no canto superior esquerdo do HUD durante o jogo.

---

## Menu inicial

O menu inicial e compacto e responsivo (adapta-se a diferentes resolucoes) e tem os
seguintes botoes:

| Botao          | Funcao                                                                 |
| -------------- | ---------------------------------------------------------------------- |
| **JOGAR**      | Inicia uma nova partida (recursos e missoes reiniciados).              |
| **PERSONAGENS**| Seleccionar a personagem jogavel.                                      |
| **MISSOES**    | Ver o resumo das missoes comunitarias e o seu estado.                  |
| **INVENTARIO** | Ver os recursos actuais e a lista de ferramentas.                      |
| **COMO JOGAR** | Ver os controlos e instrucoes basicas.                                 |
| **OPCOES**     | Informacao sobre guardar/carregar e HUD.                               |
| **SAIR**       | Fechar o jogo.                                                         |

A area de personagens mostra apenas o nome e o avatar da personagem escolhida; a lista
completa (Joaquim, Maica, Gibrity) aparece ao clicar em **PERSONAGENS**.

> Nota: **JOGAR** inicia sempre uma partida nova. Para retomar um jogo guardado usa
> `F9` durante a partida.

---

## Ferramentas (tecla F)

O menu de ferramentas abre e fecha com `F`. Tambem podes escolher directamente pelo
teclado com `1` a `5`. Cada ferramenta tem uma funcao real no mundo.

| Tecla | Ferramenta           | Tipo        | Funcao                                                        |
| ----- | -------------------- | ----------- | ------------------------------------------------------------- |
| `1`   | Machado              | corte       | Cortar arvores e recolher madeira.                            |
| `2`   | Martelo              | construcao  | Construir e reparar estruturas comunitarias.                  |
| `3`   | Serrote              | carpintaria | Aproveitar troncos ja cortados (+2 madeira).                  |
| `4`   | Recolha              | recolha     | Recolher agua, alimento e materiais (ferramenta predefinida). |
| `5`   | Primeiros socorros   | saude       | Ajudar em emergencias e na unidade sanitaria.                 |

- O menu de ferramentas fecha ao abrir a loja, ao pausar ou ao premir `F`/`Esc`.
- O menu de ferramentas nao dispara enquanto escreves texto nem com a pausa aberta.

---

## Recursos e inventario

| Recurso        | Inicial | Como obter                                                        |
| -------------- | ------- | ----------------------------------------------------------------- |
| Dinheiro (MT)  | `500`   | Recompensas de missoes e tarefas comunitarias.                    |
| Agua           | `5`     | Fontes (+5), pocos (+3), loja, recompensas.                       |
| Alimento       | `3`     | Loja e recompensas de missoes.                                    |
| Medicamentos   | `2`     | Loja e recompensas de missoes.                                    |
| Madeira        | `8`     | Cortar arvore (+3), serrar tronco (+2), loja, recompensas.        |
| Mudas          | `6`     | Loja e recompensas de missoes.                                    |

O HUD mostra no canto superior esquerdo: personagem, nivel e XP, alem de MT, agua,
alimento, medicamentos e madeira. O inventario completo pode ser visto no menu inicial.

---

## Mecanicas do mundo

### Arvores

- **Cortar**: com o **Machado** seleccionado (`1`), prime `E` junto de uma arvore. Ganhas
  `+3 madeira`. A arvore cai (animacao e som) e fica como tronco.
- Cada arvore so da madeira de corte **uma vez** (nao ha madeira infinita).
- **Serrar**: com o **Serrote** seleccionado (`3`), prime `E` no tronco de uma arvore ja
  cortada. Ganhas `+2 madeira` (uma unica vez por tronco).
- **Proteger / Inspeccionar**: sem machado, `E` inspecciona ou protege a arvore. Arvores
  protegidas nao podem ser cortadas.
- **Regeneracao**: as arvores voltam ao normal ao fim de ~120 segundos (a copa reaparece
  e a arvore pode ser cortada novamente), para a floresta nao desaparecer para sempre.
- **Plantar**: com `T`, plantares uma arvore se tiveres 1 muda e 1 agua disponiveis.

### Agua

- **Fontes de agua** (rio/lago): `E` da `+5 agua`. Cada fonte tem 8 usos e recupera
  `+2` usos a cada ~60 segundos. Quando esgota, fica temporariamente seca (nao desaparece).
- **Pocos**: estruturas permanentes. `E` da `+3 agua`. Cada poco tem 5 usos e recupera
  `+2` usos a cada ~45 segundos. Quando esgota, fica "em recuperacao" (nao desaparece).
- As instrucoes junto de cada objecto so aparecem quando estiveres perto e a accao for
  possivel.

### Interaccoes contextuais

- A instrucao de interaccao aparece apenas quando ha um objecto relevante ao alcance.
- Mostra-se uma instrucao por vez, dando prioridade ao objecto mais adequado (por
  exemplo, "Cortar arvore" so aparece com o machado seleccionado).
- A instrucao desaparece assim que te afastas ou a accao deixa de estar disponivel.

---

## Construcao

Para construir:

1. Selecciona o **Martelo** (`2`) e prime `B`.
2. Escolhe a estrutura no menu **Construir**.
3. A estrutura e colocada perto do jogador **se o espaco for valido**.

Regras:

- Os recursos so sao descontados **quando a construcao e concluida**.
- Nao e possivel construir fora dos limites nem sobre objectos existentes (casas,
  construcoes, etc.).
- A construcao de estruturas progride a missao "Resolver desafios da comunidade".

### Estruturas disponiveis

| Estrutura       | Custo (madeira / agua / alimento / MT) | Efeito                                  |
| --------------- | -------------------------------------- | --------------------------------------- |
| Casa            | 4 madeira + 1 agua + 40 MT             | Aloja uma familia e melhora o bem-estar.|
| Capoeira        | 3 madeira + 1 alimento + 30 MT         | Aloja galinhas e apoia a alimentacao.   |
| Curral          | 5 madeira + 1 agua + 45 MT             | Organiza bois e cabritos.               |
| Armazem         | 6 madeira + 70 MT                      | Guarda recursos da comunidade.          |
| Cerca           | 2 madeira + 15 MT                      | Protege areas e caminhos.               |
| Ponto de agua   | 2 madeira + 2 agua + 55 MT             | Melhora o acesso a agua segura.         |

Existe tambem a construcao rapida de **casa do jogador** (3 madeira + 1 agua), que
progride as missoes de construcao ao ser colocada.

---

## Loja do mercado

Abre/fecha com `C`. Compra recursos com o dinheiro (MT) disponivel.

| Item                        | Efeito            | Preco   |
| --------------------------- | ----------------- | ------- |
| Agua                        | +5 agua           | 50 MT   |
| Alimento                    | +3 alimento       | 40 MT   |
| Medicamento                 | +2 medicamentos   | 80 MT   |
| Madeira                     | +4 madeira        | 60 MT   |
| Muda de arvore              | +3 mudas          | 45 MT   |

---

## Missoes

As missoes sao aceites falando com os habitantes (`E`). Só podes ter **uma missao
activa** de cada vez. Os estados em portugues sao: **Disponivel**, **Activa**,
**Concluida** e **Falhada**.

Os recursos das entregas so sao gastos no momento da entrega, e a missao so fica
**concluida** quando **todos** os objectivos (incluindo a entrega) estiverem cumpridos.

| Missao                                       | Habitante            | Objectivos                                          | Entrega            | Recompensa              |
| -------------------------------------------- | -------------------- | --------------------------------------------------- | ------------------ | ----------------------- |
| Encontrar agua segura                        | Maria                | Recolher 5 agua                                     | 5 agua a Maria     | 90 MT, 60 XP, 2 agua    |
| Proteger area ambiental                      | Mateus (e Lina)      | Inspeccionar 1 arvore; proteger 1 arvore            | —                  | 80 MT, 55 XP, 2 mudas   |
| Transportar recursos para a unidade sanitaria| Antonio              | Ter 2 medicamentos                                  | 2 medicamentos     | 130 MT, 80 XP           |
| Resolver situacao de emergencia              | Nando                | Usar o kit de primeiros socorros (`5`)              | —                  | 110 MT, 75 XP           |
| Encontrar caminhos seguros                   | Bento (e Fatima/Jonas/Celeste) | Confirmar um caminho seguro na area "Marcar caminho seguro" | —      | 75 MT, 55 XP            |
| Distribuir recursos pelas familias           | Rosa                 | Ter 3 alimentos                                     | 3 alimentos        | 100 MT, 65 XP, 1 medic. |
| Resolver desafios da comunidade              | Sofia                | Cortar 1 arvore com machado; construir 1 estrutura  | —                  | 120 MT, 90 XP, 2 alimento|
| Levar agua aos animais                       | Custodio             | Recolher 4 agua                                     | 4 agua a Custodio  | 85 MT, 55 XP, 2 alimento|

Cada missao tambem melhora o **progresso da comunidade** (agua, alimentacao, saude,
ambiente e bem-estar). Algumas missoes sao partilhadas por varios habitantes (por
exemplo, Lina tambem fala da proteccao da floresta), mas continuam a ser a mesma missao.

### Tarefas comunitarias (areas no mapa)

Para alem das missoes, existem areas de **tarefa comunitaria** espalhadas pela aldeia
(marcadas com um icone). Interagir com elas da dinheiro e XP e melhora o bem-estar:
Socorrer familia, Reparar poco, Organizar horta, Plantar jardim, Limpar estrada,
Apoiar escola, Posto de saude e Cuidar da praia.

---

## Habitantes da comunidade

| Nome      | Profissao            | Missao associada           |
| --------- | -------------------- | -------------------------- |
| Maria     | Agricultora          | Encontrar agua segura      |
| Antonio   | Enfermeiro           | Recursos para a unidade sanitaria |
| Mateus    | Carpinteiro          | Proteger area ambiental    |
| Nando     | Estudante            | Resolver emergencia        |
| Sofia     | Comerciante          | Desafios da comunidade     |
| Bento     | Lider comunitario    | Encontrar caminhos seguros |
| Lina      | Pescadora            | Proteger area ambiental    |
| Fatima    | Avo da comunidade    | Encontrar caminhos seguros |
| Jonas     | Estudante            | Encontrar caminhos seguros |
| Bernardo  | Agricultor reformado | Encontrar agua segura      |
| Celeste   | Professora           | Encontrar caminhos seguros |
| Custodio  | Pastor               | Levar agua aos animais     |
| Rosa      | Responsavel do armazem | Distribuir recursos pelas familias |

---

## Animais

Animais simples que se movem pelo mundo e podem ser observados:

| Animal  | Zona aproximada     |
| ------- | ------------------- |
| Galinha | Junto as casas      |
| Cao     | Proximo das casas   |
| Boi     | Pastos              |
| Cabrito | Pastos              |

---

## Progresso da comunidade

O progresso e medido em cinco indicadores, comecando em:

| Indicador      | Valor inicial |
| -------------- | ------------- |
| Bem-estar      | 72            |
| Agua           | 60            |
| Alimentacao    | 80            |
| Saude          | 65            |
| Ambiente       | 90            |

Cada missao concluida e cada tarefa comunitaria melhoram indicadores especificos. A media
destes indicadores forma o **estado geral da comunidade**.

---

## Pausa e menus

- `Esc` abre e fecha a pausa a qualquer momento durante o jogo.
- A pausa congela a `SceneTree` (`SceneTree.paused`), mas o HUD e os botoes continuam a
  receber eventos (modo de processamento sempre activo).
- Botoes da pausa:
  - **Continuar**: fecha a pausa e retoma o jogo.
  - **Reiniciar**: recomeca a partida actual.
  - **Opcoes**: mostra a dica de guardar/carregar.
  - **Menu Principal**: volta ao menu inicial (a pausa e limpa ao sair).
  - **Sair**: fecha o jogo.
- Fechar a pausa ou qualquer menu nunca deixa overlays presos nem o jogo bloqueado.
- Ao abrir um menu, o rato fica visivel; ao voltar ao jogo, volta a capturar a camara.

---

## Guardar e carregar

- `F5` guarda o jogo.
- `F9` carrega o jogo guardado.
- Ficheiro de guarda: `user://salvar_a_comunidade.save` (versao 2).
- O que e guardado: personagem escolhida, recursos, missoes, ferramentas e construcoes.
- Saves de versoes anteriores incompativeis sao ignorados.
- **JOGAR** no menu inicial comeca sempre uma partida nova; usa `F9` para retomar.

---

## Interface e escalonamento

- Resolucao base: `1280x720`.
- `window/stretch/mode = canvas_items` com `aspect = expand`, o que mantem a interface
  legivel em diferentes resolucoes.
- A janela e redimensionavel.
- O HUD e minimalista: informacao solta no ecra (personagem/nivel/recursos no canto
  superior esquerdo, missao no canto superior direito, instrucao de interaccao em baixo,
  barra de ferramentas e mensagens).
- Existem tambem botoes tacteis na base do ecra (Ferramentas, Construir) para ecras sem
  teclado.

---

## Estrutura do projecto

```text
project.godot            Configuracao (autoloads, input map, resolucao)
README.md                Este ficheiro

scenes/
  title_screen.tscn      Menu inicial
  main.tscn              Cena principal do mundo
  player.tscn            Jogador 3D
  npc.tscn               Habitantes
  house.tscn             Casas e unidade sanitaria
  tree.tscn              Arvores
  water_source.tscn      Fontes de agua
  well.tscn              Pocos
  mission_area.tscn      Areas de missao / tarefa comunitaria

scripts/
  world.gd               Construcao procedural da comunidade, HUD, pausa, menus
  player.gd              Movimento, camara, interaccoes e instrucoes contextuais
  title_screen.gd        Logica do menu inicial
  player_manager.gd      Personagens jogaveis
  resource_manager.gd    Dinheiro e recursos
  mission_manager.gd     Missoes, progresso e estado da comunidade
  npc_manager.gd         Dados dos habitantes
  npc.gd                 Comportamento dos habitantes
  animal_manager.gd      Criacao dos animais
  animal.gd              Movimento simples dos animais
  tree.gd                Corte, serrote, proteccao e regeneracao
  water_source.gd        Fonte de agua com usos e recuperacao
  well.gd                Poco com usos e recuperacao
  house.gd               Casas interactivas
  market.gd              Mercado interactivo
  mission_area.gd        Areas de missao / tarefa comunitaria
  construction_manager.gd Estruturas construiveis e validacao de custos
  tool_manager.gd        Ferramentas e seleccao
  icon_manager.gd        Icones da interface
  sound_manager.gd       Efeitos sonoros
  save_manager.gd        Guardar/carregar estado
  pause_input.gd         Atalho de pausa sempre activo (Esc)
  interaction.gd         Utilitarios de interaccao
  ui/                    Componentes de interface

tests/
  smoke_test.tscn/gd     Testes automaticos (nao fazem parte do jogo)

PROMPT_DESENVOLVIMENTO.md Guia/prompt de desenvolvimento
```

---

## Sistemas globais (autoloads)

Definidos em `project.godot`:

| Autoload           | Responsabilidade                                |
| ------------------ | ----------------------------------------------- |
| `PlayerManager`    | Personagens jogaveis e personagem seleccionada. |
| `SaveManager`      | Guardar/carregar o estado do jogo.              |
| `ResourceManager`  | Dinheiro, agua, alimento, medicamentos, madeira, mudas. |
| `MissionManager`   | Missoes, objectivos, recompensas e estado da comunidade. |
| `NPCManager`       | Dados e tipos dos habitantes.                   |
| `AnimalManager`    | Criacao dos animais.                            |
| `IconManager`      | Icones da interface.                            |
| `ToolManager`      | Ferramentas e ferramenta seleccionada.          |
| `ConstructionManager` | Estruturas, custos e construcao.             |
| `SoundManager`     | Efeitos sonoros.                                |

---

## Testes automaticos

O projecto inclui um teste de fumo que instancia a cena principal e valida as
funcionalidades principais em modo headless:

```bash
godot --headless --path . res://tests/smoke_test.tscn
```

Cobre, entre outros:

- personagem predefinida (Maica);
- pausa (abrir, `Continuar`, `Esc`) e HUD activo durante a pausa;
- menu de ferramentas (`F`);
- corte de arvore, madeira, regeneracao e ausencia de madeira infinita;
- recolha de agua (fonte e poco);
- validacao de posicao de construcao;
- progresso e conclusao de missoes, incluindo entregas;
- area da missao "caminho seguro" (so conclui com a missao activa);
- textos de estado das missoes em portugues;
- o menu inicial limpar o estado de pausa.

Resultado esperado: `RESULTADO: OK` e codigo de saida `0`.

---
