# Salvar a Comunidade

**Salvar a Comunidade** e um jogo 3D feito em Godot 4. O jogador escolhe entre Joaquim, Maica ou Gibrity e explora uma comunidade mocambicana, ajudando habitantes, recolhendo recursos, cuidando da unidade sanitaria, protegendo o ambiente e resolvendo missoes comunitarias.

## Funcionalidades actuais

- Menu inicial com opcoes para jogar, escolher personagem, ver missoes e ver como jogar.
- Personagens jogaveis: Joaquim, Maica e Gibrity.
- Aldeia 3D com casas, unidade sanitaria, escola, mercado, floresta, rio/poco, jardim e pastos.
- NPCs com profissao, casa, estado, dialogo e missoes associadas.
- Animais simples no mundo: galinhas, caes, bois e cabritos.
- Sistema de recursos: dinheiro, agua, alimento, medicamentos, madeira e mudas.
- Sistema de missoes com recompensas em MT e XP.
- Progresso da comunidade: bem-estar, agua, alimentacao, saude e ambiente.

## Requisitos

- **Godot 4.x**
  - Recomendado: Godot 4.2 ou superior.
  - Testado localmente com Godot `4.5.1`.
- Sistema operacional: Linux, Windows ou macOS.
- Nao e necessario instalar bibliotecas externas ou assets pagos.

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

## Como rodar o projecto

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
3. Seleciona o ficheiro `project.godot`.
4. Abre o projecto.
5. Clica no botao **Run Project**.

## Validar sem abrir janela

Para verificar se o projecto carrega sem executar a janela do jogo:

```bash
godot --headless --path . --quit
```

Para validar a cena principal:

```bash
godot --headless --path . scenes/main.tscn --quit
```

## Controlos

- `W`, `A`, `S`, `D`: mover personagem.
- Rato: controlar a camara.
- `E`: interagir com NPCs, casas, fontes de agua, arvores e areas de missao.
- `F`: abrir/fechar o menu de ferramentas.
- `1` a `5`: escolher rapidamente uma ferramenta (machado, martelo, serrote, recolha, primeiros socorros).
- `B`: construir com o martelo, se houver recursos.
- `T`: plantar arvore, se houver recursos.
- `C`: abrir a loja do mercado.
- `Esc`: abrir/fechar a pausa e fechar menus.

A personagem predefinida e a **Maica**. A seleccao de outras personagens faz-se no menu **Personagens**.

## Estrutura principal

```text
scenes/
  title_screen.tscn     Menu inicial
  main.tscn             Cena principal do mundo
  player.tscn           Jogador 3D
  npc.tscn              Habitantes
  house.tscn            Casas e unidade sanitaria
  mission_area.tscn     Areas de missao
  water_source.tscn     Fontes de agua

scripts/
  player_manager.gd     Personagens jogaveis
  resource_manager.gd   Dinheiro e recursos
  mission_manager.gd    Missoes e progresso comunitario
  npc_manager.gd        Dados dos NPCs
  animal_manager.gd     Criacao dos animais
  animal.gd             Movimento simples dos animais
  world.gd              Construcao procedural da comunidade
  save_manager.gd       Base para guardar/carregar estado
```

## Observacoes

- O projecto usa modelos simples criados com primitivas 3D do Godot.
- Os emojis usados no HUD e nos labels podem aparecer de forma diferente conforme o sistema. Numa versao final, podem ser substituidos por icones SVG/PNG.
- O sistema de save ja tem uma base, mas ainda nao esta ligado a botoes de guardar/carregar no menu.
