# Prompt de desenvolvimento para continuar o jogo

Usa este prompt antes de pedir novas melhorias ao Codex ou a outro assistente:

```text
Estou a desenvolver um jogo 3D em Godot 4 chamado "Salvar a Comunidade".
O jogo deve deixar de parecer prototipo infantil e evoluir para um MVP academico jogavel.

Estado atual:
- Tela inicial funcional.
- Jogador 3D em terceira pessoa.
- Personagens montados por partes: cabeca, tronco, bracos, pernas e sapatos.
- Aldeia com casas detalhadas, janelas, portas, telhado, estrada, floresta, agua e hospital.
- Sistema de interacao com E.
- Jogador pode construir casas com B.
- Jogador pode plantar arvores com T.
- Jogador pode recolher agua interagindo com fonte.
- HUD mostra saude da comunidade, recursos e missao.

Objetivo da proxima iteracao:
1. Melhorar visualmente a aldeia sem depender de assets pagos.
2. Criar missoes encadeadas:
   - falar com NPC;
   - recolher agua;
   - construir casa;
   - plantar arvores;
   - entregar medicamentos ao hospital.
3. Adicionar feedback visual claro quando uma acao e possivel.
4. Adicionar sons simples para interacao, construcao, agua e sucesso.
5. Manter os scripts organizados em cenas pequenas, sem criar um unico script gigante.

Regras:
- Usar Godot 4.
- Preferir cenas reutilizaveis.
- Nao quebrar os controles existentes.
- Validar com Godot headless antes de executar.
- Explicar quais arquivos foram alterados.
```
