# Validação — UFN Combate 0.6.0

Executada em 12/10/2026, Windows x64, Godot 4.7.2 stable, Compatibility/OpenGL e Intel Iris Xe. Base: repositório público 0.5.0, commit `6f20244e94a63065d9a2f7aebe78276948e3e458`. [Registro da 0.5.0](QA-v050.md).

## Resultados

| Verificação | Condições verificadas | Falhas finais |
|---|---:|---:|
| 17 suítes existentes, com expectativas antigas de contra-ataque atualizadas | 3.460 | 0 |
| Ultimates 0.6 | 1.825 | 0 |
| Importação das referências | 917 | 0 |
| Estabilidade determinística | 96 | 0 |
| Renderização OpenGL real | 16.665 | 0 |
| Sessão nativa isolada | 11 | 0 |
| Executável e pacote exportado | 6 | 0 |
| **Total** | **22.980** | **0** |

Contagens incluem verificações repetidas de metadados, quadros, combinações e estados. Não representam 22.980 funcionalidades ou partidas humanas independentes.

- **Combate:** 192 combinações do Vitor contra todos os 16 IDs, jogadores 1/2, duas orientações e distâncias de 95/540/1100 px. Cobertura de perseguição, mudança de lado, cantos, alvo recuando, pulando, atacando ou se levantando; bloqueio/invulnerabilidade, interrupção e reinicialização. Quinze impactos e 280 de dano por sequência confirmada, com vermelho apenas no atacante.
- **Robôs:** objetos com deslocamento e colisão, deduplicação do par no bloqueio, seis impactos com hurtbox real e 200 de dano. Transformação somente após a sequência, duração exata de 480 frames e retorno ao visual normal. Dano/alcance dos golpes voltam ao normal sem alterar os dados de base.
- **Sprites:** 18 conjuntos de arte, todos os quadros, duas orientações, transições rápidas e invulnerabilidade; uma pose principal opaca por ator, atlas dentro dos limites, pixels presentes e leitura do resultado renderizado. Robôs visíveis conferidos nos seis momentos de impacto. Diogo e Mirkos inspecionados em folhas de 35 quadros por personagem, espelhados.
- **Estabilidade:** 57.600 passos, equivalentes a 960 segundos simulados distribuídos pelo elenco. Entradas simultâneas, recursos limitados, coordenadas finitas e reinícios sem tint, captura ou projéteis pendurados. A suíte de ultimates também executa 12 sequências ao longo de 6.000 passos.
- **Modos preservados:** testes existentes de Arcade, progressão, Torres, tutorial, seleção, controles, skins, aliada, áudio e Kart. A sessão nativa exerceu pausa, retorno, revanche, troca de lutadores, oito pilotos, divisão vertical/horizontal e retorno da corrida ao combate.
- **Exportação:** o próprio `UFNCombate.exe` distribuído carregou o `.pck`, conferiu a versão, atlas/metadados da armadura, ultimate distante do Vitor, liberação de estados e transformação do Mirkos. O pacote usa o runtime oficial com assinatura Authenticode válida; o conteúdo do jogo não recebe uma assinatura separada.

## Evidências

[Lógica](validation/v060/tests.txt), [renderização](validation/v060/render.txt), [sessão isolada](validation/v060/session-isolated.txt), [exportação](validation/v060/export.txt) e [build](validation/v060/build.txt).

- [Diogo em defesa, nos dois sentidos](screens060/diogo_guard_both_sides.png).
- [Mirkos com a nova skin](screens060/mirkos_new_skin_both_sides.png), [robôs em contato](screens060/mirkos_sequence_044.png) e [revelação da armadura](screens060/mirkos_sequence_143.png).
- [Vitor vermelho como jogador 1](screens060/vitor_red_player1_049.png) e [jogador 2](screens060/vitor_red_player2_049.png).
- 21 capturas atuais em `docs/screens060/`; referências, recortes e origem em [REFERENCIAS-0.6.0.md](REFERENCIAS-0.6.0.md).

## Ocorrência durante a validação

A [primeira sessão nativa](validation/v060/session-concurrent.txt), executada junto a outras verificações, falhou apenas no limite de tempo após reiniciar o Kart horizontal. A mesma sessão foi repetida isoladamente, sem relaxar critérios: 11/11 aprovados, com 14,817 segundos de simulação em 15 segundos observados no trecho de reinício. Foram registrados 27 nós antes/depois e zero nós órfãos. O primeiro resultado foi preservado, não descartado.

Na sessão isolada de 96,16 segundos, a cadência mediana observada foi aproximadamente 28 FPS na luta e 18–20 FPS no Kart com duas câmeras, numa janela fora da tela e sem foco. Esse procedimento serve para estabilidade funcional; não prova 60 FPS nem mede uma partida em primeiro plano. A cadência baixa também foi registrada no histórico da base. Não se atribui sua causa exclusivamente às correções desta versão.

O teste offline de referências usa leitura direta de imagens e emite avisos de que essa técnica não funciona em pacotes exportados. Ela está restrita aos importadores/testes, excluídos do executável. O renderer usa os recursos importados; a verificação do `.pck` confirma sua disponibilidade.

## Reprodução

```powershell
./tools/test.ps1 -Godot 'C:/caminho/Godot_v4.7.2-stable_win64_console.exe' -NativeRender
```

Para a sessão nativa, execute **sem outros testes gráficos concorrentes**:

```text
godot --path . --position -30000,-30000 --script tests/session_test.gd
godot --path . --script tests/capture060.gd
UFNCombate.exe --main-pack UFNCombate.pck --script C:/caminho/do/projeto/tools/export_smoke060.gd
```

Os testes de sessão/exportação usam perfis próprios, preservando o progresso normal. O importador pode ser repetido e gera os mesmos hashes dos atlases e metadados.

## Limitações

- Oito nomes de quadros da armadura reutilizam poses inteiras existentes, pois a referência não traz arte específica para dano, recuo e socos baixos/aéreos. A postura visual de soco baixo continua em pé; a lógica do golpe permanece baixa. Não foram inventadas novas imagens.
- Não foram realizadas partidas humanas com dois controles físicos, ajuste competitivo de balanceamento ou sessões de várias horas.
- Não se afirma ausência universal de bugs, nem 60 FPS garantidos. As correções principais foram verificadas nos cenários descritos.
