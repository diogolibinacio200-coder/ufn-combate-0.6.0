# Importação das referências visuais — 0.6.0

As duas imagens enviadas pelo autor foram preservadas sem alteração em `assets/references/060/`. A importação é feita pelo próprio Godot, sem redesenhar personagens, criar peças de armadura ou reconstruir membros.

## Diogo

O defeito do braço já estava gravado nos pixels da pose `guard` do atlas 0.5.0. Corrigir apenas a malha de apresentação não recuperaria esses pixels. A célula foi substituída pela pose completa da referência original, na região `[500,22,136,253]`, removendo somente o fundo conectado ao exterior. As áreas claras da camiseta foram preservadas.

O resultado usa a mesma célula de 384 × 320, com os pés em y=304. A prova visual mostra as duas orientações, em fundo escuro: `screens/060_diogo_guard_source_both_sides.png`. As demais poses e a skin alternativa não foram substituídas pelo importador.

## Mirkos

`assets/sprites/mirkos_armor/` contém um atlas independente, metadados completos e retrato. Foram extraídas 27 poses corporais inteiras da referência enviada, mantendo a escala nativa dos pixels. A posição de cada pose acompanha o centro e a altura dos pés da pose correspondente no atlas normal. Todas as 35 chaves de frame e as 32 sequências de animação existentes continuam disponíveis, com os mesmos tempos.

O fundo branco externo é identificado por conectividade. Espaços brancos fechados entre braços e pernas da armadura são removidos como regiões, preservando seus pequenos brilhos. Não há recortes de membros nem mistura de partes do Mirkos normal com a armadura.

A referência não contém imagens próprias para dano, recuo, socos agachados e socos aéreos. O mapa `whole_pose_aliases` registra explicitamente oito reutilizações de poses inteiras: defesa para dano, aterrissagem para recuo e socos fornecidos para os ataques baixos/aéreos. Esses golpes conservam sua lógica e seus tempos; os socos baixos reutilizam a postura de soco em pé. Não se afirma que tenham sido criadas poses inéditas. Os três quadros da referência que já contêm grandes efeitos de aura/rajada não são usados como aparência permanente, pois esses efeitos não correspondem aos impactos da mecânica existente.

## Reprodução e verificação

Execute a partir da raiz do projeto, com Godot 4.7.2:

```text
godot --headless --path . --script tools/import_reference060.gd
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/reference_assets060_test.gd
godot --headless --path . --script tools/capture_reference060.gd
```

O teste verificou 917 condições sem falhas: correspondência dos frames e tempos, transparência, margens contra cortes, pixels de cada pose de origem, espelhamento reversível e detalhes claros da camiseta. A execução repetida do importador produziu SHA-256 idêntico para ambos os atlases alterados e para os metadados da armadura.

As imagens de inspeção dos arquivos estão em `docs/screens/`. Elas comprovam a importação dos sprites; as capturas do combate e os testes de lógica são validações adicionais da integração.

SHA-256 das referências fornecidas:

- Mirkos: `34eab1b48aea3d543d25ab3150dbfac7f18096ea90d1bfeef968c450a79ec36a`
- Diogo: `bcc0d3dd5ed604be1bf5c193be37d7c63c8f09fbabbd3363fbec8242d9fb682b`
