# UFN Combate 0.6.0 — relatório de implementação

Atualização de 12/10/2026, sobre o repositório `diogolibinacio200-coder/ufn-combate-0.5.0`, commit `6f20244e94a63065d9a2f7aebe78276948e3e458`. O projeto original e seus modos foram mantidos.

## Problemas, causas e correções

| Problema | Causa encontrada | Correção |
|---|---|---|
| Braço do Diogo cortado | Os pixels já faltavam na pose `guard` do atlas original; não era apenas escala ou máscara do renderer. | Substituição daquela célula pela pose completa da folha enviada, com transparência, escala e apoio dos pés preservados. As demais células e a skin Careca foram mantidas. |
| Armadura do Mirkos | A versão 0.5 desenhava peças procedurais sobre o corpo normal. O início da sequência usava contato corporal de grande alcance. | Atlas independente extraído da referência. Dois robôs viajam com colisão real; o contato confirma seis impactos, totalizando 200 de dano antes da redução de combos. Após recolhimento e transformação, o atlas inteiro muda por 480 frames de simulação, conservando os bônus anteriores. Nenhuma peça da armadura antiga é desenhada sobre o personagem. |
| Ultimate do Vitor do Bem não atingia | O golpe continuava sendo do tipo `counter`; só uma agressão válida do rival disparava a captura. `balance.json` também sobrescrevia os parâmetros do golpe. O vermelho era aplicado à vítima. | Ativação proativa, vermelho no atacante e aproximação controlada ao alvo atualizado. Contato real inicia 15 impactos com hitboxes, reações, eventos de áudio e finalização, total de 280 de dano antes da redução de combos. Estados e comandos são liberados no término e em interrupções. |
| Piscamentos | Duas poses eram desenhadas com alfas complementares usando composição normal; a sobreposição perdia opacidade no meio da transição. A invulnerabilidade também oscilava a opacidade do corpo. | Um frame válido e opaco por personagem, mantendo movimento procedural. Invulnerabilidade é indicada por efeito externo, sem apagar o corpo. Quadro inexistente recorre a uma pose válida. |

Defesa, aparo e invulnerabilidade continuam sendo respostas válidas aos golpes. A ultimate não é dano inevitável: o contato ainda precisa ocorrer, e interrupções seguem as regras de combate. Os testes verificam especificamente aproximação longa, cantos, mudança de lado, adversário pulando ou atacando e recuperação de knockdown.

## Arquivos alterados

- Combate: `scripts/combat.gd`, `scripts/move_db.gd`, `data/balance.json`.
- Renderização: `scripts/arena_view.gd`, `scripts/fighter_motion.gd`.
- Arte: `assets/sprites/diogo/atlas.png`; novo `assets/sprites/mirkos_armor/`; referências em `assets/references/060/`.
- Importação reproduzível: `tools/import_reference060.gd`, `tools/capture_reference060.gd`.
- Testes: `tests/ultimate060_test.gd`, `tests/reference_assets060_test.gd`, `tests/render060_test.gd`, `tests/stability060_test.gd`, `tests/capture060.gd`. Expectativas antigas de contra-ataque atualizadas em `tests/ultimate050_test.gd` e `tests/ufn_combat_test.gd`.
- Versão e entrega: `project.godot`, `export_presets.cfg`, `scripts/interface.gd`, `tools/test.ps1`, `README.md`, `LEIA-ME.txt`, `GOLPES.md`, `BUILD-INFO.json`, documentação e fluxo de publicação.

## Preservação e validação

As suítes existentes de combate, defesa, dados, áudio, progressão, tutorial, torres, kart, pilotos, skins e aliada foram executadas. Os resultados, comandos reproduzíveis, capturas e limites estão em [QA.md](QA.md). As referências originais e suas reutilizações estão documentadas em [REFERENCIAS-0.6.0.md](REFERENCIAS-0.6.0.md).

## Limites conhecidos

A folha de armadura não fornece oito poses específicas de dano, recuo e socos baixos/aéreos. Esses nomes usam poses inteiras compatíveis da própria folha, sem inventar membros ou sobrepor o Mirkos normal. Em particular, os socos baixos usam a imagem de soco em pé, preservando a colisão e o comando do golpe baixo. Trata-se de uma limitação da arte disponível, documentada para uma futura ampliação da folha.

Testes automatizados e capturas não substituem partidas humanas de balanceamento, dois controles físicos ou sessões de várias horas. Não se declara ausência universal de defeitos nem qualidade AAA comprovada.
