# UFN Combate 0.6.1 — Clarissa

Clarissa é a 15ª personagem jogável, com raquete de beach tennis, cabelo loiro e jaqueta rosa/branca inspirados na referência fornecida. O ID novo é 16: André (14), Kelvin (15), os personagens anteriores e as torres salvas mantêm os identificadores existentes.

## Comandos

Frente e trás são relativos ao adversário. A1 = J / Num1, A2 = K / Num2, A3 = L / Num3, defesa = U / Num4, nos perfis padrão de J1/J2.

| Comando | Técnica | Energia | Comportamento |
|---|---|---:|---|
| Trás + A1 | Bola Teleguiada | 18 | Bola com rotação, rastro, orientação limitada a 42 ticks e vida de 65 ticks |
| Frente → baixo + A2 | Raquetada Explosiva | 26 | Golpe de alcance 205, recuo e levantamento, partículas de areia |
| Trás + baixo + A1 | Chuva de Bolinhas | 24 | Três bolas com colisões independentes, posições e atrasos diferentes; dano bruto máximo 84 |
| Baixo → frente + A3 | Rede de Beach Tennis | 22 | Barreira de 120 ticks; quebra após dois projéteis ou ataque corpo a corpo |
| Frente + A1 | Voleio Duplo | 16 | Dois contatos, dano bruto máximo 78, defesa e recuperação normais |
| Defesa + A2 | Rainha do Beach Tennis | 100 | Saque real; somente contato não bloqueado inicia seis impactos com orçamento total de 280 antes da redução de combo |

Os comandos alternativos antigos permanecem disponíveis. A rede ocupa o especial C universal para preservar agarrão, Ultimate e troca de dupla. Os básicos usam as mesmas regras e atributos; a raquete faz parte das poses completas. A lista de movimentos no jogo inclui os quatro especiais universais e o voleio extra.

## Integração

Seleção reorganizada em 5×3, J1/J2, Arcade, Versus, treino, Sobrevivência, Duplas, torneio, demonstração automática e sorteios das torres. Chefes continuam nos dois andares finais. Kart mapeia explicitamente o ID 16 para o novo piloto de índice 14; corpo sentado articulado, cabelo longo loiro, roupa rosa/branca e saque teleguiado próprio.

A arte usa 16 poses completas geradas a partir da referência, normalizadas para células 384×320. As poses smash/vitória foram geradas separadamente para evitar sobreposição. Animações reutilizam poses inteiras e deformação procedural da base; não são 16 animações desenhadas quadro a quadro. Importador reprodutível em `tools/import_clarissa061.gd`. Som de contato original sintetizado por `tools/generate_beach_audio.py`.

## Validação executada

- 21 suítes headless aprovadas, incluindo combate, defesa, dados, fluxo, kart, torres, skins e regressões das versões 0.5/0.6.
- `clarissa061_test.gd`: 48 verificações, zero falhas — dois lados, três distâncias de Ultimate, erro/bloqueio do saque, duração dos projéteis, chuva limitada, voleio e resistência da rede.
- `clarissa061_flow_test.gd`: 96 verificações, zero falhas — seleção nos modos, J2, troca, kart, poder do kart e resolução das animações.
- Renderer OpenGL/llvmpipe: 16.852 verificações, zero falhas, com Clarissa incluída e os personagens antigos preservados.
- Capturas reais de seleção, arena, Ultimate e kart em `docs/screens/v061/`.
- Exportação Windows x64 concluída com Godot **4.5.1 stable**, usando templates oficiais dessa versão. O executável tem pacote embutido. Não foi executado em Windows.

Os testes antigos de contagem foram atualizados de 14 para 15 jogáveis; as regras dos chefes e testes de regressão permanecem. Logs em `docs/validation/v061/`.

## Limites

O README da base declara Godot 4.7.2; o runtime usado nesta validação foi 4.5.1. Não foram validados dois controles físicos, desempenho em hardware Windows, sessão prolongada humana nem balanceamento competitivo. As capturas e testes automatizados não substituem uma revisão humana de todas as transições; a aparência é ilustração 2D com animação procedural, não uma produção AAA quadro a quadro. A Ultimate usa captura e orçamento de dano da arquitetura existente, condicionados ao primeiro contato.

A branch deve passar por revisão antes de merge. Não foi substituído o download estável 0.6.0.
