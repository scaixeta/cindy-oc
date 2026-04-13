# KB Hermes Cindy

Esta pasta é a base canônica do comportamento da Cindy no runtime Hermes.

Arquivos:

- `SOUL.md`: identidade, tom, postura e papel operacional da Cindy
- `USER.md`: preferências estáveis do operador
- `MEMORY.md`: fatos persistentes do projeto, ambiente e regras operacionais
- `RUNTIME_EXPORT.md`: retrato do runtime vivo exportado do Hermes
- `runtime_export/`: snapshots redigidos de configuração, estado e diagnósticos do runtime

Uso esperado:

- O conteúdo daqui deve orientar a sincronização dos arquivos vivos do Hermes em `/root/.hermes`
- Alterações de comportamento da Cindy devem nascer aqui primeiro
- Segredos não pertencem a esta KB; segredos ficam somente em `.env`
- Exportações do runtime devem redigir segredos e nunca carregar `auth.json`, tokens ou bancos internos do Hermes
